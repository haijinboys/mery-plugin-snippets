(*----------------------------------------
�����񌟍��p�̊֐�
PosForward/PosBackward�̒u�������p
2011/12/20(��)
�E	�쐬
//----------------------------------------*)
unit StringSearchUnit;

interface

uses
  StringUnit,
  ConstUnit,
uses_end;

type
  TSearchDirection = (sdForwardToBackward, sdBackwardToForward);
  {��ForwardToBackward:   �O������    �O������֌�������[��]
     BackwardToForward:   �������    ��납��O�֌�������[��]}

  TSearchResult = record
    SearchIndex: Integer;
    SubStrArrayIndex: Integer;
  end;

  TSearchRange = record
  private
    function GetCount: Integer;
  public
    StartIndex: Integer;
    EndIndex: Integer;
    property Count: Integer read GetCount;
  end;

function StartEndIndex(StartIndex, EndIndex: Integer): TSearchRange;
function StartIndexCount(StartIndex, Count: Integer): TSearchRange;
function StartIndexToLast(StartIndex: Integer): TSearchRange;

function Search(Direction: TSearchDirection; S: String; SubStr: String;
 CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
function Search(Direction: TSearchDirection; S: String; SubStr: String;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
function Search(Direction: TSearchDirection; S: String; SubStrs: array of string;
 CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;
function Search(Direction: TSearchDirection; S: String; SubStrs: array of string;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;



{---------------------------------------
    ���ʌ݊��֐�
�@�\:   
���l:   
����:   2011/12/20(��)
        �E  ���ʌ݊��Ƃ������Ƃɂ���
}//(*-----------------------------------
function PosForward(const SubStr, S: String; CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): Integer; overload;
function PosForward(const SubStr, S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
function PosBackward(const Substr, S: String; CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): Integer; overload;
function PosBackward(const Substr, S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;

type
  TPosResult = record
    SearchIndex: Integer;
    SubStrArrayIndex: Integer;
  end;

function PosForward(const SubStrs: array of string; const S: String;
 CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): TPosResult; overload;
function PosForward(const SubStrs: array of string; const S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): TPosResult; overload;
function PosBackward(const SubStrs: array of string; const S: String;
 CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): TPosResult; overload;
function PosBackward(const SubStrs: array of string; const S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): TPosResult; overload;

//���ʌ݊�
function RangePosForward(const SubStr, S: String;
 Index: Integer = 1; Count: Integer = MaxInt;
 CaseCompare: TCaseCompare = ccCaseSensitive): Integer;
function RangePosBackward(const SubStr, S: String;
 Index: Integer = 1; Count: Integer = MaxInt;
 CaseCompare: TCaseCompare = ccCaseSensitive): Integer;
//------------------------------------*)


implementation


function TSearchRange.GetCount: Integer;
begin
  Result := EndIndex - StartIndex + 1;
end;

function StartEndIndex(StartIndex, EndIndex: Integer): TSearchRange;
begin
  Result.StartIndex := StartIndex;
  Result.EndIndex := EndIndex;
end;

function StartIndexCount(StartIndex, Count: Integer): TSearchRange;
var
  Buffer: Int64;
begin
  Result.StartIndex := StartIndex;
  Buffer := StartIndex + Int64(Count) - 1;
  if Int64(MaxInt) < Buffer then
    Result.EndIndex := MaxInt
  else
    Result.EndIndex := Buffer;
end;

function StartIndexToLast(StartIndex: Integer): TSearchRange;
begin
  Result.StartIndex := StartIndex;
  Result.EndIndex := MaxInt;
end;

function AllRange: TSearchRange;
begin
  Result.StartIndex := 1;
  Result.EndIndex := MaxInt;
end;

function Search_Base(const S: String; const SubStrs: array of string;
 Range: TSearchRange; CaseCompare: TCaseCompare;
 SearchDirection: TSearchDirection): TSearchResult;

  function IsEmptyAllSubStrs: Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to Length(SubStrs) - 1 do
    begin
      if SubStrs[I] <> EmptyStr then
      begin
        Result := False;
        Break;
      end;
    end;
  end;

var
  I, J: Integer;
begin
  Result.SearchIndex := 0;
  Result.SubStrArrayIndex := -1;

  if (S = EmptyStr) then Exit;
  if (Range.EndIndex <= 0) then Exit;
  if (Length(S) + 1 <= Range.StartIndex) then Exit;
  if (Range.EndIndex < Range.StartIndex) then Exit;

//  if IsEmptyAllSubStrs then Exit;
  {�������炭�s�v}

  { 123456789A
    __________��Length(S) = 10
       4____9 ��StartIndex=4/EndIndex=9 ����=(9-4+1)=6
       ___    ��SubStr=3Char
        ___
         ___
          ___ �����[�v��4����7��(9+1-3)
                �t������7����4
  }

  if Range.StartIndex <= 0 then       Range.StartIndex  := 1;
  if Length(S) < Range.EndIndex then  Range.EndIndex    := Length(S);

  case SearchDirection of
    sdForwardToBackward:
    begin
      for I := Range.StartIndex to Range.EndIndex do
        for J := 0 to Length(SubStrs) - 1 do
        begin
          if (Range.EndIndex - I + 1) < Length(SubStrs[J]) then Break;
          {��EndIndex���Z���w�肳��Ă���ꍇ���̏����ł͂���}
          if StringPartsCompare(SubStrs[J], S, I, CaseCompare) then
          begin
            Result.SearchIndex := I;
            Result.SubStrArrayIndex := J;
            Exit;
          end;
        end;
    end;

    sdBackwardToForward:
    begin
      for I := Range.EndIndex downto Range.StartIndex do
        for J := 0 to Length(SubStrs) - 1 do
        begin
          if (Range.EndIndex - I + 1) < Length(SubStrs[J]) then Break;

          if StringPartsCompare(SubStrs[J], S, I, CaseCompare) then
          begin
            Result.SearchIndex := I;
            Result.SubStrArrayIndex := J;
            Exit;
          end;
        end;
    end;
  end; //case SearchDirection
end;

//Index�w��Ȃ��̌Ăяo��
function Search(Direction: TSearchDirection; S: String; SubStr: String;
 CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Search_Base(S, [SubStr], AllRange, CaseCompare, Direction).SearchIndex;
end;

//Index�w�肠��̌Ăяo��
function Search(Direction: TSearchDirection; S: String; SubStr: String;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Search_Base(S, [SubStr], Range, CaseCompare, Direction).SearchIndex;
end;

//SubStr�����w��ł�Index�w��Ȃ��̌Ăяo��
function Search(Direction: TSearchDirection; S: String; SubStrs: array of string;
 CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;
begin
  Result := Search_Base(S, SubStrs, AllRange, CaseCompare, Direction);
end;

//SubStr�����w��ł�Index�w�肠��̌Ăяo��
function Search(Direction: TSearchDirection; S: String; SubStrs: array of string;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;
begin
  Result := Search_Base(S, SubStrs, Range, CaseCompare, Direction);
end;

////////////////////////////////////////
//�擪�����ȗ��O���w��
////////////////////////////////////////

//Index�w��Ȃ��̌Ăяo��
function Search(S: String; SubStr: String;
 CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Search_Base(S, [SubStr], AllRange, CaseCompare, sdForwardToBackward).SearchIndex;
end;

//Index�w�肠��̌Ăяo��
function Search(S: String; SubStr: String;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Search_Base(S, [SubStr], Range, CaseCompare, sdForwardToBackward).SearchIndex;
end;

//SubStr�����w��ł�Index�w��Ȃ��̌Ăяo��
function Search(S: String; SubStrs: array of string;
 CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;
begin
  Result := Search_Base(S, SubStrs, AllRange, CaseCompare, sdForwardToBackward);
end;

//SubStr�����w��ł�Index�w�肠��̌Ăяo��
function Search(S: String; SubStrs: array of string;
 Range: TSearchRange; CaseCompare: TCaseCompare = ccCaseSensitive): TSearchResult; overload;
begin
  Result := Search_Base(S, SubStrs, Range, CaseCompare, sdForwardToBackward);
end;


////////////////////////////////////////
//���ʌ݊��p
////////////////////////////////////////

{---------------------------------------
    �����񌟍� PosForward/PosBackward
�@�\:   �w��͈͂���������Pos
        0:�����񂪑��݂��Ȃ�
        0�ȊO:���������񂪑��݂���S��Index
        Index/Count�ňʒu���w�肷��B
        EndIndex= Index + Count - 1 �ŋ��߂鎖���ł���
���l:   Index��1�`Length(S)�ȊO���Ƌ󕶎���Ԃ�
����:   2002/05/31
        2002/07/14
        Count �� MaxInt �̏ꍇ
            EndIndex := Index + Count -1 ��
            ���̒l�ɂȂ�̂�
            EndIndex:Cardinal�őΉ�������
        2002/08/18
            StrPartsCompare�Ŏg���Ă���
            ByteType��VCL��SysUtils�̂��̂�
            �g�킸��API���g�����Ƃɂ���
        2002/08/22
            ByteType���悤�₭�����������B
            EndIndex:Cardinal���~�߂�
            Integer�ɂ��Ĕ͈͂𒴂������̕��̒l
            ���͂����悤�ɂ���
        2002/09/29
            StrPartsCompare��AnsiStringPartsCompare_Base
            �Ƃ������̂ɕς���
            IsSameStr��AnsiStringPartsCompare�ɕύX
            RangeAnsiPos/RangeBackAnsiPos��
            �����������������̂ł܂Ƃ߂�
        2005/09/22
            �֐����ς���
����:   2011/12/16(��)
        �E  RangePos�n�̋@�\��PosForward�Ɋ܂߂��̂�
            RangePos�n�͎g�p���Ȃ������ɂ���
        �E  RangePos_Base����Pos_Base�֖��O�ύX
}//(*-----------------------------------
type
  TPosSearchDirection = (sdForward, sdBackward);
  {��Forward:   �O������    �O������֌�������[��]
     Backward:  �������    ��납��O�֌�������[��]}


function Pos_Base(const SubStrs: array of string; const S: String;
 Index, Count: Integer; CaseCompare: TCaseCompare;
 SearchDirection: TPosSearchDirection): TPosResult; overload;
var
  I, J: Integer;
  EndIndex: Integer;
  SubStrsEmptyFlag: Boolean;
begin
  Result.SearchIndex := 0;
  Result.SubStrArrayIndex := -1;

  if (S='') then Exit;
  if not (  (1<=Index) and (Index<=Length(S))  ) then Exit;
  if not (1<=Count) then Exit;

  SubStrsEmptyFlag := True;
  for I := 0 to Length(SubStrs) - 1 do
  begin
    if SubStrs[I] <> EmptyStr then
    begin
      SubStrsEmptyFlag := False;
      Break;
    end;
  end;
  if SubStrsEmptyFlag then Exit;

  {��Index+Count-1���v�Z����MaxInt�𒴂���ꍇ
     ���̒l�ɂȂ�̂ŏC��}
  EndIndex := Index + Count - 1;
  if (EndIndex < 0) or (Length(S) < EndIndex) then
  begin
    EndIndex := Length(S);
  end;

  { 123456789A
    __________��S��10Char
       4____9 ��Index=4/End=9��6Char
       ___    ��SubStr=3Char
        ___
         ___
          ___ �����[�v��4����7��(9+1-3)
                �t������7����4
  }
  case SearchDirection of
    sdForward:
    begin
      for I := Index to EndIndex do
        for J := 0 to Length(SubStrs) - 1 do
        begin
//          if StringPartsCompare_Base(SubStrs[J], S, 1, I, Min(Length(SubStrs[J]), Count), CaseCompare) then
          if (EndIndex - I + 1) < Length(SubStrs[J]) then Break;

          if StringPartsCompare(SubStrs[J], S, I, CaseCompare) then
          begin
            Result.SearchIndex := I;
            Result.SubStrArrayIndex := J;
            Exit;
          end;
        end;
    end;

    sdBackward:
    begin
      for I := EndIndex downto Index do
        for J := 0 to Length(SubStrs) - 1 do
        begin
//          if StringPartsCompare_Base(SubStrs[J], S, 1, I, Min(Length(SubStrs[J]), Count), CaseCompare) then
          if (EndIndex - I + 1) < Length(SubStrs[J]) then Break;
          if StringPartsCompare(SubStrs[J], S, I, CaseCompare) then
          begin
            Result.SearchIndex := I;
            Result.SubStrArrayIndex := J;
            Exit;
          end;
        end;
    end;
  end; //case SearchDirection
end;

//function Pos_Base(const SubStr, S: String;
// Index, Count: Integer; CaseCompare: TCaseCompare;
// SearchDirection: TSearchDirection): Integer; overload;
//begin
//  Result := Pos_Base([SubStr], S, Index, Count, CaseCompare, SearchDirection).SearchIndex;
//end;

function PosForward(const SubStr, S: String; CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): Integer; overload;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdForward).SearchIndex;
end;

function PosForward(const SubStr, S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdForward).SearchIndex;
end;

function PosForward(const SubStrs: array of string; const S: String;
 CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): TPosResult; overload;
begin
  Result := Pos_Base(SubStrs, S, Index, Count, CaseCompare, sdForward);
end;

function PosForward(const SubStrs: array of string; const S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): TPosResult; overload;
begin
  Result := Pos_Base(SubStrs, S, Index, Count, CaseCompare, sdForward);
end;

function PosBackward(const Substr, S: String; CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): Integer; overload;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdBackward).SearchIndex;
end;

function PosBackward(const Substr, S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): Integer; overload;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdBackward).SearchIndex;
end;

function PosBackward(const SubStrs: array of string; const S: String;
 CaseCompare: TCaseCompare = ccCaseSensitive;
 Index: Integer = 1; Count: Integer = MaxInt): TPosResult; overload;
begin
  Result := Pos_Base(SubStrs, S, Index, Count, CaseCompare, sdBackward);
end;

function PosBackward(const SubStrs: array of string; const S: String;
 Index: Integer; Count: Integer = MaxInt; CaseCompare: TCaseCompare = ccCaseSensitive): TPosResult; overload;
begin
  Result := Pos_Base(SubStrs, S, Index, Count, CaseCompare, sdBackward);
end;

//���ʌ݊��֐�
//PosForward/PosBackward�Œu������
function RangePosForward(const SubStr, S: String;
 Index: Integer = 1; Count: Integer = MaxInt;
 CaseCompare: TCaseCompare = ccCaseSensitive{IgnoreCase=False}): Integer;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdForward).SearchIndex;
end;

function RangePosBackward(const SubStr, S: String;
 Index: Integer = 1; Count: Integer = MaxInt;
 CaseCompare: TCaseCompare = ccCaseSensitive{IgnoreCase=False}): Integer;
begin
  Result := Pos_Base(SubStr, S, Index, Count, CaseCompare, sdBackward).SearchIndex;
end;
//------------------------------------*)


end.

