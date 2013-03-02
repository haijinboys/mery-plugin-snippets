{ --��---------------------------��--
�ėp���ʏ����֐����j�b�g
2004/08/18
�E�쐬
�ERoundOFF�֐��Ȃǂ�����
�ECeilEx/FloorEx������
2004/10/02
�ERandomRangeEx������

//--��---------------------------��-- }
unit MathUnit;

interface

uses
  Math,
uses_end;

function RoundOff(X: Extended): Int64;
function RoundOffEx(const X: Extended; DigitNumber: Integer): Extended;
function IsSame(A, B: Extended; e: Extended=0): Boolean;
function CeilEx(const X: Extended; DigitNumber: Integer): Extended;
function FloorEx(const X: Extended; DigitNumber: Integer): Extended;
function TruncEx(const X: Extended; DigitNumber: Integer): Extended;

function RandomRangeEx(const AFrom, ATo: Extended; Digit: Byte): Extended;

function CheckRange(Min, Value, Max: Integer): Boolean;
function Digit(Value: Cardinal): Integer;

implementation

{-------------------------------
//  HELP�ɂ̂��Ă���RoundOff
���l:
����:       2004/08/18
              Longint����Int64�ɕύX����
//--��----------------------��--}
function RoundOff(X: Extended): Int64;
begin
  if x >= 0 then Result := Trunc(x + 0.5)
  else Result := Trunc(x - 0.5);
end;
//--��----------------------��--

{-------------------------------
//  RoundOffEx
�@�\:       �C�ӂ̌��Ŏl�̌ܓ����܂��B
��������:   X: �l�̌ܓ��Ώ�
            DigitNumber: ����
              3:100�̌�
              2:10�̌�
              1:�ꌅ��
              0:�������Ȃ�
              -1:�����_����(�ʏ��RoundOff�Ɠ�������)
              -2:�����_����
              -3:�����_��O��
�߂�l:     �l�̌ܓ����X
            �����ł��Ȃ��ꍇX�̒l���̂܂܂�����͂�
���l:
����:       2001/09/04
//--��----------------------��--}
function RoundOffEx(const X: Extended; DigitNumber: Integer): Extended;
var
  CalcDigit: Extended;
begin
  Result := X;
  if X = 0 then Exit;

  case DigitNumber of
    0: Exit;
    1..High(DigitNumber):
    begin
      CalcDigit := IntPower(10, DigitNumber);
      Result := Roundoff(X / CalcDigit) * CalcDigit;
    end;
    Low(DigitNumber)..-1:
    begin
      CalcDigit := IntPower(10, Abs(DigitNumber)-1);
      Result := Roundoff(X * CalcDigit) / CalcDigit;
    end;
  end;
end;
//--��----------------------��--

{-------------------------------
//  IsSame
�@�\:       �K���ɏ������덷�͈͓̔���
            ���������_�l�����������ǂ����𒲂ׂ�֐�
��������:   A, B: ��r�Ώ�
            e: �}�̌덷
�߂�l:     true:������ false:�������Ȃ�
���l:
����:       2001/09/05
//--��----------------------��--}
function IsSame(A, B: Extended; e: Extended=0): Boolean;
begin
  Result := Abs(A-B) <= e;
end;
//--��----------------------��--

{---------------------------------------
    CeilEx/FloorEx/TruncEx
�@�\:   �C�ӂ̌��Ő؂�グ/�؂艺��/�؎̂Ă��܂�
����:	X: �v�Z�Ώ�
        DigitNumber: ����
          3:100�̌��������A1000�̌��Ŋۂ�
          2:10�̌��������A 100�̌��Ŋۂ�
          1:�ꌅ�ڂ������A 10�̌����ۂ�
          0:�������Ȃ�
          -1:�����_����(�ʏ��RoundOff�Ɠ�������)
          -2:�����_����
          -3:�����_��O��
���l:   �؂�グ�͐��̐�Βl�����A�؂艺���͕��̖����������
        �s����̂ŁA���̒l�̏ꍇ����ɋC�����邱�ƁB
����:   2011/09/12(��)
        �E  TruncEx��ǉ�
}//(*-----------------------------------
function CeilEx(const X: Extended; DigitNumber: Integer): Extended;
var
  CalcDigit: Extended;
begin
  Result := X;
  if X = 0 then Exit;

  case DigitNumber of
    0: Exit;
    1..High(DigitNumber):
    begin
      CalcDigit := IntPower(10, DigitNumber);
      Result := Math.Ceil(X / CalcDigit) * CalcDigit;
    end;
    Low(DigitNumber)..-1:
    begin
      CalcDigit := IntPower(10, Abs(DigitNumber)-1);
      Result := Math.Ceil(X * CalcDigit) / CalcDigit;
    end;
  end;
end;

function FloorEx(const X: Extended; DigitNumber: Integer): Extended;
var
  CalcDigit: Extended;
begin
  Result := X;
  if X = 0 then Exit;

  case DigitNumber of
    0: Exit;
    1..High(DigitNumber):
    begin
      CalcDigit := IntPower(10, DigitNumber);
      Result := Math.Floor(X / CalcDigit) * CalcDigit;
    end;
    Low(DigitNumber)..-1:
    begin
      CalcDigit := IntPower(10, Abs(DigitNumber)-1);
      Result := Math.Floor(X * CalcDigit) / CalcDigit;
    end;
  end;
end;

function TruncEx(const X: Extended; DigitNumber: Integer): Extended;
begin
  Result := X;
  if X = 0 then Exit;

  if 0 < X then
  begin
    Result := FloorEx(X, DigitNumber);
  end else
  begin
    Result := CeilEx(X, DigitNumber);
  end;
end;
//------------------------------------*)

{-------------------------------
//  RandomRangeEx
�@�\:       �C�ӌ��͈̔͂�RandomRange����֐�
��������:   AFrom/ATo: �͈�
            Digit: ����
              1:�����_1��
              2:�����_2��
              3:�����_3��
              0:�������Ȃ�
�߂�l:     AFrom/ATo�Ŏ������͈̗͂���
���l:
����:       2004/10/02
//--��----------------------��--}
function RandomRangeEx(const AFrom, ATo: Extended; Digit: Byte): Extended;
var
  CalcDigit: Extended;
begin
  CalcDigit := IntPower(10, Digit); //
  Result := RandomRange(RoundOff(AFrom*CalcDigit), RoundOff(ATo*CalcDigit)) / CalcDigit;
end;
//--��----------------------��--

{-------------------------------
//  ���l���͈͓��ɂ��邩�ǂ������ׂ�֐�
���l:       Math Unit �� InRange �֐��Ɠ���
����:       2005/11/23
//--��----------------------��--}
function CheckRange(Min, Value, Max: Integer): Boolean;
begin
  if (Min <= Value) and (Value <= Max) then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;
end;
//--��----------------------��--

{-------------------------------
//  ���������߂�
�@�\:   0�`���̐��̌��������߂܂�
�߂�l: ����
���l:   uses Math���K�v
        99999996�`99999999�̒l��
        case1�ł͌듮�삵�ċ��܂�Ȃ�
        case2�͐��m�����v�Z�񐔂������Ȃ�̂�
        case3���P�������K��
����:   2003/03/13
        2011/09/12(��)
        �E  �����̃R�[�h��case1�ɂ���case3�܂ō쐬
//--��----------------------��--}
function Digit(Value: Cardinal): Integer;
begin
  case 3 of
    1: 
    begin
      if Value = 0 then
        Result := 1
      else
        Result := Trunc(Log10(Value))+1;
    end;
  
    2: 
    begin
      Result := 1;
      while IntPower(10, Result) <= Value do
      begin
        Inc(Result);
        if High(Cardinal) < IntPower(10, Result) then Break;
      end;
    end;

    3: 
    begin
      Result := 1;
      if Value < 10 then Exit;
      Inc(Result);
      if Value < 100 then Exit;
      Inc(Result);
      if Value < 1000 then Exit;
      Inc(Result);
      if Value < 10000 then Exit;
      Inc(Result);
      if Value < 100000 then Exit;
      Inc(Result);
      if Value < 1000000 then Exit;
      Inc(Result);
      if Value < 10000000 then Exit;
      Inc(Result);
      if Value < 100000000 then Exit;
      Inc(Result);
      if Value < 1000000000 then Exit;
      Inc(Result);
      //High(Cardinal)=2147483647;�ōő�10��
 	end;
  end; //case
end;
//--��----------------------��--


end.

