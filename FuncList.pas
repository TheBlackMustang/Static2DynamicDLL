unit FuncList;

interface

uses
  System.Generics.Collections;

type

  TTypeDescInf = (tdNone, tdFn, tdProc);

  DescInf = record
  private
    FParams: string;
    FInParams: string;
    procedure SetParams(const Value: string);
  public
    fullStr: string;
    fn: TTypeDescInf;
    Start: string;
    Name: string;
    Result: string;
    CommentRes: string;
    DLL: string;
    ExtName: string;
    Tail: string;
    Replacer: string;
    procedure Reset;
    function TypeStr: string;
    function ResStr: string;
    property Params: string read FParams write SetParams;
    property InParams: string read FInParams;
  end;

  TDescInfList = TList<DescInf>;

implementation

uses
  System.RegularExpressions;

procedure DescInf.Reset;
begin
  fullStr := '';
  fn := tdNone;
  Name := '';
  FParams := '';
  FInParams := '';
  Result := '';
  CommentRes := '';
  dll := '';
  extname := '';
  tail := '';
  replacer := '';
end;

function DescInf.ResStr: string;
begin
  case fn of
    tdNone: Result := '';
    tdFn: Result := ': ' + self.Result;
    tdProc: Result := '';
    else Result := '';
  end;
end;

procedure DescInf.SetParams(const Value: string);
var
  rx: TRegEx;
  mc: TMatchCollection;
  i: integer;
begin
  FParams := Value;
  rx := TRegEx.Create('(\w*)[\,\:]', [roIgnoreCase, roMultiLine, roCompiled]);
  mc := rx.Matches(FParams);
  FInParams := '';
  for i := 0 to mc.Count - 1 do
  begin
    FInParams := FInParams + mc.Item[i].Groups.Item[1].Value;
    if i < (mc.Count - 1) then
      FInParams := FInParams + ', ';
  end;
end;

function DescInf.TypeStr: string;
begin
  case fn of
    tdNone: Result := '';
    tdFn: Result := 'function';
    tdProc: Result := 'procedure';
    else Result := '';
  end;
end;

end.
