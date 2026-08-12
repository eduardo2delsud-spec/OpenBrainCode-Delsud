param([string]$VaultPath)

$ErrorActionPreference = "Stop"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$plugins = @(
    @{ repo = "platers/obsidian-linter";        id = "obsidian-linter" },
    @{ repo = "SilentVoid13/Templater";          id = "templater-obsidian" },
    @{ repo = "mdelobelle/metadatamenu";         id = "metadata-menu" },
    @{ repo = "ElsaTam/obsidian-extended-graph"; id = "extended-graph" }
)

foreach ($p in $plugins) {
    $dest = Join-Path $VaultPath ".obsidian\plugins\$($p.id)"
    if (Test-Path (Join-Path $dest "main.js")) {
        Write-Host "OK  $($p.id) ya instalado (skip)."
        continue
    }
    Write-Host "Descargando $($p.id) desde $($p.repo)..."
    $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$($p.repo)/releases/latest" -Headers @{ "User-Agent" = "opencode" }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($asset in $rel.assets) {
        if ($asset.name -in @("main.js", "manifest.json", "styles.css")) {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile (Join-Path $dest $asset.name)
            Write-Host "  $($asset.name) ($([math]::Round($asset.size / 1kb))KB)"
        }
    }
}

Write-Host "Instalacion completa. Agrega los ids a .obsidian/community-plugins.json y reinicia Obsidian."
