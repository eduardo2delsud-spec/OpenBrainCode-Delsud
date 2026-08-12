param([string]$VaultPath)

$ErrorActionPreference = "Stop"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$graphFile = Join-Path $VaultPath ".obsidian\graph.json"
if (-not (Test-Path $graphFile)) {
    Write-Host "No se encontro .obsidian/graph.json en $VaultPath"
    exit 1
}

$groupsJson = @'
  "colorGroups": [
    { "query": "path:Proyectos",      "color": "#22c55e" },
    { "query": "path:Conceptos",      "color": "#3b82f6" },
    { "query": "path:Patrones",       "color": "#a855f7" },
    { "query": "path:Lecciones",      "color": "#f97316" },
    { "query": "path:Decisiones",     "color": "#ef4444" },
    { "query": "path:_Inbox",         "color": "#9ca3af" },
    { "query": "path:.opencode",      "color": "#06b6d4" },
    { "query": "file:OpenBrainCode",  "color": "#facc15" }
  ]
'@

$raw = [System.IO.File]::ReadAllText($graphFile)

if ($raw -match "path:Proyectos") {
    Write-Host "Colores del grafo ya estaban aplicados (sin cambios)."
    exit 0
}

if ($raw -notmatch '"colorGroups"\s*:') {
    Write-Host "No se encontro 'colorGroups' en el archivo. Revisa el archivo a mano."
    exit 1
}

$raw = [regex]::Replace($raw, '"colorGroups"\s*:\s*\[[^\]]*\]', $groupsJson, "Singleline")

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($graphFile, $raw, $utf8NoBom)
Write-Host "Colores del grafo reinyectados en .obsidian/graph.json"
Write-Host "Reabri el graph view en Obsidian para verlos."
