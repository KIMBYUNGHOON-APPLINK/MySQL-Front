unit fDExecutingSQL;

interface {********************************************************************}

uses
  Messages, Classes,
  Forms, Controls,StdCtrls,
  Forms_Ext,
  fSession, fBase;

type
  TDExecutingSQL = class (TForm_Ext)
    FBCancel: TButton;
    FInfo: TLabel;
    procedure FBCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostShow(var Message: TMessage); message UM_POST_SHOW;
  public
    Session: TSSession;
    Update: TSSession.TUpdate;
    function Execute(): Boolean;
  end;

function DExecutingSQL(): TDExecutingSQL;

implementation {***************************************************************}

{$R *.dfm}

uses
  Windows, SysUtils, 
  MySQLDB, MySQLConsts,
  fPreferences, fDAccount;

var
  FExecutingSQL: TDExecutingSQL;

function DExecutingSQL(): TDExecutingSQL;
begin
  if (not Assigned(FExecutingSQL)) then
  begin
    Application.CreateForm(TDExecutingSQL, FExecutingSQL);
    FExecutingSQL.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FExecutingSQL;
end;

{ TDOpenConnection ************************************************************}

procedure TDExecutingSQL.FBCancelClick(Sender: TObject);
begin
  Session.Connection.Terminate();
  ModalResult := mrCancel;
end;

function TDExecutingSQL.Execute(): Boolean;
begin
  ShowModal();
  Result := ModalResult = mrOk;
end;

procedure TDExecutingSQL.FormHide(Sender: TObject);
begin
  Session.ReleaseEventProc(FormSessionEvent);
end;

procedure TDExecutingSQL.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType = etAfterExecuteSQL) then
    if (Event.Session.Connection.ErrorCode <> 0) then
      ModalResult := mrCancel
    else
      ModalResult := mrOk;
end;

procedure TDExecutingSQL.FormShow(Sender: TObject);
begin
  Session.RegisterEventProc(FormSessionEvent);

  Caption := Session.Account.Name;

  PostMessage(Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDExecutingSQL.UMChangePreferences(var Message: TMessage);
begin
  FInfo.Caption := Preferences.LoadStr(882) + '...';

  FBCancel.Caption := Preferences.LoadStr(30);
end;

procedure TDExecutingSQL.UMPostShow(var Message: TMessage);
begin
  if (Update()) then
    ModalResult := mrOk;
end;

initialization
  FExecutingSQL := nil;
end.

