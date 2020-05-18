program	Yoshitora;		{$APPTYPE Console}
uses	SysUtils;


var	Input		:	TextFile;
	Output		:	TextFile;


procedure Convert;
var	CD		:	String;
	Disc		:	String;
	LastSerial	:	String;
	LastTitle	:	String;
	Line		:	String;
	Note		:	String;
	Region		:	String;
	Serial		:	String;
	Size		:	String;
	Title		:	String;
begin
WriteLn('Starting...');
LastSerial := '';
LastTitle  := '';
while (not EOF(Input)) do begin
	ReadLn(Input, Line);
	Title	:= Trim(Copy(Line, 001, 76    ));
	Disc	:= Trim(Copy(Line, 077, 07    ));
	Serial	:= Trim(Copy(Line, 084, 15    ));  Serial := StringReplace(Serial, '-', '_', [rfReplaceAll]);  Insert('.', Serial, 9);
	Region	:= Trim(Copy(Line, 099, 12    ));
	Size	:= Trim(Copy(Line, 111, 09    ));
	CD	:= Trim(Copy(Line, 120, 10    ));
	Note	:= Trim(Copy(Line, 130, MaxInt));  if (Title = '') then Title := LastTitle;
	if (Title = LastTitle) and (Serial = LastSerial) then begin
		WriteLn('Duplicate detected: ', Title);
	end;
	WriteLn(Output,	Serial	+#9+
			Region	+#9+
			CD	+#9+
			Size	+#9+
			Disc	+#9+
			Title	+#9+
			Note);
	LastSerial := Serial;
	LastTitle  := Title;
end;
WriteLn('Finished.');
ReadLn;
end;


begin
AssignFile( Input,         'yoshitora.txt');  Reset  ( Input);
AssignFile(Output, '..\..\psx_serials.txt');  Rewrite(Output);
Convert;
CloseFile( Input);
CloseFile(Output);
end.
