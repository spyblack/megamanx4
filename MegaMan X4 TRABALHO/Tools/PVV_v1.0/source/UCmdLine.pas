Unit	uCmdLine;


 //	Parameters whose first character is not a "/" are arguments.
 //	Parameters whose first character is     a "/" are switches.
 //	Switches can have options, for example "/switch=option1,option2,option3".

 //	"_Arguments" and "_Switches" are implemented as stringlists. "_Options" is implemented
 //	as a list of stringlists, i.e. "_Options[4]" contains the options for switch #4 in its
 //	own stringlist.

 //	Switches are internally stored in uppercase.


Interface  ////////////////////////////////////////////////////////////////////////////////////
uses	Windows, Classes,
	uStringLists;


Type	tCmdLine	=	class
				Private
				_Arguments		:	tStringList;
				_Options		:	tStringLists;  // list of lists
				_Switches		:	tStringList;
				Function    Get_Argument	(Const Index  : Word) : String;
				Function    Get_Option		(Const Switch : String;  Const Index : Word) : String;
				Function    Get_OptionCount	(Const Switch : String) : Integer;
				Procedure   Parse;
				Public  ///////////////////////////////////////////////////////
				Constructor Create		;
				Destructor  Destroy		;  Override;
				Function    has_Switch		(Const Switch : String) : Boolean;
				////////
				Property    Arguments		[Const Index  : Word  ] : String   read Get_Argument;
				Property    OptionCount		[Const Switch : String] : Integer  read Get_OptionCount;
				Property    Options		[Const Switch : String;  Const Index : Word] : String  read Get_Option;
				End;


Var	CmdLine		:	tCmdLine;


Implementation  ///////////////////////////////////////////////////////////////////////////////
uses	SysUtils;


Const	CRLF		=	#13#10;


Constructor tCmdLine.Create;
Begin
inherited;
_Arguments := tStringList .Create;
_Options   := tStringLists.Create;				// owns the inserted stringlists
_Switches  := tStringList .Create;  _Switches.Sorted := True;
End;


Destructor tCmdLine.Destroy;
Begin
_Switches .Free;
_Options  .Free;
_Arguments.Free;
inherited;
End;


Function tCmdLine.Get_Argument(Const Index : Word) : String;
Begin
If (Index < _Arguments.Count) then Begin			// check if argument exists
	Result := Arguments[Index];
End else Begin
	Result := '';
End;
End;


Function tCmdLine.Get_Option(Const Switch : String;  Const Index : Word) : String;
Var	i		:	Integer;
	Options		:	tStringList;
Begin
i := _Switches.IndexOf(Switch);
If (i <> -1) then Begin						// check if switch exists
	Options := _Options[i];
	If (Index < Options.Count) then Begin			// check if option exists
		Result := Options[Index];
		Exit;
	End;
End;
Result := '';
End;


Function tCmdLine.Get_OptionCount(Const Switch : String) : Integer;
Begin
Result := _Switches.IndexOf(Switch);
If (Result = -1) then Exit;					// check if switch exists
Result := _Options[Result].Count;
End;


Function tCmdLine.has_Switch(Const Switch : String) : Boolean;
Begin
Result := (_Switches.IndexOf(UpperCase(Switch)) <> -1);
End;


Procedure tCmdLine.Parse;
Var	i		:	Integer;
	InsertPos	:	Integer;
	p		:	Integer;
	Switch		:	String;
	tmpOptions	:	tStringList;
	tmpStr		:	String;
Begin
For p := 1 to ParamCount do Begin
	tmpStr := ParamStr(p);
	If (tmpStr[1] = '/') then Begin				// [switch]
		Delete(tmpStr, 1, 1);				// remove switch indicator
		i := Pos('=', tmpStr);				// get switch & options
		If (i = 0) then i := MaxInt;
		Switch := UpperCase(Copy(tmpStr, 1, i - 1));
		InsertPos := _Switches.Add(Switch);		// add switch at sorted position
		Delete(tmpStr, 1, i);				// get options
		tmpStr := StringReplace(tmpStr, ',', CRLF, [rfReplaceAll]);
		tmpOptions := tStringList.Create;		// insert options as string list
		tmpOptions.Text := tmpStr;
		_Options.Insert(InsertPos, tmpOptions);
	End else Begin
		_Arguments.Add(tmpStr);				// [parameter]
	End;
End;
End;


///////////////////////////////////////////////////////////////////////////////////////////////


Initialization
CmdLine := tCmdLine.Create;
CmdLine.Parse;							// parse right at program start


Finalization
CmdLine.Free;


End.
