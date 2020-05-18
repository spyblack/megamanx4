unit	PCSX15;


interface  //-----------------------------------------------------------------------------------
uses	Classes, Graphics, SysUtils;


type	PCSX15_Header		=	packed array[0.. 31] of AnsiChar;


	PCSX15_PreviewPixel	=	packed array[0..  2] of Byte;
	PCSX15_PreviewLine	=	packed array[0..127] of PCSX15_PreviewPixel;
	PCSX15_Preview		=	packed array[0.. 95] of PCSX15_PreviewLine;


	PCSX15_Savestate	=	class
	Header			:	PCSX15_Header;
	Preview			:	PCSX15_Preview;
	VRAM			:	Cardinal;
	function	Check_File	(const FileName : String) : Boolean;
	function	Get_Serial	(const FileName : String) : String;
	function	Get_SlotIndex	(const FileName : String) : String;
	function	Load_Preview	(const FileName : String;  const BMP : TBitmap) : Boolean;
	function	LoadFromFile	(const FileName : String;  var Stream : TMemoryStream) : Boolean;
	function	LoadFromStream	(const Stream : TStream) : Boolean;
	end;


implementation  //------------------------------------------------------------------------------
uses	UForm_Input, UShared, UStreamTools;


const	Signature	=	'STv3 PCSX v1.5';


function PCSX15_Savestate.Check_File(const FileName : String) : Boolean;
var	Header		:	PCSX15_Header;
	s		:	String;
	ZippedFile	:	TZippedFile;
begin
Result := False;
s := ExtractFileExt(FileName);
if (Length(s) <> 4   ) then exit;
if (     s[1] <> '.' ) then exit;  Delete(s, 1, 1);
if (not is_Numbers(s)) then exit;
ZippedFile := TZippedFile.Create;
try
	if (not ZippedFile.Open(FileName   )) then exit;
	if (not ZippedFile.Read(Header, 32 )) then exit;
	if (Copy(Header, 1, 14) <> Signature) then exit;
	Result := True;
finally
	ZippedFile.Free;
end;
end;


function PCSX15_Savestate.Get_Serial(const FileName : String) : String;
begin
Result := '';
end;


function PCSX15_Savestate.Get_SlotIndex(const FileName : String) : String;
var	ErrorCode	:	Integer;
	i		:	Integer;
begin
Result := Copy(ExtractFileExt(FileName), 2, MaxInt);
Val(Result, i, ErrorCode);
if (ErrorCode = 0) then  if (i >= 000) and (i <= 999) then exit(IntToStr(i));
exit('');
end;


function PCSX15_Savestate.Load_Preview(const FileName : String;  const BMP : TBitmap) : Boolean;
const	LineSize	=	SizeOf(PCSX15_PreviewLine);
var	Header		:	PCSX15_Header;
	ZippedFile	:	TZippedFile;
	y		:	Integer;
begin
ZippedFile := TZippedFile.Create;
try
	ZippedFile.Open(FileName);
	if (not ZippedFile.Read(Header, 32) ) then exit(False);
	if (Copy(Header, 1, 14) <> Signature) then exit(False);
	for y := 0 to 95 do begin
		if (not ZippedFile.Read(BMP.ScanLine[y]^, LineSize)) then exit(False);
	end;
	exit(True);
finally
	ZippedFile.Free;
end;
end;


function PCSX15_Savestate.LoadFromFile(const FileName : String;  var Stream : TMemoryStream) : Boolean;
begin
if Open_GZIP(FileName, Stream) then begin
	try
		if LoadFromStream(Stream) then exit(true);
	except
		Stream.Free;
	end;
end;
Stream := NIL;
exit(False);
end;


function PCSX15_Savestate.LoadFromStream(const Stream : TStream) : Boolean;
var	i		:	Integer;
begin
Result := False;
i      := SizeOf(Header);
if (Stream.Read(Header, i) <> i     ) then exit;
if (Copy(Header, 1, 14) <> Signature) then exit;
Result := True;
VRAM   := 2725568;
end;


//----------------------------------------------------------------------------------------------


end.

