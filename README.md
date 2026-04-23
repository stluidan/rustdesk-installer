# RustDesk Installer for Windows

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Script PowerShell que instala automáticamente la **última versión** de RustDesk en Windows.

## 🚀 Instalación Rápida

**Copia y pega esto en PowerShell (como Administrador):**

```powershell
powershell -ExecutionPolicy Bypass -Command "& { [ScriptBlock]::Create((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TU_USUARIO/rustdesk-installer/main/Install-RustDesk.ps1').Content) }"
