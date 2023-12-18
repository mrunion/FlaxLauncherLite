unit unit_tfllproject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, unit_tfllbase, unit_tfllengine;

type
  { TFLLProject Pointer }

  PTFLLProject = ^TFLLProject;

  { TFLLProject }

  TFLLProject = class(TFLLBase)
    private
      FProjectName: string;
      FProjectPath: string;
      //FEngine: PTFLLEngine;
      FEngine: TFLLEngine;

      procedure SetProjectName(const value: string);
      procedure SetProjectPath(const value: string);
      procedure SetEngine(const value: TFLLEngine);

    public
      constructor Create(const DBID: Integer; const ProjectName: string; const ProjectPath: string; const Engine: TFLLEngine);

      property ProjectName: string read FProjectName write SetProjectName;
      property ProjectPath: string read FProjectPath write SetProjectPath;
      property Engine: TFLLEngine read FEngine write SetEngine;

      function ToString: string;
  end;

implementation

constructor TFLLPRoject.Create(const DBID: Integer; const ProjectName: string; const ProjectPath: string; const Engine: TFLLEngine);
begin
  FID := DBID;
  FProjectName := ProjectName;
  FProjectPath := ProjectPath;
  FEngine := Engine;
end;

procedure TFLLPRoject.SetProjectName(const value: string);
begin
  if FProjectNAme <> value then
     FProjectName := value;
end;

procedure TFLLPRoject.SetProjectPath(const value: string);
begin
  if FProjectPath <> value then
     FProjectPath := value;
end;

procedure TFLLPRoject.SetEngine(const value: TFLLEngine);
begin
  if FEngine <> value then
     FEngine := value;
end;

function TFLLProject.ToString: string;
begin
  Result := Format('%s (%s) Uses Engine %s',
                   [ProjectName, ProjectPath,
                   FEngine.ToString]);
end;

end.

