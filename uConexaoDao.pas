unit uConexaoDao;


interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Def,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, uViaCEPClient, System.Generics.Collections;

type
  TConexaoDa = class(TDataModule)
  private
  public
    FConnection: TFDConnection;
    constructor Create;
    destructor Destroy; override;

    function GetConnection: TFDConnection;
    function Connected: Boolean;
    procedure InserirListaViaCEP(ALista: TObjectList<TViaCEP>;prAtualiza : Boolean);
    procedure InserirViaCEP(AViaCEP: TViaCEP;prAtualiza : Boolean);
  end;

var
  ConexaoDa : TConexaoDa;

implementation

{ TConexaoDAO }
{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
constructor TConexaoDa.Create;
begin
 ConexaoDa := Self;
  FConnection := TFDConnection.Create(nil);

  // Parâmetros de conexão
  FConnection.DriverName := 'FB';
  FConnection.Params.DriverID := 'FB';
  FConnection.Params.Database := 'C:\Desafio Tecnico SoftPlan\MVPDB.fdb';
  FConnection.Params.UserName := 'SYSDBA';
  FConnection.Params.Password := 'masterkey';
  FConnection.Params.Add('CharacterSet=win1252');

  try
    FConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao conectar ao banco: ' + E.Message);
  end;
end;

destructor TConexaoDa.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TConexaoDa.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

function TConexaoDa.Connected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure  TConexaoDa.InserirViaCEP( AViaCEP: TViaCEP;prAtualiza : Boolean);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    if prAtualiza then
      Query.SQL.Text :=
        'UPDATE TCONSULTASVIACEP SET ' +
        'BDLOGRADOURO = :logradouro, BDCOMPLEMENTO = :complemento, BDBAIRRO = :BAIRRO, ' +
        'BDLOCALIDADE = :LOCALIDADE, BDUF = :UF ' +
        'WHERE bdcep= :CEP'
    else
       Query.SQL.Text :=
       'INSERT INTO TCONSULTASVIACEP (BDCEP, BDLOGRADOURO, BDCOMPLEMENTO, BDBAIRRO, BDLOCALIDADE, BDUF) ' +
       'VALUES (:cep, :logradouro, :complemento, :bairro, :localidade, :uf)';
    Query.Params.ParamByName('cep').AsString := Copy(AViaCEP.cep,1,10) ;
    Query.Params.ParamByName('logradouro').AsString := Copy(AViaCEP.logradouro,1,100);
    Query.Params.ParamByName('complemento').AsString := Copy(AViaCEP.complemento,1,20);
    Query.Params.ParamByName('bairro').AsString := Copy(AViaCEP.bairro,1,20);
    Query.Params.ParamByName('localidade').AsString := Copy(AViaCEP.localidade,1,100);
    Query.Params.ParamByName('uf').AsString := Copy(AViaCEP.uf,1,2);
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure  TConexaoDa.InserirListaViaCEP( ALista: TObjectList<TViaCEP>;prAtualiza : Boolean);
var
  ViaCEP: TViaCEP;
begin
  for ViaCEP in ALista do
    InserirViaCEP(ViaCEP,prAtualiza);
end;


end.

initialization
  DMConexao := TDMConexao.Create(nil);  // ou Application
