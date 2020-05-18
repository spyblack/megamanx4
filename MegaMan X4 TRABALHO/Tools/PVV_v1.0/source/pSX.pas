unit	pSX;


interface  //-----------------------------------------------------------------------------------
uses	Classes, Graphics, SysUtils;


type	pSX_Block		=	record
	DataOffset		:	Cardinal;
	DataSize		:	Int64;			// must be 8 bytes
	ID			:	packed array[0..3] of AnsiChar;
	end;


	pSX_Savestate		=	class
	Blocks			:	array of pSX_Block;
	VRAM			:	Cardinal;
	function	Check_File	(const FileName : String) : Boolean;
	constructor	Create		;
	destructor	Destroy		;  override;
	function	Get_Serial	(const FileName : String) : String;
	function	Get_SlotIndex	(const FileName : String) : String;
	function	Load_Preview	(const FileName : String;  const BMP : TBitmap) : Boolean;
	function	LoadFromFile	(const FileName : String;  var Stream : TFileStream) : Boolean;
	function	LoadFromStream	(const Stream   : TStream) : Boolean;
	private
	function	Read_Block	(const Stream : TStream;  var Block : pSX_Block) : Boolean;
	end;


implementation  //------------------------------------------------------------------------------
uses	UForm_Input, UStreamTools;


function pSX_Savestate.Check_File(const FileName : String) : Boolean;
var	s1		:	String;
	s2		:	String;
	Signature	:	packed array[0..3] of AnsiChar;
	Stream		:	TFileStream;
begin								// 'quicksave_SCES_028.45_4.psv'
Result := False;
s1 := ExtractFileName(FileName);                           s2 := CopyUntil(s1,  '_');// 'quicksave'
if (     s2 <> 'quicksave') then exit;  Delete(s1, 1, 9);
if (Copy(s1, 1, 1) <>  '_') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '_');// 'SCES'
if (not is_AtoZ   (s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '_') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '.');// '028'
if (not is_Numbers(s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '.') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '_');// '45'
if (not is_Numbers(s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '_') then exit;  Delete(s1, 1, 1);  s2 := CopyUntil(s1,  '.');// '4'
if (not is_Numbers(s2)    ) then exit;  Delete(s1, 1, Length(s2));
if (Copy(s1, 1, 1) <>  '.') then exit;  Delete(s1, 1, 1);  s2 := Copy     (s1, 1, 3);// 'psv'
if (     s2        <>'psv') then exit;  Delete(s1, 1, Length(s2));
if (     s1        <>   '') then exit;						     // ''
if Open_Stream(FileName, Stream) then begin
	try
		if (Stream.Read(Signature, 4) <> 4) then exit;
		if (Signature <> 'ARS2'           ) then exit;
		Result := True;
	finally
		Stream.Free;
	end;
end;
end;


function pSX_Savestate.Get_Serial(const FileName : String) : String;
var	i		:	Integer;
begin
Result := ExtractFileName(FileName);  if (not SameText(ExtractFileExt(Result), '.psv'      )) then exit('');
Result := ChangeFileExt(Result, '');  if (not SameText(Copy(Result, 1, 10)   , 'quicksave_')) then exit('');
Delete(Result, 1, 10);
for i := Length(Result) downto 1 do begin
	if (Result[i] = '_') then begin
		Result := Copy(Result, 1, i - 1);
		break;
	end;
end;
Result := UpperCase(Result);
end;


function pSX_Savestate.Get_SlotIndex(const FileName : String) : String;
var	i		:	Integer;
begin
Result := ExtractFileExt(ChangeFileExt(FileName, ''));		// '.45_4'
i := Pos('_', Result);
if (i = 0) then exit('');
Delete(Result, 1, i);						// '4'
end;


constructor pSX_Savestate.Create;
begin
inherited;
SetLength(Blocks, 0);
end;


destructor pSX_Savestate.Destroy;
begin
SetLength(Blocks, 0);
inherited;
end;


function pSX_Savestate.Load_Preview(const FileName : String;  const BMP : TBitmap) : Boolean;
begin
Result := False;
end;


function pSX_Savestate.LoadFromFile(const FileName : String;  var Stream : TFileStream) : Boolean;
begin
if Open_Stream(FileName, Stream) then begin
	try
		if LoadFromStream(Stream) then exit(true);
	except
		Stream.Free;
		raise;
	end;
	Stream.Free;
end;
Stream := NIL;
exit(False);
end;


function pSX_Savestate.LoadFromStream(const Stream : TStream) : Boolean;
const	UPG		=	$47505500;
var	i		:	Integer;
	Signature	:	packed array[0..3] of AnsiChar;
begin
Result := False;
if (Stream.Read(Signature, 4) <> 4) then exit;
if (Signature <> 'ARS2'           ) then exit;
SetLength(Blocks, 0);
while (Stream.Position <> Stream.Size) do begin
	i := Length(Blocks);
	SetLength(Blocks, i + 1);
	if (not Read_Block(Stream, Blocks[i])) then exit;
end;
Result := True;
for i := 0 to High(Blocks) do  if (Cardinal(Blocks[i].ID) = UPG) then begin
	VRAM := Blocks[i].DataOffset;				// actual VRAM offset is unknown
	if odd(VRAM) then Dec(VRAM);
	break;
end;
end;


function psx_Savestate.Read_Block(const Stream : TStream;  var Block : pSX_Block) : Boolean;
var	i		:	Cardinal;
begin
with Block do begin
	if (Stream.Read(ID      , 4) <> 4) then exit(False);
	if (Stream.Read(DataSize, 8) <> 8) then exit(False);
	with Stream do begin
		DataOffset := Position;
		i  :=  Size - Position;				// remaining byte count in file
	end;
	if (i < DataSize) then exit(False);			// too small?
	Stream.Seek(DataSize, soFromCurrent);
end;
exit(True);
end;


//----------------------------------------------------------------------------------------------



end.

