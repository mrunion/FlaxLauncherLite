unit unit_addengineform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, unit_tfllengine;

type
  { TFormAddEngine }

  TFormAddEngine = class(TForm)
    ButtonSelectEngine: TButton;
    ButtonCancelEngine: TButton;
    ButtonSaveEngine: TButton;
    EditEnginePath: TEdit;
    EditEngineName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialogEngine: TOpenDialog;
    procedure ButtonCancelEngineClick(Sender: TObject);
    procedure ButtonSaveEngineClick(Sender: TObject);
    procedure ButtonSelectEngineClick(Sender: TObject);
  private

  public

  end;

var
  FormAddEngine: TFormAddEngine;

implementation

{$R *.lfm}

{ TFormAddEngine }

procedure TFormAddEngine.ButtonSaveEngineClick(Sender: TObject);
begin
  { Make sure we have the required data and then close the form if we do }
  if Length(EditEngineName.Text) < 1 then
  begin
    ShowMessage('An engine name and path are required');
    EditEngineName.SelectAll;
    EditEngineName.SetFocus;
    Exit;
  end;

  if Length(EditEnginePath.Text) < 1 then
  begin
    ShowMessage('An engine name and path are required');
    Exit;
  end;

  ModalResult := mrOK;
end;

procedure TFormAddEngine.ButtonSelectEngineClick(Sender: TObject);
begin
  { Open the file chooser so the user can pick an engine }
  OpenDialogEngine.FileName := '';

  if OpenDialogEngine.Execute then
  begin
    { They selected an engine, so set the data appropriately }
    EditEnginePath.Text := OpenDialogEngine.FileName;
  end;
end;

procedure TFormAddEngine.ButtonCancelEngineClick(Sender: TObject);
begin
  { Close the window without doing anything }
  ModalResult := mrCancel;
end;

end.

