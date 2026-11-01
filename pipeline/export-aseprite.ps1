# Exporta cada arquivo .aseprite de "Two Souls/art" para "Two Souls/assets/sprites"
# como spritesheet PNG + JSON, que o Godot lê com AsepriteFrames.load_frames().
# Uso: powershell -ExecutionPolicy Bypass -File pipeline\export-aseprite.ps1            (exporta tudo)
#      powershell -ExecutionPolicy Bypass -File pipeline\export-aseprite.ps1 orion       (só art\orion.aseprite)
param([string]$Name = "*")

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$artDir = Join-Path $root "Two Souls\art"
$outDir = Join-Path $root "Two Souls\assets\sprites"

# Executável compilado localmente (uso pessoal, não vai para o repositório).
$aseprite = $env:ASEPRITE
if (-not $aseprite) { $aseprite = "C:\dev\aseprite\build\bin\aseprite.exe" }
if (-not (Test-Path $aseprite)) { throw "Aseprite não encontrado em $aseprite. Defina `$env:ASEPRITE." }

$files = Get-ChildItem -Path $artDir -Filter "$Name.aseprite"
if (-not $files) { throw "Nenhum .aseprite encontrado em $artDir com o nome '$Name'." }

foreach ($file in $files) {
    $base = $file.BaseName
    $json = Join-Path $outDir "$base.json"
    Remove-Item $json -ErrorAction SilentlyContinue
    # O Aseprite é um programa de janela: sem o Out-Null o PowerShell não espera ele terminar.
    & $aseprite -b $file.FullName `
        --sheet (Join-Path $outDir "$base.png") `
        --data $json `
        --format json-array --sheet-type packed --list-tags `
        --filename-format "{title} {frame}" | Out-Null
    # O Aseprite sai com código 0 mesmo quando não consegue abrir o arquivo, então confere o JSON.
    if (-not (Test-Path $json) -or (Get-Item $json).Length -eq 0) {
        throw "Falha ao exportar $($file.Name)"
    }
    Write-Host "Exportado: $base.png + $base.json"
}
