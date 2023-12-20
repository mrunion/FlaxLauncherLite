unit unit_about;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, LResources;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    ButtonClose: TButton;
    ImageFLLLogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelDBInUse: TLabel;
    procedure ButtonCloseClick(Sender: TObject);
    procedure Create(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.Create(Sender: TObject);
begin
  { Load the image for the logo }
  ImageFLLLogo.Picture.LoadFromLazarusResource('FLLIcon_512x512');
end;

procedure TFormAbout.ButtonCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

initialization
  // .LRS files are plain-text pascal statements and need unit LResources to be included in the Uses clause
  {$I flaxlauncherlite.lrs}

end.

