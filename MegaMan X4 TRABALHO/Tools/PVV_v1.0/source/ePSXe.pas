unit	ePSXe;


interface  //-----------------------------------------------------------------------------------
uses	Classes, Graphics, SysUtils;


type	ePSXe_Block		=	record
	DataOffset		:	Cardinal;
	DataSize		:	Cardinal;
	ID			:	String;
	end;


	ePSXe_Savestate		=	class
	Blocks			:	array of ePSXe_Block;
	Game_ID			:	String;
	Version			:	Word;
	VRAM			:	Cardinal;
	function	Check_File	(const FileName : String) : Boolean;
	constructor	Create		;
	destructor	Destroy		;  override;
	function	Get_Serial	(const FileName : String) : String;
	function	Get_SlotIndex	(const FileName : String) : String;
	function	Load_Preview	(const FileName : String;  const BMP : TBitmap) : Boolean;
	function	LoadFromFile	(const FileName : String;  var Stream : TMemoryStream) : Boolean;
	function	LoadFromStream	(const Stream : TStream) : Boolean;
	private
	function	Read_Block	(const Stream : TStream;  var Block : ePSXe_Block) : Boolean;
	end;


implementation  //------------------------------------------------------------------------------
uses	UForm_Input, UShared, UStreamTools;


type	ePSXe_BlockID		=	packed array[0.. 2] of AnsiChar;


	ePSXe_Header		=	packed record
	Signature		:	packed array[0.. 4] of AnsiChar;
	Version			:	Word;
	Game_ID			:	packed array[0..56] of AnsiChar;
	end;


const	HeaderSize		=	SizeOf(ePSXe_Header);


function ePSXe_Savestate.Check_File(const FileName : String) : Boolean;
var	Header		:	ePSXe_Header;
var	s1		:	String;
	s2		:	String;
	ZippedFile	:	TZippedFile;
begin
Result := False;
s1 := ExtractFileName(FileName);                           s2 := CopyUntil(s1,  '_');// 'SCES'
if (not is_AtoZ   (s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '_') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '.');// '028'
if (not is_Numbers(s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '.') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '.');// '45'
if (not is_Numbers(s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '.') then exit;  Delete(s1, 1, 1);  s2 := s1;                 // '4'
if (not is_Numbers(s2)    ) then exit;
ZippedFile := TZippedFile.Create;
try
	if (not ZippedFile.Open(FileName)          ) then exit;
	if (not ZippedFile.Read(Header, HeaderSize)) then exit;
	if (Header.Signature <> 'ePSXe'            ) then exit;
	Result := True;
finally
	ZippedFile.Free;
end;
end;


constructor ePSXe_Savestate.Create;
begin
inherited;
SetLength(Blocks, 0);
end;


destructor ePSXe_Savestate.Destroy;
begin
SetLength(Blocks, 0);
inherited;
end;


function ePSXe_Savestate.Get_Serial(const FileName : String) : String;
begin
Result := UpperCase(ChangeFileExt(ExtractFileName(FileName), ''));
end;


function ePSXe_Savestate.Get_SlotIndex(const FileName : String) : String;
var	ErrorCode	:	Integer;
	i		:	Integer;
begin
Result := Copy(ExtractFileExt(FileName), 2, MaxInt);
Val(Result, i, ErrorCode);
if (ErrorCode = 0) then  if (i >= 0) and (i <= 4) then exit(IntToStr(i));
exit('');
end;


function ePSXe_Savestate.Load_Preview(const FileName : String;  const BMP : TBitmap) : Boolean;
const	LineSize	=	128 * 3;
	PreviewSize	=	LineSize * 96;
var	Stream		:	TFileStream;
	y		:	Integer;
begin
if Open_Stream(FileName + '.pic', Stream) then begin
	try
		if (Stream.Size = PreviewSize) then begin
			for y := 0 to 95 do  Stream.Read(BMP.ScanLine[y]^, LineSize);
			exit(True);
		end;
	finally
		Stream.Free;
	end;
end;
exit(False);
end;


function ePSXe_Savestate.LoadFromFile(const FileName : String;  var Stream : TMemoryStream) : Boolean;
begin
if Open_GZIP(FileName, Stream) then begin
	try
		if LoadFromStream(Stream) then exit(True);
	except							// catch 'em all
		Stream.Free;
	end;
end;
Stream := NIL;
exit(False);
end;


function ePSXe_Savestate.LoadFromStream(const Stream : TStream) : Boolean;
const	IDs		:	array[0..9] of String  =  ('PSX', 'MEM', 'REG', 'IRQ', 'GTE', 'CDR', 'SIO', 'MDE', 'GPU', 'SPU');
var	Header		:	ePSXe_Header;
	i		:	Integer;
begin
Result	:= False;
Game_ID	:= '';
Version	:= 0 ;
VRAM	:= 0 ;
if (Stream.Read(Header, HeaderSize) <> HeaderSize) then exit;
if (Header.Signature <> 'ePSXe'                  ) then exit;
SetLength(Blocks, 0);
while (Stream.Position <> Stream.Size) do begin
	i := Length(Blocks);
	SetLength(Blocks, i + 1);
	if (not Read_Block(Stream, Blocks[i])) then exit;
end;
if (Length(Blocks) < 10) then exit;
for i := 0 to 9 do  if (Blocks[i].ID <> IDs[i]) then exit;
Result	:= True;
Version := Header.Version;
Game_ID := Trim(String(Header.Game_ID));
VRAM	:= 2569183;
for i := 0 to High(Blocks) do  if (Blocks[i].ID = 'GPU') then begin
	VRAM := Blocks[i].DataOffset + 1032;
	break;
end;
end;


function ePSXe_Savestate.Read_Block(const Stream : TStream;  var Block : ePSXe_Block) : Boolean;
const	ID_SPU		:	ePSXe_BlockID		= 'SPU';
var	i		:	Cardinal;
	_ID		:	ePSXe_BlockID;
begin
Result := False;
with Block do begin
	if (Stream.Read(_ID     , 3) <> 3) then exit;
	if (Stream.Read(DataSize, 4) <> 4) then exit;
	if (_ID = 'SIO') then Dec(DataSize, $190);
	with Stream do begin
		DataOffset := Position;
		i  :=  Size - Position;				// remaining byte count in file
	end;
	if (i < DataSize) then begin				// too small?
		if (_ID = ID_SPU) then DataSize := i else exit;	// allowed for SPU (last block)
	end;
	Stream.Seek(DataSize, soFromCurrent);
	ID := String(_ID);
end;
Result := True;
end;


//----------------------------------------------------------------------------------------------


end.

