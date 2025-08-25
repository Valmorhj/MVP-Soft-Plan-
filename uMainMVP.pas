unit uMainMVP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, uConexaoDao, Vcl.StdCtrls, Vcl.ExtCtrls,  FireDAC.Comp.Client,FireDAC.DApt,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.JSON,System.Generics.Collections,
  uViaCEPClient, Vcl.Mask ,  System.UITypes,Vcl.Dialogs, uConsultaEnderecos;


type
  TfrPrincipal = class(TForm)
    rgOpcoes: TRadioGroup;
    Button1: TButton;
    lbCEP: TLabel;
    lbUF: TLabel;
    edCidade: TEdit;
    lbCidade: TLabel;
    edLogradouro: TEdit;
    lbLogradouro: TLabel;
    edCep: TMaskEdit;
    cbUf: TComboBox;
    btConsulta: TButton;
    procedure Button1Click(Sender: TObject);
    procedure edCepOnChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function FPodeExecutarProcesso : Boolean;
    procedure btConsultaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  frPrincipal: TfrPrincipal;
  FDaoConection : TConexaoDa;

implementation

{$R *.dfm}


procedure TfrPrincipal.btConsultaClick(Sender: TObject);
var
  wFormCOnsulta : TfrConsulta;
begin
  wFormCOnsulta := TfrConsulta.Create(Self);
  wFormCOnsulta.Show;
end;

procedure TfrPrincipal.Button1Click(Sender: TObject);
var
  wQuerry : TFDQuery;
  wObjViaCep : TObjectList<TViaCEP>;
  wViaCepClient : TViaCEPClient;
  wViaCep : TViaCEP;
  wAtualiza : Boolean;
  idx: Integer;

 procedure pCarregaOuAtualiza;
 begin
   Case MessageDlg('Endereço ja cadastrado na base de dados!Deseje carregar as informacoes existentes '+#13+
                'Sim - Carregar dados existentes para consulta. '+#13+
                'Não - Atualizar dados existentes', mtConfirmation, [mbYes, mbNo], 0)  of

      mrYes :
      begin
        idx := cbUf.Items.IndexOf(wQuerry.FieldByName('bduf').AsString);
        if idx <> -1 then
           cbUf.ItemIndex := idx;
        edCep.Text :=  wQuerry.FieldByName('bdcep').AsString;
        edCidade.text     := wQuerry.FieldByName('bdlocalidade').AsString;
        edLogradouro.text := wQuerry.FieldByName('bdlogradouro').AsString;
      end;
      mrNo:
      Begin
       wAtualiza := True;
      End;
   End;
 end;

begin

  if not(FPodeExecutarProcesso)  then
     Exit;

  If Trim(StringReplace(edCEP.Text,'-','', [rfReplaceAll])) <> EmptyStr then
     begin
       try
         wAtualiza := False;
         wQuerry := TFDQuery.Create(nil);
         wQuerry.Connection := FDaoConection.GetConnection;
         wQuerry.SQL.Text := 'SELECT * FROM TCONSULTASVIACEP ' +
                            'WHERE REPLACE(bdcep, ''-'', '''') = :cep';
         wQuerry.Params.ParamByName('cep').AsString := edCEP.Text;
         wQuerry.Open;
         if not(wQuerry.Eof) then
            pCarregaOuAtualiza;

         If (wQuerry.Eof) or (wAtualiza) then
            begin
              wViaCepClient:= TViaCEPClient.Create(Self);
              wViaCep := TViaCEP.Create;
              if rgOpcoes.ItemIndex = 0 then
                wViaCep :=  wViaCepClient.ConsultarPorCepJson(edCEP.Text)
              else
                wViaCep :=  wViaCepClient.ConsultarPorCepXml(edCEP.Text);
              If Assigned(wViaCep) then
                 FDaoConection.InserirViaCEP(wViaCep,wAtualiza)
              else
                 ShowMessage('CEP incorreto ou inexistente na base de dados. Verifique!');
            end



       Finally
         FreeAndNil(wQuerry);
         If Assigned(wViaCep)  then
            FreeAndNil(wViaCep);
         If Assigned(wViaCepClient)  then
            FreeAndNil(wViaCepClient);
       end;
     end
  else
    begin
      try
         wAtualiza := False;
         wQuerry := TFDQuery.Create(nil);
         wQuerry.Connection := FDaoConection.GetConnection;
         wQuerry.Sql.Text   := 'Select * from TCONSULTASVIACEP where bduf='+ QuotedStr(cbUf.Text) + ' and bdlogradouro='+QuotedStr(edLogradouro.Text)+ ' and bdlocalidade='+QuotedStr(edCidade.Text);
         wQuerry.Open;
         if not(wQuerry.Eof) then
            pCarregaOuAtualiza;


         If (wQuerry.Eof or wAtualiza) then
            begin
              wViaCepClient:= TViaCEPClient.Create(Self);
              wObjViaCep := TObjectList<TViaCEP>.Create;
              if rgOpcoes.ItemIndex = 0 then
                wObjViaCep :=  wViaCepClient.ConsultarPorEnderecoJson(cbUf.Text,edCidade.Text,edLogradouro.Text)
              else
                wObjViaCep :=  wViaCepClient.ConsultarPorEnderecoXml(cbUf.Text,edCidade.Text,edLogradouro.Text);
              If Assigned(wObjViaCep) then
                 FDaoConection.InserirListaViaCEP(wObjViaCep,wAtualiza)
              else
                 ShowMessage('CEP incorreto ou inexistente na base de dados. Verifique!');
            end



       Finally
         FreeAndNil(wQuerry);
         If Assigned(wObjViaCep)  then
            FreeAndNil(wObjViaCep);
         If Assigned(wViaCepClient)  then
            FreeAndNil(wViaCepClient);
      end;
    end;

end;



procedure TfrPrincipal.edCepOnChange(Sender: TObject);
begin
  if Trim(StringReplace(edCEP.Text,'-','', [rfReplaceAll])) = EmptyStr then
     begin
       lbUF.Enabled := True;
       cbUf.ItemIndex := 0;
       lbCidade.Enabled := True;
       lbLogradouro.Enabled := True;
       cbUf.Enabled := True;
       edCidade.Enabled := True;
       edLogradouro.Enabled := True;
     end
  else
     begin
       lbUF.Enabled := False;
       lbCidade.Enabled := False;
       lbLogradouro.Enabled := False;
       cbUf.Enabled := False;
       edCidade.Enabled := False;
       edLogradouro.Enabled := False;
       cbUf.ItemIndex := 0;
       edCidade.text := EmptyStr;
       edLogradouro.text := EmptyStr;
     end;
end;



procedure TfrPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If Assigned(FDaoConection) then
     FreeAndNil(FDaoConection);
end;

procedure TfrPrincipal.FormCreate(Sender: TObject);
begin
  FDaoConection := TConexaoDA.Create;
end;

function TfrPrincipal.FPodeExecutarProcesso: Boolean;
begin
  Result := True;
  if rgOpcoes.ItemIndex = -1 then
     begin
       ShowMessage('Selecione uma opção!');
       Result:= False;
     end;

  if ((Length(edCidade.Text)<3) or  (Length(edLogradouro.Text)<3)) and (edCep.Text=EmptyStr) then
    begin
      ShowMessage('Cidade e Logradouro devem conter no minimo 3 caracteres.');
      Result:= False;
    end;


end;

end.
