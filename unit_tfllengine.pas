unit unit_tfllengine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, unit_tfllbase;

type
  { TFLLEngine Pointer }

  PTFLLEngine = ^TFLLEngine;

  { TFLLEngine }

  TFLLEngine = class(TFLLBase)
    private
      //FID: integer;
      FEngineName: string;
      FEnginePath: string;

      //procedure SetID(const value: Integer);
      procedure SetEngineName(const value: string);
      procedure SetEnginePath(const value: string);

    public
      constructor Create(const DBID: Integer; const EngineName: string; const EnginePath: string);

      //property ID: Integer read FID write SetID;
      property EngineName: string read FEngineName write SetEngineName;
      property EnginePath: string read FEnginePath write SetEnginePath;

      function ToString: string;
  end;

implementation

constructor TFLLEngine.Create(const DBID: Integer; const EngineName: string; const EnginePath: string);
begin
  FID := DBID;
  FEngineName := EngineName;
  FEnginePath := EnginePath;
end;

{procedure TFLLEngine.SetID(const value: Integer);
begin
  if FID <> value then
     FID := value;

end;}

procedure TFLLEngine.SetEngineName(const value: string);
begin
  if FEngineName <> value then
     FEngineName := value;
end;

procedure TFLLEngine.SetEnginePath(const value: string);
begin
  if FEnginePath <> value then
     FEnginePath := value;
end;

function TFLLEngine.ToString: string;
begin
  Result := Format('%s (%s)', [EngineName, EnginePath])
end;

end.

