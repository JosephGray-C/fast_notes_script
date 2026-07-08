param(
    [ValidateSet("daily", "inbox")]
    [string]$Mode = "daily"
)

# CAMBIA ESTA RUTA A LA CARPETA QUE QUIERAS
$notesRoot = "$HOME\OneDrive - Universidad Latina\Documents\000A_notes"

$dailyPath = Join-Path $notesRoot "daily"
$learningPath = Join-Path $notesRoot "learning"
$ideasPath = Join-Path $notesRoot "ideas"
$projectsPath = Join-Path $notesRoot "projects"

$folders = @(
    $notesRoot,
    $dailyPath,
    $learningPath,
    $ideasPath,
    $projectsPath
)

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

if ($Mode -eq "daily") {
    $fileName = "$(Get-Date -Format 'yyyy-MM-dd').md"
    $filePath = Join-Path $dailyPath $fileName

    if (!(Test-Path $filePath)) {
        $template = @"
# $(Get-Date -Format 'yyyy-MM-dd')

## Tareas

- [ ] 

## Notas rápidas



## Ideas



## Aprendizaje



"@

        Set-Content -Path $filePath -Value $template -Encoding UTF8
    }
}

if ($Mode -eq "inbox") {
    $filePath = Join-Path $notesRoot "inbox.md"

    if (!(Test-Path $filePath)) {
        $template = @"
# Inbox

Notas rápidas sin organizar.

- 

"@

        Set-Content -Path $filePath -Value $template -Encoding UTF8
    }
}

# Esto hace que Neovim abra desde la carpeta principal de notas
Set-Location $notesRoot

$nvimCommand = Get-Command nvim.exe -ErrorAction SilentlyContinue

if ($null -eq $nvimCommand) {
    Write-Host "ERROR: No se encontró nvim.exe en el PATH."
    Write-Host "Prueba ejecutar: where.exe nvim"
    Read-Host "Presiona Enter para cerrar"
    exit 1
}

& $nvimCommand.Source $filePath