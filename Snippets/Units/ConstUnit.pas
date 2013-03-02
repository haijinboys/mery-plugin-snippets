unit ConstUnit;

interface

const
  EmptyStr = '';
  CR = #$D;     //#13
  LF = #$A;     //#10
  TAB= #$9;     //#9
  NullStr = #$0;//#0
  EN = '\';
  CRLF = #$D#$A;//#13#10
  Space = ' ';
  ZenkakuSpace = '�@';

  SingleQuote = '''';
  DoubleQuote = '"';

  Comma = ',';
  Colon = ':';
  SemiColon = ';';
  Period = '.';

const
  VK_ALT = 18;      //VK_MENU = 18;
  VK_RALT = 165;    //VK_RMENU = 165;
  VK_WIN = 91;      //VK_LWIN;
  VK_PAGEUP = 33;   //VK_PRIOR = 33;
  VK_PAGEDOWN = 34; //VK_NEXT = 34;

const zenHiraTbl: String =      // �S�p�Ђ炩��
    '�����������������������������������ĂƂȂɂʂ˂̂͂Ђӂւ�'+
    '�܂݂ނ߂���������������񂪂����������������������Âł�'+
    '�΂тԂׂڂς҂Ղ؂ۂ���������������';
const zenKataTbl: String =      // �S�p�J�^�J�i
    '�A�C�E�G�I�J�L�N�P�R�T�V�X�Z�\�^�`�c�e�g�i�j�k�l�m�n�q�t�w�z'+
    '�}�~�����������������������������K�M�O�Q�S�U�W�Y�[�]�_�a�d�f�h'+
    '�o�r�u�x�{�p�s�v�y�|�@�B�D�F�H���������b�[';
const hanKanaTbl: String =      // ���p�J�^�J�i
    '�������������������������������������������ܦݧ��������߰�����';
    //�����[���[���Ɣ��p�J�^�J�i�͑S�p�ɕϊ�����Ă��܂��܂�
const zenNumberTbl: String =    // �S�p����
    '�P�Q�R�S�T�U�V�W�X�O';
const hanNumberTbl: String =    // ���p����
    '1234567890';
const zenAlphaTbl: String =     // �S�p�p����
    '�`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y'+
    '����������������������������������������������������';
const hanAlphaTbl: String =     // ���p�p����
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
const zenMarkTbl: String =      // �S�p�L��(�����Ƒ�R���邯�ǈꕔ�̂�)
    '�|�D�������������H�^�C�����i�j�o�p�b�G�F�`�{�M�I�V���Q�O�E';
const hanMarkTbl: String =      // ���p�L��
    '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
const zenSpaceTbl: String = '�@';   // �S�p�X�y�[�X
const hanSpaceTbl: String = ' ';    // ���p�X�y�[�X

const CtrlCharTbl: String =     //���䕶��
    #$01#$02#$03#$04#$05#$06#$07#$08#$09#$0A#$0B#$0C#$0D#$0E#$0F+
    #$10#$11#$12#$13#$14#$15#$16#$17#$18#$19#$1A#$1B#$1C#$1D#$1E#$1F;


implementation

end.
