param(
    [string]$VaultPath,
    [switch]$OnlyErrors,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}

$script:quiet    = [bool]$Quiet
$script:onlyErr  = [bool]$OnlyErrors
$script:errors   = 0
$script:warnings = 0
$script:ok       = 0

$excludedFolders  = @("_Inbox", "_Outbox", ".obsidian", "node_modules", ".git")
$excludedFiles    = @("OpenBrainCode.md", "_Dashboard.md", "CHANGELOG.md", "_INDEX.md", "AGENTS.md", "PRIMER-INICIO.md")
$typeForDir       = @{
    "Conceptos"    = "concepto"
    "Patrones"     = "patron"
    "Lecciones"    = "leccion"
    "Decisiones"   = "decision"
    "Herramientas" = "herramienta"
    "Worklog"      = "worklog"
    "Meta"         = "meta"
}
$requiredByType   = @{
    "proyecto"     = @("project", "arch", "dominio", "updated")
    "concepto"     = @("category", "updated")
    "patron"       = @("category", "updated")
    "leccion"      = @("category", "updated")
    "herramienta"  = @("category", "updated")
    "decision"     = @("status", "updated")
    "worklog"      = @("project", "date")
    "acierto"      = @("category", "updated")
    "error"        = @("category", "status", "updated")
    "hub"          = @("updated")
    "index"        = @("updated")
    "meta"         = @("updated")
    "recurso"      = @("updated")
    "regla"        = @("updated")
}
$sectionsByType = @{
    "proyecto"    = @("Estado actual","Qué hace","Stack","Arquitectura","Conceptos que usa","Patrones que sigue","Decisiones clave","Lecciones","Historial (worklog)","Dónde buscar más")
    "concepto"    = @("Qué es","Proyectos que lo usan","Patrones relacionados","Lecciones")
    "patron"      = @("Qué es","Proyectos que lo usan","Conceptos relacionados","Lecciones")
    "leccion"     = @("Qué es","De dónde viene","Regla","Relacionado")
    "herramienta" = @("Qué es","Cómo se usa","Config y comandos","Alternativas","Proyectos que la usan","Lecciones","Relacionado")
    "decision"    = @("Estado","Contexto","Opciones consideradas","Decisión","Consecuencias","Proyectos que la aplican","Historial de status","Relacionado")
    "worklog"     = @("Sesiones","Changelog","Durable a promover","Bloqueadores")
}
$sectionAliases = @{
    "Proyectos que lo usan"  = @("Proyectos que la usan")
    "Proyectos que la usan"  = @("Proyectos que lo usan")
    "Qué es"                 = @("Qué hace")
    "Qué hace"               = @("Qué es")
}

function Normalize {
    param([string]$s)
    $s = $s.ToLower()
    $map = @{ "á"="a";"é"="e";"í"="i";"ó"="o";"ú"="u";"ü"="u";"ñ"="n" }
    foreach ($k in $map.Keys) { $s = $s.Replace($k, $map[$k]) }
    return ($s -replace "[^a-z0-9]", "")
}

function Issue {
    param([string]$Severity, [string]$Rel, [string]$Msg)
    if ($Severity -eq "E") { $script:errors++   ; $line = "[ERROR] $Rel :: $Msg" }
    elseif ($Severity -eq "W") { $script:warnings++ ; $line = "[WARN ] $Rel :: $Msg" }
    else { $script:ok++ ; $line = "[OK   ] $Rel :: $Msg" }
    if ($script:quiet) { return }
    if ($script:onlyErr -and $Severity -ne "E") { return }
    Write-Host $line
}

function IsExempt {
    param($file)
    if ($file.Name -like "Template*") { return $true }
    if ($file.Name -in $excludedFiles) { return $true }
    $rel = if ($file.DirectoryName -eq $VaultPath) { $file.Name }
           else { $file.DirectoryName.Substring($VaultPath.Length + 1) }
    foreach ($seg in ($rel -split "[\\/]")) {
        if ($seg.StartsWith("_") -or $seg.StartsWith(".") -or $seg -eq "node_modules") { return $true }
    }
    return $false
}

function Get-Frontmatter {
    param([string]$Content)
    # tolera BOM y un bloque HTML <!-- --> inicial antes del --- ; (?m) para ancla ^ por linea
    if ($Content -match "(?sm)^[\uFEFF \t]*(?:<!--.*?-->\s*[\r\n]*)?---[ \t]*[\r\n]+(.*?)^---[ \t]*(?:[\r\n]|$)") {
        $yaml = $Matches[1]
        $fields = @{}
        foreach ($m in [regex]::Matches($yaml, "(?m)^([A-Za-z_][A-Za-z0-9_]*):[ \t]*(.*)$")) {
            $fields[$m.Groups[1].Value] = $m.Groups[2].Value.Trim()
        }
        return $fields
    }
    return $null
}

$all = @(Get-ChildItem $VaultPath -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
         Where-Object { -not (IsExempt $_) } | Sort-Object FullName)

Write-Host "== Validacion Estructura Vault =="

foreach ($file in $all) {
    $rel      = $file.FullName.Substring($VaultPath.Length + 1)
    $realBase = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $leafDir  = (Split-Path $file.FullName -Parent | Split-Path -Leaf)
    $folder0  = ($rel -split "[\\/]")[0]

    $content = Get-Content $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    $fields = Get-Frontmatter $content
    if ($null -eq $fields) {
        Issue "E" $rel "sin frontmatter YAML"
        continue
    }

    $type = $fields["type"]
    if (-not $type) { Issue "E" $rel "frontmatter sin campo obligatorio 'type'" }

    # ---- tipo segun ubicacion ----
    $isProjectHub = ($folder0 -eq "Proyectos" -and $leafDir -eq $realBase)
    $expected = $typeForDir[$folder0]
    if ($isProjectHub) { $expected = "proyecto" }
    if ($expected -and $type -and $type -ne $expected) {
        Issue "E" $rel "type '$type' no coincide con la carpeta (se esperaba '$expected')"
    }

    # ---- campos requeridos y reglas de decision ----
    if ($type -and $requiredByType.ContainsKey($type)) {
        foreach ($field in $requiredByType[$type]) {
            if (-not $fields.ContainsKey($field)) { Issue "E" $rel "falta campo requerido '$field' (tipo $type)" }
        }
        if ($type -eq "decision" -and -not ($fields.ContainsKey("accepted") -or $fields.ContainsKey("date"))) {
            Issue "E" $rel "falta 'accepted' o 'date' (tipo decision)"
        }
    } elseif ($type) {
        if (-not $script:onlyErr) { Issue "W" $rel "type '$type' no reconocido" }
    }

    # ---- updated formato ----
    if ($fields.ContainsKey("updated") -and $fields["updated"] -notmatch '^\d{4}-\d{2}-\d{2}$') {
        Issue "W" $rel "updated con formato invalido: '$($fields['updated'])' (esperado YYYY-MM-DD)"
    }

    # ---- encabezado H1 ----
    if ($content -notmatch "(?m)^#\s+\S") { Issue "W" $rel "falta encabezado H1" }

    # ---- secciones obligatorias ----
    if ($type -and $sectionsByType.ContainsKey($type)) {
        $headings = @()
        foreach ($line in ($content -split "`r?`n")) {
            if ($line -match "^##\s+(.+?)\s*$") { $headings += (Normalize $Matches[1]) }
        }
        foreach ($s in $sectionsByType[$type]) {
            $found = $false
            foreach ($v in (@($s) + @($sectionAliases[$s]))) {
                $sn = Normalize $v
                if ($sn.Length -lt 2) { continue }
                foreach ($h in $headings) {
                    if ($h -like "*$sn*") { $found = $true; break }
                }
                if ($found) { break }
            }
            if (-not $found) { Issue "E" $rel "falta seccion '## $s' (tipo $type)" }
        }
    }

    # ---- nomenclatura ----
    if ($folder0 -in @("Conceptos","Patrones","Lecciones","Herramientas")) {
        if ($realBase -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
            Issue "W" $rel "nombre no kebab-case: '$($file.Name)'"
        }
    } elseif ($folder0 -eq "Decisiones" -and $file.Name -notmatch '^ADR-\d{3} .+\.md$') {
        Issue "W" $rel "nombre ADR invalido (esperado 'ADR-XXX Título.md'): '$($file.Name)'"
    }
}

# ---- ADR duplicados ----
$adrNums = @{}
Get-ChildItem (Join-Path $VaultPath "Decisiones") -Filter "ADR-*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $n = [regex]::Match($_.BaseName, '^ADR-([0-9]+)').Groups[1].Value
    if ($n) {
        if ($adrNums.ContainsKey($n)) {
            Issue "W" ("Decisiones/" + $_.Name) "numero de ADR duplicado ($n) - ya existe '$($adrNums[$n])'"
        } else { $adrNums[$n] = $_.Name }
    }
}

if (-not $script:quiet) {
    Write-Host ""
    Write-Host "OK: $($script:ok) | WARN: $($script:warnings) | ERROR: $($script:errors)"
    Write-Host "=== fin ==="
}
if ($script:errors -gt 0) { exit 1 }
exit 0