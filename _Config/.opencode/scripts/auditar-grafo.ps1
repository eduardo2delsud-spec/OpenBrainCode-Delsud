param(
    [string]$VaultPath,
    [int]$DaysUpdated = 30,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$excludedFiles = @("OpenBrainCode.md", "_Dashboard.md", "CHANGELOG.md", "_INDEX.md", "AGENTS.md", "PRIMER-INICIO.md")

function Get-MdFiles {
    param([string]$Root)
    @(Get-ChildItem $Root -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
       Where-Object {
           -not ([regex]::IsMatch($_.FullName, "[\\/](_|\.)[^\\/]*[\\/]")) -and
           $_.Name -notlike "Template*" -and
           $_.Name -cnotin $excludedFiles
       } |
       Sort-Object FullName)
}

# ---- matching maps (incluye TODOS los .md para resolver targets: hub, _INDEX, plantillas) ----
$all = @(Get-ChildItem $VaultPath -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
   Where-Object { -not ([regex]::IsMatch($_.FullName, "[\\/](_|\.)[^\\/]*[\\/]")) -and $_.Name -notlike "Template*" } |
   Sort-Object FullName)

# ---- análisis (notas reales a auditar: excluye hub, índices, plantillas, config) ----
$files = @($all | Where-Object { $_.Name -cnotin $excludedFiles })

$fullPaths = @{}   # lower rel path (sin .md baja) -> FileInfo
$names     = @{}   # lower basename -> list
foreach ($f in $all) {
    $rel = ($f.FullName.Substring($VaultPath.Length + 1) -replace '\.md$', '' -replace '\\', '/')
    $fullPaths[$rel.ToLowerInvariant()] = $f
    $base = $f.BaseName.ToLowerInvariant()
    if (-not $names.ContainsKey($base)) { $names[$base] = @() }
    $names[$base] += $f
}

function Resolve-Link {
    param([string]$Target)
    if ($Target -match '^(!?\|?)#?') { $Target = $Target -replace '^!?', '' -replace '#.*$', '' -replace '\|.*$', '' }
    $t = $Target.Trim()
    if ($t -eq '' -or $t -eq $null) { return $null }
    $tl = ($t.ToLowerInvariant()) -replace '\\', '/'
    if ($fullPaths.ContainsKey($tl)) { return $fullPaths[$tl] }
    $noExt = $tl -replace '\.md$', ''
    if ($fullPaths.ContainsKey($noExt)) { return $fullPaths[$noExt] }
    $baseName = ($tl -split '[/\\]')[-1]
    # preservar puntos dentro del nombre (ej: 'ADR-001 ... llama.cpp ...'); solo quitar .md si está
    $base = $baseName
    if ($base.EndsWith('.md')) { $base = $base.Substring(0, $base.Length - 3) }
    if ($names.ContainsKey($base)) { return @($names[$base])[0] }
    return $null
}

# ---- analysis ----
$broken  = @()
$orphans = @()
$stale   = @()
$outCount = @{}
$inCount  = @{}
foreach ($f in $all) { $inCount[$f.FullName] = 0; $outCount[$f.FullName] = 0 }
$now = Get-Date

foreach ($f in $all) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }
    $n = $f.FullName
    $out = 0
    $scan = $content -replace '`[^`]*`', ''
    $scan = [regex]::Replace($scan, '(?ms)```.*?```', '')
    foreach ($m in [regex]::Matches($scan, '\[\[([^\]]*)\]\]')) {
        $target = $m.Groups[1].Value
        $out++
        $resolved = Resolve-Link $target
        if ($null -eq $resolved) { if ($f.Name -cnotin $excludedFiles) { $broken += $f.FullName } }
        else { $inCount[$resolved.FullName]++ }
    }
    $outCount[$n] = $out
}

foreach ($f in $files) {
    $isHub = ($f.Name -eq "OpenBrainCode.md")
    $inl = $inCount[$f.FullName]
    $outl = $outCount[$f.FullName]
    if (-not $isHub -and $inl -eq 0 -and $outl -eq 0) { $orphans += $f.FullName }

    $fm = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -ne $fm -and $fm -match '(?m)^updated:[ \t]*([0-9]{4}-[0-9]{2}-[0-9]{2})') {
        if ($Matches[1] -as [datetime]) {
            $age = ((Get-Date) - ($Matches[1] -as [datetime])).Days
            if ($age -gt $DaysUpdated) { $stale += $f.FullName }
        }
    }
}

function Rel {
    param([string]$Full)
    return $Full.Substring($VaultPath.Length + 1)
}

$b = @($broken | Sort-Object -Unique)
$o = @($orphans | Sort-Object -Unique)
$s = @($stale | Sort-Object -Unique)

$issues = $b.Count + $o.Count + $s.Count

if (-not $Quiet) {
    Write-Host "== Auditoria del grafo =="
    Write-Host "Archivos .md analizados:  $($files.Count)"
    Write-Host "Enlaces rotos:            $($b.Count)"
    foreach ($x in $b) { Write-Host ("   BROKEN  " + (Rel $x)) }
    Write-Host "Huérfanos (sin in/out):   $($o.Count)"
    foreach ($x in $o) { Write-Host ("   ORPHAN  " + (Rel $x)) }
    Write-Host "Actualizados hace >$DaysUpdated días: $($s.Count)"
    foreach ($x in $s) { Write-Host ("   STALE   " + (Rel $x)) }
    Write-Host "=== fin ==="
}

exit (1,0)[$issues -eq 0]