param(
    [Parameter(Mandatory=$true)][string]$Query,
    [string]$VaultPath,
    [switch]$Notes
)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}
$scope = if ($Notes) { "Conceptos,Patrones,Lecciones,Decisiones" } else { "Proyectos" }

$dirs = @()
foreach ($d in ($scope -split ",")) {
    $p = Join-Path $VaultPath $d
    if (Test-Path $p) { $dirs += $p }
}

$patterns = @($Query -split "\s+")

Write-Host "== Buscar en: $scope =="
foreach ($d in $dirs) {
    Get-ChildItem $d -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        $score = 0
        foreach ($p in $patterns) {
            if ($content -match $p) { $score++ }
        }
        if ($score -gt 0) {
            Write-Host ("[{0}] {1}  (score {2})" -f $_.Directory.Name, $_.BaseName, $score)
        }
    }
}
Write-Host "=== fin ==="