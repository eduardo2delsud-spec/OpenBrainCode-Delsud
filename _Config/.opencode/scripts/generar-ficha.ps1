param(
    [string]$ProjectPath,
    [string]$VaultPath,
    [string]$FactsFile,
    [string]$NotePath,
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"

# guard de encoding: PowerShell 5.1 lee .ps1 sin BOM como ANSI y rompe los acentos.
# Si alguien edita este archivo con un tool que devuelve UTF-8 sin BOM, lo re-bomea solo.
$selfPath = $MyInvocation.MyCommand.Path
if ($selfPath) {
    $selfBytes = [System.IO.File]::ReadAllBytes($selfPath)
    if ($selfBytes.Length -ge 3 -and -not ($selfBytes[0] -eq 0xEF -and $selfBytes[1] -eq 0xBB -and $selfBytes[2] -eq 0xBF)) {
        $bomBytes = [byte[]](0xEF, 0xBB, 0xBF)
        [System.IO.File]::WriteAllBytes($selfPath, ($bomBytes + $selfBytes))
    }
}

if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}
$today = Get-Date -Format "yyyy-MM-dd"
$markerBegin = "<!-- AUTO: cuerpo factual generado por generar-ficha.ps1 (no editar) -->"
$markerEnd = "<!-- /AUTO -->"

# ---- facts: del JSON o scrapeando ----
$facts = $null
if ($FactsFile -and (Test-Path $FactsFile)) {
    $facts = Get-Content $FactsFile -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    if (-not $ProjectPath) { throw "Falta -ProjectPath o -FactsFile" }
    $scrape = Join-Path $PSScriptRoot "scrape-proyecto.ps1"
    $raw = & $scrape $ProjectPath -VaultPath $VaultPath 2>$null | Out-String
    try { $facts = $raw | ConvertFrom-Json } catch { Write-Host "[ERROR] scrape invalido para $ProjectPath"; exit 1 }
}

if (-not $facts.is_project) { exit 0 }

$projName = $facts.project
$realBase = $projName

# ---- ruta de la ficha (mismo criterio que indexar-todo: workspace vs plano) ----
# Si el indexer ya la resolvió, la usa; si no, la deriva (parent != root de proyectos => anidada)
$notePath = $NotePath
if (-not $notePath) {
    $projRootLeaf = Split-Path $facts.path -Parent | Split-Path -Leaf
    $baseNote = Join-Path $VaultPath ("Proyectos\{0}\{0}.md" -f $projName)
    if ($projRootLeaf -and $projRootLeaf -ne "Proyectos") {
        $notePath = Join-Path $VaultPath ("Proyectos\{0}\{1}\{1}.md" -f $projRootLeaf, $projName)
    } else {
        $notePath = $baseNote
    }
}
$rel = $notePath.Substring($VaultPath.Length + 1)

# ---- detección de arquitectura (determinista) ----
$arch = "simple"
if ($facts.workspace_kind -ne "none") { $arch = "monorepo" }
elseif (@($facts.docker_services).Count -gt 1) { $arch = "microservicios" }
elseif (@($facts.top_folders) -contains "frontend" -and @($facts.top_folders) -contains "backend") { $arch = "spa-api" }
elseif (@($facts.manifests).Count -gt 1) { $arch = "monorepo" }

# ---- frontmatter (preservar dominio/stack existentes si los hay) ----
$existing = if (Test-Path $notePath) { Get-Content $notePath -Raw -Encoding UTF8 } else { $null }
$oldStack = @($facts.dependencies)
$oldDominio = "indefinido"
if ($existing -and $existing -match '(?m)^dominio:[ \t]*(.+)$') { $oldDominio = $Matches[1].Trim() }
if ($existing -and $existing -match '(?m)^stack:[ \t]*\[([^\]]*)\]') {
    $parts = $Matches[1] -split "," | ForEach-Object { $_.Trim().Trim('"','''') } | Where-Object { $_ }
    if ($parts.Count -gt 0) { $oldStack = $parts }
}
$stackJson = ($oldStack | ForEach-Object { '"' + $_ + '"' }) -join ", "

# ---- secciones narrativas existentes (preservar) ----
function Get-Section {
    param([string]$Content, [string]$Title)
    if (-not $Content) { return $null }
    # Acumulador de markers AUTO: la regex debe cortar en el proximo ## O en un marker
    # suelto heredado de fichas generadas con versiones viejas, no arrastrarlo como narrativa.
    $m = [regex]::Match($Content, "(?ms)^## $([regex]::Escape($Title))[ \t]*\r?\n(.*?)(?=^## |^<!-- AUTO|\z)")
    if (-not $m.Success) { return $null }
    $body = $m.Groups[1].Value.Trim()
    # descartar si es placeholder del generador, un marker, o basura heredada
    if ($body -eq "" -or $body -match "^<!-- AUTO" -or $body -match "^-\s*\([^)]*\)\s*$") { return $null }
    return $body
}
$narrative = @{}
$preserve = @("Estado actual","Qué hace","Conceptos que usa","Patrones que sigue","Decisiones clave","Lecciones","Dónde buscar más","Historial (worklog)")
foreach ($s in $preserve) { $narrative[$s] = Get-Section $existing $s }

# ---- cuerpo factual AUTO ----
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine($markerBegin)
[void]$sb.AppendLine("## Stack")
[void]$sb.AppendLine()
[void]$sb.AppendLine("| Capa | Tecnología | Detalle |")
[void]$sb.AppendLine("|------|-----------|---------|")
if (@($facts.dependencies).Count -gt 0) {
    [void]$sb.AppendLine("| Runtime | " + (@($facts.dependencies) -join ", ") + " | dependencies |")
}
if (@($facts.dev_dependencies).Count -gt 0) {
    [void]$sb.AppendLine("| Dev | " + (@($facts.dev_dependencies) -join ", ") + " | devDependencies |")
}
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Comandos útiles")
[void]$sb.AppendLine()
[void]$sb.AppendLine('```bash')
if (@($facts.scripts).Count -gt 0) { foreach ($s in ($facts.scripts | Sort-Object)) { [void]$sb.AppendLine("$s") } }
else { [void]$sb.AppendLine("(sin scripts detectados)") }
[void]$sb.AppendLine('```')
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Arquitectura")
[void]$sb.AppendLine()
[void]$sb.AppendLine('```')
[void]$sb.AppendLine("workspace: $($facts.workspace_kind)")
[void]$sb.AppendLine("arch: $arch")
if (@($facts.manifests).Count -gt 0) {
    [void]$sb.AppendLine("manifests:")
    foreach ($m in ($facts.manifests | Sort-Object)) { [void]$sb.AppendLine("  $m") }
}
if (@($facts.containers).Count -gt 0) {
    [void]$sb.AppendLine("containers:")
    foreach ($c in ($facts.containers | Sort-Object)) { [void]$sb.AppendLine("  $c") }
}
[void]$sb.AppendLine("top_folders:")
foreach ($t in ($facts.top_folders | Sort-Object)) { [void]$sb.AppendLine("  $t") }
[void]$sb.AppendLine('```')
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Servicios y puertos")
[void]$sb.AppendLine()
if (@($facts.docker_services).Count -gt 0) {
    [void]$sb.AppendLine("| Servicio | Puerto | Descripción |")
    [void]$sb.AppendLine("|----------|--------|-------------|")
    foreach ($svc in ($facts.docker_services | Sort-Object)) { [void]$sb.AppendLine("| $svc | - | - |") }
} else {
    [void]$sb.AppendLine("- (sin docker-compose detectado)")
}
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Agentes opencode")
[void]$sb.AppendLine()
if (@($facts.agents).Count -gt 0) {
    [void]$sb.AppendLine("| Agente | Rol |")
    [void]$sb.AppendLine("|--------|-----|")
    foreach ($a in $facts.agents) { [void]$sb.AppendLine("| $($a.name) | $($a.role) |") }
} else {
    [void]$sb.AppendLine("- (sin agentes opencode)")
}
[void]$sb.AppendLine($markerEnd)
$factualBody = $sb.ToString()

# ---- armar documento completo ----
$doc = New-Object System.Text.StringBuilder
[void]$doc.AppendLine("---")
[void]$doc.AppendLine("type: proyecto")
[void]$doc.AppendLine("project: $projName")
[void]$doc.AppendLine("path: $($facts.path)")
[void]$doc.AppendLine("stack: [$stackJson]")
[void]$doc.AppendLine("arch: $arch")
[void]$doc.AppendLine("dominio: $oldDominio")
[void]$doc.AppendLine("updated: $today")
[void]$doc.AppendLine("---")
[void]$doc.AppendLine()
[void]$doc.AppendLine("# $projName")
[void]$doc.AppendLine()
[void]$doc.AppendLine("> ")
[void]$doc.AppendLine()
[void]$doc.AppendLine("## Qué hace")
[void]$doc.AppendLine()
if ($narrative["Qué hace"]) { [void]$doc.AppendLine($narrative["Qué hace"]) }
else { [void]$doc.AppendLine("- (describir en una línea; lo completa el skill)") }
[void]$doc.AppendLine()
[void]$doc.AppendLine("## Estado actual")
[void]$doc.AppendLine()
if ($narrative["Estado actual"]) { [void]$doc.AppendLine($narrative["Estado actual"]) }
else { [void]$doc.AppendLine("- (estado actual: en desarrollo / mantenido / archivo)") }
[void]$doc.AppendLine()
[void]$doc.AppendLine($factualBody)
[void]$doc.AppendLine()
foreach ($s in @("Conceptos que usa","Patrones que sigue","Decisiones clave","Lecciones","Dónde buscar más","Historial (worklog)")) {
    [void]$doc.AppendLine("## $s")
    [void]$doc.AppendLine()
    if ($narrative[$s]) { [void]$doc.AppendLine($narrative[$s]) }
    else { [void]$doc.AppendLine("- (por completar)") }
    [void]$doc.AppendLine()
}

# ---- escribir ----
$newDoc = $doc.ToString().TrimEnd("`r","`n") + "`n"

if ($existing -and $newDoc -eq $existing) {
    if (-not $Quiet) { Write-Host "[----] $rel :: sin cambios" }
    exit 0
}
if ($DryRun) {
    if (-not $Quiet) { Write-Host "[DRY ] $rel :: regeneraría ficha (arch: $arch, deps: $(@($facts.dependencies).Count))" }
    exit 0
}
$dir = Split-Path $notePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($notePath, $newDoc, $utf8Bom)
if (-not $Quiet) { Write-Host "[OK ] $rel :: ficha generada" }

# sentencia sin efecto para que exista el marcador en scope
