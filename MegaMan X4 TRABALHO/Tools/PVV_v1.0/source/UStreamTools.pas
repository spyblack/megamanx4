unit	UStreamTools;


interface  //-----------------------------------------------------------------------------------
uses	Classes, SysUtils,
	sgGZIP;


type	TZippedFile		=	class
	private
	GZ			:	TGUnzipStream;
	Stream			:	TFileStream;
	public
	procedure	Close		;
	destructor	Destroy		;  override;
	function	Open		(const FileName : String) : Boolean;
	function	Read		(var Buffer;  const Size : Integer                         ) : Boolean;  overload;
	function	Read		(var Buffer;  const Size : Integer;  var finished : Integer) : Boolean;  overload;
	function	Seek		(const Offset : Integer;  const Origin : Word) : Boolean;
	end;


function Open_GZIP	(const FileName : String;  var Stream : TMemoryStream) : Boolean;
function Open_Stream	(const FileName : String;  var Stream : TFileStream  ) : Boolean;


implementation  //------------------------------------------------------------------------------


function Open_GZIP(const FileName : String;  var Stream : TMemoryStream) : Boolean;
const	BufferSize	=	1024 * 1024;
type	TBuffer		=	packed array[1..BufferSize] of Byte;
var	Buffer		:	^TBuffer;
	i		:	Integer;
	ZippedFile	:	TZippedFile;
begin
Result := True;
{$WARN SYMBOL_PLATFORM off}  if (DebugHook <> 0) then Result := FileExists(FileName);
{$WARN SYMBOL_PLATFORM on }
if (not Result) then exit;
New(Buffer);
ZippedFile := TZippedFile.Create;
try
	if (not ZippedFile.Open(FileName)) then exit(False);
	Stream := TMemoryStream.Create;
	try
		repeat
			ZippedFile.Read (Buffer^, BufferSize, i);
			Stream    .Write(Buffer^,             i);
		until (i <> BufferSize);
		Stream.Position := 0;
	except							// catch 'em all
		FreeAndNIL(Stream);
		exit(False);
	end;
finally
	Dispose(Buffer);
	ZippedFile.Free;
end;
end;


function Open_Stream(const FileName : String;  var Stream : TFileStream) : Boolean;
var	load		:	Boolean;
begin
load := True;
{$WARN SYMBOL_PLATFORM off}  if (DebugHook <> 0) then load := FileExists(FileName);
{$WARN SYMBOL_PLATFORM on }
if load then begin
	try
		Stream := TFileStream.Create(FileName, fmOpenRead OR fmShareDenyWrite);
		exit(True);
	except							// catch 'em all
	end;
end;
exit(False);
end;


// TZippedFile


procedure TZippedFile.Close;
begin
FreeAndNIL(GZ    );
FreeAndNIL(Stream);
end;


destructor TZippedFile.Destroy;
begin
Close;
inherited;
end;


function TZippedFile.Open(const FileName : String) : Boolean;
var	tmp_GZ		:	TGUnzipStream;
	tmp_Stream	:	TFileStream;
begin
if (not Open_Stream(FileName, tmp_Stream)) then exit(False);
try
	tmp_GZ := TGUnzipStream.Create(tmp_Stream);
except
	tmp_Stream.Free;
	raise;
end;
Close;
GZ     := tmp_GZ;
Stream := tmp_Stream;
exit(True);
end;


function TZippedFile.Read(var Buffer;  const Size : Integer) : Boolean;
var	dummy		:	Integer;
begin
Result := Read(Buffer, Size, dummy);
end;


function TZippedFile.Read(var Buffer;  const Size : Integer;  var finished : Integer) : Boolean;
begin
finished := GZ.Read(Buffer, Size);
Result   := (finished     = Size);
end;


function TZippedFile.Seek(const Offset : Integer;  const Origin : Word) : Boolean;
var	i		:	Integer;
begin
case Origin of
	soFromBeginning	:	i := Offset;
	soFromCurrent	:	i := Offset + GZ.Position;
	else			begin  Assert(False);  exit(False);  end;
end;
Result := (GZ.Seek(Offset, Origin) = i);
end;


//----------------------------------------------------------------------------------------------


end.

