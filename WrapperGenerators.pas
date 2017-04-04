unit WrapperGenerators;

interface

uses
  DLLList, FuncList;

procedure GenerateAndInsertWrappers(var InputAStr: string; ADList: TDescInfList; ADLLList: TDLLList);

implementation

uses
  System.SysUtils, System.StrUtils, Classes;

procedure AddSysUtils(var InputAStr: string);
var
  i: integer;
begin
  i := Pos('SysUtils', InputAStr);
  if i = 0 then
  begin
    i := Pos('uses' + #13#10, InputAStr);
    if i = 0 then
    begin
      i := Pos('interface' + #13#10, InputAStr);
      if i = 0 then
        raise Exception.Create('Invalid file format')
      else
      begin
        i := PosEx(#13#10, InputAStr, i);
        if i = 0 then
          raise Exception.Create('Invalid file format');
        Insert(#13#10#13#10 + 'uses' + #13#10 + '  SysUtils;' + #13#10, InputAStr, i);
      end;
    end
    else
    begin
      i := PosEx(';' + #13#10, InputAStr, i);
      if i = 0 then
        raise Exception.Create('Invalid file format');
      Insert(', SysUtils', InputAStr, i);
    end;
  end;
end;

procedure AddImplFunctionCheckDLL(var InputAStr: string; ADLLList: TDLLList);
var
  i: integer;
  s, b: string;
begin
  i := Pos('implementation', InputAStr);
  if i = 0 then
    raise Exception.Create('Invalid file format');
  b := '';
  for s in ADLLList do
  begin
    b := b + 'function CheckDLL' + s + ': boolean;' + #13#10;
  end;
  b := b + #13#10;
  Insert(b, InputAStr, i);
end;

function GetStrDLLs(ADLLList: TDLLList): string;
var
  InsData: TStringList;
  t, s: string;
begin
  Result := '';
  InsData := TStringList.Create;
  try
    InsData.Add('');
    InsData.Add('procedure RaiseDllMsg(const AMsg: string);');
    InsData.Add('begin');
    InsData.Add('  raise Exception.Create(''DLL is not found: "'' + AMsg + ''"'');');
    InsData.Add('end;');
    InsData.Add('');
    for t in ADLLList do
    begin
      s := AnsiUpperCase(t);
      InsData.Add('{ ' + s + '.DLL }');
      InsData.Add('');
      InsData.Add('const');
      InsData.Add('  c' + s + ' = ''' + s + '.DLL'';');
      InsData.Add('');
      InsData.Add('var');
      InsData.Add('  h' + s + ': THandle = 0;');
      InsData.Add('');
      InsData.Add('procedure LoadDLL' + s + ';');
      InsData.Add('begin');
      InsData.Add('  if h' + s + ' <> 0 then');
      InsData.Add('    exit;');
      InsData.Add('  h' + s + ' := LoadLibrary(c' + s + ');');
      InsData.Add('  if h' + s + ' = 0 then');
      InsData.Add('    RaiseDllMsg(c' + s + ');');
      InsData.Add('end;');
      InsData.Add('');
      InsData.Add('procedure FreeDLL' + s + ';');
      InsData.Add('begin');
      InsData.Add('  if h' + s + ' <> 0 then');
      InsData.Add('  begin');
      InsData.Add('    FreeLibrary(h' + s + ');');
      InsData.Add('    H' + s + ' := 0;');
      InsData.Add('  end;');
      InsData.Add('end;');
      InsData.Add('');
      InsData.Add('function CheckDLL' + s + ': boolean;');
      InsData.Add('begin');
      InsData.Add('  Result := FileExists(c' + s + ');');
      InsData.Add('end;');
      InsData.Add('');
    end;
    Result := InsData.Text;
  finally
    InsData.Free;
  end;
end;

function GetStrFunctions(ADList: TDescInfList): string;
var
  InsData: TStringList;
  t: DescInf;
begin
  Result := '';
  InsData := TStringList.Create;
  try
    InsData.Add('procedure RaiseMsg(const AMsg: string);');
    InsData.Add('begin');
    InsData.Add('  raise Exception.Create(''Function not found: "'' + AMsg + ''"'');');
    InsData.Add('end;');
    InsData.Add('');
    for t in ADList do
    begin
      InsData.Add('{ ' + t.Name + ' }');
      InsData.Add('');
      InsData.Add('var');
      InsData.Add('  _' + t.Name + ': ' + t.typeStr + '(' + t.Params + ')' + t.resStr + '; stdcall = nil;');
      InsData.Add('');
      InsData.Add(t.replacer);
      InsData.Add('begin');
      InsData.Add('  if not Assigned(_' + t.Name + ') then');
      InsData.Add('  begin');
      InsData.Add('    LoadDLL' + t.dll + ';');
      InsData.Add('    @_' + t.Name + ' := GetProcAddress(H' + t.dll + ', ''' + t.extname + ''');');
      InsData.Add('  end;');
      InsData.Add('  if Assigned(_' + t.Name + ') then');
      if t.fn = tdFn then
        InsData.Add('    Result := _' + t.Name + '(' + t.InParams + ')')
      else
        InsData.Add('    _' + t.Name + '(' + t.InParams + ')');
      InsData.Add('  else');
//      if t.fn = tdFn then InsData.Add('  Result := 0;');
      InsData.Add('    RaiseMsg(''' + t.Name + ''');');
      InsData.Add('end;');
      InsData.Add('');
    end;
    Result := InsData.Text;
  finally
    InsData.Free;
  end;
end;

procedure AddWrappers(var InputAStr: string; ADList: TDescInfList; ADLLList: TDLLList);
var
  s: string;
  n: integer;
begin
  n := Pos('initialization', InputAStr);
  if n = 0 then
    n := Pos('end.', InputAStr);
  if n = 0 then
    Exception.Create('Not found end of implementation section');
  s := GetStrDLLs(ADLLList);
  s := s + GetStrFunctions(ADList);
  Insert(s, InputAStr, n);
end;

procedure AddToFinalization(var InputAStr: string; ADLLList: TDLLList);
var
  s, b: string;
  n: integer;
begin
  b := '';
  n := Pos('finalization', InputAStr);
  if n = 0 then
  begin
    n := Pos('initialization', InputAStr);
    if n = 0 then
      b := 'initialization' + #13#10;
    b := 'finalization' + #13#10;
  end;
  for s in ADLLList do
    b := b + '  FreeDLL' + s + ';' + #13#10;
  b := b + #13#10;
  n := Pos('end.', InputAStr);
  if n = 0 then
    raise Exception.Create('Invalid file format');
  Insert(b, InputAStr, n);
end;

procedure GenerateAndInsertWrappers(var InputAStr: string; ADList: TDescInfList; ADLLList: TDLLList);
begin
  AddSysUtils(InputAStr);
  AddImplFunctionCheckDLL(InputAStr, ADLLList);
  AddWrappers(InputAStr, ADList, ADLLList);
  AddToFinalization(InputAStr, ADLLList);
end;

end.
