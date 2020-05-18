unit	UINI;


//	TINI replaces tIniFile since some Win2k systems experienced annoying lag with
//	tIniFile, and because Microsoft might decide to drop support for INI files.
//
//
//	Usage:
//	¯¯¯¯¯¯
//	Select a section by assigning a string to the "Section" property. Get and set key
//	values with the "Get_?" and "Set_?" routines. if the key does not exist then the
//	"Get_?" routines won't touch the "Value" parameter, and the "Set_?" routines will
//	create the key. Sections are automatically sorted, keys are not.
//
//	A semicolon marks the begin of a comment area terminated by the end of the line.
//	Section and key names cannot contain spaces or control characters. TINI is currently
//	case-sensitive.
//
//	Note that TSaveDialog is a descendant of TOpenDialog, so it can be used with
//	Load_Dialog and Save_Dialog.


interface  //-----------------------------------------------------------------------------------
uses	Windows, Classes, ComCtrls, Dialogs, Forms, Graphics, IniFiles, StdCtrls, SysUtils,
	UShared, UStringLists;


type	TINI			=	class
	procedure	Clear		;
	constructor	Create		;
	destructor	Destroy		;  override;
	function	Get_Bool	(const Key : String;  out   Value : Boolean) : Boolean;
	function	Get_HexInt	(const Key : String;  out   Value : Integer) : Boolean;
	function	Get_Int		(const Key : String;  out   Value : Integer) : Boolean;
	function	Get_Str		(const Key : String;  out   Value : String ) : Boolean;
	procedure	Set_Bool	(const Key : String;  const Value : Boolean);
	procedure	Set_HexInt	(const Key : String;  const Value : Integer);
	procedure	Set_Int		(const Key : String;  const Value : Integer);
	procedure	Set_Str		(      Key : String;        Value : String );
	procedure	Load_CBox	(const OBJ : TCheckBox);
	procedure	Load_FileDialog	(const OBJ : TOpenDialog);
	procedure	Load_Font	(const OBJ : TFont;  Key : String);
	procedure	Load_Form	(const Center : Boolean);
	procedure	Load_LV		(const OBJ : TListView);
	procedure	Load_RBtn	(const OBJ : TRadioButton);
	function	Load_Strings	(const Key : String) : Boolean;
	procedure	Load_ToolBtn	(const OBJ : TToolButton);
	procedure	LoadFromFile	(const FileName : String);
	procedure	Save_CBox	(const OBJ : TCheckBox);
	procedure	Save_FileDialog	(const OBJ : TOpenDialog);
	procedure	Save_Font	(const OBJ : TFont;  Key : String);
	procedure	Save_Form	;
	procedure	Save_LV		(const OBJ : TListView);
	procedure	Save_RBtn	(const OBJ : TRadioButton);
	procedure	Save_Strings	(const Key : String);
	procedure	Save_ToolBtn	(const OBJ : TToolButton);
	procedure	SaveToFile	(const FileName : String);
	private
	m_curSection		:	TStringList;
	m_curSectionName	:	String;
	m_SectionNames		:	TStringList;
	m_Sections		:	TStringLists;
	private
	m_FileFound		:	Boolean;
	m_Strings		:	TStringList;
	procedure	Add_Section	;
	procedure	Select_Section	(const Name : String);
	public
	property	FileFound	: Boolean      read m_FileFound;
	property	Strings		: TStringList  read m_Strings;
	property	Section		: String       read m_curSectionName  write Select_Section;
	end;


var	INI		:	TINI;


Implementation  //------------------------------------------------------------------------------
uses	UForm_Main, UStreamTools;


 // TINI


procedure TINI.Add_Section;
var	i		:	Integer;
begin
if (m_curSection <> NIL) then Exit;				// already exists?
m_curSection := TStringList.Create;
i := m_SectionNames.Add(Section);				// add section name (sorted)
m_Sections.Insert(i, m_curSection);				// insert new section
end;


procedure TINI.Clear;
begin
m_SectionNames	.Clear;
m_Sections	.Clear;
end;


constructor TINI.Create;
begin
inherited;
m_Strings		:= TStringList .Create;
m_SectionNames		:= TStringList .Create;
m_Sections		:= TStringLists.Create(True);		// owns the lists
Section			:= '';					// sets internal data
m_SectionNames.Sorted	:= True;
end;


destructor TINI.Destroy;
begin
Section		:= '';
m_Sections	.Free;
m_SectionNames	.Free;
Strings		.Free;
inherited;
end;


function TINI.Get_Bool(const Key : String;  out Value : Boolean) : Boolean;
var	tmpStr		:	String;
begin
Result := Get_Str(Key, tmpStr);					// true = key exists
if Result then Value := (tmpStr = Str_Bool[True]);
end;


function TINI.Get_HexInt(const Key : String;  out Value : Integer) : Boolean;
var	tmpStr		:	String;
begin
Result := Get_Str(Key, tmpStr);
if Result then Value := StrToInt('$' + tmpStr);
end;


function TINI.Get_Int(const Key : String;  out Value : Integer) : Boolean;
var	tmpStr		:	String;
begin
Result := Get_Str(Key, tmpStr);
if Result then Value := StrToInt(tmpStr);
end;


function TINI.Get_Str(const Key : String;  out Value : String) : Boolean;
//	This function had been optimized for speed because at one point,
//	all the GUI strings in vSNES.inf were accessed by an instance of TINI.
var	x, y, KeyLength	:	Integer;
	c		:	Char;
	tmpStr, tmpKey	:	String;
begin
Result := False;
if (m_curSection = NIL) then Exit;
KeyLength := Length(Key) + 1;					// including the = character
for y := 0 to (m_curSection.Count - 1) do begin			// go through all strings
	tmpStr	:= m_curSection[y];				// get current string
	x	:= Length(tmpStr);
	if (x < KeyLength) then continue;
	c	:= #0;
	tmpKey	:= '';
	for x := 1 to KeyLength do begin			// search for = and get the key
		c := tmpStr[x];
		if (c = '=') then begin
			break;
		end else begin
			if (c <> Key[x]) then break;		// wrong key
			tmpKey := tmpKey + c;
		end;
	end;
	if (c <> '=') then continue;				// = must be in this line
	Value := Copy(tmpStr, x + 1, MaxInt);			// right key, get the value
	Result := True;
end;
end;


procedure TINI.Load_CBox(const OBJ : TCheckBox);
var	tmpBool		:	Boolean;
begin
if (OBJ = NIL) then Exit;
with OBJ do  if Get_Bool(Name + '.Checked', tmpBool) then Checked := tmpBool;
end;


procedure TINI.Load_FileDialog(const OBJ : TOpenDialog);
var	i		:	Integer;
	tmpStr		:	String;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	if Get_Str(Name + '.FileName'	, tmpStr) then FileName		:= tmpStr;
	if Get_Str(Name + '.InitialDir'	, tmpStr) then InitialDir	:= tmpStr;
	if Get_Int(Name + '.FilterIndex', i     ) then FilterIndex 	:= i;
end;
end;


procedure TINI.Load_Font(const OBJ : TFont;  Key : String);
var	i		:	Integer;
	tmpStr		:	String;
	tmpStyle	:	tFontStyles;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Key := Key + 'Font.';
	if Get_Str(Key + 'Name', tmpStr	) then Name := tmpStr;
	if Get_Int(Key + 'Size', i	) then Size := i;
	Load_Strings(Key + 'Style');
	tmpStyle  := [];					// no Include(Font.Style, ...)
	if (Strings.IndexOf('Bold'	) <> -1) then Include(tmpStyle, fsBold     );
	if (Strings.IndexOf('Italic'	) <> -1) then Include(tmpStyle, fsItalic   );
	if (Strings.IndexOf('Strikeout'	) <> -1) then Include(tmpStyle, fsStrikeOut);
	if (Strings.IndexOf('Underline'	) <> -1) then Include(tmpStyle, fsUnderline);
	Style := tmpStyle;
end;
end;


procedure TINI.Load_Form(const Center : Boolean);
var	tmpForm		:	tForm;
begin
tmpForm := tForm(Application.FindComponent(Section));
if (tmpForm = NIL) then Exit;
with tmpForm do begin
	if Load_Strings('Pos') then begin			// position
		Left	:= StrToInt(Strings[0]);
		Top	:= StrToInt(Strings[1]);
	end;
	if Load_Strings('Size') then begin			// size
		Width	:= StrToInt(Strings[0]);
		Height	:= StrToInt(Strings[1]);
	end else  if Center then begin				// center the form
		Left	:= (Screen.Width  - Width ) div 2;
		Top	:= (Screen.Height - Height) div 2;
	end;
	Load_Font(Font, '');
end;
end;


procedure TINI.Load_LV(const OBJ : TListView);
var	i		:	Integer;
	List		:	TStringList;
	tmp		:	Integer;
	tmpStr		:	String;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	if Get_Str(Name + '.ColumnWidths', tmpStr) then begin
		List := TStringList.Create;
		List.CommaText := tmpStr;
		for i := 0 to (List.Count - 1) do begin
			tmp := StrToInt(List[i]);
			if (PPI_cur <> PPI_dev) then tmp := (tmp * PPI_cur) div PPI_dev;
			Columns[i].Width := tmp;
		end;
		List.Free;
	end;
end;
end;


procedure TINI.Load_RBtn(const OBJ : TRadioButton);
var	tmpBool		:	Boolean;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	if Get_Bool(Name + '.Checked', tmpBool) then  if tmpBool then Checked := True;
end;
end;


procedure TINI.Load_ToolBtn(const OBJ : TToolButton);
var	tmpBool		:	Boolean;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	if Get_Bool(Name + '.Down', tmpBool) then  if tmpBool then Down := True;
end;
end;


function TINI.Load_Strings(const Key : String) : Boolean;
var	tmpStr		:	String;
begin
with Strings do begin
	Clear;
	if Get_Str(Key, tmpStr) then begin
		CommaText := tmpStr;
		Result    := True;
		Exit;
	end;
end;
Result := False;
end;


procedure TINI.LoadFromFile(const FileName : String);
var	i		:	Integer;
	Key		:	String;
	List		:	TStringList;
	Stream		:	TFileStream;
	tmpStr		:	String;
	y		:	Integer;
begin
Section := '';
m_FileFound := Open_Stream(FileName, Stream);
if (not FileFound) then Exit;
try
	List := TStringList.Create;
	try
		List.LoadFromStream(Stream);
		m_SectionNames.Clear;
		m_Sections    .Clear;
		for y := 0 to (List.Count - 1) do begin
			tmpStr := List[y];
			i := Pos(';', tmpStr);
			if (i <> 0) then tmpStr := Copy(tmpStr, 1, i - 1);
			tmpStr := Trim(tmpStr);
			i := Length(tmpStr);
			if (i = 0) then continue;
			if (tmpStr[1] + tmpStr[i] = '[]') then begin	// new section
				tmpStr := Trim(Copy(tmpStr, 2, i - 2));
				Section := tmpStr;
			end else  if (Section <> '') then begin		// skip sectionless keys
				i := Pos('=', tmpStr);
				if (i < 2) then continue;
				Key := Copy(tmpStr, 1, i - 1);
				Delete(tmpStr, 1, i);
				Set_Str(Key, tmpStr);
			end;
		end;
		Section := '';
	finally
		List.Free;
	end;
finally
        Stream.Free;
end;
end;


procedure TINI.Save_Strings(const Key : String);
begin
with Strings do begin
	Set_Str(Key, CommaText);
	Clear;
end;
end;


procedure TINI.Save_CBox(const OBJ : TCheckBox);
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Set_Bool(Name + '.Checked', Checked);
end;
end;


procedure TINI.Save_FileDialog(const OBJ : TOpenDialog);
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Set_Str(Name + '.FileName'	, FileName		);
	Set_Int(Name + '.FilterIndex'	, FilterIndex 		);
	Set_Str(Name + '.InitialDir'	, InitialDir		);
end;
end;


procedure TINI.Save_Font(const OBJ : TFont;  Key : String);
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Key :=  Key + 'Font.';
	Set_Str(Key + 'Name'	, Name				);
	Set_Int(Key + 'Size'	, Size				);
	Strings.Clear;
	if (fsBold	in Style) then Strings.Add('Bold'	);
	if (fsItalic	in Style) then Strings.Add('Italic'	);
	if (fsStrikeout	in Style) then Strings.Add('Strikeout'	);
	if (fsUnderline	in Style) then Strings.Add('Underline'	);
	Save_Strings(Key + 'Style');
end;
end;


procedure TINI.Save_Form;
var	tmpForm		:	tForm;
	WndPlacement	:	tWindowPlacement;
	L, T, W, H	:	Integer;
begin
tmpForm := tForm(Application.FindComponent(Section));
if (tmpForm = NIL) then Exit;
with tmpForm do begin
	if (tmpForm = Form_Main) then begin
		with WndPlacement do begin
			Length := SizeOf(WndPlacement);
			GetWindowPlacement(Form_Main.Handle, @WndPlacement);
			with rcNormalPosition do begin
				L := Left;
				T := Top;
				W := Right - Left;
				H := Bottom - Top;
			end;
		end;
	end else begin
		L := Left;
		T := Top;
		W := Width;
		H := Height;
	end;
	with Strings do begin
		Clear;  Add(IntToStr(L));  Add(IntToStr(T));  Save_Strings('Pos' );
		Clear;  Add(IntToStr(W));  Add(IntToStr(H));  Save_Strings('Size');
	end;
	Save_Font(Font, '');
end;
end;


procedure TINI.Save_LV(const OBJ : TListView);
var	i		:	Integer;
	tmp		:	Integer;
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Strings.Clear;
	for i := 0 to (Columns.Count - 1) do begin
		tmp := Columns[i].Width;
		if (PPI_cur <> PPI_dev) then tmp := (tmp * PPI_dev) div PPI_cur;
		Strings.Add(IntToStr(tmp));
	end;
	Save_Strings(Name + '.ColumnWidths');
end;
end;


procedure TINI.Save_RBtn(const OBJ : TRadioButton);
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Set_Bool(Name + '.Checked', Checked);
end;
end;


procedure TINI.Save_ToolBtn(const OBJ : TToolButton);
begin
if (OBJ = NIL) then Exit;
with OBJ do begin
	Set_Bool(Name + '.Down', Down);
end;
end;


procedure TINI.SaveToFile(const FileName : String);
var	i, j		:	Integer;
	List		:	TStringList;
begin
List := TStringList.Create;
try
	for i := 0 to (m_Sections.Count - 1) do begin
		if (i <> 0) then
		for j := 1 to 2 do  List.Add('');		// "CRLF" would add TWO lines
		List.Add('[' + m_SectionNames[i] + ']');
		List.AddStrings(m_Sections[i]);
	end;
	List.SaveToFile(FileName);
finally
	List.Free;
end;
end;


procedure TINI.Select_Section(const Name : String);
var	i		:	Integer;
begin
m_curSectionName := Name;
i := m_SectionNames.IndexOf(Name);
if (i <> -1)	then m_curSection := m_Sections[i]
		else m_curSection := NIL;
end;


procedure TINI.Set_Bool(const Key : String;  const Value : Boolean);
begin
Set_Str(Key, Str_Bool[Value]);
end;


procedure TINI.Set_HexInt(const Key : String;  const Value : Integer);
begin
Set_Str(Key, IntToHex(Value, 8));
end;


procedure TINI.Set_Int(const Key : String;  const Value : Integer);
begin
Set_Str(Key, IntToStr(Value));
end;


procedure TINI.Set_Str(Key : String;  Value : String);
var	i		:	Integer;
begin
Add_Section;
with m_curSection do begin
	i := IndexOfName(Key);
	if (i = -1)	then Add(Key + '=' + Value)
			else Values[Key] :=  Value;
end;
end;


//----------------------------------------------------------------------------------------------


initialization
INI := TINI.Create;


finalization
INI.Free;


end.
