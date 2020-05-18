unit	UQWord;


//	Unsigned 64-bit Integer support for Delphi 10, inspired by
//	http://www.delphi3000.com/articles/article_3040.asp  (DelphiFactory Netherlands BV)


interface  //-----------------------------------------------------------------------------------


type	QWord		=	type Int64;


function Str2QWord(Text : AnsiString;  var Value : QWord) : Boolean;
function QWord2Str(Value : QWord) : String;


implementation  //------------------------------------------------------------------------------
uses	SysUtils;


const	LastDigit	=	Length('18446744073709551615') - 1;	// largest value


type	TBCD		=	array[0..LastDigit] of 0..9;
	DWord		=	LongWord;


 // tools


function Inc_BCD(var BCD : TBCD;  const Value : TBCD) : Boolean;
var	i, sum		:	Byte;
begin
Result := True;
sum := 0;
for i := LastDigit downto 0 do begin
	Inc(sum, BCD  [i]);
	Inc(sum, Value[i]);
	if (sum < 10) then begin				// 0..9 = no overflow
		BCD[i] := sum;
		sum    := 0;
	end else begin						// 10..19  = overflow
		if (i = 0) then begin
			Result := False;
			Exit;
		end;
		BCD[i] := sum - 10;
		sum    := 1;
	end;
end;
end;


 // public functions


function Str2QWord(Text : AnsiString;  var Value : QWord) : Boolean;
const	HexChars	:	array[$0..$F] of Char  =  '0123456789ABCDEF';
type	TQWord		=	packed array[0..1] of DWord;	// split into 2 x 32-bit
var	c		:	AnsiChar;
	Digit		:	LongWord;
	hi		:	LongWord;
	i		:	LongWord;
	lo		:	LongWord;
begin
Result := False;
if (Text = '') then Exit;
for i := 1 to Length(Text) do begin				// remove leading spaces
	if (not (Text[i] in [#9, ' '])) then begin
		Delete(Text, 1, i - 1);
		Break;
	end else begin
		if (Integer(i) = Length(Text)) then Exit;	// string contains only spaces
	end;
end;
if (Text[1] = '-') then Exit;					// check for minus sign
if (Text[1] = '+') then begin					// check for plus sign
	Delete(Text, 1, 1);
	if (Text = '' ) then Exit;
end;
if (Text[1] = '$') then begin					// check for hexidecimal string
	Delete(Text, 1, 1);					// remove hex marker
	if (Text = '') then Exit;				// check if empty
	Digit := 0;						// init loop
	Value := 0;
	for i := 1 to Length(Text) do begin
		if (Value SHR 60 > 0) then Exit;		// enough space left?
		c := Text[i];
		if (c >= 'a') then Dec(c, Ord('a') - Ord('A'));  // convert to uppercase
		if (c <  '0') or (c > 'F') or ((c > '9') and (c < 'A')) then Exit;
		Dec(c, Ord('0'));				// convert to binary
		if (c > #9) then Dec(c, Ord('A') - 10);		// convert hex digits
		Value := (Value SHL 4) OR Byte(c);		// put digit into shifted result
	end;
end else begin							// decimal unsigned 64 bit conversion
	Lo := 0;
	Hi := 0;
	for i := 1 to Length(Text) do begin
		c := Text[i];
		if (c < '0') or (c > '9') then Exit;
		Digit := Ord(c) XOR Ord('0');			// convert to binary
		ASM	// HiLo := (HiLo * 10) + Digit
			PUSH	ESI
			MOV	EAX, Hi				// EDX:EAX := Hi * 10
			MOV	ECX, 10
			MUL	ECX
			OR	EDX, EDX			// check for overflow (EDX <> 0)
			JNZ	@overflow
			MOV	ESI, EAX			// ESI := Hi
			MOV	EAX, Lo				// EDX:EAX := Lo * 10
			MUL	ECX
			ADD	EDX, ESI			// Hi := (overflow of Lo) + Hi
			ADD	EAX, Digit			// EDX:EAX := HiLo + Digit
			ADC	EDX, 0				// check overflow
			JC	@overflow			// yes -> quit
			MOV	Hi, EDX				// // save HiLo
			MOV	Lo, EAX
			JMP	@exit
		  @overflow:
			MOV	Digit, 10			// error -> invalidate Digit
		  @exit:
			POP	ESI				// restore register
		END;
		if (Digit = 10) then Exit;			// check if overflow occured
	end;
	tQWord(Value)[0] := Lo;
	tQWord(Value)[1] := Hi;
end;
Result := True;
end;


function QWord2Str(Value : QWord) : String;
var	c		:	Char;
	BCD		:	tBCD;
	BitValue	:	tBCD;
	i		:	ShortInt;
	Start		:	ShortInt;
begin
if (Value = 0) then begin
	Result := '0';
	Exit;
end;
FillChar(BCD	 , SizeOf(BCD     ), 0);			// convert QWord to BCD
FillChar(BitValue, SizeOf(BitValue), 0);
BitValue[LastDigit] := 1;
repeat
	if (Value AND 1 <> 0) then Inc_BCD(BCD, BitValue);
	Inc_BCD(BitValue, BitValue);				// this doubles BitValue (SHL 1)
	Value := Value SHR 1;
until (Value = 0);
SetLength(Result, LastDigit + 1);				// convert BCD to decimal string
Start := -1;
for i := 0 to LastDigit do begin
	c := Char(Ord('0') + BCD[i]);
	Result[i + 1] := c;
	if (c <> '0') and (Start = -1) then Start := i + 1;	// get first non-zero digit
end;
Delete(Result, 1, Start - 1);					// remove leading zeroes
end;


end.
