unit unit_addprojectform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, unit_tfllproject;

type
  { TFormAddProject }

  TFormAddProject = class(TForm)
    ButtonSelectProject: TButton;
    ButtonCancelProject: TButton;
    ButtonSaveProject: TButton;
    ComboBoxEngines: TComboBox;
    EditProjectName: TEdit;
    EditProjectPath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialogProjectFile: TOpenDialog;
    OpenDialogProject: TSelectDirectoryDialog;
    procedure ButtonSelectProjectClick(Sender: TObject);
    procedure ButtonCancelProjectClick(Sender: TObject);
    procedure ButtonSaveProjectClick(Sender: TObject);
  private

  public
    IsNewProject: Boolean;

  end;

var
  FormAddProject: TFormAddProject;

implementation

{$R *.lfm}

{ TFormAddProject }

procedure TFormAddProject.ButtonSaveProjectClick(Sender: TObject);
begin
  { Make sure we have the required data then close the form if we do }
  if Length(EditProjectName.Text) < 1 then
  begin
    ShowMessage('A Project Name, Path and Engine are required');
    EditProjectName.SelectAll;
    EditProjectName.SetFocus;
    Exit;
  end;

  if Length(EditProjectPath.Text) < 1 then
  begin
    ShowMessage('A Project Name, Path and Engine are required');
    Exit;
  end;

  if ComboBoxEngines.ItemIndex < 0 then
  begin
    ShowMessage('A Project Name, Path and Engine are required');
    ComboBoxEngines.SetFocus;
    Exit
  end;

  ModalResult := mrOK;
end;

procedure TFormAddProject.ButtonSelectProjectClick(Sender: TObject);
begin
  if IsNewProject then
    begin
      if OpenDialogProject.Execute then
      begin
        { They selected a path, so set the data appropriately }
        EditProjectPath.Text := OpenDialogProject.FileName;
      end
    end
  else
    begin
      if OpenDialogProjectFile.Execute then
      begin
        { They selected a path, so set the data appropriately }
        EditProjectPath.Text := OpenDialogProjectFile.FileName;
      end
    end;
end;

procedure TFormAddProject.ButtonCancelProjectClick(Sender: TObject);
begin
  { Close the window without doing anything }
  ModalResult := mrCancel;
end;

end.

