unit IO;

interface

procedure ParseCMDLine(out FilenameInput: string; out FilenameOutput: string);
function ReadFileToString(const AFilename: string): string;
procedure WriteStringToFile(const AStr: string; const AFilename: string);

implementation

uses
  Classes, SysUtils;

procedure ParseCMDLine(out FilenameInput: string; out FilenameOutput: string);
begin
  if ParamCount <> 2 then
    raise Exception.Create('Input parameters is bad');
  FilenameInput := ParamStr(1);
  FilenameOutput := ParamStr(2);
end;

function ReadFileToString(const AFilename: string): string;
var
  fl: TStringList;
begin
  fl := TStringList.Create;
  try
    fl.LoadFromFile(AFilename);
    Result := fl.Text;
  finally
    fl.Free;
  end;
end;

procedure WriteStringToFile(const AStr: string; const AFilename: string);
var
  fl: TStringList;
begin
  fl := TStringList.Create;
  try
    fl.Text := AStr;
    fl.SaveToFile(AFilename);
  finally
    fl.Free;
  end;
end;

end.
