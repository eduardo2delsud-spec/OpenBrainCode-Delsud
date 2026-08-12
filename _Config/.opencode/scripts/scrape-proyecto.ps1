param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectPath,

    [string]$VaultPath,

    [int]$MaxDepth = 3
)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

function Get-SourceContent($path) {
    if (Test-Path $path) { return (Get-Content $path -Raw -ErrorAction SilentlyContinue) }
    return $null
}

$projectName = [System.IO.Path]::GetFileName($ProjectPath.TrimEnd('\'))
$projectRoot = (Resolve-Path $ProjectPath).Path

# ---- marcadores ----
$manifestNames   = @("package.json","requirements.txt","pyproject.toml","Cargo.toml","go.mod","composer.json")
$containerNames  = @("docker-compose.yml","docker-compose.yaml","compose.yml","compose.yaml")
$workspaceNames  = @("pnpm-workspace.yaml","lerna.json","turbo.json")
$excludeDirs     = @(".git","node_modules","dist","build",".next","out","coverage","venv",".venv","__pycache__",".cache","bin","obj",".vscode",".idea",".opencode")

function Is-ExcludedDir([string]$Name) {
    if ($Name -in $excludeDirs) { return $true }
    if ($Name.StartsWith("."))  { return $true }
    return $false
}

# ---- BFS con profundidad limitada ----
$dirsByDepth   = @{ 0 = @($projectRoot) }
$manifests     = @()   # rel path (sin \ inicial)
$containers    = @()
$workspaceHits = @()

for ($depth = 0; $depth -le $MaxDepth; $depth++) {
    if (-not $dirsByDepth.ContainsKey($depth)) { break }
    $current = $dirsByDepth[$depth]
    if ($depth -lt $MaxDepth) { $dirsByDepth[$depth + 1] = @() }
    foreach ($d in $current) {
        if (-not (Test-Path $d)) { continue }
        foreach ($child in @(Get-ChildItem $d -Directory -ErrorAction SilentlyContinue)) {
            if (Is-ExcludedDir $child.Name) { continue }
            if ($depth -lt $MaxDepth) { $dirsByDepth[$depth + 1] += $child.FullName }
            $rel = $child.FullName.Substring($projectRoot.Length).TrimStart('\', '/')
            foreach ($mn in $manifestNames) {
                if (Test-Path (Join-Path $child.FullName $mn)) { $manifests += (Join-Path $rel $mn) }
            }
            foreach ($cn in $containerNames) {
                if (Test-Path (Join-Path $child.FullName $cn)) { $containers += (Join-Path $rel $cn) }
            }
            foreach ($wn in $workspaceNames) {
                if (Test-Path (Join-Path $child.FullName $wn)) { $workspaceHits += $wn }
            }
        }
    }
}

# ---- git HEAD (para delta por hash) ----
$gitHead = $null
if (Test-Path (Join-Path $projectRoot ".git")) {
    try {
        $gitHead = (git -C $projectRoot -c safe.directory=* rev-parse HEAD 2>$null).Trim()
    } catch {}
}

# ---- raiz es proyecto? ----
$rootManifest = $null
foreach ($mn in $manifestNames) {
    if (Test-Path (Join-Path $projectRoot $mn)) { $rootManifest = $mn; break }
}
$isProject = $null -ne $rootManifest -or @($containers).Count -gt 0 -or
             @($manifests).Count -gt 0 -or
             (Get-SourceContent (Join-Path $projectRoot "README.md") -and @($workspaceHits).Count -gt 0)

# ---- dependencias y scripts (todos los package.json encontrados) ----
$allDeps = @()
$allScripts = @()
$allDevDeps = @()
foreach ($mp in @($manifests | Where-Object { $_ -match '(^|\\)package\.json$' })) {
    $abs = Join-Path $projectRoot $mp
    $raw = Get-SourceContent $abs
    if (-not $raw) { continue }
    try {
        $obj = $raw | ConvertFrom-Json
        foreach ($k in @($obj.dependencies.PSObject.Properties.Name))    { if ($k -and $k -notin $allDeps)    { $allDeps += $k } }
        foreach ($k in @($obj.devDependencies.PSObject.Properties.Name)) { if ($k -and $k -notin $allDevDeps) { $allDevDeps += $k } }
        foreach ($k in @($obj.scripts.PSObject.Properties.Name))         { if ($k -and $k -notin $allScripts) { $allScripts += $k } }
    } catch {}
}

# ---- workspace kind ----
$workspaceKind = "none"
if ($workspaceHits -contains "pnpm-workspace.yaml") { $workspaceKind = "pnpm" }
elseif ($workspaceHits -contains "lerna.json")      { $workspaceKind = "lerna" }
elseif ($workspaceHits -contains "turbo.json")      { $workspaceKind = "turbo" }
else {
    $rootPkg = Join-Path $projectRoot "package.json"
    if (Test-Path $rootPkg) {
        $raw = Get-SourceContent $rootPkg
        if ($raw) {
            try { $pkg = $raw | ConvertFrom-Json; if ($pkg.workspaces) { $workspaceKind = "npm" } } catch {}
        }
    }
}

# ---- env keys desde .env.example / .env.template ----
$envKeys = @()
foreach ($envFile in @(".env.example",".env.template","env.example",".env.sample")) {
    $abs = Join-Path $projectRoot $envFile
    if (-not (Test-Path $abs)) { continue }
    foreach ($line in (Get-Content $abs -ErrorAction SilentlyContinue)) {
        $line = $line.Trim()
        if (-not $line -or $line.StartsWith("#")) { continue }
        if ($line -match "^([A-Za-z_][A-Za-z0-9_]*)=") {
            $key = $Matches[1]
            if ($key -and $key -notin $envKeys) { $envKeys += $key }
        }
    }
}

# ---- docker services/ports (regex simple, sin parse YAML) ----
$dockerServices = @()
foreach ($cf in $containers) {
    $abs = Join-Path $projectRoot $cf
    $raw = Get-SourceContent $abs
    if (-not $raw) { continue }
    $inServices = $false
    $curService = $null
    foreach ($line in ($raw -split "`r?`n")) {
        if ($line -match "^services:") { $inServices = $true; continue }
        if ($inServices -and $line -match "^\s{2}([A-Za-z0-9_-]+):\s*$" -and $line -notmatch "image|ports|environment") {
            $curService = $Matches[1]
            $dockerServices += $curService
        }
    }
}

# ---- carpetas top-level ----
$topFolders = @()
foreach ($d in @(Get-ChildItem $projectRoot -Directory -ErrorAction SilentlyContinue)) {
    if (Is-ExcludedDir $d.Name) { continue }
    $topFolders += $d.Name
}

# ---- agentes opencode ----
$agents = @()
$agentsDir = Join-Path $projectRoot ".opencode\agents"
if (Test-Path $agentsDir) {
    foreach ($a in (Get-ChildItem $agentsDir -Filter "*.md" -ErrorAction SilentlyContinue)) {
        $desc = (Get-Content $a.FullName -TotalCount 10 -ErrorAction SilentlyContinue) -join " "
        $agents += [pscustomobject]@{ name = $a.BaseName; role = $desc.Substring(0, [Math]::Min(80, $desc.Length)) }
    }
}

# ---- output plano ----
$out = [pscustomobject]@{
    project = $projectName
    path = $projectRoot
    is_project = [bool]$isProject
    root_manifest = $rootManifest
    git_head = $gitHead
    workspace_kind = $workspaceKind
    manifests = @($manifests | Sort-Object)
    containers = @($containers | Sort-Object)
    dependencies = @($allDeps | Sort-Object)
    dev_dependencies = @($allDevDeps | Sort-Object)
    scripts = @($allScripts | Sort-Object)
    env_keys = @($envKeys | Sort-Object)
    docker_services = @($dockerServices | Sort-Object -Unique)
    top_folders = @($topFolders | Sort-Object)
    agent_count = @($agents).Count
    agents = @($agents)
}

$out | ConvertTo-Json -Depth 4
