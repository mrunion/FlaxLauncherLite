program flaxlauncherlite;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unit_mainform, unit_addengineform, unit_tfllengine, unit_tfllproject,
  unit_addprojectform, unit_tfllbase
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title := 'Flax Launcher Lite';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormAddEngine, FormAddEngine);
  Application.CreateForm(TFormAddProject, FormAddProject);
  Application.Run;
end.

