Unit	uConsole;


 //	"Open_Console" creates a console window for the application. It sets "no_console" to
 //	True or False, depending on success. "Close_Console" closes the console window. It is
 //	automatically called when the unit reaches the "Finalization" section.

 //	"Set_TextAttr" changes the text and background color for following writes. "ClrScr"
 //	clears the entire window. "GotoXY", "Set_CursorSize" and "ShowCursor" can be used for
 //	setting the cursor position and visibility.


{$ASSERTIONS ON}						// assertions MUST be enabled


Interface  ////////////////////////////////////////////////////////////////////////////////////


Type	tConsoleColor	=	0..  15			;	// just like in the DOS days
	tConsoleCoord	=	1..4096			;	// should be sufficient
	tCursorSize	=	1.. 100			;	// 100 = full


Const	ccBlack		:	tConsoleColor	=   0	;	// console color constants
	ccBlue		:	tConsoleColor	=   1	;
	ccGreen		:	tConsoleColor	=   2	;
	ccCyan		:	tConsoleColor	=   3	;
	ccRed		:	tConsoleColor	=   4	;
	ccMagenta	:	tConsoleColor	=   5	;
	ccBrown		:	tConsoleColor	=   6	;
	ccLightGray	:	tConsoleColor	=   7	;
	ccDarkGray	:	tConsoleColor	=   8	;
	ccLightBlue	:	tConsoleColor	=   9	;
	ccLightGreen	:	tConsoleColor	=  10	;
	ccLightCyan	:	tConsoleColor	=  11	;
	ccLightRed	:	tConsoleColor	=  12	;
	ccLightMagenta	:	tConsoleColor	=  13	;
	ccYellow	:	tConsoleColor	=  14	;
	ccWhite		:	tConsoleColor	=  15	;


Var	ConsoleColumn	:	String		= '    ';
	ConsolePrefix	:	String		= '- '	;	// default is for message logging
	no_console	:	Boolean		= True	;


Function  Close_Console		(				) : Boolean	;
Procedure ClrScr		(				)		;
Procedure Console_SHL		(				)		;
Procedure Console_SHR		(				)		;
Function  Get_CursorSize	(				) : tCursorSize	;
Procedure GotoXY		(Const	x, y  : tConsoleCoord	)		;
Function  Open_Console		(Const	Title : String		) : Boolean	;
Procedure Set_CursorSize	(Const  Value : tCursorSize	)		;
Procedure Set_TextBackground	(Const	Color : tConsoleColor	)		;
Procedure Set_TextColor		(Const	Color : tConsoleColor	)		;
Procedure ShowCursor		(Const	Value : Boolean		)		;
Function  WhereX		(				) : tConsoleCoord;
Function  WhereY		(				) : tConsoleCoord;
Procedure Write			(				)		;  Overload;
Procedure Write			(Const	Text  : String		)		;  Overload;
Procedure WriteLn		(				)		;  Overload;
Procedure WriteLn		(Const	Text  : String		)		;  Overload;
Procedure WriteTest		(				)		;


Implementation  ///////////////////////////////////////////////////////////////////////////////
uses	Windows,
	SysUtils;						// Delphi units > Windows units


Const	Bit0		=	DWord(1) SHL 0;
	Bit1		=	DWord(1) SHL 1;
	Bit2		=	DWord(1) SHL 2;
	Bit3		=	DWord(1) SHL 3;

	CRLF		=	#13#10;

	DefaultColor	=	7 + 0;				// light gray


Var	ConError	:	tHandle;
	ConInput	:	tHandle;
	ConOutput	:	tHandle;

	ConsoleHWND	:	HWND;
	cur_Color	:	Word;
	xRes		:	Word;
	yRes		:	Word;


 // tools


Function ConsoleCtrlHandler(CtrlType : DWord) : Boolean;  StdCall;
Const	Mask		=	[CTRL_C_EVENT, CTRL_BREAK_EVENT, CTRL_CLOSE_EVENT];
Begin
Result := (CtrlType in Mask);					// True = no further processing
End;


Function Get_ConsoleWindow : HWND;
Var	tmpStr		:	String;
Begin
tmpStr := IntToStr(GetTickCount) + ' ' + IntToStr(GetCurrentProcessID);
Assert(SetConsoleTitle(pChar(tmpStr)));
Sleep(40);
Result := FindWindow(NIL, pChar(tmpStr));
Assert(Result <> 0);
End;


Procedure Get_Handle(Var Handle : tHandle);
Begin
If (@Handle = @ConError ) then Handle := GetStdHandle(STD_ERROR_HANDLE ) else
If (@Handle = @ConInput ) then Handle := GetStdHandle(STD_INPUT_HANDLE ) else
If (@Handle = @ConOutput) then Handle := GetStdHandle(STD_OUTPUT_HANDLE) else Assert(False);
Assert(Handle <> INVALID_HANDLE_VALUE);
End;


Procedure Reset_Colors;
Begin
Set_TextColor(ccLightGray);					// DOS default
Set_TextBackground(ccBlack);
End;


 // public functions


Procedure Console_SHL;						// less indentation
Begin
Delete(ConsolePrefix, 1, Length(ConsoleColumn));
End;


Procedure Console_SHR;						// more indentation
Begin
ConsolePrefix := ConsoleColumn + ConsolePrefix;
End;


Procedure ClrScr;						// clear screen
Var	CharsWritten	:	DWord;
	Position	:	tCoord;
Begin
If no_console then Exit;
Assert(FillConsoleOutputCharacter(ConOutput, ' ', xRes * yRes, Position, CharsWritten));
GotoXY(1, 1);
End;


Function Close_Console : Boolean;
Begin
If no_console then Begin
	Result := False;
	Exit;
End;
Result := FreeConsole;
no_console := Result;
End;


Function Get_CursorSize : tCursorSize;
Var	CursorInfo	:	tConsoleCursorInfo;
Begin
If no_console then Begin
	Result := 100;
	Exit;
End;
Assert(GetConsoleCursorInfo(ConOutput, CursorInfo));
Result := CursorInfo.dwSize;
End;


Procedure GotoXY(Const x, y : tConsoleCoord);
Var	Position	:	tCoord;
Begin
If no_console then Exit;
Position.x := x - 1;
Position.y := y - 1;
Assert(SetConsoleCursorPosition(ConOutput, Position));
End;


Function Open_Console(Const Title : String) : Boolean;
Const	Flags		=	SWP_NOMOVE OR SWP_NOSIZE;
Var	Position	:	tCoord;
Begin
If no_console then Begin					// create new console window
	Result := AllocConsole;
	no_console := (not Result);
	If no_console then Exit;
	cur_Color   := DefaultColor;
	ConsoleHWND := Get_ConsoleWindow;			// get window handle
	Assert(SetConsoleTitle(pChar(Title)));			// set title
	Assert(SetConsoleOutputCP(437));			// set codepage (needs TTF font)
	Get_Handle(ConError );					// get standard file handles
	Get_Handle(ConInput );
	Get_Handle(ConOutput);
	Assert(SetWindowPos(ConsoleHWND, HWND_TOPMOST, 0, 0, 0, 0, Flags));		// topmost
	Assert(RemoveMenu(GetSystemMenu(ConsoleHWND, False), SC_CLOSE, MF_BYCOMMAND));	// no [X]
	Assert(SetConsoleCtrlHandler(@ConsoleCtrlHandler, True));			// no events
	Position := GetLargestConsoleWindowSize(ConOutput);				// get size
	With Position do Begin
		Assert((x <> 0) and (y <> 0));
		xRes := x;
		yRes := y;
	End;
End else Begin							// console already exists, reset
	Result := True;
	Assert(SetConsoleTitle(pChar(Title)));
	Reset_Colors;
	ClrScr;
	ShowCursor(True);
End;
End;


Procedure Set_CursorSize(Const Value : tCursorSize);
Var	CursorInfo	:	tConsoleCursorInfo;
Begin
If no_console then Exit;
Assert(GetConsoleCursorInfo(ConOutput, CursorInfo));  CursorInfo.dwSize := Value;
Assert(SetConsoleCursorInfo(ConOutput, CursorInfo));
End;


Procedure Set_TextBackground(Const Color : tConsoleColor);
Const	all_bits	=	BACKGROUND_RED
			OR	BACKGROUND_GREEN
			OR	BACKGROUND_BLUE
			OR	BACKGROUND_INTENSITY;
Begin
If no_console then Exit;
cur_Color := cur_Color OR all_bits;						// set all bits
If (Color AND Bit0 = 0) then cur_Color := cur_Color XOR BACKGROUND_BLUE;	// turn bits off
If (Color AND Bit1 = 0) then cur_Color := cur_Color XOR BACKGROUND_GREEN;
If (Color AND Bit2 = 0) then cur_Color := cur_Color XOR BACKGROUND_RED;
If (Color AND Bit3 = 0) then cur_Color := cur_Color XOR BACKGROUND_INTENSITY;
Assert(SetConsoleTextAttribute(ConOutput, cur_Color));				// set cur. col.
End;


Procedure Set_TextColor(Const Color : tConsoleColor);
Const	all_bits	=	FOREGROUND_RED
			OR	FOREGROUND_GREEN
			OR	FOREGROUND_BLUE
			OR	FOREGROUND_INTENSITY;
Begin
If no_console then Exit;
cur_Color := cur_Color OR all_bits;						// set all bits
If (Color AND Bit0 = 0) then cur_Color := cur_Color XOR FOREGROUND_BLUE;	// turn bits off
If (Color AND Bit1 = 0) then cur_Color := cur_Color XOR FOREGROUND_GREEN;
If (Color AND Bit2 = 0) then cur_Color := cur_Color XOR FOREGROUND_RED;
If (Color AND Bit3 = 0) then cur_Color := cur_Color XOR FOREGROUND_INTENSITY;
Assert(SetConsoleTextAttribute(ConOutput, cur_Color));				// set cur. col.
End;


Procedure ShowCursor(Const Value : Boolean);
Var	CursorInfo	:	tConsoleCursorInfo;
Begin
If no_console then Exit;
Assert(GetConsoleCursorInfo(ConOutput, CursorInfo));  CursorInfo.bVisible := Value;
Assert(SetConsoleCursorInfo(ConOutput, CursorInfo));
End;


Function WhereX : tConsoleCoord;
Var	Info		:	_CONSOLE_SCREEN_BUFFER_INFO;
Begin
Assert(GetConsoleScreenBufferInfo(ConOutput, Info));
Result := Info.dwCursorPosition.x + 1;
End;


Function WhereY : tConsoleCoord;
Var	Info		:	_CONSOLE_SCREEN_BUFFER_INFO;
Begin
Assert(GetConsoleScreenBufferInfo(ConOutput, Info));
Result := Info.dwCursorPosition.y + 1;
End;


Procedure Write;
Begin
If no_console then Exit;
Write(' ');
End;


Procedure Write(Const Text : String);
Var	CharsWritten	:	LongWord;
Begin
If no_console then Exit;
Assert(WriteConsole(ConOutput, pChar(Text), Length(Text), CharsWritten, NIL));
End;


Procedure WriteLn;
Begin
If no_console then Exit;
Write(CRLF);
End;


Procedure WriteLn(Const Text : String);
Begin
If no_console then Exit;
Write(ConsolePrefix + Text + CRLF);
End;


Procedure WriteTest;
Const	List		=	[7, 8, 9, 10, 13];
Var	i		:	Word;
	x		:	Word;
	y		:	Word;
Begin
WriteLn('console unit write test');
Console_SHR;
i := 0;
For y := 0 to 15 do Begin
	Set_TextBackground(0);  Write(ConsolePrefix);
	Set_TextBackground(y);
	For x := 0 to 15 do Begin
		Set_TextColor(x);
		If (i in List)	then Write(' ')
				else Write(Chr(i));
		Inc(i);
	End;
	WriteLn;
End;
Console_SHL;
Reset_Colors;
End;


///////////////////////////////////////////////////////////////////////////////////////////////


Initialization


Finalization
Close_Console;


End.
