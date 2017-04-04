unit DLLList;

interface

uses
  System.Generics.Collections;

type

  TDLLList = class(TList<string>)
    procedure AddUniq(const AName: string);
  end;

implementation

uses
  System.SysUtils;

procedure TDLLList.AddUniq(const AName: string);
var
  s: string;
  i: Integer;
begin
  s := AnsiUpperCase(AName);
  i := IndexOf(s);
  if i = -1 then
    Add(s);
end;

end.
