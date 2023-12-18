unit unit_tfllbase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TFLLBase Pointer }

  PTFLLBase = ^TFLLBase;

  { TFLLBase }

  TFLLBase = class
    protected
      FID: Integer;

      procedure SetID(const value: Integer);

    public
      constructor Create(const ID: Integer);

      property ID: Integer read FID write SetID;
  end;

implementation

constructor TFLLBase.Create(const ID: Integer);
begin
  FID := ID;
end;

procedure TFLLBase.SetID(const value: Integer);
begin
  if FID <> value then
     FID := value;

end;

end.

