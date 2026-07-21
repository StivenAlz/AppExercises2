<#
.SYNOPSIS
    Recorre recursivamente todos los archivos (excepto bin/obj/.vs y multimedia),
    y genera un archivo de salida con el contenido de cada archivo minificado
    (sin saltos de línea ni espacios redundantes) para que ocupe el mínimo espacio.
.DESCRIPTION
    Útil para documentar el código completo de un proyecto de forma compacta.
    El archivo de salida se guarda en la misma carpeta donde está este script.
.PARAMETER Path
    Ruta raíz desde donde comenzar la búsqueda. Por defecto, el directorio actual (.)
.PARAMETER OutputFile
    Nombre del archivo de salida. Por defecto "detalle_minificado.txt"
.EXAMPLE
    .\detallar.ps1
    Genera un archivo con todo el código minificado.
#>

param(
    [string]$Path = ".",
    [string]$OutputFile = "detalle_minificado.txt"
)

# Extensiones multimedia a excluir (y otros binarios)
$excludedExtensions = @(
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.tif', '.webp',
    '.svg', '.ico', '.heic', '.heif', '.sqlite', '.mp3', '.wav', '.flac',
    '.aac', '.ogg', '.m4a', '.wma', '.opus', '.mp4', '.avi', '.mkv',
    '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp',
    '.bin', '.metadata', '.vsidx', '.v2', '.pubxml', '.pubxml.user',
    '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.zip', '.rar',
    '.exe', '.dll', '.so', '.a', '.o', '.pyc', '.class', '.jar'
)

$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Get-Location
}

try {
    $resolvedPath = Resolve-Path $Path -ErrorAction Stop
}
catch {
    Write-Error "No se pudo resolver la ruta '$Path'."
    exit 1
}

$outputFullPath = Join-Path -Path $scriptDirectory -ChildPath $OutputFile

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "DETALLAR MINIFICADO (todo el código, sin saltos de línea)" -ForegroundColor Cyan
Write-Host "Directorio: $resolvedPath" -ForegroundColor Green
Write-Host "Salida: $outputFullPath" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan

if (Test-Path $outputFullPath) {
    Remove-Item $outputFullPath -Force
}

$totalFiles = 0
$errorFiles = 0
$excludedFolders = 0
$excludedExtensions = 0
$failedFiles = @()

# Función para minificar contenido: eliminar saltos de línea y espacios múltiples
function Minify-Content {
    param([string]$content)
    # Reemplazar saltos de línea por espacio
    $minified = $content -replace "`r`n", " " -replace "`n", " " -replace "`r", " "
    # Reemplazar múltiples espacios por uno solo
    $minified = $minified -replace '\s+', ' '
    # Eliminar espacios al inicio y final
    $minified = $minified.Trim()
    return $minified
}

# Obtener todos los archivos recursivamente (excepto excluidos)
Get-ChildItem -Path $resolvedPath -Recurse -File | Where-Object {
    $fullPath = $_.FullName
    $extension = $_.Extension.ToLower()
    
    # Excluir carpetas bin/obj/.vs
    if ($fullPath -match "\\bin\\" -or $fullPath -match "\\obj\\" -or $fullPath -match "\\.vs\\") {
        $excludedFolders++
        return $false
    }
    
    # Excluir extensiones multimedia/binarias
    if ($excludedExtensions -contains $extension) {
        $excludedExtensions++
        return $false
    }
    
    return $true
} | ForEach-Object {
    $file = $_
    $relativePath = $file.FullName.Substring($resolvedPath.Path.Length + 1)
    $fileName = $file.Name

    $totalFiles++
    Write-Host "Procesando ($totalFiles): $relativePath" -ForegroundColor Gray

    try {
        # Leer contenido completo
        $rawContent = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction Stop
        # Minificar (compactar en una sola línea)
        $minifiedContent = Minify-Content -content $rawContent
    }
    catch {
        $errorFiles++
        $failedFiles += $relativePath
        Write-Warning "Error al leer el archivo: $relativePath"
        $minifiedContent = "[ERROR DE LECTURA: $($_.Exception.Message)]"
    }

    # Escribir en el archivo de salida en formato ultracompacto
    try {
        # Encabezado breve: solo nombre y ruta
        "--- ARCHIVO: $fileName ($relativePath) ---" | Out-File -FilePath $outputFullPath -Append -Encoding UTF8
        # Contenido minificado (todo en una sola línea)
        $minifiedContent | Out-File -FilePath $outputFullPath -Append -Encoding UTF8 -NoNewline
        # Separador (dos saltos de línea) para distinguir archivos
        "`n`n" | Out-File -FilePath $outputFullPath -Append -Encoding UTF8 -NoNewline
    }
    catch {
        Write-Warning "Error al escribir en el archivo de salida: $_"
    }
}

# Resumen final
Write-Host "`n=====================================================" -ForegroundColor Green
Write-Host "PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "Archivos procesados: $totalFiles" -ForegroundColor Green
Write-Host "Excluidos por carpeta (bin/obj/.vs): $excludedFolders" -ForegroundColor Yellow
Write-Host "Excluidos por extensión multimedia/binaria: $excludedExtensions" -ForegroundColor Yellow
if ($errorFiles -gt 0) {
    Write-Host "Archivos con error: $errorFiles" -ForegroundColor Red
    Write-Host "`nLISTA DE ERRORES:" -ForegroundColor Red
    foreach ($failed in $failedFiles) {
        Write-Host "  - $failed" -ForegroundColor Red
    }
}
Write-Host "Resultado guardado en: $outputFullPath" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green