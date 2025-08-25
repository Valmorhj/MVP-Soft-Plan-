program ProjectMVP;

uses
  Vcl.Forms,
  uMainMVP in 'uMainMVP.pas' {frPrincipal},
  uViaCEPClient in 'uViaCEPClient.pas',
  uConsultaEnderecos in 'uConsultaEnderecos.pas' {frConsulta},
  uConexaoDao in 'uConexaoDao.pas' {ConexaoDa: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TConexaoDa, ConexaoDa);
  Application.CreateForm(TfrPrincipal, frPrincipal);
  Application.Run;
end.
