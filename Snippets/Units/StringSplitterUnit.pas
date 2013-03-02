(*--��---------------------------��--
�Z�p���[�^�ŕ����𕪉����鏈��
00/05/11
00/08/22    �������ۂ��ƕύX���܂����B
            �P�ꕪ����@������I���o����悤�ɂ����̂�
            Excel��CSV�t�@�C���ȂǓǂނƂ������p�ł��܂��B
            ���ɂ�Delimiters�������w�肷��悤�ɂ��Ďg�����肪�オ���Ă��܂��B
00/08/25    Wordxxx2�Ƃ����֐�����Wordxxx�ɂ��܂���
01/03/29    �^�u�����̑Ή����o���Ă��Ȃ������̂ŏC��
            �J���}������Delimiters�Ɋ܂܂�Ă��Ȃ��ꍇ�̏������C��
            WordCount��WordGet�̓������[�`����WordDecomposer�Ƃ���1�ɂ܂Ƃ߂�
01/10/29    TWordDecompose������
            ���̂��߂ɖ��ʂ��Ȃ��悤�� function WordDecomposer ��
            StringList�������œn���悤�ɂ���
02/07/04    TWordDecompose��IndexOf����������
2002/11/07
  Split�֐���StringUnitLight����ړ�
  Split�֐��̓����������AWordDecomposer�̓������������ׂĂ܂���
2010/03/03(��)
�E  WordDecompose.pas����
    DelimitedTextUnit.pas�Ɩ��O�ύX
�E  TSpliter��TWideStringSpliter�Ƃ��Ď������܂Ƃ߂�
�E  WordCount/WordGet�̃t���ODecomposedMode��
    TSplitFlags�Œu��������
2010/03/05(��)
�E  WordCount/WordGet��TSplitter�Œu��������
2010/03/07(��)
�E  Split�֐���WideStringRecordList.SetBaseText�Œu��������
    �e�X�g��ʉ߂����B
    SetBaseText�̕��������@�\�͑啝�ɋ��������B
�E  TWordDecompose�̓�����Split�֐�����
    WideStringRecordList.SetBaseText�Œu��������
�E  TSplitter�̖�ڂ͂Ȃ��Ȃ����̂Ŕp�~�����B
2011/05/11(��)
�E  GrepExtension��ǉ������B
2011/06/10(��)
�E���O�� DelimitedTextUnit ���� StringSplitterUnit �ɕύX�����B
�ETWordSplited ���� TStringSplitter �ɕύX�����B
2011/08/12(��)
�EGrepExtension�����ǂ��� uses Classes ��r�����܂���
//--��---------------------------��--*)
unit StringSplitterUnit;

interface

uses
  Types,
  SysUtils,
  StringUnit,
  StringRecordList,
  ConstUnit,

uses_end;

type
  TSplitFlags = set of (sfInDelimiter, sfInEmptyStr);
  {��sfIncludeDelimiter
       �������̖߂�l�ɋ�؂蕶�����̂��܂܂��
     sfEmptyStr
       �󕶎������������Ƃ݂Ȃ�
       �Ⴆ��[A,B,]�𕪊����鎞[A][B][�󕶎�]�ɕ��������}

const
  dmUserFriendly: TSplitFlags = [];
  dmDelimiterExactly: TSplitFlags = [sfInEmptyStr];
  {�P�ꕪ����@
   UserFriendly�͋�؂蕶���������ł��P��P�ʂɕ���
   DelimiterExactly�͋�؂蕶���Ɋ��S�ɐ��m�ɕ���
   �ړ����dm��DelimitMode�Ƃ������ɂ���}

//  TDecomposeMode = (dmUserFriendly, dmDelimiterExactly);
//  ���͗񋓌^���������ATSplitFlags�ɓ��������B

function WordCount(const S: String; Delimiters: array of String;
 const SplitFlag: TSplitFlags): Integer;
function WordGet(const S: String; Delimiters: array of String;
 WordIndex: Integer; SplitFlag: TSplitFlags): String;

type
  TStringSplitter = class(TObject)
  private
    FWords: TStringRecordList;
    FSentence: String;
    FDelimiters: TStringDynArray;
    function GetWords(Index: Integer): String;
    function GetCount: Integer;
  public
    constructor Create(const Sentence: String;
     Delimiters: array of String; SplitFlag: TSplitFlags);
    destructor Destroy; override;
    property Words[Index: Integer]: String read GetWords;
    property Count: Integer read GetCount;
    property Sentence: String read FSentence;
    property Delimiters: TStringDynArray read FDelimiters;
    function IndexOf(const Word: String; IgnoreCase: Boolean): Integer;
  end;
  {Create���ɒP�ꕪ�����s���Ă��܂��N���X
   WordCount/WordGet���ɏ������閳�ʂ��͂Ԃ����ɗ��p�ł���}

function Split(const S: String; const Delimiters: array of String;
 SplitFlag: TSplitFlags): TStringDynArray; overload;

function GrepExtension(Filter, Target: String): Boolean;


implementation


type
  TWideStringRecordListAccess = class(TStringRecordList);

function SplitFlagsToDelimitStyle(SplitFlag: TSplitFlags): TDelimitStyle;
begin
  if SplitFlag = [sfInDelimiter, sfInEmptyStr] then
    Result := dsInDelimInEmpty
  else
  if SplitFlag = [sfInEmptyStr] then
    Result := dsNoDelimInEmpty
  else
  if SplitFlag = [sfInDelimiter] then
    Result := dsInDelimNoEmpty
  else
  if SplitFlag = [] then
    Result := dsNoDelimNoEmpty
  else
  begin
    Result := dsLineBreaks;
    Assert(False, 'Error SplitFlagsToDelimitStyle');
  end;
end;

{----------------------------------------
//      WordGet/WordCount
        
�@�\:       ��؂蕶�����w�肵�ĒP��ɕ���
			�P����擾��������𒲂ׂ鎖���ł���
���l:       ����A��������������̂�
			�����ɂ���Ă͑���Split/TStringSplitter���g���Ƃ悢
            �����ƍׂ�������� TWideStringRecordList �{�̂��g����
            ��������Ƃ悢��������Ȃ�
����:       2010/03/07(��)
            �E  TWideStringRecordList.SetBaseText���g����
                �������X�V�����B
//----------------------------------------}
function WordCount(const S: String; Delimiters: array of String;
 const SplitFlag: TSplitFlags): Integer;
begin
  with TWideStringRecordListAccess.Create do try
  SetBaseText(S, Delimiters,
    SplitFlagsToDelimitStyle(SplitFlag));
  Result := Count;
  finally Free; end;
end;

function WordGet(const S: String; Delimiters: array of String;
 WordIndex: Integer; SplitFlag: TSplitFlags): String;
begin
  with TWideStringRecordListAccess.Create do try
  SetBaseText(S, Delimiters,
    SplitFlagsToDelimitStyle(SplitFlag));
  Result := Items[WordIndex];
  finally Free; end;
end;
//----------------------------------------

{----------------------------------------
//      WordGet/WordCount�̃N���X��
�@�\:       WordCount���ă��[�v����
            �v�f����WordGet����Ƃ����R�[�h�ł�
            ����A��������������̂Ŗ��ʂȂ̂�
            �N���X�����ĕ��������͍ŏ���1��Ɍ��肵��
            ���Ƃ̓L���b�V����ǂގ����ɂȂ��Ă���B
���l:       
����:       2010/03/07(��)
            �E  WordGet/Count�Ɠ��l�ɓ���������ύX����
				TWideStringRecordList�{�̂����b�s���O���Ă���
				�Ƃ����`�ɂ��Ȃ��Ă���B
//----------------------------------------}
{ TStringSplitter }

constructor TStringSplitter.Create(const Sentence: String;
 Delimiters: array of String; SplitFlag: TSplitFlags);
var
  i: Integer;
begin
  FSentence := Sentence;
  FWords := TStringRecordList.Create;
  TWideStringRecordListAccess(FWords).SetBaseText(Sentence, Delimiters,
    SplitFlagsToDelimitStyle(SplitFlag));

  SetLength(FDelimiters, Length(Delimiters));
  for i := 0 to Length(Delimiters) - 1 do
  begin
    FDelimiters[i] := Delimiters[i];
  end;
end;

destructor TStringSplitter.Destroy;
begin
  FWords.Free;
  inherited;
end;

function TStringSplitter.GetCount: Integer;
begin
  Result := FWords.Count;
end;

function TStringSplitter.GetWords(Index: Integer): String;
begin
  if ( 0 <= Index ) and ( Index <= (GetCount-1) ) then
  begin
    Result := FWords.Items[Index];
  end else
  begin
    Result := '';
  end;
end;

function TStringSplitter.IndexOf(const Word: String;
 IgnoreCase: Boolean): Integer;
var
  i: Integer;
  CompareFunction: function(const S1, S2: WideString): Boolean;
begin
  Result := -1;

  for i := 0 to GetCount - 1 do
  begin
    if (IgnoreCase=True) then
    begin
      CompareFunction := WideSameText;
    end else
    begin
      CompareFunction := WideSameStr;
    end;

    if CompareFunction(FWords[i], Word) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;
//----------------------------------------

{----------------------------------------
//      Split
�@�\:       ��؂蕶���ŕ���������
			���I�z��ŕԂ��֐�
���l:       
����:       2002/09/27
              �쐬
            2002/10/02
              ItemAddDelimiter�t���O��ǉ�
            2002/11/07
              ItemAddEmptyStr�t���O��ǉ�
			2010/03/07(��)
			�E	������啝�ɕς��Ă���B
			�E	�S�Ẵe�X�g�ɒʉ߂��Ă���̂�
				�i���ɂ͉e���Ȃ��͂��ł��B
//----------------------------------------}
function Split(const S: String; const Delimiters: array of String;
 SplitFlag: TSplitFlags): TStringDynArray;
var
  Spliter: TWideStringRecordListAccess;
  i: Integer;
begin
  Spliter := TWideStringRecordListAccess.Create; try
  Spliter.SetBaseText(S, Delimiters,
    SplitFlagsToDelimitStyle(SplitFlag));

  SetLength(Result, Spliter.Count);
  for i := 0 to Spliter.Count - 1 do
  begin
    Result[i] := Spliter.Items[i];
  end;
  finally Spliter.Free; end;
end;
//----------------------------------------


{---------------------------------------
    And��Or��g�ݍ��킹�����������邽�߂̊֐�
�@�\:   Filter�ɁuAA BB CC\r\nDD EE�v���w�肷���
        ���镶������AAA��BB��CC���܂܂�Ă��邩�ADD��EE���܂܂�Ă��邩
        �ǂ����𒲂ׂ邱�Ƃ��ł���B
        ���Z�q�ŕ\������� (AA and BB and CC)or(DD and EE)�ƂȂ�B
���l:   �󕶎����w�肷��Ɩ߂�l��True�ɂȂ�̂�
        �t�B���^�Ƃ��Ďg�����ɑS�đS�Ă̍��ڂ��L���ɂȂ�ׂ�������B
����:   2011/05/11(��)
        �E  �쐬
        2011/08/12(��)
        �E  �e�ʂ�H���̂�TStrings��p�~�Buses Classes ���s�v�ɂȂ����B
}//(*-----------------------------------
function GrepExtension(Filter, Target: String): Boolean;
var
  K, J: Integer;
  AndFilterWords: TStringSplitter;
  AndFilterFlag: Boolean;
  FilterStrRecList: TStringRecordList;
begin
  if TrimChar(Filter, ' ' + '�@'+CtrlCharTbl)=EmptyStr then
  begin
    Result := True;
  end else
  begin
    Result := False;

    FilterStrRecList := TStringRecordList.Create; try
    FilterStrRecList.Text := Filter;
    for K := 0 to FilterStrRecList.Count - 1 do
    begin
      AndFilterWords := TStringSplitter.Create(FilterStrRecList[K], [' ', '�@'], dmUserFriendly); try
      if AndFilterWords.Count = 0 then
      begin
        AndFilterFlag := False;
      end else
      begin
        AndFilterFlag := True;

        for J := 0 to AndFilterWords.Count - 1 do
        begin
          if not InStr(AndFilterWords.Words[J], Target, ccIgnoreCase) then
          begin
            AndFilterFlag := False;
            Break;
          end;
        end;
      end;
      Result := Result or AndFilterFlag;
      finally AndFilterWords.Free; end;
    end;
    finally FilterStrRecList.Free; end;
  end;
end;
//------------------------------------*)

end.
