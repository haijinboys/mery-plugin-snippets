{ --��---------------------------��--
    �\���̃��X�g/�N���X���X�g��
    �e���v���[�g�̂悤�Ȏ���
����:
2002/05/15
  MyClassList.pas/NumericList�Ȃǂ�����
2002/08/15
  StringClass�ɕ�������������R���X�g���N�^������
  StringClassList/StringRecordList��Text�v���p�e�B������
2002/08/16
  StringRecordList�̂��߂�MyRecordList��Initialize/Finalize������
  TList�Ɉˑ����Ȃ����߂�TM��List������
2003/09/19
  �\���̔j���̏������C��(SetCount�ȂǂŃ��������[�N���Ă�)
  GetMem Initialize/FreeMem Finalize������
  New/Dispose�̏����ɕύX����
  �Q�l:[Delphi-ML:18256] Re: RE: Re: ���I�ɔz��������@
2003/11/09
  ���t�@�N�^�����O����TMyRecordList��TRecordList�ɂ���
2007/04/29
�EFList/GetItem/SetItem/GetCount/SetCount��
  private����protected�ɂ����B
  �\�[�g�����Ōp���N���X��FList�ɃA�N�Z�X����K�v������������
//--��---------------------------��-- }

////////////////////////////////////////////////////////////
{$ifndef RecordList}
{$define RecordList}
// interface
////////////////////////////////////////////////////////////

  PRecord = ^TRecord;

  TRecordList = class(TObject)
  private
  protected
    FList: TListClone;
    function GetItem(Index: Integer): TRecord;
    procedure SetItem(Index: Integer; const Value: TRecord);
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Item:TRecord): Integer;
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; Item: TRecord);
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Exchange(Index1, Index2: Integer);
    procedure Clear;
	procedure Assign(Source: TRecordList); virtual;
    function IndexOf(const Value: TRecord): Integer;
    property Items[Index:Integer]:TRecord read GetItem write SetItem;default;
    property Count: Integer read GetCount write SetCount;
  end;

////////////////////////////////////////////////////////////
{$else}
// implementation
////////////////////////////////////////////////////////////

//-------------------------------
{ TRecordList }
//-------------------------------


constructor TRecordList.Create;
begin
  FList := TListClone.Create;
end;

destructor TRecordList.Destroy;
begin
  Self.Clear;
  FList.Free;
  inherited;
end;

function TRecordList.Add(Item:TRecord): Integer;
var
  p:PRecord;
begin
  {��New�̕ς���
       GetMem(p,SizeOf(Item));
       Initialize(p^);
     �ł��悢�炵��}
  New(p);
  p^ := Item;
  result := FList.Add(p);
end;

procedure TRecordList.Delete(Index: Integer);
begin
  {��Dispose�̕ς���
       Finalize(PRecord(FList[Index])^);
       FreeMem(PRecord(FList[Index]));
     �ł��悢�炵��}
  Dispose(PRecord(FList[Index]));
  FList.Delete(Index);
end;

procedure TRecordList.Insert(Index: Integer; Item: TRecord);
var
  p: PRecord;
begin
  New(p); {��GetMem(p,SizeOf(Item))�ł������̂��ȁH
             Initialize�͑�����Ă��邩��v��Ȃ��C������}
  p^ := Item;
  FList.Insert(Index, p);
end;

procedure TRecordList.Clear;
var
  i:integer;
begin
  for i := 0 to FList.Count-1 do
  begin
    Dispose(PRecord(FList[i]));
  end;
  FList.Clear;
end;

procedure TRecordList.Exchange(Index1, Index2: Integer);
begin
  FList.Exchange(Index1, Index2);
end;

procedure TRecordList.Move(CurIndex, NewIndex: Integer);
begin
  FList.Move(CurIndex, NewIndex);
end;

function TRecordList.GetItem(Index: Integer): TRecord;
begin
  result := PRecord(FList[Index])^;
end;

procedure TRecordList.SetItem(Index: Integer; const Value: TRecord);
begin
  PRecord(FList[Index])^ := Value;
end;

function TRecordList.IndexOf(const Value: TRecord): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FList.Count-1 do
  begin
    if RecordEqual(Value, GetItem(i)) then
    begin
      Result := i;
      Break;
    end
  end;
end;

function TRecordList.GetCount: Integer;
begin
  result := FList.Count;
end;

procedure TRecordList.SetCount(const Value: Integer);
var
  i: Integer;
  p: PRecord;
begin
  if FList.Count = Value then
    Exit
  else
  if Value < FList.Count then
  begin
    {��SetCount�����݂�ListItem�̐���菭�Ȃ��̂�
       ���X�g�ɒ�`���Ă���]���ȕ����폜����}
    for i := FList.Count-1 downto Value do
    begin
      Self.Delete(i);
    end;
  end else
  if FList.Count < Value then
  begin
    {��SetCount�����݂�ListItem�̐���葽���̂�}
    for i := FList.Count+1 to Value do
    begin
      {�����������m�ۂ���0�N���A�����l��Add����
         New�̕ς���
           GetMem(p, SizeOf(TRecord));
           FillChar(p^, SizeOf(TRecord), 0);
         �Ƃ����R�[�h�ł��悢�炵��}
      New(p);
      FList.Add(p);
    end;
  end;
end;

procedure TRecordList.Assign(Source: TRecordList);
var
  i: Integer;
begin
  if Source is TRecordList then
  begin
    Self.Clear;
    for I := 0 to TRecordList(Source).Count - 1 do
    begin
      Self.Add(TRecordList(Source).Items[I]);
    end;
  end;

//  inherited Assign(Source);
end;

////////////////////////////////////////////////////////////
{$endif}
////////////////////////////////////////////////////////////

