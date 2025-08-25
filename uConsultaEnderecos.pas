unit uConsultaEnderecos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  uConexaoDao, FireDAC.Comp.Client;

type
  TfrConsulta = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FDataSet : TDataSet;
  end;

var
  frConsulta: TfrConsulta;

implementation

{$R *.dfm}

procedure TfrConsulta.FormCreate(Sender: TObject);
var
  wQuerry : TFDQuery;
  i: Integer;
begin

  wQuerry := TFDQuery.Create(Self);
  try
    wQuerry.Connection := ConexaoDa.FConnection;
    DataSource1.DataSet := wQuerry;
    DBGrid1.DataSource := DataSource1;
    wQuerry.SQL.Text := 'select  bdcodigo "Codigo",  bdcep "Cep", bdlogradouro "Logradouro", bdcomplemento "Complemento",  bdbairro "Bairro", bdlocalidade "Localidade", bduf "UF" from tconsultasviacep';
    wQuerry.Open;

   DBGrid1.Columns.Clear;
   for i := 0 to wQuerry.Fields.Count - 1 do
    DBGrid1.Columns.Add.FieldName := wQuerry.Fields[i].FieldName;

  except
    wQuerry.Free;
    raise;
  end;
end;






end.
