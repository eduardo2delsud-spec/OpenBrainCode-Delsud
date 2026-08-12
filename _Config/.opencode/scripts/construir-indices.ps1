param(
    [string]$VaultPath,
    [switch]$Herramientas,
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

$areaInfo = [ordered]@{
    "Conceptos"    = @{ title = "Conceptos — Índice";    desc = "Conceptos técnicos y del dominio, tipados con su `category`. Plantilla: [[Conceptos/Template Concepto]]." }
    "Patrones"     = @{ title = "Patrones — Índice";     desc = "Patrones de diseño e integración, tipados. Plantilla: [[Patrones/Template Patrón]]." }
    "Lecciones"    = @{ title = "Lecciones — Índice";    desc = "Lecciones aprendidas y reglas derivadas de la práctica. Plantilla: [[Lecciones/Template Lección]]." }
    "Decisiones"   = @{ title = "Decisiones — Índice";   desc = "ADR — decisiones de arquitectura con contexto. Plantilla: [[Decisiones/Template ADR]]." }
    "Reglas"       = @{ title = "Reglas — Índice";       desc = "Reglas operativas del vault (arranques, convenciones, documentación)." }
    "Herramientas" = @{ title = "Herramientas — Índice"; desc = "Herramientas que usás y cómo se usan. Plantilla: [[Herramientas/Template Herramienta]]." }
}

$areas = @("Conceptos","Patrones","Lecciones","Decisiones","Reglas")
if ($Herramientas) { $areas += "Herramientas" }

$markerBegin = "<!-- AUTO: cuerpo regenerado por construir-indices.ps1 (no editar) -->"
$markerEnd   = "<!-- /AUTO -->"

function Get-Fields {
    param([string]$Content)
    if ($Content -match "(?sm)^[\uFEFF \t]*(?:<!--.*?-->\s*[\r\n]*)?---[ \t]*[\r\n]+(.*?)^---[ \t]*(?:[\r\n]|$)") {
        $fields = @{}
        foreach ($m in [regex]::Matches($Matches[1], "(?m)^([A-Za-z_][A-Za-z0-9_]*):[ \t]*(.*)$")) {
            $fields[$m.Groups[1].Value] = $m.Groups[2].Value.Trim()
        }
        return $fields
    }
    return $null
}

function Get-Members {
    param([string]$Area)
    $dir = Join-Path $VaultPath $Area
    @(Get-ChildItem $dir -Filter "*.md" -File -ErrorAction SilentlyContinue |
       Where-Object { $_.Name -notlike "Template*" -and -not $_.Name.StartsWith("_") } |
       Sort-Object Name)
}

function Get-BodyInner {
    param([string]$Area)
    $notes = Get-Members $Area
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.AppendLine("## Catálogo (Dataview)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('```dataview')
    [void]$sb.AppendLine('TABLE category AS "Categoría", length(file.inlinks) AS "Referencias", updated')
    [void]$sb.AppendLine("FROM `"$Area`"")
    [void]$sb.AppendLine('WHERE !startswith(file.name, "Template")')
    [void]$sb.AppendLine("SORT file.name ASC")
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Registro")
    [void]$sb.AppendLine()

    if ($notes.Count -eq 0) {
        [void]$sb.AppendLine("- (vacío — el script no encontró notas)")
    }
    foreach ($n in $notes) {
        $content = Get-Content $n.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) { continue }
        $fields = Get-Fields $content
        $h1   = ([regex]::Match($content, "(?m)^#\s+(.+)$")).Groups[1].Value.Trim()
        $title = if ($h1) { $h1 } else { $n.BaseName }
        $cat   = if ($fields -and $fields.ContainsKey("category")) { $fields["category"] } else { "-" }
        $upd   = if ($fields -and $fields.ContainsKey("updated"))   { $fields["updated"] }   else { "-" }
        [void]$sb.AppendLine("- [[$Area/$($n.BaseName)]] — $title  (category: $cat · updated: $upd)")
    }

    return $sb.ToString().TrimEnd("`r", "`n")
}

function Get-FullDoc {
    param([string]$Area, [System.Collections.IDictionary]$Info, [string]$BodyInner)
    return @"
---
type: index
area: $Area
updated: $today
---

# $($Info.title)

> $($Info.desc)

$markerBegin
$BodyInner
$markerEnd

## Relacionado

- [[OpenBrainCode]] — hub general.
"@
}

function Replace-Body {
    param([string]$Content, [string]$BodyInner)
    $beginIdx = $Content.IndexOf($markerBegin)
    if ($beginIdx -lt 0) { return $null }
    $endIdx = $Content.IndexOf($markerEnd, $beginIdx + $markerBegin.Length)
    if ($endIdx -lt 0) { return $null }
    $endIdxC = $endIdx + $markerEnd.Length
    return $Content.Substring(0, $beginIdx) +
           $markerBegin + "`n" + $BodyInner + "`n" + $markerEnd +
           $Content.Substring($endIdxC)
}

function Set-UpdatedField {
    param([string]$Content)
    return [regex]::Replace($Content, "(?m)^updated:[ \t]*[^\r\n]*$", "updated: $today")
}

foreach ($Area in $areas) {
    $info = $areaInfo[$Area]
    $dir  = Join-Path $VaultPath $Area
    $file = Join-Path $dir "_INDEX.md"

    if (-not (Test-Path $dir)) {
        if (-not $Quiet) { Write-Host "[SKIP] $Area :: carpeta inexistente" }
        continue
    }

    $bodyInner = Get-BodyInner $Area

    if (-not (Test-Path $file)) {
        $doc = Get-FullDoc $Area $info $bodyInner
        if ($DryRun) { if (-not $Quiet) { Write-Host "[DRY] $Area :: crearía $file" }; continue }
        Set-Content -LiteralPath $file -Value $doc -Encoding UTF8
        if (-not $Quiet) { Write-Host "[OK ] $Area :: creado _INDEX.md" }
        continue
    }

    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    $newContent = Replace-Body $content $bodyInner
    if ($null -eq $newContent) {
        if (-not $Quiet) { Write-Host "[WARN] $Area :: _INDEX.md sin marcadores AUTO; no toco (lo creá o borrá)" }
        continue
    }
    $newContent = Set-UpdatedField $newContent

    if ($newContent -eq $content) {
        if (-not $Quiet) { Write-Host "[----] $Area :: sin cambios" }
        continue
    }

    if ($DryRun) { if (-not $Quiet) { Write-Host "[DRY ] $Area :: actualizaría $file" }; continue }
    Set-Content -LiteralPath $file -Value $newContent -Encoding utf8
    if (-not $Quiet) { Write-Host "[OK ] $Area :: _INDEX.md actualizado" }
}

if (-not $Quiet) { Write-Host "=== fin ===" }