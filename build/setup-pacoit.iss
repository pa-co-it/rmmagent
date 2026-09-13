; ============================================================================
;  setup-pacoit.iss  -  Instalador Inno Setup por cliente (pa.co.it)
;  Genera un .exe con client/site/token embebidos en espanol.
;
;  Se compila con ISCC y defines:
;    /DClient=  /DSite=  /DApi=  /DToken=  /DAgentType=
;    /DRunFlags=  /DAgentVersion=  /DAgentExePath=  /DOutName=
; ============================================================================

#ifndef AppName
  #define AppName "Agente de gestion PA.CO.IT"
#endif
#ifndef AppPublisher
  #define AppPublisher "INGENIERIA SANITARIA S.L."
#endif
#ifndef AppURL
  #define AppURL "https://pa.co.it"
#endif
#ifndef AgentVersion
  #define AgentVersion "2.11.0"
#endif
#ifndef Client
  #define Client "0"
#endif
#ifndef Site
  #define Site "0"
#endif
#ifndef Api
  #define Api "https://api.pa.co.it"
#endif
#ifndef Token
  #define Token ""
#endif
#ifndef AgentType
  #define AgentType "server"
#endif
#ifndef RunFlags
  #define RunFlags "--silent"
#endif
#ifndef AgentExePath
  #define AgentExePath "tacticalrmm.exe"
#endif
#ifndef OutName
  #define OutName "agente-pacoit"
#endif

[Setup]
; Mismo AppId que el instalador original: actualiza/reemplaza instalaciones previas
AppId={{0D34D278-5FAF-4159-A4A0-4E2D2C08139D}
AppName={#AppName}
AppVersion={#AgentVersion}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
DefaultDirName={autopf}\TacticalAgent
DisableDirPage=yes
DisableProgramGroupPage=yes
SetupLogging=yes
Compression=lzma
SolidCompression=yes
WizardStyle=modern
RestartApplications=no
CloseApplications=no
MinVersion=6.1
PrivilegesRequired=admin
VersionInfoVersion={#AgentVersion}.0
VersionInfoOriginalFileName=tacticalrmm.exe
AppCopyright=Copyright (C) 2026 {#AppPublisher}
OutputBaseFilename={#OutName}

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#AgentExePath}"; DestDir: "{app}"; DestName: "tacticalrmm.exe"; Flags: ignoreversion

[Run]
; Instala y registra el agente (servicio + mesh) con los datos del cliente
Filename: "{app}\tacticalrmm.exe"; Parameters: "-m install --api {#Api} --client-id {#Client} --site-id {#Site} --agent-type {#AgentType} --auth {#Token} {#RunFlags}"; Flags: runhidden waituntilterminated
Filename: "{app}\tacticalrmm.exe"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallRun]
Filename: "{app}\tacticalrmm.exe"; Parameters: "-m cleanup"; RunOnceId: "cleanuprm"
Filename: "{cmd}"; Parameters: "/c taskkill /F /IM tacticalrmm.exe"; RunOnceId: "killtacrmm"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Exec('cmd.exe', '/c ping 127.0.0.1 -n 2 && net stop tacticalrmm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('cmd.exe', '/c taskkill /F /IM tacticalrmm.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;

function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
begin
  Exec('cmd.exe', '/c ping 127.0.0.1 -n 2 && net stop tacticalrmm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('cmd.exe', '/c taskkill /F /IM tacticalrmm.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('cmd.exe', '/c sc delete tacticalrmm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;
