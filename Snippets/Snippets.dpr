// -----------------------------------------------------------------------------
// スニペット
//
// Copyright (c) Kuro. All Rights Reserved.
// e-mail: info@haijin-boys.com
// www:    https://www.haijin-boys.com/
// -----------------------------------------------------------------------------

library Snippets;

{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$WEAKLINKRTTI ON}

{$R 'mPlugin.res' 'mPlugin.rc'}


uses
  Winapi.Windows,
  System.SysUtils,
  System.Math,
  ConstUnit,
  ListClone,
  MathUnit,
  StringRecordList,
  StringSplitterUnit,
  StringUnit,
  NotePadEncoding,
  mCommon in 'mCommon.pas',
  mPlugin in 'mPlugin.pas';

resourcestring
  SName = 'スニペット';
  SVersion = '2.3.1';

const
  IDS_MENU_TEXT = 1;
  IDS_STATUS_MESSAGE = 2;
  IDI_ICON = 101;

{$IFDEF DEBUG}
{$R *.res}
{$ENDIF}


function MenuOption(CheckValue, EnabledValue: Boolean): Integer;
begin
  Result := MF_STRING;
  if CheckValue then
    Result := Result or MF_CHECKED;
  if not EnabledValue then
    Result := Result or MF_GRAYED;
end;

function CheckTabLevel(Line: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(Line) do
    if Line[I] = TAB then
      Inc(Result)
    else
      Break;
end;

function NextLineTabLevel(StrList: TStringRecordList;
  ItemIndex: Integer): Integer;
begin
  if CheckRange(0, ItemIndex, StrList.Count - 2) then
    Result := CheckTabLevel(StrList.Items[ItemIndex + 1])
  else
    Result := -1;
end;

procedure StrStackPush(StrList: TStringRecordList; Value: string);
begin
  StrList.Add(Value);
end;

function StrStackPop(StrList: TStringRecordList): string;
begin
  Result := '';
  if StrList.Count <> 0 then
  begin
    Result := StrList.Items[StrList.Count - 1];
    StrList.Delete(StrList.Count - 1);
  end;
end;

procedure OnCommand(hwnd: HWND); stdcall;
var
  S: string;
  I, J, Len: Integer;
  P: TPoint;
  CaretPoint: TPoint;
  SelStartPoint, SelEndPoint: TPoint;
  FileName: string;
  List: TStringRecordList;
  PopupMenuResult: Integer;
  MenuItemText: string;
  TabIndentLevelStacks: TListClone;
  TabIndentLevelIndex: Integer;
  PreLineTabIndentLevel: Integer;
  PopupArray: array of Integer;
  E1, E2: Boolean;
  Encoding: TFileEncoding;
  procedure CreateMenuFunc(TabIndentLevel: Integer);
  begin
    if Length(PopupArray) - 1 < TabIndentLevelIndex then
    begin
      SetLength(PopupArray, TabIndentLevelIndex + 1);
    end;
    PopupArray[TabIndentLevelIndex] := CreatePopupMenu;
  end;
  procedure AppendMenuFunc(TabIndentLevel, LineIndex: Integer; Text: string);
  begin
    if CheckStrInTable(Text, '-') = itAllInclude then
      AppendMenu(PopupArray[TabIndentLevel], MF_SEPARATOR, 0, '')
    else if WordCount(Text, [TAB], dmUserFriendly) = 1 then
      AppendMenu(PopupArray[TabIndentLevel], MF_STRING, LineIndex + 1, PChar(Copy(Text, 0, 16)))
    else if WordCount(Text, [TAB], dmUserFriendly) > 1 then
      AppendMenu(PopupArray[TabIndentLevel], MF_STRING, LineIndex + 1, PChar(WordGet(Text, [TAB], 0, dmUserFriendly)));
  end;
  procedure AppendMenuPopFunc(TabIndentLevel: Integer; Text: string);
  begin
    AppendMenu(PopupArray[TabIndentLevel], MF_POPUP,
      PopupArray[TabIndentLevel + 1],
      PChar(Text));
  end;

begin
  if not GetIniFileName(S) then
    Exit;
  List := TStringRecordList.Create;
  try
    FileName := ExtractFilePath(S) + 'Plugins\Snippets\Snippets.txt';
    if FileExists2(FileName) then
    begin
      Encoding := feNone;
      List.Text := LoadFromFile(FileName, Encoding, True, E1, E2);
    end;
    TabIndentLevelStacks := TListClone.Create;
    try
      CreateMenuFunc(0);
      PreLineTabIndentLevel := -1;
      for I := 0 to List.Count - 1 do
      begin
        MenuItemText := Trim(List[I]);
        TabIndentLevelIndex := CheckTabLevel(List[I]);
        if PreLineTabIndentLevel + 2 <= TabIndentLevelIndex then
          Continue;
        if TabIndentLevelIndex < NextLineTabLevel(List, I) then
        begin
          if PreLineTabIndentLevel < TabIndentLevelIndex then
            CreateMenuFunc(TabIndentLevelIndex);
          if TabIndentLevelStacks.Count - 1 <= TabIndentLevelIndex then
            TabIndentLevelStacks.Add(TStringRecordList.Create);
          StrStackPush(TStringRecordList(TabIndentLevelStacks[TabIndentLevelIndex]), MenuItemText);
        end
        else if TabIndentLevelIndex = NextLineTabLevel(List, I) then
        begin
          if PreLineTabIndentLevel < TabIndentLevelIndex then
            CreateMenuFunc(TabIndentLevelIndex);
          AppendMenuFunc(TabIndentLevelIndex, I, MenuItemText);
        end
        else if TabIndentLevelIndex > NextLineTabLevel(List, I) then
        begin
          if PreLineTabIndentLevel < TabIndentLevelIndex then
            CreateMenuFunc(TabIndentLevelIndex);
          AppendMenuFunc(TabIndentLevelIndex, I, MenuItemText);
          for Len := TabIndentLevelIndex - 1 downto Max(0, NextLineTabLevel(List, I)) do
            AppendMenuPopFunc(Len, StrStackPop(TStringRecordList(TabIndentLevelStacks[Len])));
        end;
        PreLineTabIndentLevel := TabIndentLevelIndex;
      end;
      for J := 0 to TabIndentLevelStacks.Count - 1 do
        TStringRecordList(TabIndentLevelStacks[J]).Free;
    finally
      TabIndentLevelStacks.Free;
    end;
    if List.Count <> 0 then
      AppendMenu(PopupArray[0], MF_SEPARATOR, 0, '');
    AppendMenu(PopupArray[0], MenuOption(False, not(Editor_GetSelType(hwnd) = SEL_TYPE_NONE)), List.Count + 1, '選択範囲を登録');
    AppendMenu(PopupArray[0], MF_STRING, List.Count + 2, 'スニペットを編集...');
    if (GetKeyState(VK_SHIFT) and $80 > 0) or (GetKeyState(VK_CONTROL) and $80 > 0) then
    begin
      Editor_GetCaretPos(hwnd, POS_DEV, @P);
      CaretPoint := P;
    end
    else
{$IF CompilerVersion > 22.9}
      Winapi.Windows.GetCursorPos(CaretPoint);
{$ELSE}
      Windows.GetCursorPos(CaretPoint);
{$IFEND}
    PopupMenuResult := Integer(TrackPopupMenu(PopupArray[0], TPM_RETURNCMD, CaretPoint.X, CaretPoint.Y, 0, hwnd, nil));
    Editor_Redraw(hwnd, False);
    try
      Editor_GetSelStart(hwnd, POS_LOGICAL, @SelStartPoint);
      Editor_GetSelEnd(hwnd, POS_LOGICAL, @SelEndPoint);
      if (1 <= PopupMenuResult) and (PopupMenuResult <= List.Count) then
      begin
        S := Trim(List.Items[PopupMenuResult - 1]);
        if WordCount(S, [TAB], dmUserFriendly) = 2 then
          Editor_InsertString(hwnd, PChar(DecodeEscapeSequence(WordGet(S, [TAB], 1, dmUserFriendly))))
        else
          Editor_InsertString(hwnd, PChar(DecodeEscapeSequence(S)));
      end
      else if PopupMenuResult = List.Count + 1 then
      begin
        Len := Editor_GetSelText(hwnd, 0, nil);
        SetLength(S, Len - 1);
        Editor_GetSelText(hwnd, Len, @S[1]);
        List.Insert(0, EncodeEscapeSequence(S) + CRLF);
        if not FileExists2(FileName) then
          ForceDirectories(ExtractFilePath(FileName));
        SaveToFile(FileName, Trim(List.Text), feUTF8BOM);
      end
      else if PopupMenuResult = List.Count + 2 then
      begin
        if not FileExists2(FileName) then
        begin
          ForceDirectories(ExtractFilePath(FileName));
          SaveToFile(FileName, '', feUTF8BOM);
        end;
        Editor_LoadFile(hwnd, True, PChar(FileName));
      end
      else
        Exit;
    finally
      List.Free;
    end;
  finally
    Editor_Redraw(hwnd, True);
  end;
end;

function QueryStatus(hwnd: HWND; pbChecked: PBOOL): BOOL; stdcall;
begin
  pbChecked^ := False;
  Result := True;
end;

function GetMenuTextID: Cardinal; stdcall;
begin
  Result := IDS_MENU_TEXT;
end;

function GetStatusMessageID: Cardinal; stdcall;
begin
  Result := IDS_STATUS_MESSAGE;
end;

function GetIconID: Cardinal; stdcall;
begin
  Result := IDI_ICON;
end;

procedure OnEvents(hwnd: HWND; nEvent: Cardinal; lParam: LPARAM); stdcall;
begin
  //
end;

function PluginProc(hwnd: HWND; nMsg: Cardinal; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := 0;
  case nMsg of
    MP_GET_NAME:
      begin
        Result := Length(SName);
        if lParam <> 0 then
          lstrcpynW(PChar(lParam), PChar(SName), wParam);
      end;
    MP_GET_VERSION:
      begin
        Result := Length(SVersion);
        if lParam <> 0 then
          lstrcpynW(PChar(lParam), PChar(SVersion), wParam);
      end;
  end;
end;

exports
  OnCommand,
  QueryStatus,
  GetMenuTextID,
  GetStatusMessageID,
  GetIconID,
  OnEvents,
  PluginProc;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

end.
