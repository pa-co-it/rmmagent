; ============================================================================
;  setup-pacoit.iss  -  Instalador Inno Setup por cliente (pa.co.it)
;  Genera un .exe con client/site/token embebidos en espanol.
;
;  Se compila con ISCC y defines:
;    /DClient=  /DSite=  /DApi=  /DToken=  /DAgentType=
;    /DRunFlags=  /DAgentVersion=  /DAgentExePath=  /DOutName=
;
;  El instalador se relanza solo con /VERYSILENT (guardado por WizardSilent):
;  el usuario nunca ve el asistente "Siguiente, Siguiente", solo la
;  confirmacion final. El agente se instala en modo silencioso.
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
DisableWelcomePage=yes
DisableReadyPage=yes
DisableReadyMemo=yes
DisableFinishedPage=yes
DisableStartupPrompt=yes
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

[UninstallRun]
Filename: "{app}\tacticalrmm.exe"; Parameters: "-m cleanup"; RunOnceId: "cleanuprm"
Filename: "{cmd}"; Parameters: "/c taskkill /F /IM tacticalrmm.exe"; RunOnceId: "killtacrmm"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
// Si el usuario lo lanza a mano (no silencioso), relanza el propio instalador
// con /VERYSILENT y aborta esta instancia. El segundo arranque ya no muestra
// ningun asistente y termina con un unico cuadro de confirmacion.
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  if not WizardSilent() then
  begin
    // Ojo: Exec no puede lanzar el propio setup, por eso se hace via "start".
    Exec('cmd.exe',
         '/c start "" "' + ExpandConstant('{srcexe}') + '" /VERYSILENT /NORESTART',
         '', SW_HIDE, ewNoWait, ResultCode);
    Result := False;
    Exit;
  end;

  Exec('cmd.exe', '/c ping 127.0.0.1 -n 2 && net stop tacticalrmm', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('cmd.exe', '/c taskkill /F /IM tacticalrmm.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssDone then
  begin
    MsgBox('Instalación completada correctamente.' + #13#10#13#10 +
           'Este equipo ya está bajo el soporte técnico de pa.co.it.' + #13#10 +
           'En unos minutos aparecerá en nuestro sistema de monitorización.' + #13#10#13#10 +
           'Ya puede cerrar esta ventana.' + #13#10#13#10 +
           '¿Alguna duda? Escríbanos a soporte@pa.co.it',
           mbInformation, MB_OK);

    // Instalacion correcta: borra este mismo instalador. Se lanza un cmd
    // desacoplado que espera unos segundos (a que este proceso suelte el
    // fichero) y lo elimina en silencio.
    Exec('cmd.exe',
         '/c ping 127.0.0.1 -n 5 > nul & del /f /q "' + ExpandConstant('{srcexe}') + '"',
         '', SW_HIDE, ewNoWait, ResultCode);
  end;
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
