param([string]$VaultPath)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$all = @(Get-ChildItem $VaultPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue)
$cProy = @($all | Where-Object { $_.FullName -like (Join-Path $VaultPath "Proyectos\*\*.md") }).Count
$cCon  = @($all | Where-Object { $_.Directory.Name -eq "Conceptos" }).Count
$cPat  = @($all | Where-Object { $_.Directory.Name -eq "Patrones" }).Count
$cDec  = @($all | Where-Object { $_.Directory.Name -eq "Decisiones" }).Count
$cLec  = @($all | Where-Object { $_.Directory.Name -eq "Lecciones" }).Count

$links = 0
foreach ($f in $all) {
    $c = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -ne $c) { $links += [regex]::Matches($c, "\[\[|\]\]\(").Count }
}

Write-Host "== Metricas OpenBrainCode =="
Write-Host "Notas totales:        $($all.Count)"
Write-Host "  Proyectos:          $cProy"
Write-Host "  Conceptos:          $cCon"
Write-Host "  Patrones:           $cPat"
Write-Host "  Decisiones (ADRs):  $cDec"
Write-Host "  Lecciones:          $cLec"
Write-Host "Enlaces wiki/links:   $links"
Write-Host "=== fin ==="