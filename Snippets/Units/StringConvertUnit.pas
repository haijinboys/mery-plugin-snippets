(*----------------------------------------
������ϊ����s�����j�b�g
2011/12/22(��)
�E  �쐬
//----------------------------------------*)
unit StringConvertUnit;

interface

uses
  Types,      //���ʌ݊��֐��ł�TStringDynArray�̐錾�̂���
  StringUnit, //���ʌ݊��֐��ł�StringsReplace�̗��p�̂���
  ConstUnit,
uses_end;

type
  TStringConvertOption = (
    scUpperCase, scLowerCase,
    scAlphabetToZenkaku,  scAlphabetToHankaku,
    scSymbolToZenkaku,    scSymbolToHankaku,
    scNumericToZenakaku,  scNumericToHankaku,
    scKatakanaToZenkaku,  scKatakanaToHankaku,
    scKatakanaToHiragana, scHiraganaToKatakana
  );
procedure StringConvert(var S: string; Option: TStringConvertOption); overload;
procedure StringConvert(Option: TStringConvertOption; var S: string); overload;
procedure StringConvert(var S: String;
 const OldPatterns, NewPatterns: String); overload;



////////////////////////////////////////
//���ʌ݊�
////////////////////////////////////////

function ConvertHanKataToZenKata(const Source: String): String;
function ConvertZenKataToHanKata(const Source: String): String;

function ConvertNumericHanToZen(const Source: String): String;
function ConvertNumericZenToHan(const Source: String): String;
function ConvertSymbolHanToZen(const Source: String): String;
function ConvertSymbolZenToHan(const Source: String): String;
function ConvertAlphabetHanToZen(const Source: String): String;
function ConvertAlphabetZenToHan(const Source: String): String;
function ConvertAlphabetUpperCase(const Source: String): String;


implementation

uses

end_uses;

{---------------------------------------
    ������ϊ�
�@�\:   �啶���������̕ϊ��̂悤��1�����Ƒ΂ɂȂ���1������
        �\�����ꍇ�̕ϊ����s���֐�
���l:   �S�p���p�ϊ����s����̂�UnicodeString�̂���������
        AnsiString�ł����Ă����p�̍����ϊ��ɂ���
        ���W�b�N���g���Ƃ悢���낤
����:   2011/12/21(��)
        �E  �쐬
}//(*-----------------------------------
type
  TCharDynArray       = array of Char;

procedure StringConvert(var S: String;
 OldPatterns, NewPatterns: TCharDynArray); overload;
var
  I, J: Integer;
begin
  if Length(OldPatterns) = 0 then Exit;
  if Length(OldPatterns) <> Length(NewPatterns) then Exit;
  if S = EmptyStr then Exit;

  for I := 1 to Length(S) do
  begin
    for J := 0 to Length(OldPatterns) - 1 do
    begin
      if S[I] = OldPatterns[J] then
      begin
        S[I] := NewPatterns[J];
      end;
    end;
  end;
end;

procedure StringConvert(var S: String;
 const OldPatterns, NewPatterns: String); overload;
var
  I, J: Integer;
begin
  if Length(OldPatterns) = 0 then Exit;
  if Length(OldPatterns) <> Length(NewPatterns) then Exit;
  if S = EmptyStr then Exit;

  for I := 1 to Length(S) do
  begin
    for J := 1 to Length(OldPatterns) do
    begin
      if S[I] = OldPatterns[J] then
      begin
        S[I] := NewPatterns[J];
      end;
    end;
  end;
end;
//------------------------------------*)

type
  TConvertTable = class
  public
    const HankakuKatakana: array[0..86] of String =
        (
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�','�','�','�');

    const ZenkakuKatakana: array[0..86] of Char =
        (
        '�K','�M','�O','�Q','�S',
        '�U','�W','�Y','�[','�]',
        '�_','�a','�d','�f','�h',
        '�o','�r','�u','�x','�{',
        '�p','�s','�v','�y','�|',
        '�A','�C','�E','�G','�I',
        '�J','�L','�N','�P','�R',
        '�T','�V','�X','�Z','�\',
        '�^','�`','�c','�e','�g',
        '�i','�j','�k','�l','�m',
        '�n','�q','�t','�w','�z',
        '�}','�~','��','��','��',
        '��','��','��',
        '��','��','��','��','��',
        '��','��','��',
        '�@','�B','�D','�F','�H',
        '��','��','��',
        '�b','�K','�[','�E','�A','�B','�u','�v');

    const ZenkakuHiragana: array[0..86] of Char =
        (
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��',
        '��','��','��','��','��',
        '��','��','��',
        '��','��','��','��','��',
        '��','��','��',
        '��','�K','�[','�E','�A','�B','�u','�v');

    const Numeric: String =
        ('0123456789-+/.');
    const ZenkakuNumeric: String =
        ('�O�P�Q�R�S�T�U�V�W�X�|�{�^�D');

    const Symbol: String =
        (
        '!?$\%&#''"_' +
        '()[]<>{}' +
        '-+/*=.,;:@| ');

    const ZenkakuSymbol: String =
        (
        '�I�H�����������f�h�Q' +
        '�i�j�m�n�����o�p' +
        '�|�{�^�����D�C�G�F���b�@');

    const AlphabetUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const AlphabetLower = 'abcdefghijklmnopqrstuvwxyz';
    const Alphabet = AlphabetUpper + AlphabetLower;

    const ZenkakuAlphabetUpper =
      '�`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y';
    const ZenkakuAlphabetLower =
      '����������������������������������������������������';
    const ZenkakuAlphabet = ZenkakuAlphabetUpper + ZenkakuAlphabetLower;
  end;

    function StringToCharDynArray(const Table: String): TCharDynArray;
    var
      I: Integer;
    begin
      SetLength(Result, Length(Table));
      for I := 0 to Length(Table) - 1 do
        Result[I] := Table[I + 1];
    end;

    function CharDynArrayToStringDynArray(Table: array of char): TStringDynArray;
    var
      I: Integer;
    begin
      SetLength(Result, Length(Table));
      for I := 0 to Length(Table) - 1 do
        Result[I] := Table[I];
    end;

procedure StringConvert(var S: string; Option: TStringConvertOption); overload;
var
  Table1, Table2: String;
begin
  case Option of
    scUpperCase:
    begin
      Table1 := TConvertTable.AlphabetLower + TConvertTable.ZenkakuAlphabetLower;
      Table2 := TConvertTable.AlphabetUpper + TConvertTable.ZenkakuAlphabetUpper;
    end;
    scLowerCase:
    begin
      Table1 := TConvertTable.AlphabetUpper + TConvertTable.ZenkakuAlphabetUpper;
      Table2 := TConvertTable.AlphabetLower + TConvertTable.ZenkakuAlphabetLower;
    end;

    scAlphabetToZenkaku:
    begin
      Table1 := TConvertTable.AlphabetUpper + TConvertTable.AlphabetLower;
      Table2 := TConvertTable.ZenkakuAlphabetUpper + TConvertTable.ZenkakuAlphabetLower;
    end;
    scAlphabetToHankaku:
    begin
      Table1 := TConvertTable.ZenkakuAlphabetUpper + TConvertTable.ZenkakuAlphabetLower;
      Table2 := TConvertTable.AlphabetUpper + TConvertTable.AlphabetLower;
    end;

    scSymbolToZenkaku:
    begin
      Table1 := TConvertTable.Symbol;
      Table2 := TConvertTable.ZenkakuSymbol;
    end;
    scSymbolToHankaku:
    begin
      Table1 := TConvertTable.ZenkakuSymbol;
      Table2 := TConvertTable.Symbol;
    end;

    scNumericToZenakaku:
    begin
      Table1 := TConvertTable.Numeric;
      Table2 := TConvertTable.ZenkakuNumeric;
    end;
    scNumericToHankaku:
    begin
      Table1 := TConvertTable.ZenkakuNumeric;
      Table2 := TConvertTable.Numeric;
    end;

    scKatakanaToZenkaku:
    begin
      S := StringsReplace(S,
        TConvertTable.HankakuKatakana, CharDynArrayToStringDynArray(TConvertTable.ZenkakuKatakana));
      Exit;
    end;
    scKatakanaToHankaku:
    begin
      S := StringsReplace(S,
        CharDynArrayToStringDynArray(TConvertTable.ZenkakuKatakana), TConvertTable.HankakuKatakana);
      Exit;
    end;

    scKatakanaToHiragana:
    begin
      S := StringsReplace(S,
        TConvertTable.HankakuKatakana, CharDynArrayToStringDynArray(TConvertTable.ZenkakuKatakana));
      Table1 := TConvertTable.ZenkakuKatakana;
      Table2 := TConvertTable.ZenkakuHiragana;
    end;
    scHiraganaToKatakana:
    begin
      Table1 := TConvertTable.ZenkakuHiragana;
      Table2 := TConvertTable.ZenkakuKatakana;
    end;
  end;

  StringConvert(S, Table1, Table2);

end;

procedure StringConvert(Option: TStringConvertOption; var S: string); overload;
begin
  StringConvert(S, Option);
end;

////////////////////////////////////////
//���ʌ݊�
////////////////////////////////////////

{-------------------------------
//  �J�^�J�i�𔼊p�̑S�p���ݕϊ����܂�
    ConvertHanKataToZenKata
    ConvertZenKataToHanKata
�@�\:       �J�^�J�i��ϊ����܂�
��������:   Source: ���̕�����
�߂�l:     �ϊ���̕�����
���l:
����:       2003/06/15
//--��----------------------��--}
const
  ConvertTblHanKata: array[0..86] of String =
       (
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '��','��','��','��','��',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�',
        '�','�','�',
        '�','�','�','�','�','�','�','�');
  ConvertTblZenKata: array[0..86] of String =
       (
        '�K','�M','�O','�Q','�S',
        '�U','�W','�Y','�[','�]',
        '�_','�a','�d','�f','�h',
        '�o','�r','�u','�x','�{',
        '�p','�s','�v','�y','�|',
        '�A','�C','�E','�G','�I',
        '�J','�L','�N','�P','�R',
        '�T','�V','�X','�Z','�\',
        '�^','�`','�c','�e','�g',
        '�i','�j','�k','�l','�m',
        '�n','�q','�t','�w','�z',
        '�}','�~','��','��','��',
        '��','��','��',
        '��','��','��','��','��',
        '��','��','��',
        '�@','�B','�D','�F','�H',
        '��','��','��',
        '�b','�K','�[','�E','�A','�B','�u','�v');
function ConvertHanKataToZenKata(const Source: String): String;
var
  HanKanaPatterns, ZenKanaPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanKanaPatterns, High(ConvertTblHanKata)+1);
  for i := 0 to High(ConvertTblHanKata) do
    HanKanaPatterns[i] := ConvertTblHanKata[i];
  SetLength(ZenKanaPatterns, High(ConvertTblZenKata)+1);
  for i := 0 to High(ConvertTblZenKata) do
    ZenKanaPatterns[i] := ConvertTblZenKata[i];

  Result := StringsReplace(Source, HanKanaPatterns, ZenKanaPatterns);
end;

function ConvertZenKataToHanKata(const Source: String): String;
var
  HanKanaPatterns, ZenKanaPatterns: TStringDynArray;
  i: Integer;
  SymbolCount: Integer;
begin
  SymbolCount := 5;
  {���S�p�����p�̏ꍇ�A�Ђ炪�ȋL���w�E�A�B�u�v�x�����̓J�^�J�i�ɂ��Ȃ��Ă悢}
  SetLength(HanKanaPatterns, High(ConvertTblHanKata)+1 - SymbolCount);
  for i := 0 to High(ConvertTblHanKata) - SymbolCount do
    HanKanaPatterns[i] := ConvertTblHanKata[i];
  SetLength(ZenKanaPatterns, High(ConvertTblZenKata)+1 - SymbolCount);
  for i := 0 to High(ConvertTblZenKata) - SymbolCount do
    ZenKanaPatterns[i] := ConvertTblZenKata[i];

  Result := StringsReplace(Source, ZenKanaPatterns, HanKanaPatterns);
end;
//--��----------------------��--

{-------------------------------
//  �p��Ɛ��l�ƋL�����p�̑S�p���ݕϊ����܂�
    ConvertAlphabetHanToZen
    ConvertAlphabetZenToHan
    ConvertNumericHanToZen
    ConvertNumericZenToHan
    ConvertSymbolHanToZen
    ConvertSymbolZenToHan
�@�\:       ���l�ƋL����ϊ����܂�
��������:   Source: ���̕�����
�߂�l:     �ϊ���̕�����
���l:
����:       2006/04/05
//--��----------------------��--}
const
  ConvertTblHanNumeric: String =
       ('0123456789-+/.');
  ConvertTblZenNumeric: String =
       ('�O�P�Q�R�S�T�U�V�W�X�|�{�^�D');
function ConvertNumericHanToZen(const Source: String): String;
var
  HanNumericPatterns, ZenNumericPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanNumericPatterns, Length(ConvertTblHanNumeric));
  for i := 0 to Length(ConvertTblHanNumeric)-1 do
    HanNumericPatterns[i] := ConvertTblHanNumeric[i+1];
  SetLength(ZenNumericPatterns, Length(ConvertTblZenNumeric));
  for i := 0 to Length(ConvertTblZenNumeric)-1 do
    ZenNumericPatterns[i] := ConvertTblZenNumeric[i+1];

  Result := StringsReplace(Source, HanNumericPatterns, ZenNumericPatterns);
end;

function ConvertNumericZenToHan(const Source: String): String;
var
  HanNumericPatterns, ZenNumericPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanNumericPatterns, Length(ConvertTblHanNumeric));
  for i := 0 to Length(ConvertTblHanNumeric)-1 do
    HanNumericPatterns[i] := ConvertTblHanNumeric[i+1];
  SetLength(ZenNumericPatterns, Length(ConvertTblZenNumeric));
  for i := 0 to Length(ConvertTblZenNumeric)-1 do
    ZenNumericPatterns[i] := ConvertTblZenNumeric[i+1];

  Result := StringsReplace(Source, ZenNumericPatterns, HanNumericPatterns);
end;


const
  ConvertTblHanSymbol: String =
       ('!?$\%&#''"_' +
        '()[]<>{}' +
        '-+/*=.,;:@| ');
  ConvertTblZenSymbol: String =
       ('�I�H�����������f�h�Q' +
        '�i�j�m�n�����o�p' +
        '�|�{�^�����D�C�G�F���b�@');
function ConvertSymbolHanToZen(const Source: String): String;
var
  HanSymbolPatterns, ZenSymbolPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanSymbolPatterns, Length(ConvertTblHanSymbol));
  for i := 0 to Length(ConvertTblHanSymbol)-1 do
    HanSymbolPatterns[i] := ConvertTblHanSymbol[i+1];
  SetLength(ZenSymbolPatterns, Length(ConvertTblZenSymbol));
  for i := 0 to Length(ConvertTblZenSymbol)-1 do
    ZenSymbolPatterns[i] := ConvertTblZenSymbol[i+1];

  Result := StringsReplace(Source, HanSymbolPatterns, ZenSymbolPatterns);
end;

function ConvertSymbolZenToHan(const Source: String): String;
var
  HanSymbolPatterns, ZenSymbolPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanSymbolPatterns, Length(ConvertTblHanSymbol));
  for i := 0 to Length(ConvertTblHanSymbol)-1 do
    HanSymbolPatterns[i] := ConvertTblHanSymbol[i+1];
  SetLength(ZenSymbolPatterns, Length(ConvertTblZenSymbol));
  for i := 0 to Length(ConvertTblZenSymbol)-1 do
    ZenSymbolPatterns[i] := ConvertTblZenSymbol[i+1];

  Result := StringsReplace(Source, ZenSymbolPatterns, HanSymbolPatterns);
end;

const
  ConvertTblAlphabetUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  ConvertTblAlphabetLower = 'abcdefghijklmnopqrstuvwxyz';
  ConvertTblAlphabet = ConvertTblAlphabetUpper + ConvertTblAlphabetLower;

  ConvertTblZenkakuAlphabetUpper =
    '�`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y';
  ConvertTblZenkakuAlphabetLower =
    '����������������������������������������������������';
  ConvertTblZenkakuAlphabet = ConvertTblZenkakuAlphabetUpper + ConvertTblZenkakuAlphabetLower;

function ConvertAlphabetHanToZen(const Source: String): String;
var
  HanAlphabetPatterns, ZenAlphabetPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanAlphabetPatterns, Length(ConvertTblAlphabet));
  for i := 0 to Length(ConvertTblAlphabet)-1 do
    HanAlphabetPatterns[i] := ConvertTblAlphabet[i+1];
  SetLength(ZenAlphabetPatterns, Length(ConvertTblZenkakuAlphabet));
  for i := 0 to Length(ConvertTblZenkakuAlphabet)-1 do
    ZenAlphabetPatterns[i] := ConvertTblZenkakuAlphabet[i+1];

  Result := StringsReplace(Source, HanAlphabetPatterns, ZenAlphabetPatterns);
end;

function ConvertAlphabetZenToHan(const Source: String): String;
var
  HanAlphabetPatterns, ZenAlphabetPatterns: TStringDynArray;
  i: Integer;
begin
  SetLength(HanAlphabetPatterns, Length(ConvertTblAlphabet));
  for i := 0 to Length(ConvertTblAlphabet)-1 do
    HanAlphabetPatterns[i] := ConvertTblAlphabet[i+1];
  SetLength(ZenAlphabetPatterns, Length(ConvertTblZenkakuAlphabet));
  for i := 0 to Length(ConvertTblZenkakuAlphabet)-1 do
    ZenAlphabetPatterns[i] := ConvertTblZenkakuAlphabet[i+1];

  Result := StringsReplace(Source, ZenAlphabetPatterns, HanAlphabetPatterns);
end;

  function StringTableToDynArray(Table: String): TStringDynArray;
  var
    I: Integer;
  begin
    SetLength(Result, Length(Table));
    for I := 0 to Length(Table) - 1 do
      Result[I] := Table[I + 1];
  end;

function ConvertAlphabetUpperCase(const Source: String): String;
begin
  Result := StringsReplace(Source,
    StringTableToDynArray(ConvertTblAlphabetLower + ConvertTblZenkakuAlphabetLower),
    StringTableToDynArray(ConvertTblAlphabetUpper + ConvertTblZenkakuAlphabetUpper));
end;
//--��----------------------��--





end.
