# ============================================================================
#  build-installer.ps1  -  Compila el instalador Inno de un cliente (pa.co.it)
#
#  Ejemplo:
#    .\build-installer.ps1 -Client 5 -Site 12 -Api https://api.pa.co.it `
#      -Token ABC123 -AgentType workstation -Rdp 0 -Ping 1 -Power 0
#
#  Requiere Inno Setup 6 (ISCC.exe) y el binario del agente (tacticalrmm.exe).
# ============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][int]$Client,
    [Parameter(Mandatory = $true)][int]$Site,
    [Parameter(Mandatory = $true)][string]$Api,
    [Parameter(Mandatory = $true)][string]$Token,
    [ValidateSet("server", "workstation")][string]$AgentType = "server",
    [int]$Rdp = 0,
    [int]$Ping = 0,
    [int]$Power = 0,
    [string]$AgentVersion = "2.11.0",
    [string]$AgentExe = "$PSScriptRoot\tacticalrmm.exe",
    [string]$OutName = "agente-pacoit-$Client",
    [string]$Iscc = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    [string]$OutDir = "$PSScriptRoot\out"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $AgentExe)) { throw "No existe el binario del agente: $AgentExe" }
if (-not (Test-Path -LiteralPath $Iscc))     { throw "No existe ISCC.exe: $Iscc" }

$flags = "--silent"
if ($Rdp -eq 1)   { $flags += " --rdp" }
if ($Ping -eq 1)  { $flags += " --ping" }
if ($Power -eq 1) { $flags += " --power" }

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$iss = Join-Path $PSScriptRoot "setup-pacoit.iss"
Write-Host "Compilando instalador: client=$Client site=$Site type=$AgentType flags='$flags'"

& $Iscc `
    "/DClient=$Client" `
    "/DSite=$Site" `
    "/DApi=$Api" `
    "/DToken=$Token" `
    "/DAgentType=$AgentType" `
    "/DRunFlags=$flags" `
    "/DAgentVersion=$AgentVersion" `
    "/DAgentExePath=$AgentExe" `
    "/DOutName=$OutName" `
    "/O$OutDir" `
    $iss

if ($LASTEXITCODE -ne 0) { throw "ISCC fallo con codigo $LASTEXITCODE" }

$out = Join-Path $OutDir "$OutName.exe"
Write-Host "OK -> $out"
