# Sistema rápido de notas con PowerShell + Neovim en Windows

Este setup permite abrir una nota diaria o una nota tipo inbox usando atajos de teclado en Windows.

La idea general es:

```txt
Shortcut key → acceso directo .lnk → archivo .bat → script PowerShell → Neovim
```

Esto se hizo así porque los shortcut keys nativos de Windows pueden fallar cuando apuntan directamente a un script `.ps1`. Usar un `.bat` como intermediario suele ser más estable.

---

## 1. Requisitos

Necesitas:

- Windows 10 o Windows 11.
- PowerShell.
- Neovim instalado.
- Opcional, pero recomendado: Winget.

---

## 2. Verificar si tienes Winget

Abre PowerShell y ejecuta:

```powershell
winget --version
```

Si te muestra una versión, ya tienes Winget instalado.

Ejemplo:

```txt
v1.9.25200
```

Si PowerShell dice que `winget` no se reconoce como comando, entonces necesitas instalarlo o actualizarlo.

---

## 3. Instalar Winget si no lo tienes

Winget viene incluido dentro de la aplicación **App Installer** de Microsoft.

### Opción recomendada: Microsoft Store

1. Abre **Microsoft Store**.
2. Busca:

```txt
App Installer
```

3. Instala o actualiza **App Installer**.
4. Cierra y vuelve a abrir PowerShell.
5. Verifica:

```powershell
winget --version
```

Si ahora muestra una versión, ya puedes continuar.

---

## 4. Instalar Neovim con Winget

En PowerShell, ejecuta:

```powershell
winget install Neovim.Neovim
```

Cuando termine, cierra y vuelve a abrir PowerShell.

Verifica la instalación con:

```powershell
nvim --version
```

También puedes verificar la ubicación del ejecutable con:

```powershell
where.exe nvim
```

Si `nvim --version` funciona, Neovim ya está instalado correctamente.

---

## 5. Ubicación de los scripts

Los scripts se guardarán en esta carpeta:

```txt
%USERPROFILE%\Scripts
```

En PowerShell, crea la carpeta con:

```powershell
mkdir "$HOME\Scripts"
```

Ahí se guardarán estos archivos:

```txt
%USERPROFILE%\Scripts\note.ps1
%USERPROFILE%\Scripts\daily-note.bat
%USERPROFILE%\Scripts\inbox-note.bat
```

---

## 6. Escoger dónde se guardarán las notas

Dentro del script `note.ps1`, la variable importante es esta:

```powershell
$notesRoot = "$HOME\OneDrive - Universidad Latina\Documents\000A_notes"
```

Esa es la carpeta raíz donde se guardará todo.

Puedes cambiarla por cualquier ubicación personal.

Ejemplos:

```powershell
$notesRoot = "$HOME\Documents\Notas"
```

```powershell
$notesRoot = "D:\Notas"
```

```powershell
$notesRoot = "$HOME\OneDrive\Notas"
```

```powershell
$notesRoot = "$HOME\OneDrive - Universidad Latina\Documents\000A_notes"
```

La estructura final quedará así:

```txt
000A_notes/
├── daily/
│   └── 2026-07-07.md
├── learning/
├── ideas/
├── projects/
└── inbox.md
```

---

## 7. Crear el script principal `note.ps1`

Crea el archivo:

```powershell
notepad "$HOME\Scripts\note.ps1"
```

Pega este contenido:

```powershell
param(
    [ValidateSet("daily", "inbox")]
    [string]$Mode = "daily"
)

# Cambia esta ruta por la ubicación donde quieres guardar tus notas.
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

# Abrir Neovim desde la carpeta raíz de notas.
Set-Location $notesRoot

$nvimCommand = Get-Command nvim.exe -ErrorAction SilentlyContinue

if ($null -eq $nvimCommand) {
    Write-Host "ERROR: No se encontró nvim.exe en el PATH."
    Write-Host "Prueba ejecutar: where.exe nvim"
    Read-Host "Presiona Enter para cerrar"
    exit 1
}

& $nvimCommand.Source $filePath
```

---

## 8. Probar el script manualmente

Para abrir la nota diaria:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Scripts\note.ps1" daily
```

Para abrir el inbox:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Scripts\note.ps1" inbox
```

Si esos comandos funcionan, el script está bien.

---

## 9. Crear los archivos `.bat`

El `.bat` sirve como intermediario entre Windows y PowerShell.

### Daily note

Crea el archivo:

```powershell
notepad "$HOME\Scripts\daily-note.bat"
```

Pega esto:

```bat
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\note.ps1" daily
```

### Inbox note

Crea el archivo:

```powershell
notepad "$HOME\Scripts\inbox-note.bat"
```

Pega esto:

```bat
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\note.ps1" inbox
```

---

## 10. Probar los `.bat`

Desde el Explorador de archivos, abre:

```txt
%USERPROFILE%\Scripts
```

Haz doble click en:

```txt
daily-note.bat
```

Debe abrir la nota diaria en Neovim.

Luego prueba:

```txt
inbox-note.bat
```

Debe abrir el archivo `inbox.md`.

---

## 11. Crear accesos directos para los `.bat`

En el escritorio:

1. Click derecho.
2. Selecciona **New > Shortcut**.
3. Para la nota diaria, usa esta ubicación:

```txt
"%USERPROFILE%\Scripts\daily-note.bat"
```

4. Nombre sugerido:

```txt
Daily Note
```

Repite el proceso para inbox:

```txt
"%USERPROFILE%\Scripts\inbox-note.bat"
```

Nombre sugerido:

```txt
Inbox Note
```

---

## 12. Mover los shortcuts al Start Menu

Esto ayuda a que Windows reconozca mejor los shortcut keys.

1. Presiona:

```txt
Win + R
```

2. Escribe:

```txt
shell:Start Menu
```

3. Presiona Enter.
4. Pega ahí los accesos directos `Daily Note` e `Inbox Note`.

También puedes pegarlos dentro de la carpeta:

```txt
Programs
```

si quieres que queden organizados como aplicaciones del menú inicio.

---

## 13. Asignar shortcut keys

Haz click derecho sobre el acceso directo `Daily Note`.

Luego:

```txt
Properties > Shortcut > Shortcut key
```

Presiona:

```txt
Ctrl + Alt + N
```

Luego:

```txt
Apply > OK
```

Para `Inbox Note`, usa por ejemplo:

```txt
Ctrl + Alt + I
```

---

## 14. Reiniciar Explorer si el shortcut key no funciona

A veces Windows no registra el shortcut key inmediatamente.

Abre PowerShell y ejecuta:

```powershell
taskkill /f /im explorer.exe
start explorer.exe
```

Después prueba de nuevo:

```txt
Ctrl + Alt + N
```

---

## 15. Flujo de uso recomendado

Usa la nota diaria para lo que pertenece al día actual:

```txt
Ctrl + Alt + N
```

Usa inbox para capturar ideas rápidas sin pensar mucho:

```txt
Ctrl + Alt + I
```

Después puedes mover contenido desde `inbox.md` hacia:

```txt
learning/
ideas/
projects/
```

---

## 16. Notas importantes

Si el shortcut key no funciona, pero el `.bat` sí funciona con doble click, entonces el problema no está en PowerShell ni en Neovim. El problema está en cómo Windows está registrando el acceso directo.

En ese caso, revisa:

- Que el acceso directo esté en el escritorio o en `shell:Start Menu`.
- Que el shortcut key no esté siendo usado por otro programa.
- Que el `.bat` abra correctamente con doble click.
- Que hayas reiniciado Explorer.

---

## 17. Archivos finales del setup

```txt
%USERPROFILE%\Scripts\note.ps1
%USERPROFILE%\Scripts\daily-note.bat
%USERPROFILE%\Scripts\inbox-note.bat
```

La carpeta de notas se define aquí:

```powershell
$notesRoot = "$HOME\OneDrive - Universidad Latina\Documents\000A_notes"
```

Cambia esa línea según la ubicación donde quieras guardar tus notas.
