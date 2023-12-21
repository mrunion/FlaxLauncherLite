unit unit_mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, SQLite3Conn, SQLDB, DB, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, Menus, DBCtrls, ExtCtrls, ActnList,
  StdActns, Generics.Collections, Generics.Defaults, Process,
  unit_addengineform, unit_addprojectform, unit_tfllbase, unit_tfllengine,
  unit_tfllproject, unit_about;

type
  { Engine and Project object lists }
  EngineTObjectList = specialize TObjectList<TFLLEngine>;
  ProjectTObjectList = specialize TObjectList<TFLLProject>;

  { TFLLPanel }
  TFLLPanel = class(TPanel)
    public
      EngineID: Integer;
      ProjectID: Integer;
      Constructor Create(AOwner : TComponent); override;
  end;

  { TFormMain }

  TFormMain = class(TForm)
    AAbout: TAction;
    AExit: TAction;
    ActionListMain: TActionList;
    ButtonAbout: TButton;
    ButtonExit: TButton;
    FlowPanelEngines: TFlowPanel;
    FlowPanelProjects: TFlowPanel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemAddEngine2: TMenuItem;
    MenuItemImportProject2: TMenuItem;
    MenuItemNewProject2: TMenuItem;
    MenuItemRemoveEngine: TMenuItem;
    MenuItemLaunchProject: TMenuItem;
    MenuItemRemoveProject: TMenuItem;
    MenuItemAddEngine: TMenuItem;
    MenuItemNewProject: TMenuItem;
    MenuItemImportProject: TMenuItem;
    PageControl: TPageControl;
    PopupMenuProject: TPopupMenu;
    PopupMenuEngine: TPopupMenu;
    PopupMenuEnginesFlowPanel: TPopupMenu;
    PopupMenuProjectsFlowPanel: TPopupMenu;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    TabSheetProjects: TTabSheet;
    TabSheetEngines: TTabSheet;
    procedure AboutClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItemAddEngine2Click(Sender: TObject);
    procedure MenuItemImportProject2Click(Sender: TObject);
    procedure MenuItemNewProject2Click(Sender: TObject);
    procedure MenuItemRemoveEngineClick(Sender: TObject);
    procedure MenuItemLaunchProjectClick(Sender: TObject);
    procedure MenuItemRemoveProjectClick(Sender: TObject);
    procedure MenuItemAddEngineClick(Sender: TObject);
    procedure MenuItemImportProjectClick(Sender: TObject);
    procedure MenuItemNewProjectClick(Sender: TObject);
  private
    procedure CreateFLLDB;
    procedure LoadEngines;
    procedure LoadProjects;
    procedure SaveEngine(engine: TFLLEngine);
    procedure SaveProject(project: TFLLProject);

    procedure CreateEnginesGUI;
    procedure CreateProjectsGUI;
    function CreatePanelGUI(const isProject: Boolean; const itemID: Integer; const itemLabel: String; const itemHint: String; const TheParent: TComponent; const imageResourceName: String = 'lazarus'): TFLLPanel;
  private
    EngineList : EngineTObjectList;
    PRojectList : ProjectTObjectList;

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFLLPanel }

Constructor TFLLPanel.Create(AOwner : TComponent);
begin
  inherited;
end;

{ TFormMain }

procedure TFormMain.ButtonExitClick(Sender: TObject);
begin
  { Close the application }
  Close;
end;

procedure TFormMain.AboutClick(Sender: TObject);
begin
  { Show the about dialog as a modal }
  FormAbout.LabelDBInUse.Caption := 'Using DB: ' + SQLite3Connection1.DatabaseName;
  FormAbout.ShowModal;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  { Create the objects we need to have available }
  EngineList := EngineTObjectList.Create;
  PRojectList := ProjectTObjectList.Create;

  { Call the database creation procedure to set up the DB }
  CreateFLLDB;

  { Load the engines and projects }
  LoadEngines;
  LoadProjects;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  { Free any resources }
  EngineList.Free;
  ProjectList.Free;

  SQLite3Connection1.Close;
  SQLQuery1.Free;
  SQLTransaction1.Free;
  SQLite3Connection1.Free;
end;

procedure TFormMain.MenuItemAddEngine2Click(Sender: TObject);
begin
  MenuItemAddEngineClick(Sender);
end;

procedure TFormMain.MenuItemImportProject2Click(Sender: TObject);
begin
  MenuItemImportProjectClick(Sender);
end;

procedure TFormMain.MenuItemNewProject2Click(Sender: TObject);
begin
  MenuItemNewProjectClick(Sender);
end;

procedure TFormMain.MenuItemRemoveEngineClick(Sender: TObject);
var
  engine: TFLLEngine;
  engineInUse: Boolean;
begin
  { Find the engine this item is referencing }
  for engine in EngineList do
  begin
    if engine.ID = TFLLPanel(PopupMenuEngine.PopupComponent).EngineID then
      begin
        { First see if the engine is being referenced }
        SQLQuery1.Close;

        SQLQuery1.SQL.Text := 'SELECT COUNT(*) FROM projects WHERE engine_id = :ENGINEID;';
        SQLQuery1.Params.ParamByName('ENGINEID').AsInteger := engine.ID;

        SQLTransaction1.Active := True;
        SQLQuery1.Open;

        engineInUse := False;
        while not SQLQuery1.EOF do
          begin
            if SQLQuery1.Fields[0].AsInteger > 0 then
              engineInUse := True;

            SQLQuery1.Next;
          end;
        SQLTransaction1.Commit;

        if engineInUse then
          begin
            ShowMessage('Selected Engine is in use by Projects and cannot be deleted');
            Exit;
          end;

        { Remove the engine info from the database }
        SQLQuery1.Close;

        SQLQuery1.SQL.Text := 'DELETE FROM engines WHERE id = :ID;';
        SQLQuery1.Params.ParamByName('ID').AsInteger := engine.ID;

        SQLTransaction1.Active := True;
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;

        { Remove the control for this engine }
        TFLLPanel(FlowPanelEngines.FindChildControl('TFLLPanelEngine' + StringReplace(engine.EngineName, ' ', '', [rfReplaceAll]))).Destroy;

        LoadEngines;
        Exit;
      end;
  end;
end;

procedure TFormMain.MenuItemLaunchProjectClick(Sender: TObject);
var
  process: TProcess;
  project: TFLLProject;
begin
  { Find the project this item is referencing }
  for project in ProjectList do
  begin
    if project.ID = TFLLPanel(PopupMenuProject.PopupComponent).ProjectID then
      begin
        { Execute the command to launch the project }
        process := TProcess.Create(nil);
        process.Executable := project.Engine.EnginePath;
        process.Parameters.Add('-project ' + project.ProjectPath);
        process.Execute;
        process.Free;
        Exit;
      end;
  end;
end;

procedure TFormMain.MenuItemRemoveProjectClick(Sender: TObject);
var
  project: TFLLProject;
begin
  { Find the project this item is referencing }
  for project in ProjectList do
  begin
    if project.ID = TFLLPanel(PopupMenuProject.PopupComponent).ProjectID then
      begin
        { Remove the project info from the database }
        SQLQuery1.Close;

        SQLQuery1.SQL.Text := 'DELETE FROM projects WHERE id = :ID;';
        SQLQuery1.Params.ParamByName('ID').AsInteger := project.ID;

        SQLTransaction1.Active := True;
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;

        { Remove the control for this project }
        TFLLPanel(FlowPanelProjects.FindChildControl('TFLLPanelProject' + StringReplace(project.ProjectName, ' ', '', [rfReplaceAll]))).Destroy;

        LoadProjects;
        Exit;
      end;
  end;
end;

procedure TFormMain.MenuItemAddEngineClick(Sender: TObject);
var
  item: TFLLEngine;
begin
  { Clear the form fields }
  FormAddEngine.EditEngineName.Text := '';
  FormAddEngine.EditEnginePath.Text := '';

  if FormAddEngine.ShowModal = mrOK then
  begin
    { Save the engine definition in the database }
    item := TFLLEngine.Create(-1, FormAddEngine.EditEngineName.Text, FormAddEngine.EditEnginePath.Text);
    SaveEngine(item);
  end;
end;

procedure TFormMain.MenuItemImportProjectClick(Sender: TObject);
var
  item: TFLLProject;
  engine: TFLLEngine;
begin
  { Clear the form fields }
  FormAddProject.EditProjectName.Text := '';
  FormAddProject.EditProjectPath.Text := '';
  FormAddProject.IsNewProject := False;

  { Fill the list of engines on the project form }
  FormAddProject.ComboBoxEngines.Items.Clear;
  for engine in EngineList do
  begin
    FormAddProject.ComboBoxEngines.Items.AddObject(engine.ToString, engine);
  end;

  if FormAddProject.ShowModal = mrOK then
  begin
    { Save the project definition in the database }
    engine :=TFLLEngine(FormAddProject.ComboBoxEngines.Items.Objects[FormAddProject.ComboBoxEngines.ItemIndex]);
    item := TFLLProject.Create(-1, FormAddProject.EditProjectName.Text, FormAddProject.EditProjectPath.Text, engine);
    SaveProject(item);
  end;
end;

procedure TFormMain.MenuItemNewProjectClick(Sender: TObject);
var
  process: TProcess;
  project: TFLLProject;
  engine: TFLLEngine;
begin

  { Clear the form fields }
  FormAddProject.EditProjectName.Text := '';
  FormAddProject.EditProjectPath.Text := '';
  FormAddProject.IsNewProject := True;

  { Fill the list of engines on the project form }
  FormAddProject.ComboBoxEngines.Items.Clear;
  for engine in EngineList do
  begin
    FormAddProject.ComboBoxEngines.Items.AddObject(engine.ToString, engine);
  end;

  if FormAddProject.ShowModal = mrOK then
  begin
    { Save the project definition in the database }
    engine :=TFLLEngine(FormAddProject.ComboBoxEngines.Items.Objects[FormAddProject.ComboBoxEngines.ItemIndex]);
    project := TFLLProject.Create(-1, FormAddProject.EditProjectName.Text, FormAddProject.EditProjectPath.Text + '/' + FormAddProject.EditProjectName.Text + '/' + FormAddProject.EditProjectName.Text + '.flaxproj', engine);
    SaveProject(project);

    { Now execute Flax to create the actual project on disk }
    process := TProcess.Create(nil);
    process.Executable := project.Engine.EnginePath;
    process.Parameters.Add('-new');
    process.Parameters.Add('-project ' + FormAddProject.EditProjectPath.Text + '/' + FormAddProject.EditProjectName.Text);
    process.Execute;
    process.Free;
  end;
end;

procedure TFormMain.LoadEngines;
begin
  { Query all the engines from the database and load them in the GUI }
  EngineList.Clear;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'SELECT id, engine_name, engine_path FROM engines ORDER BY engine_name;';
  SQLQuery1.Open;

  while not SQLQuery1.EOF do
  begin
    EngineList.Add(TFLLEngine.Create(SQLQuery1.Fields[0].AsInteger, SQLQuery1.Fields[1].AsString, SQLQuery1.Fields[2].AsString));
    SQLQuery1.Next;
  end;

  { Create the GUI for the engine list }
  CreateEnginesGUI;

  SQLQuery1.Close;
  SQLTransaction1.Commit;
end;

procedure TFormMain.LoadProjects;
var
  idx: SizeInt;
  engine: TFLLEngine;
  project: TFLLProject;
begin
  { Query all the projects from the database and load them in the GUI }
  ProjectList.Clear;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'SELECT p.id, p.project_name, p.project_path, p.engine_id, e.engine_name, e.engine_path FROM projects AS p LEFT JOIN engines AS e ON e.id = p.engine_id ORDER BY project_name;';
  SQLQuery1.Open;

  while not SQLQuery1.EOF do
  begin
    { Find the engine this project uses and get a reference to it }
    for idx := 0 to EngineList.Count - 1 do
    begin
      if EngineList.Items[idx].ID = SQLQuery1.Fields[3].AsInteger then
         engine := EngineList.Items[idx];
    end;

    project := TFLLProject.Create(SQLQuery1.Fields[0].AsInteger, SQLQuery1.Fields[1].AsString, SQLQuery1.Fields[2].AsString, engine);
    ProjectList.Add(project);

    SQLQuery1.Next;
  end;

  { Create the GUI for the project list }
  CreateProjectsGUI;

  SQLQuery1.Close;
  SQLTransaction1.Commit;
end;

procedure TFormMain.CreateFLLDB;
var createTables: Boolean;
begin
  {$IFDEF UNIX} // Linux
    {$IFNDEF DARWIN}
      //SQLiteLibraryName := 'libsqlite3.so';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF WINDOWS} // Windows
    //SQLiteLibraryName := 'sqlite3.dll';
  {$ENDIF}

  SQLite3Connection1.DatabaseName := GetAppConfigDir(false) + 'fll.db';

  { Check if the DB exists and if not create it }
  if not DirectoryExists(GetAppConfigDir(false)) then
    MkDir(GetAppConfigDir(false));

  { See if the database file exists and if not create it and the tables }
  createTables := not FileExists(SQLite3Connection1.DatabaseName);

  SQLite3Connection1.Open;
  SQLTransaction1.Active := True;

  { Create the tables if we need to }
  if createTables then
    begin
      // Create appinfo table
      SQLite3Connection1.ExecuteDirect('CREATE TABLE "appinfo"(' +
                                               ' "version" Text NOT NULL);');
      SQLTransaction1.Commit;

      SQLite3Connection1.ExecuteDirect('INSERT INTO "appinfo" VALUES("1");');
      SQLTransaction1.Commit;

      // Create the engines table
      SQLite3Connection1.ExecuteDirect('CREATE TABLE "engines"(' +
                                               ' "id" Integer NOT NULL PRIMARY KEY,' +
                                               ' "engine_name" Text NOT NULL,' +
                                               ' "engine_path" Text NOT NULL);');
      SQLite3Connection1.ExecuteDirect('CREATE INDEX "engines_engine_name_idx" ON "engines"("engine_name");');
      SQLite3Connection1.ExecuteDirect('CREATE UNIQUE INDEX "engines_idx" ON "engines"("id");');
      SQLTransaction1.Commit;

      // Create the projects table
      SQLite3Connection1.ExecuteDirect('CREATE TABLE "projects"(' +
                                               ' "id" Integer NOT NULL PRIMARY KEY,' +
                                               ' "project_name" Text NOT NULL,' +
                                               ' "project_path" Text NOT NULL,' +
                                               ' "engine_id" Integer,' +
                                               ' CONSTRAINT "fk_engines"' +
                                               ' FOREIGN KEY ("engine_id") REFERENCES "engines"("id"));');
      SQLite3Connection1.ExecuteDirect('CREATE INDEX "projects_project_name_idx" ON "projects"("project_name");');
      SQLite3Connection1.ExecuteDirect('CREATE UNIQUE INDEX "projects_idx" ON "projects"("id");');
      SQLTransaction1.Commit;

    end;
end;

procedure TFormMain.SaveEngine(engine: TFLLEngine);
begin
  { Save the engine info in the database }
  SQLQuery1.Close;

  { If this is a new item we don't use the ID field }
  if engine.ID = -1 then
    begin
      SQLQuery1.SQL.Text := 'INSERT INTO engines (engine_name, engine_path) VALUES(:ENGINENAME, :ENGINEPATH);';
    end
  else
     begin
       SQLQuery1.SQL.Text := 'INSERT INTO engines VALUES(:ID, :ENGINENAME, :ENGINEPATH);';
       SQLQuery1.Params.ParamByName('ID').AsInteger := engine.ID;
     end;

  SQLQuery1.Params.ParamByName('ENGINENAME').AsString := engine.EngineName;
  SQLQuery1.Params.ParamByName('ENGINEPATH').AsString := engine.EnginePath;

  SQLTransaction1.Active := True;
  SQLQuery1.ExecSQL;
  SQLTransaction1.Commit;

  LoadEngines;
end;

procedure TFormMain.SaveProject(project: TFLLProject);
begin
  { Save the project info in the database }
  SQLQuery1.Close;

  { If this is a new item we don't use the ID field }
  if project.ID = -1 then
    begin
      SQLQuery1.SQL.Text := 'INSERT INTO projects (project_name, project_path, engine_id) VALUES (:PROJECTNAME, :PROJECTPATH, :ENGINEID);';
    end
  else
    begin
      SQLQuery1.SQL.Text := 'INSERT INTO projects VALUES (:ID, :PROJECTNAME, :PROJECTPATH, :ENGINEID);';
      SQLQuery1.Params.ParamByName('ID').AsInteger := project.ID;
    end;

  SQLQuery1.Params.ParamByName('PROJECTNAME').AsString := project.ProjectName;
  SQLQuery1.Params.ParamByName('PROJECTPATH').AsString := project.ProjectPath;
  SQLQuery1.Params.ParamByName('ENGINEID').AsInteger := project.Engine.ID;

  SQLTransaction1.Active := True;
  SQLQuery1.ExecSQL;
  SQLTransaction1.Commit;

  LoadProjects;
end;

procedure TFormMain.CreateEnginesGUI;
var
  engine: TFLLEngine;
  panel: TFLLPanel;
begin
  { Loop through the list of projects and create the GUI representation }
  for engine in EngineList do
  begin
    panel := FlowPanelEngines.FindChildControl('TFLLPanelEngine' + StringReplace(engine.EngineName, ' ', '', [rfReplaceAll])) as TFLLPanel;
    if panel <> nil then
      begin
        panel.Destroy;
      end;

    CreatePanelGUI(False, engine.ID, engine.EngineName, engine.ToString, FlowPanelEngines, 'FLLEngineIcon_128x128').Parent := FlowPanelEngines;
  end;
end;

procedure TFormMain.CreateProjectsGUI;
var
  project: TFLLProject;
  panel: TFLLPanel;
begin
  { Loop through the list of projects and create the GUI representation }
  for project in ProjectList do
  begin
    panel := FlowPanelProjects.FindChildControl('TFLLPanelProject' + StringReplace(project.ProjectName, ' ', '', [rfReplaceAll])) as TFLLPanel;
    if panel <> nil then
      begin
        panel.Destroy;
      end;

    CreatePanelGUI(True, project.ID, project.ProjectName, project.ToString, FlowPanelProjects, 'FLLProjectIcon_128x128').Parent := FlowPanelProjects;
  end;
end;

function TFormMain.CreatePanelGUI(const isProject: Boolean; const itemID: Integer; const itemLabel: String; const itemHint: String; const TheParent: TComponent; const imageResourceName: String = 'lazarus'): TFLLPanel;
var
  panelCtl: TFLLPanel;
  imageCtl: TImage;
  textCtl: TLabel;
begin
  { Create a panel that contains the visual representation of this item }
  panelCtl := TFLLPanel.Create(TheParent);
  panelCtl.Height := 120;
  panelCtl.Width := 140;
  panelCtl.Tag := itemID;

  { See which property to set and popup to add based on whether this is an Engine or Project item }
  if isProject then
    begin
      panelCtl.PopupMenu := PopupMenuProject;
      panelCtl.ProjectID := itemID;
      panelCtl.EngineID := 0;
      panelCtl.Name := 'TFLLPanelProject' + StringReplace(itemLabel, ' ', '', [rfReplaceAll]);
    end
  else
    begin
      panelCtl.PopupMenu := PopupMenuEngine;
      panelCtl.ProjectID := 0;
      panelCtl.EngineID := itemID;
      panelCtl.Name := 'TFLLPanelEngine' + StringReplace(itemLabel, ' ', '', [rfReplaceAll]);
    end;

  panelCtl.Caption := '';

  imageCtl := TImage.Create(panelCtl);
  imageCtl.Picture.LoadFromLazarusResource(imageResourceName);
  imageCtl.Hint := itemHint;
  imageCtl.ShowHint := True;
  imageCtl.Height := 64;
  imageCtl.Width := 64;
  imageCtl.Left := 40;
  imageCtl.Top := 8;
  imageCtl.Center := True;
  imageCtl.Stretch := True;
  imageCtl.Transparent := True;
  imageCtl.Parent := panelCtl;
  imageCtl.Tag := itemID;

  textCtl := TLabel.Create(panelCtl);
  textCtl.Caption := itemLabel;
  textCtl.Height := 32;
  textCtl.Width := 119;
  textCtl.Left := 8;
  textCtl.Top := 80;
  textCtl.Constraints.MinHeight := 32;
  textCtl.Constraints.MinWidth := 119;
  textCtl.Alignment := TAlignment.taCenter;
  textCtl.Layout := TTextLayout.tlCenter;
  textCtl.Parent := panelCtl;
  textCtl.Tag := itemID;

  Result := panelCtl;
end;

initialization
  // .LRS files are plain-text pascal statements and need unit LResources to be included in the Uses clause
  {$I flaxlauncherlite.lrs}

end.

