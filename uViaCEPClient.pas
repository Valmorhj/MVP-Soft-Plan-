unit uViaCEPClient;

interface

uses
  System.Classes, System.SysUtils, System.Net.HttpClient, System.Net.URLClient,
  System.JSON, System.Generics.Collections, System.NetEncoding, Xml.XMLDoc, Xml.XMLIntf;

type
  TViaCEP = class
  public
    cep, logradouro, complemento, unidade, bairro, localidade, uf: string;
  end;

  TViaCEPClient = class(TComponent)
  private
    FHTTP: THTTPClient;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ConsultarPorCepJson(ACep: string): TViaCEP;
    function ConsultarPorEnderecoJson(UF, Cidade, Logradouro: string): TObjectList<TViaCEP>;
    function ConsultarPorCepXML(ACep: string): TViaCEP;
    function ConsultarPorEnderecoXML(UF, Cidade, Logradouro: string): TObjectList<TViaCEP>;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Exemplos', [TViaCEPClient]);
end;

{ TViaCEPClient }

constructor TViaCEPClient.Create(AOwner: TComponent);
begin
  inherited;
  FHTTP := THTTPClient.Create;
end;

destructor TViaCEPClient.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TViaCEPClient.ConsultarPorCepJson(ACep: string): TViaCEP;
var
  Resp: IHTTPResponse;
  Json: TJSONObject;
begin
  Result := nil;
  ACep := ACep.Replace('-', '').Trim;

  Resp := FHTTP.Get('https://viacep.com.br/ws/' + ACep + '/json/');
  if Resp.StatusCode = 200 then
  begin
    Json := TJSONObject.ParseJSONValue(Resp.ContentAsString) as TJSONObject;
    try
      if (Assigned(Json)) and  (Json.GetValue('erro', False).ToString <> 'true')  then
      begin
        Result := TViaCEP.Create;
        Result.cep         := Json.GetValue<string>('cep');
        Result.logradouro  := Json.GetValue<string>('logradouro');
        Result.complemento := Json.GetValue<string>('complemento');
        Result.unidade     := Json.GetValue<string>('unidade');
        Result.bairro      := Json.GetValue<string>('bairro');
        Result.localidade  := Json.GetValue<string>('localidade');
        Result.uf          := Json.GetValue<string>('uf');
      end;
    finally
      Json.Free;
    end;
  end;
end;

function TViaCEPClient.ConsultarPorEnderecoJson(UF, Cidade, Logradouro: string): TObjectList<TViaCEP>;
var
  Resp: IHTTPResponse;
  JsonArray: TJSONArray;
  JsonObj: TJSONObject;
  VCep: TViaCEP;
  i: Integer;
  URL: string;
begin
  Result := TObjectList<TViaCEP>.Create(True); // True = auto free dos itens
  URL := Format('https://viacep.com.br/ws/%s/%s/%s/json/',
                [UF.Trim, TNetEncoding.URL.Encode(Cidade.Trim), TNetEncoding.URL.Encode(Logradouro.Trim)]);

  Resp := FHTTP.Get(URL);
  if Resp.StatusCode = 200 then
  begin
    JsonArray := TJSONObject.ParseJSONValue(Resp.ContentAsString) as TJSONArray;
    try
      for i := 0 to JsonArray.Count - 1 do
      begin
        JsonObj := JsonArray.Items[i] as TJSONObject;
        VCep := TViaCEP.Create;
        VCep.cep         := JsonObj.GetValue<string>('cep');
        VCep.logradouro  := JsonObj.GetValue<string>('logradouro');
        VCep.complemento := JsonObj.GetValue<string>('complemento');
        VCep.unidade     := JsonObj.GetValue<string>('unidade');
        VCep.bairro      := JsonObj.GetValue<string>('bairro');
        VCep.localidade  := JsonObj.GetValue<string>('localidade');
        VCep.uf          := JsonObj.GetValue<string>('uf');
        Result.Add(VCep);
      end;
    finally
      JsonArray.Free;
    end;
  end;
end;

function TViaCEPClient.ConsultarPorCepXML(ACep: string): TViaCEP;
var
  Resp: IHTTPResponse;
  XMLDoc: IXMLDocument;
  RootNode: IXMLNode;
begin
  Result := nil;
  ACep := ACep.Replace('-', '').Trim;

  Resp := FHTTP.Get('https://viacep.com.br/ws/' + ACep + '/xml/');
  if Resp.StatusCode = 200 then
  begin
    XMLDoc := TXMLDocument.Create(nil);
    try
      XMLDoc.LoadFromXML(Resp.ContentAsString);
      XMLDoc.Active := True;

      RootNode := XMLDoc.DocumentElement;  // Nó raiz <xmlcep>
      if Assigned(RootNode) and (RootNode.NodeName = 'xmlcep') then
      begin
        Result := TViaCEP.Create;
        Result.cep         := RootNode.ChildNodes['cep'].Text;
        Result.logradouro  := RootNode.ChildNodes['logradouro'].Text;
        Result.complemento := RootNode.ChildNodes['complemento'].Text;
        Result.unidade     := RootNode.ChildNodes['unidade'].Text;
        Result.bairro      := RootNode.ChildNodes['bairro'].Text;
        Result.localidade  := RootNode.ChildNodes['localidade'].Text;
        Result.uf          := RootNode.ChildNodes['uf'].Text;
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  end
  else
    raise Exception.Create('Erro na requisição XML: ' + Resp.StatusText);
end;

function TViaCEPClient.ConsultarPorEnderecoXML(UF, Cidade, Logradouro: string): TObjectList<TViaCEP>;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
  XMLDoc: IXMLDocument;
  RootNode, EnderecoNode: IXMLNode;
  VCep: TViaCEP;
  i: Integer;
  URL : String;
begin
  Result := TObjectList<TViaCEP>.Create(True);
  Http := THTTPClient.Create;
  try
    URL := Format('https://viacep.com.br/ws/%s/%s/%s/xml/',
                [UF.Trim, TNetEncoding.URL.Encode(Cidade.Trim), TNetEncoding.URL.Encode(Logradouro.Trim)]);
    Resp := FHTTP.Get(URL);
    if Resp.StatusCode = 200 then
    begin
      XMLDoc := TXMLDocument.Create(nil);
      XMLDoc.LoadFromXML(Resp.ContentAsString);
      XMLDoc.Active := True;

      RootNode := XMLDoc.DocumentElement; // Ex: <enderecos>

      for i := 0 to RootNode.ChildNodes.Count - 1 do
      begin
        EnderecoNode := RootNode.ChildNodes[i]; // ex: <endereco>
        VCep := TViaCEP.Create;
        VCep.cep         := EnderecoNode.ChildNodes['cep'].Text;
        VCep.logradouro  := EnderecoNode.ChildNodes['logradouro'].Text;
        VCep.complemento := EnderecoNode.ChildNodes['complemento'].Text;
        VCep.unidade     := EnderecoNode.ChildNodes['unidade'].Text;
        VCep.bairro      := EnderecoNode.ChildNodes['bairro'].Text;
        VCep.localidade  := EnderecoNode.ChildNodes['localidade'].Text;
        VCep.uf          := EnderecoNode.ChildNodes['uf'].Text;
        Result.Add(VCep);
      end;
    end
    else
      raise Exception.Create('Erro na requisição XML: ' + Resp.StatusText);
  finally
    Http.Free;
  end;
end;

end.

