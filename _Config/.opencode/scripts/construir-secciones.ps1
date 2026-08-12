param(
    [string]$VaultPath,
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
if (-not $VaultPath) {
    $cur = $PSScriptRoot
    while ($cur -and -not (Test-Path (Join-Path $cur "Proyectos"))) { $cur = Split-Path $cur -Parent }
    $VaultPath = $cur
}
$today = Get-Date -Format "yyyy-MM-dd"

$excludedFiles  = @("OpenBrainCode.md", "_Dashboard.md", "CHANGELOG.md", "_INDEX.md", "AGENTS.md", "PRIMER-INICIO.md")
$typeForDir     = @{
    "Conceptos"    = "concepto"
    "Patrones"     = "patron"
    "Lecciones"    = "leccion"
    "Decisiones"   = "decision"
    "Herramientas" = "herramienta"
    "Worklog"      = "worklog"
    "Meta"         = "meta"
}
$requiredByType = @{
    "proyecto"    = @("project", "arch", "dominio", "updated")
    "concepto"    = @("category", "updated")
    "patron"      = @("category", "updated")
    "leccion"     = @("category", "updated")
    "herramienta" = @("category", "updated")
    "decision"    = @("status", "updated")
    "worklog"     = @("project", "date")
    "index"       = @("updated")
    "meta"        = @("updated")
    "hub"         = @("updated")
    "recurso"     = @("updated")
    "regla"       = @("updated")
}
$sectionsByType = @{
    "proyecto"    = @("Estado actual","Que hace","Stack","Arquitectura","Conceptos que usa","Patrones que sigue","Decisiones clave","Lecciones","Historial (worklog)","Donde buscar mas")
    "concepto"    = @("Que es","Proyectos que lo usan","Patrones relacionados","Lecciones")
    "patron"      = @("Que es","Proyectos que lo usan","Conceptos relacionados","Lecciones")
    "leccion"     = @("Que es","De donde viene","Regla","Relacionado")
    "herramienta" = @("Que es","Como se usa","Config y comandos","Alternativas","Proyectos que la usan","Lecciones","Relacionado")
    "decision"    = @("Estado","Contexto","Opciones consideradas","Decision","Consecuencias","Proyectos que la aplican","Historial de status","Relacionado")
    "worklog"     = @("Sesiones","Changelog","Durable a promover","Bloqueadores")
}
$sectionAliases = @{
    "Proyectos que lo usan"  = @("Proyectos que la usan")
    "Proyectos que la usan"  = @("Proyectos que lo usan")
    "Que es"                 = @("Que hace")
    "Que hace"               = @("Que es")
}
$placeholder = @{
    "Historial (worklog)" = "- definicion del worklog: plantilla y flujo de promocion (ver AGENTS.md)"
    "Lecciones"           = "- sin lecciones registradas aun"
    "Conceptos relacionados" = "- (sin conceptos enlazados aun)"
    "Donde buscar mas"    = "- (referencias por completar)"
}

function Normalize {
    param([string]$s)
    $s = $s.ToLowerInvariant()
    $map = @{ "á"="a";"é"="e";"í"="i";"ó"="o";"ú"="u";"ü"="u";"ñ"="n" }
    foreach ($k in $map.Keys) { $s = $s.Replace($k, $map[$k]) }
    return ($s -replace "[^a-z0-9]", "")
}

function Accent {
    param([string]$s)
    $e = [char]0x00E9   # e
    $o = [char]0x00F3   # o
    $a = [char]0x00E1   # a
    if ($s -eq "Que es") { return "Qu" + $e + " es" }
    if ($s -eq "Que hace") { return "Qu" + $e + " hace" }
    if ($s -eq "Que " -or $s.StartsWith("Que ")) { return "Qu" + $e + $s.Substring(3) }
    if ($s -like "De donde*") { return "De d" + $o + "nde" + $s.Substring(8) }
    if ($s -eq "Decision") { return "Decisi" + $o + "n" }
    if ($s -eq "Donde buscar mas") { return "D" + $o + "nde buscar m" + $a + "s" }
    if ($s -eq "Como se usa") { return "C" + $o + "mo se usa" }
    return $s
}

function Get-Fields {
    param([string]$Content)
    if ($Content -match "(?sm)^(?:\xEF\xBB\xBF)?[ \t]*(?:<!--.*?-->[\s]*)?---[ \t]*[\r\n]+(.*?)^---[ \t]*(?:[\r\n]|$)") {
        $fields = @{}
        foreach ($m in [regex]::Matches($Matches[1], "(?m)^([A-Za-z_][A-Za-z0-9_]*):[ \t]*(.*)$")) {
            $fields[$m.Groups[1].Value] = $m.Groups[2].Value.Trim()
        }
        return $fields
    }
    return $null
}

function Get-Headings {
    param([string]$Content)
    $h = @()
    foreach ($line in ($Content -split "`r?`n")) {
        if ($line -match "^##\s+(.+?)\s*$") { $h += (Normalize $Matches[1]) }
    }
    return $h
}

$all = @(Get-ChildItem $VaultPath -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -notlike "Template*" -and $_.Name -cnotin $excludedFiles -and
                        -not ([regex]::IsMatch($_.FullName, "[\\/](_|\.)[^\\/]*[\\/]")) } |
         Sort-Object FullName)

$changed = 0

foreach ($file in $all) {
    $rel   = $file.FullName.Substring($VaultPath.Length + 1)
    $realBase = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $leafDir = (Split-Path $file.FullName -Parent | Split-Path -Leaf)
    $folder0 = ($rel -split "[\\/]")[0]

    $content = Get-Content $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    $fields = Get-Fields $content
    if ($null -eq $fields) { continue }
    $type = $fields["type"]
    if (-not $type) { continue }

    if ($folder0 -eq "Proyectos" -and $leafDir -eq $realBase) { $type = "proyecto" }

    $addHeadings = @()
    if ($sectionsByType.ContainsKey($type)) {
        $headings = Get-Headings $content
        foreach ($s0 in $sectionsByType[$type]) {
            $found = $false
            foreach ($v in (@($s0) + @($sectionAliases[$s0]))) {
                $sn = Normalize $v
                if ($sn.Length -lt 2) { continue }
                foreach ($h in $headings) { if ($h -like "*$sn*") { $found = $true; break } }
                if ($found) { break }
            }
            if (-not $found) { $addHeadings += $s0 }
        }
    }

    $addFields = @()
    if ($requiredByType.ContainsKey($type)) {
        foreach ($f in $requiredByType[$type]) {
            if ($f -ne "updated" -and -not $fields.ContainsKey($f)) { $addFields += $f }
        }
    }

    if ($addHeadings.Count -eq 0 -and $addFields.Count -eq 0) { continue }

    $newContent = $content

    foreach ($s0 in $addHeadings) {
        $accName = Accent $s0
        $ph = $placeholder[$s0]
        if (-not $ph) {
            $ph = if ($accName -eq "Dude buscar") { "- (referencias por completar)" } else { "- (por completar)" }
        }
        $sec = "`n## $accName`n`n$ph"
        if ($newContent -match "(?m)^## Relacionado") {
            $newContent = [regex]::Replace($newContent, "(?m)^## Relacionado", ($sec + "`n`n## Relacionado"), 1)
        } else {
            $newContent = $newContent.TrimEnd("`r","`n") + $sec + "`n"
        }
    }

    foreach ($f in $addFields) {
        $val = if ($f -eq "arch") { "simple" } elseif ($f -eq "dominio") { "indefinido" } else { "general" }
        if ($newContent -match "(?m)^updated:[^\r\n]*$") {
            $newContent = [regex]::Replace($newContent, "(?m)^(updated:[^\r\n]*)$", ("`$1`n${f}: $val"), 1)
        } elseif ($newContent -match "^---[\r\n]+") {
            $newContent = [regex]::Replace($newContent, "^---[\r\n]+", ("---`n${f}: $val`n"), 1)
        }
    }

    if ($newContent -ne $content) {
        if ($DryRun) {
            if (-not $Quiet) { Write-Host ("[DRY] " + $rel + " :: secciones:[" + ($addHeadings -join ',') + "] campos:[" + ($addFields -join ',') + "]") }
            continue
        }
        $newContent = [regex]::Replace($newContent, "(?m)^updated:[ \t]*[^\r\n]*", "updated: $today")
        $utf8Bom = New-Object System.Text.UTF8Encoding($true)
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8Bom)
        if (-not $Quiet) { Write-Host ("[OK ] " + $rel + " :: +[" + ($addHeadings -join ',') + "] +[" + ($addFields -join ',') + "]") }
        $changed++
    }
}

if (-not $Quiet) { Write-Host "=== fin: $changed notas modificadas ===" }