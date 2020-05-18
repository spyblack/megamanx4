unit	UForm_Input;


interface  //-----------------------------------------------------------------------------------
uses	Windows, Buttons, Classes, ComCtrls, Controls, Dialogs, ExtCtrls, Forms, Graphics,
	ImgList, Math, Messages, StdCtrls, StrUtils, SysUtils,
	ePSXe, PCSX15, PCSX19, pSX;


const	LineSize			=	1024 * 2;
	WindowSize			=	0512 * LineSize;


type	TInputType			=	(it_File, it_ePSXe, it_PCSX15, it_PCSX19, it_pSX);


	TSavestateItem			=	class
	Disk				:	String;
	CD				:	String;
	FileName			:	String;
	InputType			:	TInputType;
	Notes				:	String;
	Region				:	String;
	Serial				:	String;
	Size				:	String;
	Slot				:	String;
	Title				:	String;
	constructor	Create			(const FileName : String;  const InputType : TInputType);
	end;


	TForm_Input			=	class(TForm)
	Btn_Backward			:	TButton;
	Btn_BrowsePath			:	TSpeedButton;
	Btn_Forward			:	TButton;
	DialogOpen			:	TOpenDialog;
	DialogSave			:	TSaveDialog;
	Edit_Offset			:	TEdit;
	Edit_Path			:	TEdit;
	Edit_Source			:	TEdit;
	Edit_Type			:	TEdit;
	GBox_Blocks			:	TGroupBox;
	GBox_Offset			:	TGroupBox;
	GBox_Preview			:	TGroupBox;
	Image_Preview			:	TImage;
	ImageList_Files			:	TImageList;
	ImageList_Slots			:	TImageList;
	LV_Blocks			:	TListView;
	LV_Files			:	TListView;
	LV_Slots			:	TListView;
	Panel_CurrentBottom		:	TPanel;
	Panel_CurrentTop		:	TPanel;
	Panel_FilesBottom		:	TPanel;
	Panel_FilesPath			:	TPanel;
	Panel_Jump			:	TPanel;
	Panel_Path			:	TPanel;
	Panel_Preview			:	TPanel;
	PC				:	TPageControl;
	RBtn_Line			:	TRadioButton;
	RBtn_Window			:	TRadioButton;
	Splitter			:	TSplitter;
	TS_Current			:	TTabSheet;
	TS_Files			:	TTabSheet;
	GBox_Source			:	TGroupBox;
	procedure	GUI_ChangedPath		(Sender : TObject);
	procedure	GUI_ChangeOffset	(Sender : TObject);
	procedure	GUI_ChangePC		(Sender : TObject);
	procedure	GUI_ChangingPC		(Sender : TObject;  var AllowChange : Boolean);
	procedure	GUI_ClickBrowse		(Sender : TObject);
	procedure	GUI_ClickJump		(Sender : TObject);
	procedure	GUI_ClickPreview	(Sender : TObject);
	procedure	GUI_CreateForm		(Sender : TObject);
	procedure	GUI_DblClickFiles	(Sender : TObject);
	procedure	GUI_DblClickSlots	(Sender : TObject);
	procedure	GUI_DestroyForm		(Sender : TObject);
	procedure	GUI_HideForm		(Sender : TObject);
	procedure	GUI_KeyDownPath		(Sender : TObject;  var Key : Word;  Shift : TShiftState);
	procedure	GUI_KeyDownFiles	(Sender : TObject;  var Key : Word;  Shift : TShiftState);
	procedure	GUI_KeyDownForm		(Sender : TObject;  var Key : Word;  Shift : TShiftState);
	procedure	GUI_KeyPressOffset	(Sender : TObject;  var Key : Char);
	procedure	GUI_SelectBlock		(Sender : TObject;  Item : TListItem;  Selected : Boolean);
	procedure	GUI_SelectFile		(Sender : TObject;  Item : TListItem;  Selected : Boolean);
	procedure	GUI_ShowForm		(Sender : TObject);
	private
	ActiveCtrls			:	array[0..1] of TWinControl;
	AppTitle			:	String;
	cur_Path			:	String;		// including path delimiter
	Directories			:	TStringList;
	ePSXe				:	ePSXe_Savestate;
	Files				:	TStringList;
	FileStream			:	TFileStream;
	first_OnShow			:	Boolean;
	GameTitle			:	String;
	InputType			:	TInputType;
	LastOffset			:	Integer;
	LastPage			:	Integer;
	LastSlot			:	String;
	List_Entries			:	TStringList;
	List_Serials			:	TStringList;
	MemoryStream			:	TMemoryStream;
	Path_SelLen			:	Integer;
	Path_SelPos			:	Integer;
	PCSX15				:	PCSX15_Savestate;
	PCSX19				:	PCSX19_Savestate;
	pSX				:	pSX_Savestate;
	Savestates			:	TStringList;
	procedure	ChangeDir		(const Directory : String);
	function	Get_GameEntry		(const Serial : String) : String;
	function	Get_InputType		(const FileName : String) : TInputType;
	function	Get_SlotIndex		(const FileName : String) : String;
	procedure	Load_GameList		;
	procedure	Load_Preview		(const FileName : String;  const BMP : TBitmap);
	procedure	Load_Settings		;
	procedure	Update_Files		;
	procedure	Update_Slots		(const Item : TListItem;  const Selected : Boolean);
	public
	LastFile			:	String;
	LastLoaded			:	String;
	LastVisible			:	Boolean;
	Offset				:	Integer;
	procedure	Activate_File		;
	procedure	Activate_Slot		;
	procedure	LoadFromFile		(FileName : String;  const NewOffset : Integer = -1);
	procedure	Reload			;
	procedure	Save_Settings		;
	procedure	Set_Offset		(const Value : Integer);
	end;


var	Form_Input	:	TForm_Input;
	InputSource	:	TStream;


function CopyUntil	(const Text, Terminator : String) : String;
function is_AtoZ	(const Text : String		) : Boolean;
function is_Numbers	(const Text : String		) : Boolean;


implementation  //------------------------------------------------------------------------------
uses	UForm_Main, UForm_Palette, UINI, UShared, UStreamTools;


{$R *.dfm}


const	Attr		=	faAnyFile - 2;			// faHidden (ignore platform warning)


// tools


function CopyUntil(const Text, Terminator : String) : String;
var	i		:	Integer;
begin
i := Pos(Terminator, Text) - 1;  if (i = -1) then i := MaxInt;
Result := Copy(Text, 1, i);
end;


procedure Error(const Text : String);
begin
MessageDlg(Text, mtError, [mbOK], 0);
end;


procedure Get_DirectoryContent(const Path : String;  const Directories, Files : TStringList);
var	empty		:	Boolean;
	SearchRec	:	TSearchRec;
begin
Directories.Clear;
Files      .Clear;
empty := (FindFirst(Path + '*', Attr, SearchRec) <> 0);
try
	if (not empty) then with SearchRec do repeat
		if (Name = '.') then continue;
		if (Attr AND faDirectory <> 0)	then Directories.Add(Name)
						else Files      .Add(Name);
	until (FindNext(SearchRec) <> 0);
finally
	FindClose(SearchRec);
end;
end;


function Get_SubString(const Text : String;  const Index : Cardinal) : String;
var	cur_Index	:	Cardinal;
	i		:	Integer;
	StartPos	:	Integer;
begin
cur_Index := 0;
StartPos  := 1;
repeat
	i := PosEx(#9, Text, StartPos);
	if (cur_Index = Index) then begin
		if (i = 0) then i := MaxInt;
		Result := Copy(Text, StartPos, i - StartPos);
		exit;
	end;
	Inc(cur_Index);
	StartPos := i + 1;
until (i = 0);
Result := '';
end;


function Find_WinControl(const Name : String;  const Start : TWinControl) : TWinControl;
var	i		:	Integer;
	Ctrl		:	TControl;
	WinCtrl		:	TWinControl absolute Ctrl;
begin
for i := 0 to (Start.ControlCount - 1) do begin
	Ctrl := Start.Controls[i];
	if (Ctrl is TWinControl) then begin
		if (WinCtrl.Name = Name) then begin
			Result := WinCtrl;
			exit;
		end;
		Result := Find_WinControl(Name, WinCtrl);
		if (Result <> NIL) then exit;
	end;
end;
Result := NIL;
end;


function is_AtoZ(const Text : String) : Boolean;
var	i		:	Integer;
	s		:	String;
begin
s := UpperCase(Text);
for i := 1 to Length(s) do begin
	if (not CharInSet(s[i], ['A'..'Z'])) then exit(False);
end;
exit(True);
end;


function is_Numbers(const Text : String) : Boolean;
var	i		:	Integer;
begin
i := Length(Text);
if (i = 0) then exit(False);
for i := 1 to i do begin
	if (not CharInSet(Text[i], ['0'..'9'])) then exit(False);
end;
exit(True);
end;


procedure Set_LVStatus(const LV : TListView);
begin
with LV do begin
	Enabled := (Items.Count <> 0);
	if Enabled then begin
		Color := clWindow;
		ItemFocused := Items[0];
		ItemFocused.Selected := True;
	end else begin
		ParentColor := True;
	end;
end;
end;


procedure Swap_PointerContents(var PointerVar1, PointerVar2);
var	tmp		:	Pointer;
	Var1		:	Pointer absolute PointerVar1;
	Var2		:	Pointer absolute PointerVar2;
begin
tmp  := Var1;
Var1 := Var2;
Var2 := tmp ;
end;


procedure Warn(const Text : String);
begin
MessageDlg(Text, mtWarning, [mbOK], 0);
end;


// TForm_Input


procedure TForm_Input.Activate_File;
begin
with LV_Files.ItemFocused do begin
	if (not Selected) then exit;
	case ImageIndex of
		0, 1:	ChangeDir	(           Caption);	// directory
		2   :	LoadFromFile	(cur_Path + Caption);	// file
		3   :	Activate_Slot;				// savestate
		else	Assert(False);
	end;
end;
end;


procedure TForm_Input.Activate_Slot;
begin
with LV_Slots do begin
	if (not Enabled) then exit;
	with ItemFocused do begin
		if (not Selected) then exit;
		LoadFromFile(SubItems[0]);
	end;
end;
end;


procedure TForm_Input.GUI_ClickJump(Sender : TObject);
var	Btn		:	TButton absolute Sender;
	i		:	Integer;
begin
if RBtn_Line.Checked	then i := LineSize
			else i := WindowSize;
if (Btn = Btn_Backward)	then i := -i else
if (Btn = Btn_Forward )	then i := +i else Assert(False);
Edit_Offset.Text := IntToStr(Offset + i);
end;


procedure TForm_Input.ChangeDir(const Directory : String);
var	i		:	Integer;
	prev_Dir	:	String;
	prev_Item	:	TListItem;
	s		:	String;
begin
if (Directory = '.' ) then exit;
if (Directory = '..') then begin
	s := Copy(cur_Path, 1, Length(cur_Path) - 1);		// remove last char
	for i := Length(s) downto 1 do begin
		if (s[i] = PathDelim) then begin
			prev_Dir	:= Copy(s, i + 1, MaxInt);
			Edit_Path.Text	:= Copy(s,     1,      i);  // update GUI
			prev_Item	:= LV_Files.FindCaption(0, prev_Dir, False, True, False);
			if (prev_Item <> NIL) then with prev_Item do begin
				Focused  := True;
				Selected := True;
				MakeVisible(False);
			end;
			break;
		end;
	end;
end else begin
	Edit_Path.Text := cur_Path + Directory + '\';		// update GUI
end;
end;


function TForm_Input.Get_GameEntry(const Serial : String) : String;
var	i		:	Integer;
begin
i := List_Serials.IndexOf(Serial);
if (i <> -1)	then Result := List_Entries[i]
		else Result := '';
end;


function TForm_Input.Get_InputType(const FileName : String) : TInputType;
begin
if  pSX  .Check_File(FileName) then exit(it_pSX   );		// uncompressed
if ePSXe .Check_File(FileName) then exit(it_ePSXe );		//   compressed
if PCSX15.Check_File(FileName) then exit(it_PCSX15);		//   compressed
if PCSX19.Check_File(FileName) then exit(it_PCSX19);		//   compressed
exit(it_File);
end;


function TForm_Input.Get_SlotIndex(const FileName : String) : String;
begin
case Get_InputType(FileName) of
	it_ePSXe	:	Result := 'ePSXe'     + ' slot ' + ePSXe .Get_SlotIndex(FileName);
	it_PCSX15	:	Result := 'PCSX v1.5' + ' slot ' + PCSX15.Get_SlotIndex(FileName);
	it_PCSX19	:	Result := 'PCSX v1.9' + ' slot ' + PCSX19.Get_SlotIndex(FileName);
	it_pSX		:	Result :=  'pSX'      + ' slot ' +  pSX  .Get_SlotIndex(FileName);
	else			Result := '';
end;
end;


procedure TForm_Input.GUI_ChangedPath(Sender : TObject);
var	c		:	Char;
	s		:	String;
begin
Changed_Edit(Sender);
s := Edit_Path.Text;
if (Length(s) = 1) then begin
	c := UpCase(s[1]);
	if CharInSet(c, ['A'..'Z']) then begin
		Edit_Path.Text := c + ':\';
		Edit_Path.SelStart := MaxInt;
		exit;
	end;
end;
Update_Files;
end;


procedure TForm_Input.GUI_ChangeOffset(Sender : TObject);
var	corrected	:	Integer;
	ErrorCode	:	Integer;
	i		:	Integer;
	s		:	String;
	UserValue	:	Integer;
begin
Changed_Edit(Sender);
Val(Edit_Offset.Text, UserValue, ErrorCode);
if (ErrorCode <> 0)	then corrected := Offset
			else corrected := -1;
if (corrected = -1) then begin
	i := Max(0, InputSource.Size - WindowSize);
	if (UserValue < 0) then corrected := 0;
	if (UserValue > i) then corrected := i;
end;
if (corrected <> -1) then begin
	s := IntToStr(corrected);
	with Edit_Offset do  if (Text <> s) then Text := s;
	exit;
end;
if (UserValue <> Offset) then begin
	Set_Offset(UserValue);
	Form_Main.Update_GUI;
end;
end;


procedure TForm_Input.GUI_ChangePC(Sender : TObject);
begin
ActiveControl := ActiveCtrls[PC.ActivePageIndex];
if (PC.ActivePageIndex = 0) then begin
	Edit_Path.SelStart  := Path_SelPos;
	Edit_Path.SelLength := Path_SelLen;
end;
end;


procedure TForm_Input.GUI_ChangingPC(Sender : TObject;  var AllowChange : Boolean);
begin
ActiveCtrls[PC.ActivePageIndex] := ActiveControl;
if (PC.ActivePageIndex = 0) then begin
	Path_SelPos := Edit_Path.SelStart;
	Path_SelLen := Edit_Path.SelLength;
end;
end;


procedure TForm_Input.GUI_ClickBrowse(Sender : TObject);
var	b		:	Boolean;
	Pos		:	TPoint;
	s		:	String;
begin
with Pos, Btn_BrowsePath do begin
	x := Width  div 2;
	y := Height div 2;
	Pos := ClientToScreen(Pos);
end;
b := Exec_DirDlg('', s, Pos);
SetFocus;
if b then  with Edit_Path do begin
	Text := IncludeTrailingPathDelimiter(s);		// update GUI
	SelectAll;
end;
end;


procedure TForm_Input.GUI_ClickPreview(Sender : TObject);
begin
Save_Image(Image_Preview, DialogSave);
end;


procedure TForm_Input.GUI_CreateForm(Sender : TObject);
begin
inherited;
AppTitle	:= Application		.Title;
cur_Path	:= Edit_Path		.Text;
Directories	:= TStringList		.Create;  Directories.Sorted := True;
ePSXe		:= ePSXe_Savestate	.Create;
Files		:= TStringList		.Create;  Files      .Sorted := True;
List_Entries	:= TStringList		.Create;
List_Serials	:= TStringList		.Create;
MemoryStream	:= TMemoryStream	.Create;
PCSX15		:= PCSX15_Savestate	.Create;
PCSX19		:= PCSX19_Savestate	.Create;
 pSX		:=    pSX_Savestate	.Create;
Savestates	:= TStringList		.Create(True);
first_OnShow	:= True;
InputSource	:= MemoryStream;
with Image_Preview.Picture.Bitmap do begin
	PixelFormat			:= pf24Bit;
	Canvas.Brush.Color		:= clBlack;
	Width				:= 128;
	Height				:=  96;
end;
Load_GameList;
Load_Settings;
end;


procedure TForm_Input.GUI_DblClickFiles(Sender: TObject);
begin
Activate_File;
end;


procedure TForm_Input.GUI_DblClickSlots(Sender: TObject);
begin
Activate_Slot;
end;


procedure TForm_Input.GUI_DestroyForm(Sender : TObject);
begin
Directories	.Free;
ePSXe		.Free;
Files		.Free;
FileStream	.Free;
List_Entries	.Free;
List_Serials	.Free;
MemoryStream	.Free;
PCSX15		.Free;
PCSX19		.Free;
 pSX		.Free;
Savestates	.Free;
end;


procedure TForm_Input.GUI_HideForm(Sender : TObject);
begin
with Form_Main.Btn_InputSource do begin
	if Down then Down := False;
end;
end;


procedure TForm_Input.GUI_KeyDownPath(Sender : TObject;  var Key : Word;  Shift : TShiftState);
begin
case Key of
	VK_Return	:	Btn_BrowsePath.Click;
	else			exit;
end;
Key := 0;
end;


procedure TForm_Input.GUI_KeyDownFiles(Sender : TObject;  var Key : Word;  Shift : TShiftState);
var	LV		:	TListView absolute Sender;
	NewKey		:	Word;
begin
NewKey := 0;
case Key of
	VK_Back		:	ChangeDir('..');
	VK_Left		:	NewKey := VK_PgUp;
	VK_Right	:	with LV_Slots do  if Enabled then SetFocus;
	VK_Return	:	Activate_File;
	else			exit;
end;
Key := NewKey;
end;


procedure TForm_Input.GUI_KeyDownForm(Sender : TObject;  var Key : Word;  Shift : TShiftState);
const	OffsetKeys	=	[VK_PgUp, VK_PgDown, VK_Add, VK_Subtract];
var	b		:	Boolean;
	i		:	Integer;
begin
if (Key = VK_F4) and (ssAlt in Shift) then begin
	Form_Main.Close;
	Key := 0;
end;
if (Key in OffsetKeys) then begin
	b := True;
	if (Key in [VK_PgUp, VK_PgDown  ]) and (ActiveControl.ClassType = TListView) then b := False;
	if (Key in [VK_Add , VK_Subtract]) and (ActiveControl           = Edit_Path) then b := False;
	if b then begin
		Form_Main.GUI_KeyDownForm(Sender, Key, Shift);
		Key := 0;
	end;
end;
if (ActiveControl = Edit_Offset) then begin
	i := Offset;
	case Key of
		VK_Down	:	Dec(i);
		VK_Up	:	Inc(i);
	end;
	if (i <> Offset) then begin
		Edit_Offset.Text := IntToStr(i);
		Edit_Offset.SelectAll;
		Key := 0;
	end;
end;
if (ActiveControl = LV_Slots) then begin
	case Key of
		VK_Left	:	LV_Files.SetFocus;
		VK_Right:	begin
				Key := VK_PgDown;
				exit;
				end;
		VK_Up	:	begin
				if (LV_Slots.ItemIndex <> 0) then exit;
				if (LV_Files.ItemIndex  = 0) then exit;
				with LV_Files do begin
					ItemFocused := Items[ItemIndex - 1];
					ItemFocused.Selected := True;
					ItemFocused.MakeVisible(False);
				end;
				with LV_Slots do  if Enabled then begin
					ItemFocused := Items[Items.Count - 1];
					ItemFocused.Selected := True;
					ItemFocused.MakeVisible(False);
					SetFocus;
				end else begin
					LV_Files.SetFocus;
				end;
				end;
		VK_Down	:	begin
				with LV_Slots do  if (ItemIndex <> Items.Count - 1) then exit;
				with LV_Files do  if (ItemIndex  = Items.Count - 1) then exit;
				with LV_Files do begin
					ItemFocused := Items[ItemIndex + 1];
					ItemFocused.Selected := True;
					ItemFocused.MakeVisible(False);
				end;
				with LV_Slots do  if Enabled then begin
					ItemFocused := Items[0];
					ItemFocused.Selected := True;
					ItemFocused.MakeVisible(False);
					SetFocus;
				end else begin
					LV_Files.SetFocus;
				end;
				end;
		VK_Return:	Activate_Slot;
		else	 	exit;
	end;
	Key := 0;
end;
end;


procedure TForm_Input.GUI_KeyPressOffset(Sender : TObject;  var Key : Char);
begin
if CharInSet(Key, ['-', '+']) then Key := #0;
end;


procedure TForm_Input.GUI_SelectBlock(Sender : TObject;  Item : TListItem;  Selected : Boolean);
begin
if Selected then Edit_Offset.Text := Item.SubItems[0];
end;


procedure TForm_Input.GUI_SelectFile(Sender : TObject;  Item : TListItem;  Selected : Boolean);
begin
Update_Slots(Item, Selected);
end;


procedure TForm_Input.GUI_ShowForm(Sender : TObject);
var	Item		:	TListItem;
begin
if first_OnShow then begin
	first_OnShow   := False;
	Edit_Path.Text := cur_Path;				// update GUI
	with LV_Files do begin
		Item := FindCaption(0, LastFile, False, True, False);
		if (Item <> NIL) then begin
			ItemFocused := Item;
			Item.MakeVisible(False);
			Item.Selected := True;
		end;
	end;
	with LV_Slots do begin
		Item := FindCaption(0, LastSlot, False, True, False);
		if (Item <> NIL) then begin
			ItemFocused := Item;
			Item.MakeVisible(False);
			Item.Selected := True;
		end;
	end;
	if (ActiveCtrls[0] = NIL) then begin
		if LV_Files.Enabled	then ActiveCtrls[0] := LV_Files
					else ActiveCtrls[0] := Edit_Path;
	end;
	if (ActiveCtrls[1] = NIL) then begin
		ActiveCtrls[1] := PC;
	end;
	PC.ActivePageIndex := LastPage;
	ActiveControl      := ActiveCtrls[LastPage];
end;
with Form_Main.Btn_InputSource do begin
	if (not Down) then Down := True;
end;
end;


procedure TForm_Input.Load_GameList;
var	i		:	Integer;
	List		:	TStringList;
	s		:	String;
	y		:	Integer;
begin
s := ExtractFilePath(Application.ExeName) + 'psx_serials.txt';
List := TStringList.Create;
try
	try List.LoadFromFile(s) except end;			// catch 'em all
	if (List.Count <> 0) then begin
		List.Sort;
		for y := 0 to (List.Count - 1) do begin		// separate into serial & entry
			s := List[y];
			i := Pos(#9, s);
			if (i <> 0) then begin
				List_Serials.Add(Trim(Copy(s,     1,  i - 1)));
				List_Entries.Add(Trim(Copy(s, i + 1, MaxInt)));
			end;
		end;
	end;
finally
	List.Free;
end;
end;


procedure TForm_Input.Load_Preview(const FileName : String;  const BMP : TBitmap);
begin
if ePSXe .Load_Preview(FileName, BMP) then exit;
if PCSX15.Load_Preview(FileName, BMP) then exit;
if PCSX19.Load_Preview(FileName, BMP) then exit;
with BMP.Canvas do begin
	Brush.Color := clBlack;
	FillRect(ClipRect);
end;
end;


procedure TForm_Input.Load_Settings;
var	i		:	Integer;
	s		:	String;
begin
LastOffset := -1;
with INI do begin
	Section := Name;
	Load_Form	(False			);
	Load_FileDialog	(DialogOpen		);
	Load_FileDialog	(DialogSave		);
	Load_RBtn	(RBtn_Line		);
	Load_RBtn	(RBtn_Window		);
	Get_Bool	('Visible', LastVisible	);
	if Get_Str	('ActiveCtrls[0]'    , s) then ActiveCtrls[0]	:= Find_WinControl(s, Self);
	if Get_Str	('ActiveCtrls[1]'    , s) then ActiveCtrls[1]	:= Find_WinControl(s, Self);
	if Get_Str	('cur_Path'          , s) then cur_Path		:= FollowPath(s);
	if Get_Str	('LastFile'          , s) then LastFile		:= s;
	if Get_Str	('LastLoaded'        , s) then LastLoaded	:= FollowPath(s);
	if Get_Int	('LastOffset'        , i) then LastOffset	:= i;
	if Get_Int	('LastPage'          , i) then LastPage		:= i;
	if Get_Str	('LastSlot'          , s) then LastSlot		:= s;
end;
end;


procedure TForm_Input.LoadFromFile(FileName : String;  const NewOffset : Integer = -1);
const	TypeNames	:	array[TInputType] of String
			=	('file', 'ePSXe savestate', 'PCSX v1.5 savestate', 'PCSX v1.9 savestate', 'pSX savestate');
var	fs		:	TFileStream;
	i		:	Integer;
	j		:	Integer;
	ms		:	TMemoryStream;
	s		:	String;
	Serial		:	String;
	Slot		:	String;
	tmp_ePSXe	:	ePSXe_Savestate;
	tmp_PCSX15	:	PCSX15_Savestate;
	tmp_PCSX19	:	PCSX19_Savestate;
	tmp_pSX		:	pSX_Savestate;
begin
tmp_ePSXe :=  ePSXe_Savestate.Create;
tmp_PCSX15:= PCSX15_Savestate.Create;
tmp_PCSX19:= PCSX19_Savestate.Create;
tmp_pSX   :=    pSX_Savestate.Create;
try
	if tmp_pSX.LoadFromFile(FileName, fs) then begin	// uncompressed
		Swap_PointerContents(pSX, tmp_pSX);		// swap savestate with temporary savestate
		FileStream.Free;
		FileStream	:= fs;
		InputSource	:= fs;
		InputType	:= it_pSX;
		i		:= pSX.VRAM;
	end else
	if tmp_ePSXe.LoadFromFile(FileName, ms) then begin	// compressed
		Swap_PointerContents(ePSXe, tmp_ePSXe);		// swap savestate with temporary savestate
		MemoryStream.Free;
		MemoryStream	:= ms;
		InputSource	:= ms;
		InputType	:= it_ePSXe;
		i		:= ePSXe.VRAM;
	end else
	if tmp_PCSX15.LoadFromFile(FileName, ms) then begin	// compressed
		Swap_PointerContents(PCSX15, tmp_PCSX15);	// swap savestate with temporary savestate
		MemoryStream.Free;
		MemoryStream	:= ms;
		InputSource	:= ms;
		InputType	:= it_PCSX15;
		i		:= PCSX15.VRAM;
	end else
	if tmp_PCSX19.LoadFromFile(FileName, ms) then begin	// compressed
		Swap_PointerContents(PCSX19, tmp_PCSX19);	// swap savestate with temporary savestate
		MemoryStream.Free;
		MemoryStream	:= ms;
		InputSource	:= ms;
		InputType	:= it_PCSX19;
		i		:= PCSX19.VRAM;
	end else
	if Open_Stream(FileName, fs) then begin			// fallback
		FileStream.Free;
		FileStream	:= fs;
		InputSource	:= fs;
		InputType	:= it_File;
		i		:= 0;
	end else begin						// error
		Error('cannot open file "' + FileName + '"');
		exit;
	end;
finally
	tmp_ePSXe .Free;					// remove old and/or temporary savestate objects
	tmp_PCSX15.Free;
	tmp_PCSX19.Free;
	tmp_pSX   .Free;
end;
if (NewOffset <> -1) then i := NewOffset;
LastLoaded := FileName;
s := TypeNames[InputType];
case InputType of
	it_ePSXe:	with ePSXe do  s := s + ' - version ' + IntToStr(Version) + ' - "' + Game_ID + '"';
end;
with Edit_Source do begin  Enabled := True;  Text := LastLoaded;  end;
with Edit_Type   do begin  Enabled := True;  Text :=          s;  end;
Edit_Offset.Text := IntToStr(i);
with LV_Blocks do begin
	Items.BeginUpdate;
	Clear;
	if (InputType = it_ePSXe) then  with ePSXe do begin
		for i := 0 to High(Blocks) do begin
			with Items.Add, Blocks[i] do begin
				Caption := ID;
				SubItems.Add(IntToStr(DataOffset));
				SubItems.Add(IntToStr(DataSize));
			end;
		end;
	end else
	if (InputType = it_PCSX15) then begin
		{}
	end else
	if (InputType = it_PCSX19) then begin
		{}
	end else
	if (InputType = it_pSX) then  with pSX do  for i := 0 to High(Blocks) do  with Blocks[i] do begin
		s := ''     ;  for j := 0 to 3 do  s := s + IntToHex(Ord(ID[j]), 2) + ' ';
		s := s + ' ';  for j := 0 to 3 do  if (ID[j] = #0) then s := s + '_' else s := s + String(ID[j]);
		with Items.Add do begin
			Caption := s;
			SubItems.Add(IntToStr(DataOffset));
			SubItems.Add(IntToStr(DataSize  ));
		end;
	end;
	Items.EndUpdate;
	Enabled := (Items.Count <> 0);
	if Enabled then Color := clWindow else ParentColor := True;
end;
Load_Preview(LastLoaded, Image_Preview.Picture.Bitmap);
case InputType of
	it_ePSXe :	Serial := ePSXe .Get_Serial(FileName);
	it_PCSX15:	Serial := PCSX15.Get_Serial(FileName);
	it_PCSX19:	Serial := PCSX19.Get_Serial(FileName);
	it_pSX   :	Serial :=  pSX  .Get_Serial(FileName);
	else		Serial := '';
end;
Slot := Get_SlotIndex(FileName);  if (Slot <> '') then Slot := ' [' + Slot + ']';
if (InputType = it_PCSX15)					// get title or empty string
	then GameTitle := Trim(ChangeFileExt(FileName, ''))
	else GameTitle := Get_SubString(Get_GameEntry(Serial), 4);
FileName := ExtractFileName(FileName);
if (GameTitle = '') then s := FileName else s := GameTitle+Slot;// get FileName or "title [slot]"
Application .Title   := s + ' - ' + AppTitle;			// set taskbar button caption
Form_Palette.Caption := s;					// set Form_Palette   caption
Form_Main   .Caption := Application.Title + ' - ' + LastLoaded;	// set Form_Main      caption
Form_Main.Update_GUI;
if (InputType = it_ePSXe) then with ePSXe do begin
	if (Game_ID <> Serial) then Warn('internal ID "' + Game_ID + '" <> file ID "' + Serial + '"');
end;
end;


procedure TForm_Input.Reload;
begin
LoadFromFile(LastLoaded, LastOffset);
end;


procedure TForm_Input.Save_Settings;
var	Name0		:	String;
	Name1		:	String;
begin
LastPage		:= PC.ActivePageIndex;
ActiveCtrls[LastPage]	:= ActiveControl;
with LV_Files do  if Enabled then LastFile := ItemFocused.Caption else LastFile := '';
with LV_Slots do  if Enabled then LastSlot := ItemFocused.Caption else LastSlot := '';
if assigned(ActiveCtrls[0])  then Name0    := ActiveCtrls[0].Name else Name0    := '';
if assigned(ActiveCtrls[1])  then Name1    := ActiveCtrls[1].Name else Name1    := '';
with INI do begin
	Section := Name;
	Save_Form;
	Set_Str		('ActiveCtrls[0]'	, Name0			);
	Set_Str		('ActiveCtrls[1]'	, Name1			);
	Set_Str		('cur_Path'		, cur_Path		);
	Set_Bool	('Focused'		, Focused		);
	Set_Str		('LastFile'		, LastFile		);
	Set_Str		('LastLoaded'		, LastLoaded		);
	Set_Int		('LastOffset'		, LastOffset		);
	Set_Int		('LastPage'		, LastPage		);
	Set_Str		('LastSlot'		, LastSlot		);
	Set_Bool	('Visible'		, Visible		);
	Save_FileDialog	(DialogOpen					);
	Save_FileDialog	(DialogSave					);
	Save_RBtn	(RBtn_Line					);
	Save_RBtn	(RBtn_Window					);
end;
end;


procedure TForm_Input.Set_Offset(const Value : Integer);
var	i		:	Integer;
begin
Offset := Value;
i := InputSource.Size - WindowSize;
if (Offset > i) then Offset := i;
if (Offset < 0) then Offset := 0;
if (PC.ActivePageIndex = 1) then ActiveCtrls[1] := ActiveControl;
Btn_Backward.Enabled := (Offset > 0				);
Btn_Forward .Enabled := (Offset < InputSource.Size - WindowSize	);
if (ActiveCtrls[1] = Btn_Backward) or (ActiveCtrls[1] = Btn_Forward) then begin
	if (not ActiveCtrls[1].Enabled) then ActiveCtrls[1] := Edit_Offset;
end;
if (PC.ActivePageIndex = 1) then ActiveControl := ActiveCtrls[1];
LastOffset := Offset;
end;


procedure TForm_Input.Update_Files;
var	i		:	Integer;
	Item		:	TSavestateItem;
	j		:	Integer;
	s		:	String;
	tmpType		:	TInputType;
begin
cur_Path := IncludeTrailingPathDelimiter(Edit_Path.Text);
Get_DirectoryContent(cur_Path, Directories, Files);		// get directories & files lists
Savestates.Clear;						// extract savestate names
for i := (Files.Count - 1) downto 0 do begin
	s := Files[i];
	tmpType := Get_InputType(cur_Path + s);
	if (tmpType <> it_File) then begin
		Savestates.Insert(0, s);
		Savestates.Objects[0] := TSavestateItem.Create(s, tmpType);
		Files.Delete(i);
		if (tmpType = it_ePSXe) then begin		// remove *.pic entry
			j := Files.IndexOf(s + '.pic');
			if (j <> -1) then Files.Delete(j);
		end;
	end;
end;
LV_Files.Items.BeginUpdate;					// update GUI
LV_Files.Clear;
for i := 0 to (Directories.Count - 1) do begin			// add directory items
	with LV_Files.Items.Add do begin
		Caption := Directories[i];
		if (Caption = '..')	then ImageIndex := 1
					else ImageIndex := 0;
	end;
end;
for i := 0 to (Savestates.Count - 1) do begin			// add one item per savestate
	Item := (Savestates.Objects[i] as TSavestateItem);
	s := Item.Serial;
	if (LV_Files.FindCaption(0, s, False, True, False) <> NIL) then continue;
	with LV_Files.Items.Add do begin
		ImageIndex	:= 3;
		Caption		:= s;
		Data		:= Item;
		SubItems.Add(Item.Title	);
		SubItems.Add(Item.Disk	);
		SubItems.Add(Item.Region);
		SubItems.Add(Item.CD	);
		SubItems.Add(Item.Size	);
		SubItems.Add(Item.Notes	);
	end;
end;
for i := 0 to (Files.Count - 1) do begin			// add remaining files
	with LV_Files.Items.Add do begin
		ImageIndex := 2;
		Caption    := Files[i];
	end;
end;
LV_Files.Items.EndUpdate;
Set_LVStatus(LV_Files);						// causes LV_Slots to update
end;


procedure TForm_Input.Update_Slots(const Item : TListItem;  const Selected : Boolean);
var	BMP		:	TBitmap;
	i		:	Integer;
	s		:	String;
	SavestateItem	:	TSavestateItem;
	tmpItem		:	TSavestateItem;
begin
BMP := TBitmap.Create;
with BMP do begin
	PixelFormat := pf24Bit;
	Width       := 128;
	Height      :=  96;
end;
with LV_Slots.Items do begin
	BeginUpdate;
	Clear;
end;
ImageList_Slots.Clear;
try
	if (not Selected        ) then exit;
	if (Item.ImageIndex <> 3) then exit;
	SavestateItem := TSavestateItem(Item.Data);
	for i := 0 to (Savestates.Count - 1) do begin
		tmpItem := (Savestates.Objects[i] as TSavestateItem);
		if (tmpItem.Serial = SavestateItem.Serial) then begin
			s := cur_Path + tmpItem.FileName;
			Load_Preview(s, BMP);
			ImageList_Slots.AddMasked(BMP, clNone);
			with LV_Slots.Items.Add do begin
				ImageIndex := ImageList_Slots.Count - 1;
				Caption    := tmpItem.Slot;
				SubItems.Add(s);
			end;
		end;
	end;
finally
	BMP.Free;
	LV_Slots.Items.EndUpdate;
	Set_LVStatus(LV_Slots);
end;
end;


// TSavestateItem


constructor TSavestateItem.Create(const FileName : String;  const InputType : TInputType);
var	i		:	Integer;
	s		:	String;
begin
inherited Create;
Self.FileName  := FileName;
Self.InputType := InputType;
s := Form_Input.cur_Path + FileName;
case InputType of
	it_ePSXe :  with Form_Input.ePSXe  do begin  Serial := Get_Serial(s);  Slot := ' ePSXe '    + Get_SlotIndex(s);  end;
	it_PCSX15:  with Form_Input.PCSX15 do begin  Serial := Get_Serial(s);  Slot := ' PCSX 1.5 ' + Get_SlotIndex(s);  end;
	it_PCSX19:  with Form_Input.PCSX19 do begin  Serial := Get_Serial(s);  Slot := ' PCSX 1.9 ' + Get_SlotIndex(s);  end;
	it_pSX   :  with Form_Input. pSX   do begin  Serial := Get_Serial(s);  Slot := ' pSX '      + Get_SlotIndex(s);  end;
	else        begin  Assert(False);  exit;  end;
end;
if (Serial = '') then Serial := FileName;
s := Form_Input.Get_GameEntry(Serial);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  Region	:= Copy(s, 1, i - 1);  Delete(s, 1, i);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  CD	:= Copy(s, 1, i - 1);  Delete(s, 1, i);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  Size	:= Copy(s, 1, i - 1);  Delete(s, 1, i);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  Disk	:= Copy(s, 1, i - 1);  Delete(s, 1, i);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  Title	:= Copy(s, 1, i - 1);  Delete(s, 1, i);
i := Pos(#9, s);  if (i = 0) then i := MaxInt;  Notes	:= Copy(s, 1, i - 1);
end;


//----------------------------------------------------------------------------------------------


initialization
ForceCurrentDirectory := True;


end.

