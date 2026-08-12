param(
    [string]$VaultPath,
    [switch]$Dry
)

$ErrorActionPreference = "Stop"

if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$script = Join-Path $PSScriptRoot "indexar-sqlite.mjs"
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) { Write-Host "[error] node no encontrado."; exit 1 }

$invocation = @($node, $script, "--vault", $VaultPath)
if ($Dry) { $invocation += "--dry" }

& $invocation