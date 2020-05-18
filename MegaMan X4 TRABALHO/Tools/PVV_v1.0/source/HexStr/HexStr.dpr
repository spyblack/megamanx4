Program	HexStr;


Const	xRes		=	8;		LastX = xRes - 1;
	yRes		=	256 div xRes;	LastY = yRes - 1;

	Bit0		=	1 SHL 0;  Bits0 = Bit0 - 1;
	Bit1		=	1 SHL 1;  Bits1 = Bit1 - 1;
	Bit2		=	1 SHL 2;  Bits2 = Bit2 - 1;
	Bit3		=	1 SHL 3;  Bits3 = Bit3 - 1;
	Bit4		=	1 SHL 4;  Bits4 = Bit4 - 1;
	Bit5		=	1 SHL 5;  Bits5 = Bit5 - 1;
	Bit6		=	1 SHL 6;  Bits6 = Bit6 - 1;
	Bit7		=	1 SHL 7;  Bits7 = Bit7 - 1;

	Tab		=	#9;
	CRLF		=	#13#10;

	HexChars	:	Array[$0..$F] of Char
			=	'0123456789ABCDEF';


Var	DestFile	:	TextFile;


Procedure Write(Const Text : String);
Begin
System.Write(DestFile, Text);
End;


Function Byte2Hex(Const Value : Byte) : String;
Begin
Result := HexChars[Value SHR 4] + HexChars[Value AND Bits4];
End;


Procedure Main;
Var	i, x, y		:	Byte;
	Table		:	Array[Byte] of String;
Begin
For i := $00 to $FF do	Table[i] := Byte2Hex(i);		// fill the table
i := 0;
For y := 0 to LastY do Begin
	Write('  ');						// start of a line
	For x := 0 to LastX do Begin				// write the values
		If (x <> 0) then Write(', ');			// separator
		Write('''' + Table[i] + '''+#0');		// value
		If (i <> $FF) then Inc(i);			// $FF will be last value of i
	End;
	If (y <> LastY) then Write(',' + CRLF);			// end of a line
End;
Write(CRLF);
End;


Begin
AssignFile(DestFile, 'table.inc');
ReWrite(DestFile);
Main;
CloseFile(DestFile);
End.
