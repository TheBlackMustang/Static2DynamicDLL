unit PatternsCollection;

interface

uses
  FuncList, DLLList;

procedure ApplyPatternsAndGetLists(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);

implementation

uses
  System.RegularExpressions;

procedure FunctionWithParameters(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);
var
  rx, rp: TRegEx;
  rs1, rs2: string;
  mc: TMatchCollection;
  gc: TGroupCollection;
  i: integer;
  t: DescInf;
begin
  rs1 := '^(.*)function\s(\w*)\(([a-zA-Z\:\;\=\/à-ÿÀ-ß\,0-9\(\)_\/\<\+\-\%\*\\\=\!\>\~\|\&\^\[\]\{\}\.\s]*)\)([a-zA-Z\:\;\=\/à-ÿÀ-ß\,0-9\(\)_\/\<\+\-\%\*\\\=\!\>\~\|\&\^\[\]\{\}\.\s]*)\:\s*(\w*)\;\s*stdcall;\s*external\s*\''(\w*)\.dll\''\s*name\s*\''(.*)\''(.*)';
  rs2 := '$1function $2($3): $5$8 $4';
  rx := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  rp := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  mc := rx.Matches(InputStr);
  for i := 0 to mc.Count - 1 do
  begin
    t.Reset;
    gc := mc.Item[i].Groups;
    t.fullStr := gc.Item[0].Value;
    t.fn := tdFn;
    t.Start := gc.Item[1].Value;
    t.Name := gc.Item[2].Value;
    t.Params := gc.Item[3].Value;
    t.CommentRes := gc.Item[4].Value;
    t.Result := gc.Item[5].Value;
    t.DLL := gc.Item[6].Value;
    t.ExtName := gc.Item[7].Value;
    t.Tail := gc.Item[8].Value;
    t.Replacer := rp.Replace(t.fullStr, rs2);
    ADList.Add(t);
    ADLLList.AddUniq(t.DLL);
  end;
  InputStr := rx.Replace(InputStr, rs2);
end;

procedure FunctionWithoutParametersAndWithBrace(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);
var
  rx, rp: TRegEx;
  rs1, rs2: string;
  mc: TMatchCollection;
  gc: TGroupCollection;
  i: integer;
  t: DescInf;
begin
  rs1 := '^(.*)function\s(\w*)[\w\s]*\:\s*(\w*)\;\s*stdcall;\s*external\s*\''(\w*)\.dll\''\s*name\s*\''(.*)\''(.*)';
  rs2 := '$1function $2: $3;';
  rx := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  rp := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  mc := rx.Matches(InputStr);
  for i := 0 to mc.Count - 1 do
  begin
    t.Reset;
    gc := mc.Item[i].Groups;
    t.fullStr := gc.Item[0].Value;
    t.fn := tdFn;
    t.Start := gc.Item[1].Value;
    t.Name := gc.Item[2].Value;
    t.Params := '';
    t.Result := gc.Item[3].Value;
    t.DLL := gc.Item[4].Value;
    t.ExtName := gc.Item[5].Value;
    t.Tail := gc.Item[6].Value;
    t.Replacer := rp.Replace(t.fullStr, rs2);
    ADList.Add(t);
    ADLLList.AddUniq(t.DLL);
  end;
  InputStr := rx.Replace(InputStr, rs2);
end;

procedure FunctionWithoutParametersAndWithoutBrace(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);
var
  rx, rp: TRegEx;
  rs1, rs2: string;
  mc: TMatchCollection;
  gc: TGroupCollection;
  i: integer;
  t: DescInf;
begin
  rs1 := '^(.*)function\s(\w*)\(\s*\)\:\s*(\w*)\;\s*stdcall;\s*external\s*\''(\w*)\.dll\''\s*name\s*\''(.*)\''(.*)';
  rs2 := '$1function $2(): $3;';
  rx := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  rp := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  mc := rx.Matches(InputStr);
  for i := 0 to mc.Count - 1 do
  begin
    t.Reset;
    gc := mc.Item[i].Groups;
    t.fullStr := gc.Item[0].Value;
    t.fn := tdFn;
    t.Start := gc.Item[1].Value;
    t.Name := gc.Item[2].Value;
    t.Params := '';
    t.Result := gc.Item[3].Value;
    t.DLL := gc.Item[4].Value;
    t.ExtName := gc.Item[5].Value;
    t.Tail := gc.Item[6].Value;
    t.Replacer := rp.Replace(t.fullStr, rs2);
    ADList.Add(t);
    ADLLList.AddUniq(t.DLL);
  end;
  InputStr := rx.Replace(InputStr, rs2);
end;

procedure ProcedureWithParameters(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);
var
  rx, rp: TRegEx;
  rs1, rs2: string;
  mc: TMatchCollection;
  gc: TGroupCollection;
  i: integer;
  t: DescInf;
begin
  rs1 := '^(.*)procedure\s(\w*)\(([a-zA-Z\:\;\=\/à-ÿÀ-ß\,0-9\(\)_\/\<\+\-\%\*\\\=\!\>\~\|\&\^\[\]\{\}\.\s]*)\)\;\s*stdcall;\s*external\s*\''(\w*)\.dll\''\s*name\s*\''(.*)\''(.*)';
  rs2 := '$1procedure $2($3);';
  rx := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  rp := TRegEx.Create(rs1, [roIgnoreCase, roMultiLine, roCompiled]);
  mc := rx.Matches(InputStr);
  for i := 0 to mc.Count - 1 do
  begin
    t.Reset;
    gc := mc.Item[i].Groups;
    t.fullStr := gc.Item[0].Value;
    t.fn := tdProc;
    t.Start := gc.Item[1].Value;
    t.Name := gc.Item[2].Value;
    t.Params := gc.Item[3].Value;
    t.Result := '';
    t.DLL := gc.Item[4].Value;
    t.ExtName := gc.Item[5].Value;
    t.Tail := gc.Item[6].Value;
    t.Replacer := rp.Replace(t.fullStr, rs2);
    ADList.Add(t);
    ADLLList.AddUniq(t.DLL);
  end;
  InputStr := rx.Replace(InputStr, rs2);
end;

procedure ApplyPatternsAndGetLists(var InputStr: string; ADList: TDescInfList; ADLLList: TDLLList);
begin
  FunctionWithParameters(InputStr, ADList, ADLLList);
  FunctionWithoutParametersAndWithBrace(InputStr, ADList, ADLLList);
  FunctionWithoutParametersAndWithoutBrace(InputStr, ADList, ADLLList);
  ProcedureWithParameters(InputStr, ADList, ADLLList);
end;

end.
