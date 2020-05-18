unit	UShared;


 //	"Bit??"  is the number you get when setting ONLY bit  "??"      of a variable.
 //	"Bits??" is the number you get when setting the first "??" bits of a variable.
 //
 //	The "RevBits_??"  functions reverse the entire bit order in an integer value.
 //	The "RevBytes_??" functions reverse only the byte  order in an integer value.
 //
 //	In Delphi, boolean variables used as array selectors must not have any bits
 //	set except bit 0.  Fix_Bool returns a boolean with only this bit set (or not).
 //
 //	ShiftLeft can be used with negative shifting steps.
 //
 //	"Read_Backw" does not really 'read backwards', it reads forwards but updates
 //	the stream position as if it had read backwards (used by the tZMV decoder).


interface  //-----------------------------------------------------------------------------------
uses	Windows,
	ActiveX, Classes, Clipbrd, ComCtrls, Consts, Contnrs, Controls, Dialogs,
	ExtCtrls, Forms, Graphics, Math, Messages, ShlObj, StdCtrls, SysUtils,
	sgGZIP,
	UQWord;


const	crHand		=	1;				// cursor constants
	crMove		=	2;
	crPick		=	3;
	crZoom		=	4;

	max_Previews	=	8;
	TimeFormat	=	'yyyy"-"mm"-"dd" "hh":"nn":"ss';

	CRLF		=	#13#10;
	Tab		=	#9;
	NullColor	:	TRGBQuad  =  ();

				// GUI strings
	MSG_NoFile	=	'File not found.';
	MSG_NoInt	=	'No integer number in the range of 0..2147483647 has been entered.';
	MSG_SelDir	=	'Select a directory containing ';

{	mt_AppActivate		=	'Appl. activated'	;  // internal messages - still
	mt_AppDeactivate	=	'Appl. deactivated'	;  // fast since not the text is
	mt_Load_Cfg		=	'load config'		;  // compared, but just the
	mt_New_Cart		=	'new Cart'		;  // pointers (I hope)
	mt_New_ListItem		=	'new ListItem'		;
	mt_New_PalCell		=	'new PalCell'		;
	mt_New_PalColors	=	'new palette colors'	;
	mt_New_ROM		=	'new Cart.ROM'		;
	mt_New_State		=	'new savestate'		;
	mt_New_StateMenuItem	=	'new savestate and menu item';
 //	mt_New_StatePreview	=	'new savestate preview'	;
	mt_New_SNES		=	'new SNES'		;
	mt_New_S9X		=	'new S9X'		;
	mt_New_SGT		=	'new SGT'		;
	mt_New_SPC		=	'new SPC'		;
	mt_New_SRAM		=	'new SRAM'		;
	mt_New_SSL		=	'new SSL'		;
	mt_New_SSL_Preview	=	'new SSL.Preview'	;
	mt_New_WRAM		=	'new WRAM'		;
	mt_New_ZST_Data		=	'new ZST.Data'		;
	mt_New_ZST_Preview	=	'new ZST.Preview'	;
	mt_New_ZST_Stream	=	'new ZST.Stream'	;
	mt_Save_Cfg		=	'save config'		;
	mt_StartUp		=	'startup'		;
	mt_UpdateFileDlgs	=	'update file dialogs'	;}


	NullPoint	:	TPoint				= (x:  0;  y:  0	);
	Point_64x56	:	TPoint				= (x: 64;  y: 56	);
	NullRect	:	TRect				= (			);
	Str_Bool	:	array[Boolean] of String	= ('False', 'True'	);
	Str_BinChars	=	'01';
	Str_DecChars	=	'0123456789';
	Str_HexChars	=	'0123456789ABCDEF';		// indices 1..16
	Base36_Chars	=	'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	DecChars	:	array[$0..$9] of Char		// indices 0..9
			=	'0123456789';

	HexChars	:	array[$0..$F] of Char		// indices 0..15
			=	'0123456789ABCDEF';

	StrHex_Byte	:	array[Byte] of String[3]	// must be exactly 4 bytes
			=	({$INCLUDE HexStr\table.inc});  // 0=length, 1+2=hex, 3=NULL

	CRC32_Table	:	array[Byte] of DWord
			=	({$INCLUDE CRC32.inc});

	_32K		=	DWord($8000) * 1;		//  32 KB
	_64K		=	DWord($8000) * 2;		//  64 KB
	_128K		=	DWord($8000) * 4;		// 128 KB
	_1MBit		=	(1 * 1000 * 1000) div 8;	// 10^6 bit

	BankSize	=	_32K;

	VK_PgUp		=	VK_PRIOR;			// $21
	VK_PgDown	=	VK_NEXT ;			// $22
	VK_Pos1		=	VK_Home;			// $24
	VK_0		=	Ord('0');			// $30
	VK_1		=	Ord('1');			// $31
	VK_2		=	Ord('2');			// $32
	VK_3		=	Ord('3');			// $33
	VK_4		=	Ord('4');			// $34
	VK_5		=	Ord('5');			// $35
	VK_6		=	Ord('6');			// $36
	VK_7		=	Ord('7');			// $37
	VK_8		=	Ord('8');			// $38
	VK_9		=	Ord('9');			// $39
	VK_A		=	Ord('A');			// $41
	VK_B		=	Ord('B');			// $42
	VK_C		=	Ord('C');			// $43
	VK_D		=	Ord('D');			// $44
	VK_E		=	Ord('E');			// $45
	VK_F		=	Ord('F');			// $46
	VK_G		=	Ord('G');			// $47
	VK_H		=	Ord('H');			// $48
	VK_I		=	Ord('I');			// $49
	VK_J		=	Ord('J');			// $4A
	VK_K		=	Ord('K');			// $4B
	VK_L		=	Ord('L');			// $4C
	VK_M		=	Ord('M');			// $4D
	VK_N		=	Ord('N');			// $4E
	VK_O		=	Ord('O');			// $4F
	VK_P		=	Ord('P');			// $50
	VK_Q		=	Ord('Q');			// $51
	VK_R		=	Ord('R');			// $52
	VK_S		=	Ord('S');			// $53
	VK_T		=	Ord('T');			// $54
	VK_U		=	Ord('U');			// $55
	VK_V		=	Ord('V');			// $56
	VK_W		=	Ord('W');			// $57
	VK_X		=	Ord('X');			// $58
	VK_Y		=	Ord('Y');			// $59
	VK_Z		=	Ord('Z');			// $5A
	VK_Num0		=	VK_NUMPAD0;			// $60
	VK_Num1		=	VK_NUMPAD1;			// $61
	VK_Num2		=	VK_NUMPAD2;			// $62
	VK_Num3		=	VK_NUMPAD3;			// $63
	VK_Num4		=	VK_NUMPAD4;			// $64
	VK_Num5		=	VK_NUMPAD5;			// $65
	VK_Num6		=	VK_NUMPAD6;			// $66
	VK_Num7		=	VK_NUMPAD7;			// $67
	VK_Num8		=	VK_NUMPAD8;			// $68
	VK_Num9		=	VK_NUMPAD9;			// $69

	Bit0		=	QWord(1) SHL 00;  Bits0  = Bit0  - 1;  // 00000000b
	Bit1		=	QWord(1) SHL 01;  Bits1  = Bit1  - 1;  // 00000001b
	Bit2		=	QWord(1) SHL 02;  Bits2  = Bit2  - 1;  // 00000011b
	Bit3		=	QWord(1) SHL 03;  Bits3  = Bit3  - 1;  // 00000111b
	Bit4		=	QWord(1) SHL 04;  Bits4  = Bit4  - 1;  // 00001111b
	Bit5		=	QWord(1) SHL 05;  Bits5  = Bit5  - 1;  // 00011111b
	Bit6		=	QWord(1) SHL 06;  Bits6  = Bit6  - 1;  // 00111111b
	Bit7		=	QWord(1) SHL 07;  Bits7  = Bit7  - 1;  // 01111111b
	Bit8		=	QWord(1) SHL 08;  Bits8  = Bit8  - 1;  // 11111111b
	Bit9		=	QWord(1) SHL 09;  Bits9  = Bit9  - 1;  // ...
	Bit10		=	QWord(1) SHL 10;  Bits10 = Bit10 - 1;
	Bit11		=	QWord(1) SHL 11;  Bits11 = Bit11 - 1;
	Bit12		=	QWord(1) SHL 12;  Bits12 = Bit12 - 1;
	Bit13		=	QWord(1) SHL 13;  Bits13 = Bit13 - 1;
	Bit14		=	QWord(1) SHL 14;  Bits14 = Bit14 - 1;
	Bit15		=	QWord(1) SHL 15;  Bits15 = Bit15 - 1;
	Bit16		=	QWord(1) SHL 16;  Bits16 = Bit16 - 1;
	Bit17		=	QWord(1) SHL 17;  Bits17 = Bit17 - 1;
	Bit18		=	QWord(1) SHL 18;  Bits18 = Bit18 - 1;
	Bit19		=	QWord(1) SHL 19;  Bits19 = Bit19 - 1;
	Bit20		=	QWord(1) SHL 20;  Bits20 = Bit20 - 1;
	Bit21		=	QWord(1) SHL 21;  Bits21 = Bit21 - 1;
	Bit22		=	QWord(1) SHL 22;  Bits22 = Bit22 - 1;
	Bit23		=	QWord(1) SHL 23;  Bits23 = Bit23 - 1;
	Bit24		=	QWord(1) SHL 24;  Bits24 = Bit24 - 1;
	Bit25		=	QWord(1) SHL 25;  Bits25 = Bit25 - 1;
	Bit26		=	QWord(1) SHL 26;  Bits26 = Bit26 - 1;
	Bit27		=	QWord(1) SHL 27;  Bits27 = Bit27 - 1;
	Bit28		=	QWord(1) SHL 28;  Bits28 = Bit28 - 1;
	Bit29		=	QWord(1) SHL 29;  Bits29 = Bit29 - 1;
	Bit30		=	QWord(1) SHL 30;  Bits30 = Bit30 - 1;
	Bit31		=	QWord(1) SHL 31;  Bits31 = Bit31 - 1;
	Bit32		=	QWord(1) SHL 32;  Bits32 = Bit32 - 1;
	Bit33		=	QWord(1) SHL 33;  Bits33 = Bit33 - 1;
	Bit34		=	QWord(1) SHL 34;  Bits34 = Bit34 - 1;
	Bit35		=	QWord(1) SHL 35;  Bits35 = Bit35 - 1;
	Bit36		=	QWord(1) SHL 36;  Bits36 = Bit36 - 1;
	Bit37		=	QWord(1) SHL 37;  Bits37 = Bit37 - 1;
	Bit38		=	QWord(1) SHL 38;  Bits38 = Bit38 - 1;
	Bit39		=	QWord(1) SHL 39;  Bits39 = Bit39 - 1;
	Bit40		=	QWord(1) SHL 40;  Bits40 = Bit40 - 1;
	Bit41		=	QWord(1) SHL 41;  Bits41 = Bit41 - 1;
	Bit42		=	QWord(1) SHL 42;  Bits42 = Bit42 - 1;
	Bit43		=	QWord(1) SHL 43;  Bits43 = Bit43 - 1;
	Bit44		=	QWord(1) SHL 44;  Bits44 = Bit44 - 1;
	Bit45		=	QWord(1) SHL 45;  Bits45 = Bit45 - 1;
	Bit46		=	QWord(1) SHL 46;  Bits46 = Bit46 - 1;
	Bit47		=	QWord(1) SHL 47;  Bits47 = Bit47 - 1;
	Bit48		=	QWord(1) SHL 48;  Bits48 = Bit48 - 1;
	Bit49		=	QWord(1) SHL 49;  Bits49 = Bit49 - 1;
	Bit50		=	QWord(1) SHL 50;  Bits50 = Bit50 - 1;
	Bit51		=	QWord(1) SHL 51;  Bits51 = Bit51 - 1;
	Bit52		=	QWord(1) SHL 52;  Bits52 = Bit52 - 1;
	Bit53		=	QWord(1) SHL 53;  Bits53 = Bit53 - 1;
	Bit54		=	QWord(1) SHL 54;  Bits54 = Bit54 - 1;
	Bit55		=	QWord(1) SHL 55;  Bits55 = Bit55 - 1;
	Bit56		=	QWord(1) SHL 56;  Bits56 = Bit56 - 1;
	Bit57		=	QWord(1) SHL 57;  Bits57 = Bit57 - 1;
	Bit58		=	QWord(1) SHL 58;  Bits58 = Bit58 - 1;
	Bit59		=	QWord(1) SHL 59;  Bits59 = Bit59 - 1;
	Bit60		=	QWord(1) SHL 60;  Bits60 = Bit60 - 1;
	Bit61		=	QWord(1) SHL 61;  Bits61 = Bit61 - 1;
	Bit62		=	QWord(1) SHL 62;  Bits62 = Bit62 - 1;
	Bit63		=	QWord(1) SHL 63;  Bits63 = Bit63 XOR Bits62;
						  Bits64 = $FFFFFFFFFFFFFFFF;


type	TSNES_Address	=	Bits0..Bits24;

	TBooleans	=	packed array[Bits0..Bits31 - 1] of Byte;  // arrays of 2 GB - 1
	TBytes		=	packed array[Bits0..Bits31 - 1] of Byte;
	TChars		=	packed array[Bits0..Bits31 - 1] of AnsiChar;
	TWords		=	packed array[Bits0..Bits30 - 1] of Word;
	TDWords		=	packed array[Bits0..Bits29 - 1] of DWord;

	pByte		=	^Byte;
	pWord		=	^Word;
	pDWord		=	^DWord;
	pQWord		=	^QWord;

	pBooleans	=	^TBooleans;
	pBytes		=	^TBytes;
	pChars		=	^TChars;
	pWords		=	^TWords;
	pDWords		=	^TDWords;

	TLine08		=	TBytes;				// basic bitmap scanline
	TLine15		=	TWords;				//  ext. bitmap scanline
	TLine16		=	TWords;				//  ext. bitmap scanline
	TLine32		=	TDWords;			//  ext. bitmap scanline

	TPalette	=	packed array[Bits0..Bits8] of TRGBQuad;  // for SetDIBColorTable

	TBooleans2	=	packed array[0..    2 - 1] of Boolean;
	TBooleans3	=	packed array[0..    3 - 1] of Boolean;
	TBooleans4	=	packed array[0..    4 - 1] of Boolean;
	TBooleans5	=	packed array[0..    5 - 1] of Boolean;
	TBooleans6	=	packed array[0..    6 - 1] of Boolean;
	TBooleans256	=	packed array[0..  256 - 1] of Boolean;

	TBytes2		=	packed array[0..    2 - 1] of Byte;
	TBytes3		=	packed array[0..    3 - 1] of Byte;
	TBytes4		=	packed array[0..    4 - 1] of Byte;
	TBytes5		=	packed array[0..    5 - 1] of Byte;
	TBytes6		=	packed array[0..    6 - 1] of Byte;
	TBytes7		=	packed array[0..    7 - 1] of Byte;
	TBytes8		=	packed array[0..    8 - 1] of Byte;
	TBytes9		=	packed array[0..    9 - 1] of Byte;
	TBytes16	=	packed array[0..   16 - 1] of Byte;
	TBytes25	=	packed array[0..   25 - 1] of Byte;
	TBytes32	=	packed array[0..   32 - 1] of Byte;
	TBytes64	=	packed array[0..   64 - 1] of Byte;
	TBytes128	=	packed array[0..  128 - 1] of Byte;
	TBytes160	=	packed array[0..  160 - 1] of Byte;
	TBytes196	=	packed array[0..  196 - 1] of Byte;
	TBytes256	=	packed array[0..  256 - 1] of Byte;
	TBytes512	=	packed array[0..  512 - 1] of Byte;
	TBytes544	=	packed array[0..  544 - 1] of Byte;
	TBytes1024	=	packed array[0.. 1024 - 1] of Byte;
	TBytes2K	=	packed array[0.. 2048 - 1] of Byte;
	TBytes32K	=	packed array[0.. _32K - 1] of Byte;
	TBytes64K	=	packed array[0.. _64K - 1] of Byte;
	TBytes128K	=	packed array[0.._128K - 1] of Byte;

	pBytes8		=	^TBytes8;

	TChars2		=	packed array[0..    2 - 1] of Char;
	TChars3		=	packed array[0..    3 - 1] of Char;
	TChars4		=	packed array[0..    4 - 1] of Char;
	TChars5		=	packed array[0..    5 - 1] of Char;
	TChars6		=	packed array[0..    6 - 1] of Char;
	TChars7		=	packed array[0..    7 - 1] of Char;
	TChars8		=	packed array[0..    8 - 1] of Char;
	TChars9		=	packed array[0..    9 - 1] of Char;
	TChars16	=	packed array[0..   16 - 1] of Char;
	TChars20	=	packed array[0..   20 - 1] of Char;
	TChars21	=	packed array[0..   21 - 1] of Char;
	TChars32	=	packed array[0..   32 - 1] of Char;
	TChars64	=	packed array[0..   64 - 1] of Char;
	TChars128	=	packed array[0..  128 - 1] of Char;
	TChars256	=	packed array[0..  256 - 1] of Char;
	TChars512	=	packed array[0..  512 - 1] of Char;

	TWords2		=	packed array[0..    2 - 1] of Word;
	TWords3		=	packed array[0..    3 - 1] of Word;
	TWords4		=	packed array[0..    4 - 1] of Word;
	TWords16	=	packed array[0..   16 - 1] of Word;
	TWords256	=	packed array[0..  256 - 1] of Word;

	TDWords2	=	packed array[0..    2 - 1] of DWord;
	TDWords3	=	packed array[0..    3 - 1] of DWord;
	TDWords4	=	packed array[0..    4 - 1] of DWord;


	TBoolPoint	=	Record
				x			:	Boolean;
				y			:	Boolean;
				end;


	TWordPoint	=	Record
				x			:	Word;
				y			:	Word;
				end;


	TLV_Status	=	Record
				ItemCaption		:	String;
				Offset			:	Integer;
				end;


	pSearchRec	=	^TSearchRec;


var	AppPath		:	String;
	DialogActive	:	Boolean;
	Dlg_FullPath	:	String;
	PPI_cur		:	Integer;			// PixelsPerInch (current)
	PPI_dev		:	Integer;			// PixelsPerInch (at design-time)
	quitting	:	Boolean;


function  _Byte			(var	DATA					) : pByte	;
function  _Word			(var	DATA					) : pWord	;
function  _DWord		(var	DATA					) : pDWord	;
function  _QWord		(var	DATA					) : pQWord	;

function  RevBits_8		(const	Value	: Byte				) : Byte	;
function  RevBits_16		(const	Value	: Word				) : Word	;
function  RevBits_24		(const  Value	: TBytes3			) : TBytes3	;
function  RevBits_32		(const	Value	: DWord				) : DWord	;
function  RevBits_48		(const	Value	: QWord				) : QWord	;
function  RevBits_64		(const	Value	: QWord				) : QWord	;

function  RevBytes_16		(const	Value	: Word				) : Word	;
function  RevBytes_24		(const	Value	: TBytes3			) : TBytes3	;
function  RevBytes_32		(const	Value	: DWord				) : DWord	;
function  RevBytes_48		(const	Value	: QWord				) : QWord	;
function  RevBytes_64		(const	Value	: QWord				) : QWord	;

function  RevColors_15		(const	Value	: Word				) : Word;

procedure MemClear		(var	DATA	; const Count : Integer		)		;
procedure MemCopy		(var	SRC,DEST; const Count : Integer		)		;
procedure MemFill		(var	DATA	; const Count : Integer		)		;
procedure MemNOT		(var	DATA	; const Count : Integer		)		;

function  Bin2Int		(const	Text	: String			) : QWord	;
function  Dec2Int		(const	Text	: String			) : QWord	;
function  Hex2Int		(	Text	: String			) : QWord	;
function  Int2Base36		(	Value	: QWord;  Digits : Byte		) : String	;
function  Int2Bin		(	Value	: QWord;  Digits : Byte		) : String	;
function  Int2Dec		(const	Value	: QWord;  Digits : Byte		) : String	;
function  Int2Hex		(const	Value	: QWord;  Digits : Byte		) : String	;
function  Byte2Hex		(const	Value	: Byte				) : String	;
function  ConvertError		(						) : Boolean	;

procedure Add_Hex		(var	Text	: String;  const Value : Int64;  const Digits : Byte);
function  Add_Magnification	(const	Text	: String;  const Value : Integer) : String	;
procedure Click_Btn		(const  Btn	: TToolButton			)		;
function  Color2RGB		(const	Color	: DWord				) : TRGBQuad	;
function  even			(const	Value	: Int64				) : Boolean	;
function  Get_Bits		(var	DATA	; const BitOffs, BitCount: DWord) : DWord	;
function  Get_CRC32		(var	DATA	; const Size : DWord		) : DWord	;
function  Fix_Bool		(const	Value	: Boolean			) : Boolean	;
function  Get_InvertedColor	(const	Color	: TColor			) : TColor	;
function  Get_FullName		(	FileName: String			) : String	;
function  is_AlphaNumeric	(const	Text	: String			) : Boolean	;
function  is_HexString		(const	Text	: String			) : Boolean	;
function  is_IntStr		(	Text	: String;  hex : Boolean	) : Boolean	;
function  is_NoNumber		(const	Text	: String			) : Boolean	;
function  No_Spaces		(const	Text	: String			) : String	;
function  No_ZeroChars		(const	Text	: String			) : String	;
function  ReverseStr		(const	Text	: String			) : String	;
function  RGB2Color		(const	Color	: TRGBQuad			) : TColor	;
function  Safe_ToInt		(const	Text	: String			) : Int64	;
function  ShiftLeft		(const	Value	, Digits : Integer		) : Integer	;
function  Signed_IntStr		(const	Value	: Integer			) : String	;
function  Swap_Color		(const	Color	: DWord				) : DWord	;
function  Swap_RGB		(const	Color	: TRGBQuad			) : TRGBQuad	;
function  StrOfStr		(const	Text	: String;  const Count : Integer) : String	;
function  Valid_Chars		(const	Text	, Chars : String		) : Boolean	;

procedure Changed_Edit		(const	Sender	: TObject			)		;
procedure Changed_LEdit		(const	Sender	: TObject			)		;
procedure Changed_Memo		(const	Sender	: TObject			)		;
procedure Clear_Bitmap		(const	Bitmap	: TBitmap			)		;
procedure Copy_Bitmap		(const	Bitmap	: TBitmap			)		;
procedure Copy_Font		(const	Src,Dest: TFont				)		;
procedure Create_Bitmap		(const	Image	: TImage;  xRes, yRes : Integer	)		;
function  Exec_ColorDlg		(const	Dialog	: TColorDialog			) : Boolean	;
function  Exec_DirDlg		(const	Text	: String;  var Dir : String;  Pos : TPoint) : Boolean;
function  Exec_FileDlg		(const	Dialog	: TOpenDialog			) : Boolean	;
function  Exec_FontDlg		(const	Dialog	: TFontDialog			) : Boolean	;
function  Key2Char		(const	VK	: Word				) : String	;
procedure Load_LVFav		(const	LV	: TListView			)		;
procedure LV_AddItem		(const  LV	: TListView;  SubCount : Integer)		;
function  MessageDlg		(const	Msg	: String;  DlgType : TMsgDlgType;  Buttons : TMsgDlgButtons;  HelpCtx : LongInt) : Word;
function  Same_Start		(const  String1	, String2 : String		) : Boolean	;
procedure Set_Buffering		(const  Control	: TWinControl			)		;
procedure Set_LVCount		(const	LV	: TListView;  DestCount, SubCount : Integer)	;
procedure Set_NumericInput	(const	Edit	: TEdit				)		;

function  FollowPath		(const FileName : String) : String;
function  GetDesktopPath	: String;

function  pressing_Alt		: Boolean;
function  pressing_Ctrl		: Boolean;
function  pressing_Shift	: Boolean;

procedure Global_Msg		(const	Src	: Pointer;  const Msg : String	)		;


 //  Unix time conversion functions
function  Get_UnixDateStr	(const	Value : DWord				) : String	;
function  Unix2DateTime		(	Value : DWord				) : TDateTime	;
function  DateTime2Unix		(	Value : TDateTime			) : DWord	;

 //  stream routines
procedure Compress		(const	Stream	: TMemoryStream			)		;
procedure Decompress		(const	Stream	: TMemoryStream			)		;
procedure Delete_Bytes		(const	Stream	: TMemoryStream;  const Offset, Count : DWord);
procedure Insert_Bytes		(const	Stream	: TMemoryStream;  Offset : DWord;  const Count : DWord;  var DATA);
procedure Read_Backw		(const	Stream	: TStream;  var DATA;  const Size : Integer)	;

implementation  //------------------------------------------------------------------------------
uses	UConsole, UForm_Main, UINI;


{$R cursors\cursors.res}					// load the cursors


const	ReverseBits	:	array[Byte] of Byte
			=	({$INCLUDE ReverseBits\table.inc});


var	_ConvertError	:	Boolean;


 // get a value from an address


function _Byte(var DATA) : pByte;
begin
Result := @DATA;
end;


function _Word(var DATA) : pWord;
begin
Result := @DATA;
end;


function _DWord(var DATA) : pDWord;
begin
Result := @DATA;
end;


function _QWord(var DATA) : pQWord;
begin
Result := @DATA;
end;


 // reverting bits


function RevBits_8(const Value : Byte) : Byte;
begin
Result := ReverseBits[Value];
end;


function RevBits_16(const Value : Word) : Word;
var	Src		:	TBytes2;
	Dest		:	TBytes2;
begin
Word(Src) := Value;
Dest[0] := ReverseBits[Src[1]];
Dest[1] := ReverseBits[Src[0]];
Result  := Word(Dest);
end;


function RevBits_24(const Value : TBytes3) : TBytes3;
begin
Result[0] := Value[2];
Result[1] := Value[1];
Result[2] := Value[0];
end;


function RevBits_32(const Value : DWord) : DWord;
var	Src		:	TBytes4;
	Dest		:	TBytes4;
begin
DWord(Src) := Value;
Dest[0] := ReverseBits[Src[3]];
Dest[1] := ReverseBits[Src[2]];
Dest[2] := ReverseBits[Src[1]];
Dest[3] := ReverseBits[Src[0]];
Result  := DWord(Dest);
end;


function RevBits_48(const Value : QWord) : QWord;
var	Src		:	TBytes8;
	Dest		:	TBytes8;
begin
QWord(Src) := Value;
Dest[0] := ReverseBits[Src[5]];
Dest[1] := ReverseBits[Src[4]];
Dest[2] := ReverseBits[Src[3]];
Dest[3] := ReverseBits[Src[2]];
Dest[4] := ReverseBits[Src[1]];
Dest[5] := ReverseBits[Src[0]];
Result  := QWord(Dest);
end;


function RevBits_64(const Value : QWord) : QWord;
var	Src		:	TBytes8;
	Dest		:	TBytes8;
begin
QWord(Src) := Value;
Dest[0] := ReverseBits[Src[7]];
Dest[1] := ReverseBits[Src[6]];
Dest[2] := ReverseBits[Src[5]];
Dest[3] := ReverseBits[Src[4]];
Dest[4] := ReverseBits[Src[3]];
Dest[5] := ReverseBits[Src[2]];
Dest[6] := ReverseBits[Src[1]];
Dest[7] := ReverseBits[Src[0]];
Result  := QWord(Dest);
end;


 // reverting bytes


function RevBytes_16(const Value : Word) : Word;
ASM
	XCHG	AH,	AL
END;


function RevBytes_24(const Value : TBytes3) : TBytes3;
var	Src		:	TBytes3;
	Dest		:	TBytes3;
begin
Src	:= Value;
Dest[0]	:= Src[2];
Dest[1]	:= Src[1];
Dest[2]	:= Src[0];
Result	:= Dest;
end;


function RevBytes_32(const Value : DWord) : DWord;
var	Src		:	TBytes4;
	Dest		:	TBytes4;
begin
DWord(Src) := Value;
Dest[0] := Src[3];
Dest[1] := Src[2];
Dest[2] := Src[1];
Dest[3] := Src[0];
Result  := DWord(Dest);
end;


function RevBytes_48(const Value : QWord) : QWord;
var	Src		:	TBytes8;
	Dest		:	TBytes8;
begin
QWord(Src) := Value;
Dest[0] := Src[5];
Dest[1] := Src[4];
Dest[2] := Src[3];
Dest[3] := Src[2];
Dest[4] := Src[1];
Dest[5] := Src[0];
Result  := QWord(Dest);
end;


function RevBytes_64(const Value : QWord) : QWord;
var	Src		:	TBytes8;
	Dest		:	TBytes8;
begin
QWord(Src) := Value;
Dest[0] := Src[7];
Dest[1] := Src[6];
Dest[2] := Src[5];
Dest[3] := Src[4];
Dest[4] := Src[3];
Dest[5] := Src[2];
Dest[6] := Src[1];
Dest[7] := Src[0];
Result  := QWord(Dest);
end;


function RevColors_15(const Value : Word) : Word;
var	B		:	Word;
	G		:	Word;
	R		:	Word;
begin
R := (Value SHR 00) AND Bits5;
G := (Value SHR 05) AND Bits5;
B := (Value SHR 10) AND Bits5;
Result := (R SHL 10) OR (G SHL 5) OR (B SHL 0);
end;


 // memory routines


procedure MemClear(var DATA;  const Count : Integer);
begin
FillChar(DATA, Count, 0);
end;


procedure MemCopy(var SRC, DEST;  const Count : Integer);
begin
Move(SRC, DEST, Count);
end;


procedure MemFill(var DATA;  const Count : Integer);
begin
FillChar(DATA, Count, Bits8);					// set all bits to 1
end;


procedure MemNOT(var DATA;  const Count : Integer);
var	Bytes		:	pBytes;
	i		:	Integer;
begin
Bytes := @DATA;
for i := 0 to (Count - 1) do  Bytes[i] := NOT Bytes[i];		// invert all bits
end;


 // misc tools


procedure Add_Hex(var Text : String;  const Value : Int64;  const Digits : Byte);
begin
Text := Text + IntToHex(Value, Digits);
end;


function Add_Magnification(const Text : String;  const Value : Integer) : String;
var	i, a, b		:	Integer;
begin
a := 1;
b := 1;
if (Value >= 0)	then  for i := +1 to Value do  a := a * 2
		else  for i := Value to -1 do  b := b * 2;
Result := Copy(Text, 1, Pos('(', Text)) + IntToStr(a) + ':' + IntToStr(b) + ')';
end;


procedure Changed_Edit(const Sender : TObject);
var	Edit		:	TEdit;
begin
Edit := (Sender as TEdit);
with Edit do begin
	ParentColor := {(not Enabled) or} (Text = '');
	if (not ParentColor) then Color := clWindow;
end;
end;


procedure Changed_LEdit(const Sender : TObject);
var	LEdit		:	tLabeledEdit;
begin
LEdit := (Sender as tLabeledEdit);
with LEdit do begin
	ParentColor := {(not Enabled) or} (Text = '');
	if (not ParentColor) then Color := clWindow;
end;
end;


procedure Changed_Memo(const Sender : TObject);
var	Memo		:	tMemo;
begin
Memo := (Sender as tMemo);
with Memo do begin
	ParentColor := (not Enabled) or (Text = '');
	if (not ParentColor) then Color := clWindow;
end;
end;


procedure Clear_Bitmap(const Bitmap : TBitmap);
var	y		:	SmallInt;
begin
with Bitmap do  for y := 0 to (Height - 1) do
	MemClear(ScanLine[y]^, Width);
end;


procedure Copy_Bitmap(const Bitmap : TBitmap);
begin
ClipBoard.Assign(Bitmap);
end;


procedure Copy_Font(const Src, Dest : TFont);
begin
with Src do begin
	Dest.Color	:= Color;
	Dest.Name	:= Name;
	Dest.Height	:= Height;
	Dest.Style	:= Style;
end;
end;


procedure Click_Btn(const Btn : TToolButton);			// click via code
begin
with Btn do begin
	Down := not Down;
	Click;							// calls event handler
end;
end;


function Color2RGB(const Color : DWord) : TRGBQuad;
var	tmp		:	TRGBQuad;
begin
DWord(tmp) := Color;
Result := Swap_RGB(tmp);
end;


procedure Create_Bitmap(const Image : TImage;  xRes, yRes : Integer);
var	BMP		:	TBitmap;
begin
BMP := TBitmap.Create;						// ownership won't change!
with BMP do begin
	PixelFormat := pf8Bit;
	Canvas.Brush.Color := clBlack;
	Width	:= xRes;
	Height	:= yRes;
	Image.Picture.Bitmap := BMP;				// just copies the attributes!
	Free;
end;
Image.Tag := 0;							// set zoom level
end;


 // Get_FullName expects the absolute path, ie. including the drive, and the file must exist!

var	gfn_Base	:	String		=	'';

function Get_FullName(FileName : String) : String;		// local variables
var	i		:	Integer;
	IsDrive		:	Boolean;
	SearchRec	:	tSearchRec;
begin
IsDrive := (FileName[2] = ':');
i := Pos('\', FileName);					// get next backslash position
if (i = 0) then begin						// no more directories
	FindFirst(gfn_Base + FileName, faAnyFile, SearchRec);	// get long file name
	Result := SearchRec.Name;
	FindClose(SearchRec);
	gfn_Base := '';						// reset for next call!
	Exit;
end;
gfn_Base := gfn_Base + Copy(FileName, 1, i);			// move leftmost directory...
Delete(FileName, 1, i);						// (with backslash) to Base
if IsDrive then begin						// process drive part
	Result := UpperCase(gfn_Base);				// save base! - important since
	Result := Result + Get_FullName(FileName);		// ... base will be resetted
	Exit;
end;
FindFirst(gfn_Base + '.', faAnyFile, SearchRec);		// get name of the cur. directory
Result := SearchRec.Name;
FindClose(SearchRec);
Result := Result + '\' + Get_FullName(FileName);		// get next part
end;


function even(const Value : Int64) : Boolean;
begin
Result := (Value mod 2) = 0;
end;


function Get_Bits(var DATA;  const BitOffs, BitCount : DWord) : DWord;
const	ResulTBytes	=	SizeOf(Result) * 1;
	ResultBits	=	SizeOf(Result) * 8;
var	DataArray	:	pBytes;
	ByteOffs	:	DWord;
	OverlapCount	:	Integer;
	tmp		:	DWord;
begin
if (BitCount > ResultBits) then RunError(215);			// "arithmetic overflow"
DataArray := @DATA;
ByteOffs := BitOffs div 8;
MemCopy(DataArray[ByteOffs], Result, ResulTBytes);		// get the basic bits
Result := Result SHR (BitOffs mod 8);				// remove lower unwanted bits
if (BitCount < ResultBits) then					// remove upper unwanted bits
	Result := Result AND ((Bit0 SHL BitCount) - 1);
OverlapCount := Integer(BitOffs + BitCount) - ResultBits;	// get the overlapping bits
if (OverlapCount > 0) then begin
	tmp := _Byte(DataArray[ByteOffs + ResulTBytes])^;
	Result := Result AND ((Bit0 SHL OverlapCount) - 1);
	Result := Result OR  (tmp SHL BitCount);
end;
end;


function Get_CRC32(var DATA;  const Size : DWord) : DWord;
var	tmp		:	pBytes;
	i		:	DWord;
begin
tmp := @Data;
Result := Bits32;
for i := 0 to (Size - 1) do begin
	Result := ((Result SHR 8) AND Bits24) XOR CRC32_Table[(Result XOR tmp[i]) AND Bits8];
end;
Result := NOT Result;
end;


function Fix_Bool(const Value : Boolean) : Boolean;
begin
Result := (Value <> False);					// make only bit0 set (or not)
end;


function Get_InvertedColor(const Color : TColor) : TColor;
begin
Result := Color XOR (Bit23 OR Bit15 OR Bit7);			// toggle bit 7 of each channel
end;


function Int2Base36(Value : QWord;  Digits : Byte) : String;	// convert & format value
begin
Result := '';
repeat
	Result	:= Base36_Chars[(Value mod 36) + 1] + Result;
	Value	:= Value div 36;
until (Value = 0);
Result := StringOfChar('0', (((Length(Result) - 1) div Digits) + 1) * Digits - Length(Result)) + Result;
end;


function Int2Bin(Value : QWord;  Digits : Byte) : String;	// convert & format value
begin
Result := '';
repeat
	Result	:= Chr((Value AND 1) + Ord('0')) + Result;
	Value	:= Value SHR 1;
until (Value = 0);
Result := StringOfChar('0', (((Length(Result) - 1) div Digits) + 1) * Digits - Length(Result)) + Result;
end;


function Int2Dec(const Value : QWord;  Digits : Byte) : String;  // convert & format value
begin
Result := IntToStr(Value);
Result := StringOfChar('0', Digits - Length(Result)) + Result;
end;


function Int2Hex(const Value : QWord;  Digits : Byte) : String;  // convert & format value
begin
Result := IntToHex(Value, 1);
Result := StringOfChar('0', (((Length(Result) - 1) div Digits) + 1) * Digits - Length(Result)) + Result;
end;


function Byte2Hex(const Value : Byte) : String;
begin
Result := HexChars[Value SHR 4] + HexChars[Value AND Bits4];
end;


function ConvertError : Boolean;
begin
Result := _ConvertError;
_ConvertError := False;
end;


function is_AlphaNumeric(const Text : String) : Boolean;
var	i		:	Integer;
begin
i := Length(Text);
Result := (i <> 0);
for i := 1 to i do begin					// skipped if i < start value
	if (not CharInSet(UpCase(Text[i]), ['0'..'9', 'A'..'Z'])) then begin
		Result := False;
		Break;
	end;
end;
end;


function is_HexString(const Text : String) : Boolean;
const	HexChars	=	['0'..'9', 'A'..'F'];
var	i		:	Integer;
begin
Result := False;
if (Text = '') then Exit;
for i := 1 to Length(Text) do begin
	if (not CharInSet(Text[i], HexChars)) then Exit;
end;
Result := True;
end;


function is_IntStr(Text : String;  hex : Boolean) : Boolean;
const	DecChars	=	['0'..'9'		];
	HexChars	=	['0'..'9', 'A'..'F'	];
	MaxDec		=	'2147483647';
var	i		:	Byte;
begin
Result := False;
if (Text = '') then Exit;
while (Length(Text) > 1) do
	if (Text[1] = '0') then Delete(Text, 1, 1) else Break;	// remove leading zeroes
if hex then begin
	if (Length(Text) > 8) then Exit;			// max: $FFFFFFFF
	for i := 1 to Length(Text) do
		if (not CharInSet(Text[i], HexChars)) then Exit;
end else begin
	if (Length(Text) > 10) then Exit;			// max: 2147483647
	if (Length(Text) = 10) then  for i := 1 to 10 do begin	// check manually
		if (not CharInSet(Text[i], HexChars)) or	// no hex. or too large
			(Ord(Text[i]) > Ord(MaxDec[i])) then Exit;
	end else  for i := 1 to Length(Text) do begin		// no hex. char
		if (not CharInSet(Text[i], HexChars)) then Exit;
	end;
end;
Result := True;
end;


function is_NoNumber(const Text : String) : Boolean;
var	i		:	DWord;
begin
Result := True;
if (Text = '') then Exit;
for i := 1 to Length(Text) do
	if (not CharInSet(Text[i], ['0'..'9'])) then Exit;
Result := False;
end;


function Key2Char(const VK : Word) : String;  // www.swissdelphicenter.ch/de/showcode.php?id=1425
var	KeyState	:	TKeyboardState;
	RetCode		:	Integer;
begin
if (not (GetKeyboardState(KeyState))) then RaiseLastOSError;
SetLength(Result, 2);
RetCode := ToAscii(VK, MapVirtualKey(VK, 0), KeyState, @Result[1], 0);
Case RetCode of
	1:	SetLength(Result, 1);
	2:	;
	else	Result := '';					// RetCode < 0 for dead keys
end;
end;


procedure Load_LVFav(const LV : TListView);
var	i		:	Integer;
	tmpStr		:	String;
begin
with INI do  with LV do begin
	if Load_Strings(Name + '.ItemCaptions') then  for i := 0 to (Strings.Count - 1) do begin
		tmpStr := Strings[i];
		if {Form_Options.CBox_OptionsLinks.Checked and} (not DirectoryExists(tmpStr)) then Continue;
		Items.Add.Caption := tmpStr;
	end;
	if (Items.Count <> 0) then begin
		Enabled		:= True;
		Color		:= clWindow;
	end;
end;
end;


procedure LV_AddItem(const LV : TListView;  SubCount : Integer);
var	i		:	Integer;
begin
if (LV = NIL) then Exit;
with LV.Items.Add.SubItems do
	for i := 1 to SubCount do  Add('');
end;


function No_Spaces(const Text : String) : String;
var	i		:	Integer;
begin
{$IFOPT R+    }  {$DEFINE Prev_R}  {$R-}  {$ENDIF}		// disable range    checks
{$IFOPT Q+    }  {$DEFINE Prev_Q}  {$R-}  {$ENDIF}		// disable overflow checks
Result := '';
for i := 1 to Length(Text) do begin
	if (Text[i] <> ' ') then Result := Result + Text[i];
end;
{$IFDEF Prev_Q}  {$UNDEF  Prev_Q}  {$Q+}  {$ENDIF}		//  enable overflow checks
{$IFDEF Prev_R}  {$UNDEF  Prev_R}  {$R+}  {$ENDIF}		//  enable range    checks
end;


function No_ZeroChars(const Text : String) : String;
var	i		:	Integer;
begin
{$IFOPT R+    }  {$DEFINE Prev_R}  {$R-}  {$ENDIF}		// disable range    checks
{$IFOPT Q+    }  {$DEFINE Prev_Q}  {$R-}  {$ENDIF}		// disable overflow checks
Result := Text;
for i := 1 to Length(Result) do
	if (Result[i] = #0) then Result[i] := ' ';
{$IFDEF Prev_Q}  {$UNDEF  Prev_Q}  {$Q+}  {$ENDIF}		//  enable overflow checks
{$IFDEF Prev_R}  {$UNDEF  Prev_R}  {$R+}  {$ENDIF}		//  enable range    checks
end;


function ReverseStr(const Text : String) : String;
var	SI, DI		:	DWord;
begin
SI := Length(Text);						// also points to last char
SetLength(Result, SI);
for DI := 1 to SI do begin
	Result[DI] := Text[SI];
	Dec(SI);
end;
end;


function MessageDlg(const Msg : String;  DlgType : TMsgDlgType;  Buttons : TMsgDlgButtons;  HelpCtx : LongInt) : Word;
begin
DialogActive := True;
try
	Result := Dialogs.MessageDlg(Msg, DlgType, Buttons, HelpCtx);
finally
	DialogActive := False;
end;
end;


procedure Set_Buffering(const Control : TWinControl);
var	i		:	Integer;
	tmp		:	TControl;
	tmpWin		:	TWinControl absolute tmp;
begin
with Control do begin
	{if (not (Control is TListView)) then} DoubleBuffered := True;
	for i := 0 to (ControlCount - 1) do begin
		tmp := Controls[i];
		if (tmp is TWinControl) then Set_Buffering(tmpWin);
	end
end;
end;


procedure Set_LVCount(const LV : TListView;  DestCount, SubCount : Integer);
var	x, y		:	Integer;
begin
with LV.Items do begin
	y := DestCount - Count;
	if (y >= 0)	then  for y := 1 to +y do Add
			else  for y := y to -1 do Delete(Count - 1);
	for y := 0 to (Count - 1) do  with Item[y].SubItems do begin
		x := SubCount - Count;
		if (x >= 0)	then  for x := 1 to +x do  Add('')
				else  for x := x to -1 do  Delete(Count - 1);
	end;
end;
end;


procedure Set_NumericInput(const Edit : TEdit);
var	tmp		:	Integer;
begin
tmp :=	GetWindowLong(Edit.Handle, GWL_STYLE);
	SetWindowLong(Edit.Handle, GWL_STYLE, tmp OR ES_NUMBER);
end;


function RGB2Color(const Color : TRGBQuad) : TColor;
var	tmp		:	TColor;
begin
tmp := TColor(Color);
Result := Swap_Color(tmp);
end;


function Safe_ToInt(const Text : String) : Int64;
begin
Result := Dec2Int(Text);
end;


function ShiftLeft(const Value, Digits : Integer) : Integer;
begin
if (Digits < 0)	then Result := Value SHR Abs(Digits) else
if (Digits > 0)	then Result := Value SHL    (Digits)
		else Result := Value;
end;


function Signed_IntStr(const Value : Integer) : String;
begin
Result := IntToStr(Value);
if (Value >= 0) then Result := '+' + Result;
end;


function Swap_Color(const Color : DWord) : DWord;
var	Src		:	TBytes4;
	Dest		:	TBytes4;
begin
DWord(Src) := Color;
Dest[0] := Src[2];
Dest[1] := Src[1];
Dest[2] := Src[0];
Dest[3] := Src[3];						// should be the same
Result := DWord(Dest);
end;


function Swap_RGB(const Color : TRGBQuad) : TRGBQuad;
var	Src		:	TBytes4;
	Dest		:	TBytes4;
begin
TRGBQuad(Src) := Color;
Dest[0] := Src[2];
Dest[1] := Src[1];
Dest[2] := Src[0];
Dest[3] := Src[3];						// should be the same
Result := TRGBQuad(Dest);
end;



function StrOfStr(const Text : String;  const Count : Integer) : String;
var	i, Len		:	Integer;
	Dest, Src	:	^Char;
begin
Len := Length(Text);
SetLength(Result, Len * Count);
Src  := @Text	[1];
Dest := @Result	[1];
for i := 1 to Count do begin
	MemCopy	(Src^, Dest^, Len);
	Inc	(Dest       , Len);
end;
end;


function Bin2Int(const Text : String) : QWord;
const	BinChars	=	'01';
var	i, j		:	Integer;
begin
Result	:= 0;
j	:= Length(Text);
_ConvertError := (not Valid_Chars(Text, BinChars)) or (j > 64);
if _ConvertError then Exit;
for i := 1 to j do begin
	j := Pos(Text[i], BinChars) - 1;
	Result := (Result SHL 1) + j;
end;
end;


function Dec2Int(const Text : String) : QWord;
var	Code		:	Integer;
begin
{$IFOPT R+    }  {$DEFINE Prev_R}  {$R-}  {$ENDIF}		// disable range checks
Val(Text, Result, Code);
{$IFDEF Prev_R}  {$UNDEF  Prev_R}  {$R+}  {$ENDIF}		//  enable range checks
_ConvertError := (Code <> 0);
end;


function Hex2Int(Text : String) : QWord;
var	i, j		:	Integer;
begin
Result	:= 0;
j	:= Length(Text);
Text := UpperCase(Text);
_ConvertError := (not Valid_Chars(Text, Str_HexChars)) or (j > 16);
if _ConvertError then Exit;
for i := 1 to j do begin
	j := Pos(Text[i], Str_HexChars) - 1;
	Result := (Result SHL 4) + j;
end;
end;


function Valid_Chars(const Text, Chars : String) : Boolean;
var	i		:	Integer;
begin
Result := False;
for i := 1 to Length(Text) do
	if (Pos(Text[i], Chars) = -1) then Exit;
Result := (Text <> '');
end;


procedure Compress(const Stream : TMemoryStream);
var	tmpStream	:	TMemoryStream;
	GZIP		:	TGZIP;
begin
Stream.Position := 0;
tmpStream := TMemoryStream.Create;
GZIP := TGZIP.Create;
GZIP.Compress(Stream, tmpStream);
GZIP.Free;
Stream.SetSize(0);
Stream.CopyFrom(tmpStream, 0);
Stream.Position := 0;
tmpStream.Free;
end;


procedure Decompress(const Stream : TMemoryStream);
var	tmpStream	:	TMemoryStream;
	GZIP		:	TGZIP;
begin
Stream.Position := 0;
tmpStream := TMemoryStream.Create;
GZIP := TGZIP.Create;
GZIP.UnCompress(Stream, tmpStream);
GZIP.Free;
Stream.SetSize(0);
Stream.CopyFrom(tmpStream, 0);
Stream.Position := 0;
tmpStream.Free;
end;


procedure Delete_Bytes(const Stream : TMemoryStream;  const Offset, Count : DWord);
var	tmpStream	:	TMemoryStream;
begin
if (Integer(Offset            ) >= Stream.Size) then Exit;	// no bytes to delete
if (Integer(Offset + Count - 1) >= Stream.Size) then begin	// no copying required
	Stream.Size := Offset;
end else begin
	tmpStream := TMemoryStream.Create;
	Stream.Position := Offset + Count;
	tmpStream.CopyFrom(Stream, Stream.Size - Stream.Position);  // save the trailing data
	Stream.Position := Offset;
	Stream.CopyFrom(tmpStream, 0);				// overwrite old data
	Stream.Size := Stream.Position;				// discard surmounting data
	tmpStream.Free;
end;
end;


procedure Insert_Bytes(const Stream : TMemoryStream;  Offset : DWord;  const Count : DWord;  var DATA);
var	i		:	DWord;
	tmpStream	:	TMemoryStream;
begin
i := Stream.Size;						// get the last offset
if (Offset > i) then Offset := i;				// adjust Index
Stream.Position := Offset;
if (Offset = i) then begin					// no copying required
	Stream.Write(DATA, Count);
end else begin
	tmpStream := TMemoryStream.Create;
	tmpStream.CopyFrom(Stream, Stream.Size - Stream.Position);  // save the trailing data
	Stream.Position := Offset;
	Stream.Write(DATA, Count);				// insert new data
	Stream.CopyFrom(tmpStream, 0);				// insert old data
	tmpStream.Free;
end;
end;


procedure Read_Backw(const Stream : TStream;  var DATA;  const Size : Integer);
var	DataSize	:	Integer;
	i		:	Integer;
begin
DataSize := Size;
with Stream do begin
	i := Position - DataSize;				// get the dest. position
	Position := i;  Read(DATA, DataSize);			// read the data
	Position := i;						// return to dest. position
end;
end;


function FollowPath(const FileName : String) : String;
var	i		:	Integer;
begin
if (FileName = '') then exit('');
Result := ExpandUNCFileName(FileName);
repeat
	if (GetFileAttributes(pChar(Result)) <> INVALID_FILE_ATTRIBUTES) then exit;
	for i := (Length(Result) - 1) downto 1 do begin		// remove last item
		if (Result[i] = PathDelim) then begin
			SetLength(Result, i);
			break;
                end;
        end;
until (Result = '');
Assert(False);							// should never be called, but...
end;


function GetDesktopPath : String;				// get Desktop folder location
var	DesktopPidl	:	pItemIDList;
	DesktopPath	:	array[0..MAX_PATH] of Char;
begin
SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, DesktopPidl);
SHGetPathFromIDList(DesktopPidl, DesktopPath);
Result := IncludeTrailingPathDelimiter(DesktopPath);
end;


function pressing_Alt   : Boolean;  begin  Result := (GetKeyState(VK_MENU   ) < 0);  end;  // may not work in WinME
function pressing_Ctrl  : Boolean;  begin  Result := (GetKeyState(VK_CONTROL) < 0);  end;
function pressing_Shift : Boolean;  begin  Result := (GetKeyState(VK_SHIFT  ) < 0);  end;


 // window management


var	Pos_SelDir	:	TPoint;				// position and size


function DlgDirCB(Wnd : HWnd;  uMsg : UInt;  lParam, lpData : LParam) : Integer;  stdcall;
var	tmpRect		:	TRect;
begin
if (uMsg = BFFM_INITIALIZED) then begin
	GetWindowRect(Wnd, tmpRect);
	with tmpRect do  with Pos_SelDir do begin
		Dec(x, (Right - Left) div 2);
		Dec(y, (Bottom - Top) div 2);
		SetWindowPos(Wnd, 0, x, y, 0, 0, SWP_NOSIZE);
	end;
	if (lpData <> 0) then SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpData);
end;
Result := 0;
end;


function Exec_ColorDlg(const Dialog : TColorDialog) : Boolean;
var	tmpForm		:	tForm;
begin
with Dialog do begin
	tmpForm := Screen.ActiveForm;
	DialogActive := True;
	try
		Result := Execute;
	finally
		DialogActive := False;
	end;
	if assigned(tmpForm) then tmpForm.SetFocus;
	if (not Result) then Exit;
end;
end;


function Exec_DirDlg(const Text : String;  var Dir : String;  Pos : TPoint) : Boolean;
var	Buffer		:	pChar;
	oldErrorMode	:	DWord;
	ItemIDList,
	RootItemIDList	:	pItemIDList;
	ShellMalloc	:	IMalloc;
	WndListPtr	:	Pointer;
	BrowseInfo	:	tBrowseInfo;
begin
Result := False;
if (ShGetMalloc(ShellMalloc) <> NOERROR) or (ShellMalloc = NIL) then Exit;
Buffer := ShellMalloc.Alloc(MAX_PATH);
MemClear(BrowseInfo, SizeOf(BrowseInfo));
if (not DirectoryExists(Dir)) then Dir := '';
DialogActive := True;
try
	RootItemIDList := NIL;
	with BrowseInfo do begin
		hwndOwner	:= Application.Handle;
		pidlRoot	:= RootItemIDList;
		pszDisplayName	:= Buffer;
		lpszTitle	:= pChar(Text);
		ulFlags		:= BIF_RETURNONLYFSDIRS;
		lpfn		:= DlgDirCB;
		if (Dir <> '') then lParam := Integer(pChar(Dir));
	end;
	Pos_SelDir		:= Pos;
	WndListPtr		:= DisableTaskWindows(0);
	oldErrorMode		:= SetErrorMode(SEM_FAILCRITICALERRORS);
	try
		ItemIDList	:= ShBrowseForFolder(BrowseInfo);
	finally
		SetErrorMode(oldErrorMode);
		EnableTaskWindows(WndListPtr);
	end;
	if assigned(ItemIDList) then begin
		Result := True;
		ShGetPathFromIDList(ItemIDList, Buffer);
		ShellMalloc.Free(ItemIDList);
		Dir := Buffer;
	end else Result := False;
finally
	ShellMalloc.Free(Buffer);
	DialogActive := False;
end;
end;


function Exec_FileDlg(const Dialog : TOpenDialog) : Boolean;
var	tmpForm		:	tForm;
	tmp_Options	:	tOpenOptions;
begin
with Dialog do begin
	if (Dialog is tSaveDialog) then begin
		tmp_Options := Options;
		{if Form_Options.CBox_OptionsConfirm.Checked
			then Include(tmp_Options, ofOverwritePrompt)
			else} Exclude(tmp_Options, ofOverwritePrompt);
		Options := tmp_Options;
	end;
	if (not DirectoryExists(InitialDir)) then InitialDir := 'C:\';
	tmpForm := Screen.ActiveForm;
	DialogActive := True;
	try
		Result := Execute;
	finally
		DialogActive := False;
	end;
	if assigned(tmpForm) then tmpForm.SetFocus;
	if (not Result) then Exit;
	Dlg_FullPath	:= FileName;
	InitialDir	:= ExtractFilePath(FileName);
	FileName	:= ExtractFileName(FileName);
end;
end;


function Exec_FontDlg(const Dialog : TFontDialog) : Boolean;
var	tmpForm		:	tForm;
begin
with Dialog do begin
	tmpForm := Screen.ActiveForm;
	DialogActive := True;
	try
		Result := Execute;
	finally
		DialogActive := False;
	end;
	if assigned(tmpForm) then tmpForm.SetFocus;
	if (not Result) then Exit;
end;
end;


function Same_Start(const String1, String2 : String) : Boolean;
var	i		:	Integer;
begin
i := Min(Length(String1), Length(String2));
Result := AnsiSameStr(	Copy(String1, 1, i),
			Copy(String2, 1, i));
end;


 //  Unix time conversion functions


function Get_UnixDateStr(const Value : DWord) : String;
begin
DateTimeToString(Result, TimeFormat, Unix2DateTime(Value));
end;


function Unix2DateTime(Value : DWord) : TDateTime;
var	dwValue	:	DWord;
	Days	:	DWord;
	Hour	:	Word;
	Min	:	Word;
	Sec	:	Word;
begin
dwValue := Value;
Days	:= dwValue div SecsPerDay;
dwValue := dwValue mod SecsPerDay;
Hour	:= dwValue div 3600;
dwValue := dwValue mod 3600;
Min	:= dwValue div 60;
Sec	:= dwValue mod 60;
Result	:= EncodeDate(1970, 1, 1) + Days + EncodeTime(Hour, Min, Sec, 0);
end;


function DateTime2Unix(Value : TDateTime) : DWord;
var	Year	:	Word;
	Month	:	Word;
	Day	:	Word;
	Hour	:	Word;
	Min	:	Word;
	Sec	:	Word;
	MSec	:	Word;
	Days	:	Integer;
begin
DecodeDate(Value, Year, Month, Day);
DecodeTime(Value, Hour, Min, Sec, MSec);
Days := Trunc(EncodeDate(Year, Month, Day) - EncodeDate(1970, 1, 1));
Result := (Days * SecsPerDay) + (Hour * 3600) + (Min * 60) + Sec;
end;


 // global stuff


procedure Global_Msg(const Src : Pointer;  const Msg : String);
begin
{Cart		.New_Msg(Src, Msg);
IPS		.New_Msg(Src, Msg);
SNES		.New_Msg(Src, Msg);
SNES.PPU	.New_Msg(Src, Msg);
S9X		.New_Msg(Src, Msg);
SMV		.New_Msg(Src, Msg);
SPC		.New_Msg(Src, Msg);
SGT		.New_Msg(Src, Msg);
SSL		.New_Msg(Src, Msg);
ZMV		.New_Msg(Src, Msg);
ZST		.New_Msg(Src, Msg);
WindowList	.New_Msg(Src, Msg);
Form_Cart	.New_Msg(Src, Msg);
Form_CHT	.New_Msg(Src, Msg);
Form_Hex	.New_Msg(Src, Msg);
Form_List	.New_Msg(Src, Msg);
Form_Main	.New_Msg(Src, Msg);
Form_Memory	.New_Msg(Src, Msg);
Form_Movie	.New_Msg(Src, Msg);
Form_Open	.New_Msg(Src, Msg);
Form_Options	.New_Msg(Src, Msg);
Form_Palette	.New_Msg(Src, Msg);
Form_PalFinder	.New_Msg(Src, Msg);
Form_Preview	.New_Msg(Src, Msg);
Form_Quit	.New_Msg(Src, Msg);
Form_Scene	.New_Msg(Src, Msg);
Form_Search	.New_Msg(Src, Msg);
Form_SPC	.New_Msg(Src, Msg);}
end;


//----------------------------------------------------------------------------------------------


initialization
AppPath := ExtractFilePath(Application.ExeName);
INI.LoadFromFile(AppPath + 'PVV.ini');
with Screen do begin
	Cursors[crHand] := LoadCursor(HInstance, 'Hand');
	Cursors[crMove] := LoadCursor(HInstance, 'Move');
	Cursors[crPick] := LoadCursor(HInstance, 'Pick');
	Cursors[crZoom] := LoadCursor(HInstance, 'Zoom');
end;


end.
