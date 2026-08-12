param(
    [string]$VaultPath,
    [string]$ProjectsRoot,
    [string[]]$ExtraRoots,
    [switch]$Delta,
    [switch]$DryRun,
    [switch]$GenerateNotes,
    [switch]$RunValidators,
    [switch]$List,
    [switch]$ProjDebug,
    [int]$MaxDepth = 2
)

$ErrorActionPreference = "Continue"

if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}
if (-not $ProjectsRoot) { $ProjectsRoot = $env:OPENBRAIN_PROJECTS_ROOT }
if (-not $ProjectsRoot) {
    Write-Host "ERROR: no se encuentra la carpeta de proyectos. Definila con OPENBRAIN_PROJECTS_ROOT o pasala con -ProjectsRoot."
    exit 1
}
if ($ExtraRoots.Count -eq 0 -and $env:OPENBRAIN_PROJECTS_EXTRA) {
    $ExtraRoots = @($env:OPENBRAIN_PROJECTS_EXTRA -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
$roots = @($ProjectsRoot) + @($ExtraRoots) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$scrapeScript  = Join-Path $scriptDir "scrape-proyecto.ps1"
$genScript      = Join-Path $scriptDir "generar-ficha.ps1"
$cacheDir       = Join-Path (Split-Path $scriptDir -Parent) ".cache"
if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
$stateFile = Join-Path $cacheDir "index-state.json"

$exclude = @("node_modules", ".git", "Herramientas", "Guias", "Old-Viejos", "Nueva carpeta")

function Test-ProjectMarkers {
    param([string]$Path)
    foreach ($m in @("package.json", "requirements.txt", "pyproject.toml", "Cargo.toml", "go.mod", "docker-compose.yml", "compose.yaml")) {
        if (Test-Path (Join-Path $Path $m)) { return $true }
    }
    return $false
}

function Get-ProjectNotePath {
    param([string]$Vault, [string]$Root, [string]$ProjPath)
    $projName = Split-Path $ProjPath -Leaf
    foreach ($r in $Root) {
        $relTop = $ProjPath.Substring($r.Length).TrimStart('\', '/')
        if ($relTop -and -not ($relTop -match '[\\/]')) {
            return (Join-Path $Vault ("Proyectos\{0}\{0}.md" -f $projName))
        }
    }
    $parent = Split-Path $ProjPath -Parent | Split-Path -Leaf
    return (Join-Path $Vault ("Proyectos\{0}\{1}\{1}.md" -f $parent, $projName))
}

# ---- estado de cache (delta por hash git) ----
$state = @{}
if ($Delta -and (Test-Path $stateFile)) {
    try {
        $stateObj = Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($prop in $stateObj.PSObject.Properties) {
            $state[$prop.Name] = @{
                source_head = $prop.Value.source_head
                note        = $prop.Value.note
                indexed     = $prop.Value.indexed
            }
        }
    } catch { $state = @{} }
}

# ---- descubrimiento: nivel 1 + hijos dentro de contenedores sin markers ----
$candidates = @()
foreach ($root in $roots) {
    if (-not (Test-Path $root)) { continue }
    foreach ($top in @(Get-ChildItem $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notin $exclude -and -not $_.Name.StartsWith(".") })) {
        if (Test-ProjectMarkers $top.FullName) { $candidates += $top }
        else {
            # un nivel extra: hijo con markers dentro de un contenedor/workspace
            foreach ($sub in @(Get-ChildItem $top.FullName -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -notin $exclude -and -not $_.Name.StartsWith(".") })) {
                if (Test-ProjectMarkers $sub.FullName) { $candidates += $sub }
            }
        }
    }
}
$candidates = @($candidates | Sort-Object FullName)

Write-Host "== OpenBrainCode Indexer =="
Write-Host "Project candidates: $($candidates.Count)"

if ($List) {
    foreach ($c in $candidates) {
        $hash = $null
        try { $hash = (git -C $c.FullName -c safe.directory=* rev-parse HEAD 2>$null).Trim() } catch {}
        Write-Host ("  " + $c.FullName + "  [head=" + $hash + "]")
    }
    exit 0
}

$indexed = @(); $new = 0; $skipped = 0

foreach ($proj in $candidates) {
    $p = $proj.FullName
    $name = $proj.Name
    $notePath = Get-ProjectNotePath $VaultPath ($roots) $p
    $hasNote = Test-Path $notePath

    # ---- delta por hash git ----
    $skip = $false
    if ($Delta -and $hasNote) {
        $head = $null
        try { $head = (git -C $p -c safe.directory=* rev-parse HEAD 2>$null).Trim() } catch {}
        $entry = $state[$p]
        if ($head -and $entry -and $entry["source_head"] -eq $head) { $skip = $true }
    }
    if ($skip) { $skipped++; if (-not $DryRun) { Write-Host ("  [SKIP-delta] " + $proj.Name) }; continue }

    # ---- scrape ----
    try {
        $facts = & $scrapeScript $p -VaultPath $VaultPath 2>$null
        $json = ($facts | Out-String | ConvertFrom-Json)
    } catch {
        Write-Host ("  [SKIP] " + $proj.Name + " - no project markers")
        $skipped++
        continue
    }
    if (-not $json.is_project) {
        Write-Host ("  [INFO] " + $proj.Name + " - not a software project")
        $skipped++
        continue
    }

    $indexed += $json
    if (-not $hasNote) { $new++ }
    Write-Host ("  [OK] " + $proj.Name + " - deps: " + @($json.dependencies).Count + " workspace: " + $json.workspace_kind)
    Write-Host ("  [DBG] notePath=" + $notePath + " hasNote=" + $hasNote)

    # ---- generar ficha determinista ----
    if ($GenerateNotes -or $DryRun) {
        $safeName = $proj.Name -replace '[^A-Za-z0-9._-]', '_'
        $factsTmp = Join-Path $cacheDir ("facts-" + $safeName + ".json")
        $json | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $factsTmp -Encoding UTF8
        $genArgs = @{
            ProjectPath = $p
            VaultPath   = $VaultPath
            FactsFile   = $factsTmp
            NotePath    = $notePath
        }
        if ($DryRun) { $genArgs.DryRun = $true }
        if ($ProjDebug) { Write-Host ("  [gen-" + $proj.Name + "] " + (& $genScript @genArgs 2>&1 6>&1 | Out-String) -replace "`r?`n"," | ") }
        else { & $genScript @genArgs 2>&1 | Out-Null }
        Remove-Item -LiteralPath $factsTmp -ErrorAction SilentlyContinue
    }

    # ---- persistir estado del delta ----
    if ($Delta) {
        $head = $null
        try { $head = (git -C $p -c safe.directory=* rev-parse HEAD 2>$null).Trim() } catch {}
        if ($head) {
            $state[$p] = @{ source_head = $head; note = $notePath; indexed = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
        }
    }
}

if ($Delta -and $state.Count -gt 0) {
    $state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $stateFile -Encoding UTF8
}

Write-Host ""
Write-Host "Indexed: $($indexed.Count) | New: $new | Skipped: $skipped"
Write-Host "Total: $($indexed.Count) proyectos colectados."

# ---- CI local: validar + auditar ----
if ($RunValidators) {
    Write-Host ""
    Write-Host "== Post-index: validaciones =="
    $validate = Join-Path $scriptDir "validar-vault.ps1"
    $audit    = Join-Path $scriptDir "auditar-grafo.ps1"
    & $validate -VaultPath $VaultPath -OnlyErrors -Quiet
    $codeV = $LASTEXITCODE
    & $audit -VaultPath $VaultPath -Quiet
    $codeA = $LASTEXITCODE
    Write-Host "validar-vault exit=$codeV | auditar-grafo exit=$codeA"
    if ($codeV -ne 0 -or $codeA -ne 0) { exit 1 }
}

exit 0
