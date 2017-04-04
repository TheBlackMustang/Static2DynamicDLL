program static2dynamic;

uses
  System.SysUtils,
  System.Generics.Collections,
  PatternsCollection in 'PatternsCollection.pas',
  FuncList in 'FuncList.pas',
  DLLList in 'DLLList.pas',
  WrapperGenerators in 'WrapperGenerators.pas',
  IO in 'IO.pas';

var
  FilenameInput: string;
  FilenameOutput: string;
  Data: string;
  DLLList: TDLLList;
  FuncList: TDescInfList;
begin
  DLLList := TDLLList.Create;
  FuncList := TList<DescInf>.Create;
  try
    ParseCMDLine(FilenameInput, FilenameOutput);
    Data := ReadFileToString(FilenameInput);
    ApplyPatternsAndGetLists(Data, FuncList, DLLList);
    if DLLList.Count = 0 then
      raise Exception.Create('Static linked DLL is absent');
    GenerateAndInsertWrappers(Data, FuncList, DLLList);
    WriteStringToFile(Data, FilenameOutput);
  finally
    FuncList.Free;
    DLLList.Free;
  end;
end.
