unit Principal;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms,openssl,opensslsockets, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    edtEmail: TEdit;
    edtPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    memoToken: TMemo;
    Button1: TButton;
    Label3: TLabel;
    Button2: TButton;
    memoResp: TMemo;
    Label4: TLabel;
    Label5: TLabel;
    edtNode: TEdit;
    Label6: TLabel;
    edtKey: TEdit;
    Button3: TButton;
    Label7: TLabel;
    edtDomain: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
    Firebase.Interfaces,
  Firebase.Auth,
  Firebase.Database,
fpjson,fphttpclient,Generics.Collections, streamex;
{$R *.lfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Auth: IFirebaseAuth;
  AResponse: IFirebaseResponse;
  JSONResp:TJSONData ;
  Obj: TJSONObject;
  idToken:string;
begin
  Auth := TFirebaseAuth.Create;
  Auth.SetApiKey(edtKey.Text);
  AResponse := Auth.SignInWithEmailAndPassword(edtEmail.Text, edtPassword.Text);
  JSONResp :=GetJSON(AResponse.ContentAsString);



  if (not Assigned(JSONResp)) or (not(JSONResp is TJSONObject)) then
  begin
    if Assigned(JSONResp) then
    begin
      JSONResp.Free;
    end;
    Exit;
  end;
  Obj := JSONResp as TJSONObject;
  memoToken.Lines.Add(  obj.Get('idToken',''));

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  ADatabase: TFirebaseDatabase;
  AResponse: IFirebaseResponse;
  AParams: TDictionary<string, string>;
  JSONResp: TJSONData;
begin
  ADatabase := TFirebaseDatabase.Create;
  ADatabase.SetBaseURI(edtDomain.Text);
  ADatabase.SetToken(memoToken.Text);
  memoResp.Lines.Clear;
  AParams := TDictionary<string, string>.Create;
  try
    AParams.Add('orderBy', '"$key"');
    AParams.Add('limitToLast', '2');
    AResponse := ADatabase.Get([edtNode.Text + '.json'], AParams);
    JSONResp :=GetJSON(AResponse.ContentAsString);


    if (not Assigned(JSONResp)) or (not(JSONResp is TJSONObject)) then
    begin
      if Assigned(JSONResp) then
      begin
        JSONResp.Free;
      end;
      Exit;
    end;

    memoResp.Lines.Add(JSONResp.asjson);
  finally
    AParams.Free;
    ADatabase.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  ADatabase: TFirebaseDatabase;
  AResponse: IFirebaseResponse;
  JSONReq, Produto: TJSONObject;
  JSONResp: TJSONData;
  ProdutosArray: TJSONArray;
begin

 JSONReq := TJSONObject.Create;
  JSONReq.Add('razao', 'softclass software ltda');
  JSONReq.Add('data', '08/02/2017');
  JSONReq.Add('hora', '11:03');

  ProdutosArray := TJSONArray.Create;
  JSONReq.Add('Produtos', ProdutosArray);

  Produto := TJSONObject.Create;
  Produto.Add('nome', 'Produto 1');
  Produto.Add('preco', 10.99);
  Produto.Add('quantidade', 2);
  ProdutosArray.Add(Produto);


  Produto := TJSONObject.Create;
  Produto.Add('nome', 'Produto 2');
  Produto.Add('preco', 20.50);
  Produto.Add('quantidade', 1);
  ProdutosArray.Add(Produto);

  ;
  //JSONReq := TJSONObject.ParseJSONValue(StringWriter.ToString) as TJSONObject;

  ADatabase := TFirebaseDatabase.Create;
  ADatabase.SetBaseURI(edtDomain.Text);
  ADatabase.SetToken(memoToken.Text);
  try
    AResponse := ADatabase.Post([edtNode.Text + '.json'], JSONReq);
    JSONResp :=GetJSON(AResponse.ContentAsString);
    if (not Assigned(JSONResp)) or (not(JSONResp is TJSONObject)) then
    begin
      if Assigned(JSONResp) then
      begin
        JSONResp.Free;
      end;
      Exit;
    end;
    memoResp.Text :=  JSONResp.asjson;
  finally
    ADatabase.Free;
  end;

end;
end.

