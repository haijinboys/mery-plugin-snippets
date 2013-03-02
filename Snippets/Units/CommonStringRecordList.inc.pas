{ -----------------------------------
2003/06/15
  SetText�ŕ�����𕪉�����Ƃ��̉��s�R�[�h����������
  Win��#13#10�����őΉ����Ă������̂�
  #13�A#10�P�Ƃł̏ꍇ�����삷��悤�ɉ���
2010/02/23(��)
�ESetText�̎�����Delimiter�w��ł�
  �o����悤��SetBaseText�����������B
2010/03/04(��)
�ESetBaseText��SplitFlags��t������
  �@�\�����������B
�ESplitFlags�ł͂Ȃ��AdtfIncludeDelimiter��ON/OFF�ɂ���
2010/03/05(��)
�EDelimitStyle�Ƃ���5�^�C�v�ɕ��ނ��Ď���
//----------------------------------- }
{$ifdef interface}
{$undef interface}

  TDelimitStyle = (dsLineBreaks,
    dsNoDelimInEmpty, dsNoDelimNoEmpty, dsInDelimInEmpty, dsInDelimNoEmpty);
    {�� SetBaseText���g���Ƃ��ɓ��삷�镪����@
        dsLineBreaks
            SetText���g���Ƃ��Ɏg�p�������
            SetBaseText('ABC\r\n\r\nDEF\r\n', [\r\n], dsLineBreaks)�Ƃ����
            [ABC\r\n][\r\n][DEF\r\n]�ƂȂ�
        dsNoDelimInEmpty
            ��؂蕶���Ȃ��ŋ󕶎����܂ޏ���
            SetBaseText('ABC,,DEF,', ',' dsNoDelimInEmpty)�Ƃ����
            [ABC][][DEF][]�ƕ��������
        dsNoDelimNoEmpty
            ��؂蕶���Ȃ��ŋ󕶎��Ȃ��̏���
            SetBaseText('ABC,,DEF,', ',' dsNoDelimNoEmpty)�Ƃ����
            [ABC][DEF]�ƕ��������
        dsInDelimInEmpty
            ��؂蕶������ŋ󕶎����܂ޏ���
            SetBaseText('ABC,,DEF,', ',' dsInDelimInEmpty)�Ƃ����
            [ABC][,][][,][DEF][,][]�ƕ��������
        dsInDelimNoEmpty
            ��؂蕶������ŋ󕶎��Ȃ��̏���
            SetBaseText('ABC,,DEF,', ',' dsNoDelimNoEmpty)�Ƃ����
            [ABC][,][,][DEF][,]�ƕ��������
    }

  TCommonStringRecordList = class(TRecordList)
  protected
    procedure SetText(const Value: TRecord);
    function GetText: TRecord;
    procedure SetBaseText(const Value: TRecord;
     Delimiters: array of TRecord; const Style: TDelimitStyle);
  public
    procedure SetDelimitedText(const Value: TRecord;
     Delimiters: array of TRecord);
    function GetDelimitedText(Delimiter: TRecord): String;
    property Text: TRecord read GetText write SetText;
  end;
{$endif}

{$ifdef RecordEqual}
{$undef RecordEqual}
function RecordEqual(const Value1, Value2: TRecord): Boolean;
begin
  if ( TRecord(Value1) = TRecord(Value2) ) then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;
end;
{$endif}

{$ifdef GetSetText}
{$undef GetSetText}

function TCommonStringRecordList.GetText: TRecord;
var
  StringLength, ResultIndex: Integer;
  i, j: Integer;
begin
  StringLength := 0;
  for i := 0 to Self.Count - 1 do
  begin
    Inc(StringLength, Length(Self.Items[i]));
  end;

  SetLength(Result, StringLength);
  ResultIndex := 1;
  for i := 0 to Self.Count - 1 do
  begin
    for j := 1 to Length(Self.Items[i]) do
    begin
      Result[ResultIndex] := Self.Items[i][j];
      Inc(ResultIndex);
    end;
  end;
end;


procedure TCommonStringRecordList.SetText(const Value: TRecord);
const
  LineBreakStrs: array[0..2] of TRecord = (#13#10, #13, #10);
  {��#13#10,#13,#10�̏��Ԃ�����ACRLF�������ċ�؂�
     CR��LF�Ɉ�v���Ȃ��ꍇ��CR��LF�Ŕ��肵�ċ�؂鎖���ł���
	 #13,#10,#13#10�ȂǂƂ������тł͂����Ȃ�}
begin
  SetBaseText(Value, LineBreakStrs, dsLineBreaks);
end;

{----------------------------------------
�E	ABC\r\n\r\nDEF\r\n�𕪊������ꍇ
	���̂悤�ɂȂ�B
	�E	LineBreaksStyle
		[ABC\r\n][\r\n][DEF\r\n]�ƂȂ�
        ��؂蕶��(\r\n)��O�̗v�f�ɒǉ����ĕ�������

	�E	NoDelimInEmpty
		[ABC][][DEF]
        ��؂蕶��(\r\n)�͏������ėv�f��ǉ��B
		�󕶎��̏ꍇ���󕶎��v�f��1�����ԂɂȂ�
        StringList�I�Ɏg����C������

	�E	NoDelimNoEmpty
		[ABC][DEF]
        ��؂蕶��(\r\n)���󕶎����ǉ�����Ȃ�

	�E	InDelimInEmpty
		[ABC][\r\n][][\r\n][DEF][\r\n]
        ��؂蕶��(\r\n)���󕶎����������ėv�f�ɓo�^����
        ���̏������s���Ă��炢�낢�돈�������₷����������Ȃ�

	�E	InDelimNoEmpty
		[ABC][\r\n][\r\n][DEF][\r\n]
        ��؂蕶��(\r\n)�͕������A��v�f�͂Ȃ��ɂ��鏈���B
		����͖��ɗ��̂��낤���c
//----------------------------------------}
procedure TCommonStringRecordList.SetBaseText(const Value: TRecord;
 Delimiters: array of TRecord; const Style: TDelimitStyle);

    function Delimiters_IndexOf(ValueIndex: Integer): Integer;
    var
      j: Integer;
    begin
      Result := -1;
      for j := Low(Delimiters) to High(Delimiters) do
      begin
        if StringPartsCompare(Delimiters[j], Value, ValueIndex) then
        begin
          Result := j;
          break;
        end;
      end;
    end;

    procedure Add_CopyIndex_NotEmptyStr(ValueStartIndex, ValueEndIndex: Integer;
      ValueLen: Integer);
    begin
      if ValueStartIndex <= ValueEndIndex then
        if (CheckRange(1, ValueStartIndex, ValueLen))
          or (CheckRange(1, ValueEndIndex, ValueLen)) then
        begin
          Self.Add(CopyIndex(Value, ValueStartIndex, ValueEndIndex));
        end;
    end;

var
  i, Len, StartIndex, EndIndex: Integer;
  DelimitersIndex: Integer;
begin
  Self.Clear;
  {��ds�cInEmpty�t���O�̏ꍇ��
     Value�ɋ󕶎����^����ꂽ��
     �v�f����0�ŕԂ��ꍇ�͈ȉ��̏��������s
     �v�f����1�œ��e���󕶎�������悤�ɂ���ɂ�
     �ȉ��̏��������s���Ȃ��B}
{----------------------------------------
  if Value = EmptyStr then
  begin
    Exit;
  end;
//----------------------------------------}

  Len := Length(Value);

  StartIndex := 0;
  EndIndex := 0;

  case Style of
    dsLineBreaks:
    begin
      {��[abc\r\n][\r\n][def\r\n]�ƂȂ�
         ��؂蕶�������������ꏊ=i��
         ��؂蕶���̒����𑫂��āA��؂蕶���̍Ō�̈ʒu
         ��EndIndex�����߂Ă��܂�}
      i := 1; while (i <= Len) do
      begin
        DelimitersIndex := Delimiters_IndexOf(i);

        if DelimitersIndex <> -1 Then
        begin
          EndIndex := i + Length(Delimiters[DelimitersIndex]) - 1;
          Self.Add(CopyIndex(Value, StartIndex, EndIndex));
          i := EndIndex + 1;
          StartIndex := i;
        end else
        begin
          EndIndex := i;
          Inc(i);
        end;
      end;
      Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
    end;

    dsNoDelimInEmpty:
    begin
      {��[abc][][def]�ƂȂ�
         ��؂蕶�������������ꏊ=i��
         1�����O���؂���ׂ��ʒu
         ��EndIndex�ɂȂ�܂�}
      i := 1; while (i <= Len) do
      begin
        DelimitersIndex := Delimiters_IndexOf(i);

        if DelimitersIndex <> -1 Then
        begin
          EndIndex := i - 1;
          Self.Add(CopyIndex(Value, StartIndex, EndIndex));
          i := i + Length(Delimiters[DelimitersIndex]);
          StartIndex := i;
        end else
        begin
          EndIndex := i;
          Inc(i);
        end;
      end;
      Self.Add(CopyIndex(Value, StartIndex, EndIndex));
    end;

    dsNoDelimNoEmpty:
    begin
		{��[ABC][DEF]
		   �󕶎�����؂蕶�����ǉ�����Ȃ�}
      i := 1; while (i <= Len) do
      begin
        DelimitersIndex := Delimiters_IndexOf(i);

        if DelimitersIndex <> -1 Then
        begin
          EndIndex := i - 1;
          Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
          i := i + Length(Delimiters[DelimitersIndex]);
          StartIndex := i;
        end else
        begin
          EndIndex := i;
          Inc(i);
        end;
      end;
      Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
    end;

    dsInDelimInEmpty:
    begin
      {��[ABC][\r\n][][\r\n][DEF][\r\n]}
      i := 1; while (i <= Len) do
      begin
        DelimitersIndex := Delimiters_IndexOf(i);

        if DelimitersIndex <> -1 Then
        begin
          EndIndex := i - 1;
          Self.Add(CopyIndex(Value, StartIndex, EndIndex));
          Self.Add(Copy(Value, EndIndex+1, Length(Delimiters[DelimitersIndex])));
          i := i + Length(Delimiters[DelimitersIndex]);
          StartIndex := i;
        end else
        begin
          EndIndex := i;
          Inc(i);
        end;
      end;
      Self.Add(CopyIndex(Value, StartIndex, EndIndex));
    end;

    dsInDelimNoEmpty:
    begin
      {��[ABC][\r\n][\r\n][DEF][\r\n]}
      i := 1; while (i <= Len) do
      begin
        DelimitersIndex := Delimiters_IndexOf(i);

        if DelimitersIndex <> -1 Then
        begin
          EndIndex := i - 1;
          Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
          Self.Add(Copy(Value, EndIndex+1, Length(Delimiters[DelimitersIndex])));
          i := i + Length(Delimiters[DelimitersIndex]);
          StartIndex := i;
        end else
        begin
          EndIndex := i;
          Inc(i);
        end;
      end;
      Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
    end;
  end;

//  i := 1; while (i <= Len) do
//  begin
//    DelimitersIndex := Delimiters_IndexOf(i);
//
//    if DelimitersIndex <> -1 Then
//    begin
//      case Style of
//      dsLineBreaks:
//      begin
//        {��[abc\r\n][\r\n][def\r\n]�ƂȂ�
//           ��؂蕶�������������ꏊ=i��
//           ��؂蕶���̒����𑫂��āA��؂蕶���̍Ō�̈ʒu
//           ��EndIndex�����߂Ă��܂�}
//        EndIndex := i + Length(Delimiters[DelimitersIndex]) - 1;
//        Self.Add(CopyIndex(Value, StartIndex, EndIndex));
//        i := EndIndex + 1;
//        StartIndex := i;
//      end;
//
//      dsNoDelimInEmpty:
//      begin
//        {��[abc][][def]�ƂȂ�
//           ��؂蕶�������������ꏊ=i��
//           1�����O���؂���ׂ��ʒu
//           ��EndIndex�ɂȂ�܂�}
//        EndIndex := i - 1;
//        Self.Add(CopyIndex(Value, StartIndex, EndIndex));
//        i := i + Length(Delimiters[DelimitersIndex]);
//        StartIndex := i;
//      end;
//
//      dsNoDelimNoEmpty:
//      begin
//		{��[ABC][DEF]
//		   �󕶎�����؂蕶�����ǉ�����Ȃ�}
//        EndIndex := i - 1;
//        Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
//        i := i + Length(Delimiters[DelimitersIndex]);
//        StartIndex := i;
//      end;
//
//      dsInDelimInEmpty:
//      begin
//        {��[ABC][\r\n][][\r\n][DEF][\r\n]}
//        EndIndex := i - 1;
//        Self.Add(CopyIndex(Value, StartIndex, EndIndex));
//        Self.Add(Copy(Value, EndIndex+1, Length(Delimiters[DelimitersIndex])));
//        i := i + Length(Delimiters[DelimitersIndex]);
//        StartIndex := i;
//      end;
//
//      dsInDelimNoEmpty:
//      begin
//        {��[ABC][\r\n][\r\n][DEF][\r\n]}
//        EndIndex := i - 1;
//        Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
//        Self.Add(Copy(Value, EndIndex+1, Length(Delimiters[DelimitersIndex])));
//        i := i + Length(Delimiters[DelimitersIndex]);
//        StartIndex := i;
//      end;
//
//      end;
//    end else
//    begin
//      EndIndex := i;
//      Inc(i);
//    end;
//  end;
//
//  {���Ō�Ɏc��������������ꍇ�͎擾����
//     �Ō�ɋ�؂蕶��������ꍇ��StartIndex��
//     Length�𒴂���̂Ŏ擾�ł��Ȃ����炱���OK}
//  case Style of
//
//  dsNoDelimInEmpty, dsInDelimInEmpty:
//  begin
//    Self.Add(CopyIndex(Value, StartIndex, EndIndex));
//  end;
//
//  dsLineBreaks, dsNoDelimNoEmpty, dsInDelimNoEmpty:
//  begin
//    Add_CopyIndex_NotEmptyStr(StartIndex, EndIndex, Len);
//  end;
//
//  end;

end;

{-------------------------------
//      ��؂蕶�����w�肵�ĕ�����𕪊�����
�@�\:
���l:       StringList.DelimitedText�̋@�\��
            �����悤�ȋ@�\�Ƃ��Ďg����
����:       2010/02/23(��)
//--��----------------------��--}
procedure TCommonStringRecordList.SetDelimitedText(const Value: TRecord;
 Delimiters: array of TRecord);
begin
  SetBaseText(Value, Delimiters, dsNoDelimInEmpty);
end;
//--��----------------------��--


{---------------------------------------
    ��؂蕶�����w�肵�ĘA��������������擾����
�@�\:   
���l:   
����:   2011/06/13(��)
        �E	�쐬
            CommaText�̓��o�͂Ɠ����悤�ɂ���
}//(*-----------------------------------
function TCommonStringRecordList.GetDelimitedText(Delimiter: TRecord): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Self.Count - 1 do
  begin
    Result := Result + Items[I] + Delimiter;
  end;
  Result := ExcludeLastStr(Result, Delimiter);
end;
//------------------------------------*)


{$endif}




