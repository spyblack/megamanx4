unit	UForm_Main;


interface  //-----------------------------------------------------------------------------------
uses	Windows, AppEvnts, Classes, ComCtrls, Controls, Dialogs, ExtCtrls, Forms, Graphics,
	ImgList, Math, Messages, PNGImage, SysUtils, ToolWin;


type	TBPP				=	(BPP_04, BPP_08, BPP_15, BPP_24);
	TInputMode			=	(imOutput, imPalette, imScroll, imZoom);
	TOutputMode			=	(                     omScroll, omZoom);


	TForm_Main			=	class(TForm)
	AppEvents			:	TApplicationEvents;
	Btn_04bpp			:	TToolButton;
	Btn_08bpp			:	TToolButton;
	Btn_15bpp			:	TToolButton;
	Btn_24bpp			:	TToolButton;
	Btn_InputScroll			:	TToolButton;
	Btn_InputSource			:	TToolButton;
	Btn_InputZoom			:	TToolButton;
	Btn_Output			:	TToolButton;
	Btn_OutputScroll		:	TToolButton;
	Btn_OutputZoom			:	TToolButton;
	Btn_Palette			:	TToolButton;
	Btn_Reload			:	TToolButton;
	Btn_SaveInput			:	TToolButton;
	Btn_SaveOutput			:	TToolButton;
	Btn_Separator1			:	TToolButton;
	Btn_Separator2			:	TToolButton;
	Btn_Separator4			:	TToolButton;
	Btn_Separator5			:	TToolButton;
	Btn_ShowPalette			:	TToolButton;
	DialogSave_Input		:	TSaveDialog;
	DialogSave_Output		:	TSaveDialog;
	Image_Input			:	TImage;
	Image_Output			:	TImage;
	ImageList			:	TImageList;
	ScrollBox_Input			:	TScrollBox;
	ScrollBox_Output		:	TScrollBox;
	Splitter			:	TSplitter;
	StatusBar			:	TStatusBar;
	Timer				:	TTimer;
	ToolBar				:	TToolBar;
	procedure	GUI_ActivateApp		(Sender : TObject);
	procedure	GUI_ClickBPP		(Sender : TObject);
	procedure	GUI_ClickInput		(Sender : TObject);
	procedure	GUI_ClickInputMode	(Sender : TObject);
	procedure	GUI_ClickOutputMode	(Sender : TObject);
	procedure	GUI_ClickPalette	(Sender : TObject);
	procedure	GUI_ClickReload		(Sender : TObject);
	procedure	GUI_ClickSaveInput	(Sender : TObject);
	procedure	GUI_ClickSaveOutput	(Sender : TObject);
	procedure	GUI_CloseForm		(Sender : TObject;  var Action : TCloseAction);
	procedure	GUI_CreateForm		(Sender : TObject);
	procedure	GUI_KeyDownForm		(Sender : TObject;  var Key : Word;  Shift : TShiftState);
	procedure	GUI_MessageApp		(var Msg : tagMSG;  var Handled : Boolean);
	procedure	GUI_MouseDownImage	(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
	procedure	GUI_MouseDownInput	(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
	procedure	GUI_MouseMoveImage	(Sender : TObject;  Shift : TShiftState;  x, y : Integer);
	procedure	GUI_MouseMoveInput	(Sender : TObject;  Shift : TShiftState;  x, y : Integer);
	procedure	GUI_MouseUpImage	(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
	procedure	GUI_MouseWheelForm	(Sender : TObject;  Shift : TShiftState;  WheelDelta : Integer;  MousePos : TPoint;  var Handled : Boolean);
	procedure	GUI_OnTimer		(Sender : TObject);
	procedure	GUI_ShowForm		(Sender : TObject);
	private
	BPP				:	TBPP;
	first_OnShow			:	Boolean;
	InputMode			:	TInputMode;
	Last_Focused			:	String;
	Last_InputScrollPos		:	TPoint;
	Last_InputZoom			:	Integer;
	Last_OutputScrollPos		:	TPoint;
	Last_OutputSize			:	Integer;
	Last_OutputZoom			:	Integer;
	Last_WindowState		:	TWindowState;
	old_Cursor			:	Integer;
	OutputMode			:	TOutputMode;
	Pos_MouseDown			:	TPoint;
	OutPos1				:	TPoint;
	OutPos2				:	TPoint;
	PalPos				:	TPoint;
	PalSize				:	Integer;
	procedure	Change_OutputSelection	(dx, dy, dw, dh : Integer);
	procedure	Change_PaletteSelection	(const dx, dy : Integer);
	procedure	Draw_Selections		;
	function	Get_Magnification	(const Value : Integer) : String;
	procedure	Get_Palette		;
	procedure	Global_KeyDown		(var Msg : tagMSG;  var Handled : Boolean);
	procedure	Init_ScrollMode		(const Image : TImage;  const x, y : Integer);
	procedure	Load_Settings		;
	procedure	Save_Settings		;
	procedure	Set_BPP			(const Btn : TToolButton);
	procedure	Set_InputMode		(const Btn : TToolButton);
	procedure	Set_OutputMode		(const Btn : TToolButton);
	procedure	Set_OutputSize		;
	procedure	Set_Selection		(x, y : Integer;  const Shift : TShiftState);
	procedure	Set_Zoom		(const Image : TImage;  const Level : Integer);
	procedure	Update_Input		;
	procedure	Update_Output		;
	procedure	Update_Palettes		;
	procedure	Update_StatusBar	;
	procedure	Update_Zoom		(const Image : TImage;  x, y : Integer;  const Level : Integer);
	public
	procedure	Update_GUI		;
	end;


var	Form_Main			:	TForm_Main;


procedure Save_Image(const Image : TImage;  const Dialog : TSaveDialog);


implementation  //------------------------------------------------------------------------------
uses	UForm_Input, UForm_Palette, UINI, UShared;


{$R *.dfm}


const	max_ZoomLevel	=	3;


type	TLine		=	packed array[0..1023] of Word;

	TLine04		=	packed array[0..($80000000 - 1) - 1] of Byte;
	TLine08		=	packed array[0..($80000000 - 1) - 1] of Byte;
	TLine15		=	packed array[0..($40000000 - 1) - 1] of Word;
	TLine24		=	packed array[0..($2AAAAAAA - 1) - 1] of TBytes3;


// tools


function Convert(const c : Word) : Word;  inline;
var	B		:	Word;
	G		:	Word;
	R		:	Word;
begin
R := (c       ) AND Bits5;
G := (c SHR  5) AND Bits5;
B := (c SHR 10) AND Bits5;
Result := (R SHL 10) OR (G SHL 5) OR (B);
end;


procedure Init_Image(const Image : TImage;  const PF : TPixelFormat);
begin
with Image do begin
	with Picture.Bitmap do begin
		PixelFormat		:= PF;
		Canvas.Brush.Color	:= clBlack;
	end;
	Picture.Bitmap.Width		:= Width;
	Picture.Bitmap.Height		:= Height;
end;
end;


function Rev_Nybbles(const Value : Byte) : Byte;  inline;
begin
Result := ((Value AND Bits4) SHL 4) OR (Value SHR 4);
end;


procedure Save_Image(const Image : TImage;  const Dialog : TSaveDialog);
var	PNG		:	TPNGImage;
begin
if (not Exec_FileDlg(Dialog)) then exit;
if (LowerCase(ExtractFileExt(Dlg_FullPath)) = '.png') then begin
	PNG := TPNGImage.Create;
	try
		PNG.Assign(Image.Picture.Bitmap);
		PNG.SaveToFile(Dlg_FullPath);
	finally
		PNG.Free;
	end;
end else begin
	Image.Picture.Bitmap.SaveToFile(Dlg_FullPath);
end;
end;


// TForm_Main


procedure TForm_Main.Change_OutputSelection(dx, dy, dw, dh : Integer);
begin
if (OutPos1.x + dx < 0) then dx := -OutPos1.x;
if (OutPos1.y + dy < 0) then dy := -OutPos1.y;
with OutPos1 do begin  Inc(x, dx);  Inc(y, dy);  end;		// move start point
with OutPos2 do begin  Inc(x, dx);  Inc(y, dy);  end;		// move end   point
with OutPos2 do begin  Inc(x, dw);  Inc(y, dh);  end;		// move end   point
with OutPos1 do begin
	if (x > 1023) then x := 1023;
	if (y >  511) then y :=  511;
end;
with OutPos2 do begin
	if (x > 1023) then x := 1023  else  if (x < OutPos1.x) then x := OutPos1.x;
	if (y >  511) then y :=  511  else  if (y < OutPos1.y) then y := OutPos1.y;
end;
end;


procedure TForm_Main.Change_PaletteSelection(const dx, dy : Integer);
var	i		:	Integer;
begin
with PalPos do begin						// move start point
	Inc(x, dx);
	Inc(y, dy);
	if (x < 0) then x := 0 else begin  i := 1024 - PalSize;  if (x > i) then x := i;  end;
	if (y < 0) then y := 0 else begin  i :=  512 -       1;  if (y > i) then y := i;  end;
	if (not pressing_Alt) then x := x AND (Bits10 - Bits4);
end;
end;


procedure TForm_Main.Draw_Selections;
const	Pal_BPPs	=	[BPP_04, BPP_08];
	Blue		=	Bits5 SHL  0;
	Green		=	Bits5 SHL  5;
	Red		=	Bits5 SHL 10;
	Grid		=	Blue;
var	Line		:	^TLine15;
	Line2		:	^TLine15;
	StepX		:	Integer;
	StepY		:	Integer;
	x		:	Integer;
	y		:	Integer;
begin
with Image_Input.Picture.Bitmap do begin
	if (InputMode = imOutput) then begin			// output grid
		if (BPP = BPP_24) then begin
			StepX := 480;
			StepY := 224;				// should be 239 (240?) for PAL
		end else begin
			StepX :=  64;
			StepY := 256;
		end;
		for y := 0 to 511 do begin
			Line := ScanLine[y];
			for x := 0 to ((Width div StepX) - 1) do  Line[x * StepX] := Grid;
		end;
		y := 0;
		repeat
			Line := ScanLine[y];
			for x := 0 to 1023 do  Line[x] := Grid;
			Inc(y, StepY);
		until (y >= Height);
	end;
	if (InputMode = imPalette) then				// palette grid
	if (BPP in Pal_BPPs) then begin
		for y := 0 to 511 do begin
			Line := ScanLine[y];
			for x := 0 to 63 do  Line[x * 16] := Grid;
		end;
	end;
	if (InputMode <> imPalette) then begin			// output selection
		Line  := ScanLine[OutPos1.y];
		Line2 := ScanLine[OutPos2.y];
		for x := OutPos1.x to OutPos2.x do begin
			Line [x] := Red;
			Line2[x] := Red;
		end;
		for y := (OutPos1.y + 1) to (OutPos2.y - 1) do begin
			Line := ScanLine[y];
			Line[OutPos1.x] := Red;
			Line[OutPos2.x] := Red;
		end;
	end;
	if (BPP in Pal_BPPs) then begin				// palette selection
		Line := ScanLine[PalPos.y];
		for x := 0 to (PalSize - 1) do  Line[PalPos.x + x] := Green;
	end;
end;
end;


function TForm_Main.Get_Magnification(const Value : Integer) : String;
var	i, a, b		:	Integer;
begin
a := 1;
b := 1;
if (Value >= 0)	then  for i := +1 to Value do  a := a * 2
		else  for i := Value to -1 do  b := b * 2;
Result := IntToStr(a) + ':' + IntToStr(b);
end;


procedure TForm_Main.Get_Palette;
var	Line		:	pWords;
	x		:	Integer;
begin
MemClear(Palette, SizeOf(Palette));
Line := Image_Input.Picture.Bitmap.ScanLine[PalPos.y];
for x := 0 to (PalSize - 1) do begin
	Palette[x] := Convert(Line[PalPos.x + x]);
end;
end;


procedure TForm_Main.Global_KeyDown(var Msg : tagMSG;  var Handled : Boolean);
var	b		:	Boolean;
	Form		:	TForm;
begin
case Msg.wParam of
	VK_Escape	:	begin
				Form := Screen.ActiveForm;
				b := (Form <> Application.MainForm);
				Form.Close;
				if b then Application.MainForm.SetFocus;
				end;
	VK_F2		:	Btn_SaveOutput.Click;
	VK_F3		:	Click_Btn(Btn_InputSource);
	VK_F5		:	Btn_Reload.Click;
	else			exit;
end;
Handled := True;
end;


procedure TForm_Main.GUI_ActivateApp(Sender : TObject);
begin
Screen.ActiveForm.SetFocus;
end;


procedure TForm_Main.GUI_ClickBPP(Sender : TObject);
var	Btn		:	TToolButton absolute Sender;
begin
Set_BPP(Btn);
Update_GUI;
end;


procedure TForm_Main.GUI_ClickInput(Sender : TObject);
begin
Form_Input.Visible := TToolButton(Sender).Down;
end;


procedure TForm_Main.GUI_ClickInputMode(Sender : TObject);
begin
Set_InputMode(TToolButton(Sender));
Update_GUI;
end;


procedure TForm_Main.GUI_ClickOutputMode(Sender : TObject);
begin
Set_OutputMode(TToolButton(Sender));
end;


procedure TForm_Main.GUI_ClickPalette(Sender : TObject);
begin
Form_Palette.Visible := TToolButton(Sender).Down;
end;


procedure TForm_Main.GUI_ClickReload(Sender : TObject);
begin
with Form_Input do  if (LastLoaded <> '') then Reload;
end;


procedure TForm_Main.GUI_ClickSaveInput(Sender : TObject);
begin
Save_Image(Image_Input, DialogSave_Input);
end;


procedure TForm_Main.GUI_ClickSaveOutput(Sender : TObject);
begin
Save_Image(Image_Output, DialogSave_Output);
end;


procedure TForm_Main.GUI_CloseForm(Sender : TObject;  var Action : TCloseAction);
begin
INI.Clear;
Self		.Save_Settings;
Form_Input	.Save_Settings;
Form_Palette	.Save_Settings;
INI.SaveToFile(AppPath + 'PVV.ini');
end;


procedure TForm_Main.GUI_CreateForm(Sender : TObject);
begin
{	(*$WARN SYMBOL_PLATFORM off*)  ShowMessage(CmdLine);
	(*$WARN SYMBOL_PLATFORM on *)				{}
Caption		:= Application.Title;
first_OnShow	:= True;
OutPos1		:= Point(000, 000);
OutPos2		:= Point(255, 255);
PalPos		:= Point(000, 000);
PalSize		:= 16;
Init_Image(Image_Input , pf15bit);
Init_Image(Image_Output, pf8Bit );
Load_Settings;
end;


procedure TForm_Main.GUI_KeyDownForm(Sender : TObject;  var Key : Word;  Shift : TShiftState);
const	CursorKeys	=	[VK_Up, VK_Down, VK_Left, VK_Right];
	NumpadKeys	=	[VK_Num1..VK_Num9];
var	dx, dw		:	Integer;			// delta xpos, height
	dy, dh		:	Integer;			// delta ypos, width
	i		:	Integer;
begin
if (Key = VK_F4) and (ssAlt in Shift) then begin
	Close;
	Key := 0;
end;
if (Key in NumpadKeys) then begin				// numpad keys
	if (ssShift in Shift) then Key := 0;			// cannot handle them (yet?)
	case Key of
		VK_Num1	:	begin  dx := -16;  dy := +1;  end;
		VK_Num2	:	begin  dx :=   0;  dy := +1;  end;
		VK_Num3	:	begin  dx := +16;  dy := +1;  end;
		VK_Num4	:	begin  dx := -16;  dy :=  0;  end;
		VK_Num5	:	begin  dx :=   0;  dy := +1;  end;
		VK_Num6	:	begin  dx := +16;  dy :=  0;  end;
		VK_Num7	:	begin  dx := -16;  dy := -1;  end;
		VK_Num8	:	begin  dx :=   0;  dy := -1;  end;
		VK_Num9	:	begin  dx := +16;  dy := -1;  end;
		else		begin  dx :=   0;  dy :=  0;  end;
	end;
	if (ssCtrl in Shift) then begin
		dx := Sign(dx) * 64;
		dy := Sign(dy) * 64;
	end;
	Change_PaletteSelection(dx, dy);
	Update_GUI;
	Key := 0;
end;
if (Key in CursorKeys) then begin				// cursor keys
	dx := 0;  dw := 0;
	dy := 0;  dh := 0;
	case Key of
		VK_Up	:	dy := -1;
		VK_Down	:	dy := +1;
		VK_Left	:	dx := -1;
		VK_Right:	dx := +1;
	end;
	if (ssCtrl in Shift) then begin
		dx := Sign(dx) * 64;
		dy := Sign(dy) * 64;
	end;
	if (ssShift in Shift) then begin
		dw := dx;  dx := 0;
		dh := dy;  dy := 0;
	end;
	Change_OutputSelection(dx, dy, dw, dh);
	Update_GUI;
	Key := 0;
end;
if (Key <> 0) then begin
	i := Form_Input.Offset;					// other keys
	case Key of
		VK_Home	:	i := 0;
		VK_End	:	i := MaxInt;
		VK_Add	:	Inc(i,          2);
		VK_Subtract:	Dec(i,          2);
		VK_PgDown:	Inc(i, WindowSize);
		VK_PgUp	:	Dec(i, WindowSize);
	end;
	Form_Input.Edit_Offset.Text := IntToStr(i);
end;
end;


procedure TForm_Main.GUI_MessageApp(var Msg : tagMSG;  var Handled : Boolean);
//	When numlock is deactivated, the numpad keys no longer send virtual keycodes, but send
//	the alternative function instead (e.g. VK_NUMPAD4 becomes VK_LEFT). There's also the
//	"feature" of Windows since version 3.0 (or even earlier) that causes the same behavior
//	when the Shift key is pressed, even when Numlock is activated.
//	Another issue is that when a numpad key key is pressed while the Shift key is held down,
//	Windows _sends a WM_KEYUP message for the Shift key_ even though it's still held down...
//	And when the numpad key's WM_KEYDOWN message has been sent, Windows sends a WM_KEYDOWN
//	message for the Shift key to synchronize the software side with reality again.
//	Fixing that would require something like DirectInput or parsing WM_INPUT messages.
var	Ctrl		:	TWinControl;
begin
case Msg.Message of
	WM_KeyDown,
	WM_KeyUp	:	begin
				if ((Msg.lParam AND Bit24 )  = 0) then  // not an extended key?
				if (GetKeyState(VK_Numlock) >= 0) then  case Msg.wParam of
					VK_End		:	Msg.wParam := VK_Numpad1;
					VK_Down		:	Msg.wParam := VK_Numpad2;
					VK_PgDown	:	Msg.wParam := VK_Numpad3;
					VK_Left		:	Msg.wParam := VK_Numpad4;
					VK_Clear	:	Msg.wParam := VK_Numpad5;
					VK_Right	:	Msg.wParam := VK_Numpad6;
					VK_Home		:	Msg.wParam := VK_Numpad7;
					VK_Up		:	Msg.wParam := VK_Numpad8;
					VK_PgUp		:	Msg.wParam := VK_Numpad9;
					VK_Insert	:	Msg.wParam := VK_Numpad0;
					VK_Delete	:	Msg.wParam := VK_Decimal;
				end;
				if (Msg.Message = WM_KeyDown) then Global_KeyDown(Msg, Handled);
				end;
	WM_MouseWheel	:	begin
				Ctrl := FindVCLWindow(Mouse.CursorPos);
				if (Ctrl = NIL) then exit;
				Msg.hwnd := Ctrl.Handle;
				end;
end;
end;


procedure TForm_Main.GUI_MouseDownImage(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
var	Image		:	TImage absolute Sender;
begin
if (Image.Cursor = crMove) then exit;
if (Button = mbMiddle) then case OutputMode of			// switch to next mode
	omScroll	:	Set_OutputMode(Btn_OutputZoom);
	omZoom		:	Set_OutputMode(Btn_OutputScroll);
end else case OutputMode of
	omScroll	:	case Button of
					mbLeft	:	Init_ScrollMode(Image, x, y);
					mbRight	:	Set_OutputMode(Btn_OutputZoom);
				end;
	omZoom		:	case Button of
					mbLeft	:	Update_Zoom(Image, x, y, +1);
					mbRight	:	Update_Zoom(Image, x, y, -1);
				end;
end;
end;


procedure TForm_Main.GUI_MouseDownInput(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
var	Btn		:	TToolButton;
	ScrollBox	:	TScrollBox absolute Sender;
begin
if (Image_Input.Cursor = crMove) then exit;
if (Sender.ClassType = TScrollBox) then  with ScrollBox do begin
	Inc(x, HorzScrollBar.Position);
	Inc(y, VertScrollBar.Position);
end;
if (InputMode = imPalette) and (Button = mbRight) then Button := mbMiddle;
if (Button = mbMiddle) then begin				// switch to previous/next mode
	case InputMode of
		imOutput :  if (ssShift in Shift) then Btn := Btn_InputZoom   else Btn := Btn_Palette;
		imPalette:  if (ssShift in Shift) then Btn := Btn_Output      else Btn := Btn_InputScroll;
		imScroll :  if (ssShift in Shift) then Btn := Btn_Palette     else Btn := Btn_InputZoom;
		imZoom   :  if (ssShift in Shift) then Btn := Btn_InputScroll else Btn := Btn_Output;
		else        begin  Assert(False);  exit;  end;
	end;
	Set_InputMode(Btn);
	Update_GUI;
end else
case InputMode of
	imOutput,
	imPalette:	begin					// de-zoom coordinates
			with Image_Input do begin
				x := ShiftLeft(x, -Tag);
				y := ShiftLeft(y, -Tag);
			end;
			Set_Selection(x, y, Shift);
			end;
	imScroll:	case Button of
				mbLeft	:	Init_ScrollMode(Image_Input, x, y);
				mbRight	:	begin  Set_InputMode(Btn_InputZoom);  Update_GUI;  end;
			end;
	imZoom	:	case Button of
				mbLeft	:	Update_Zoom(Image_Input, x, y, +1);
				mbRight	:	Update_Zoom(Image_Input, x, y, -1);
			end;
end;
end;


procedure TForm_Main.GUI_MouseMoveImage(Sender : TObject;  Shift : TShiftState;  x, y : Integer);
var	Image		:	TImage absolute Sender;
begin
if (Image.Cursor = crMove) then  with (Image.Parent as TScrollBox) do begin
	with HorzScrollBar do  Position := Position + (Pos_MouseDown.x - x);
	with VertScrollBar do  Position := Position + (Pos_MouseDown.y - y);
end;
end;


procedure TForm_Main.GUI_MouseMoveInput(Sender : TObject;  Shift : TShiftState;  x, y : Integer);
var	ScrollBox	:	TScrollBox absolute Sender;
begin
if (Image_Input.Cursor = crMove) then begin
        GUI_MouseMoveImage(Image_Input, Shift, x, y);
	exit;
end;
if (Sender.ClassType = TScrollBox) then  with ScrollBox do begin
	Inc(x, HorzScrollBar.Position);
	Inc(y, VertScrollBar.Position);
end;
if (InputMode in [imOutput, imPalette]) then begin
	with Image_Input do begin				// de-zoom coordinates
		x := ShiftLeft(x, -Tag);
		y := ShiftLeft(y, -Tag);
	end;
	Set_Selection(x, y, Shift);
end;
end;


procedure TForm_Main.GUI_MouseUpImage(Sender : TObject;  Button : TMouseButton;  Shift : TShiftState;  x, y : Integer);
var	Image		:	TImage absolute Sender;
begin
If (Image.Cursor = crMove) then begin
	Image		.Cursor := old_Cursor;
	Image.Parent	.Cursor := crDefault;
	Screen		.Cursor := crDefault;
	ClipCursor(NIL);
end;
end;


procedure TForm_Main.GUI_MouseWheelForm(Sender : TObject;  Shift : TShiftState;  WheelDelta : Integer;  MousePos : TPoint;  var Handled : Boolean);
var	Ctrl		:	TWinControl;
	CtrlScrollBar	:	TControlScrollBar;
	P		:	TPoint;
begin
GetCursorPos(P);
Ctrl := FindControl(WindowFromPoint(P));
if (Ctrl           =  NIL       ) then exit;
if (Ctrl.ClassType =  TImage    ) then Ctrl := Ctrl.Parent;
if (Ctrl.ClassType <> TScrollBox) then exit;
Handled := True;
if (ssShift in Shift)	then CtrlScrollBar := TScrollBox(Ctrl).HorzScrollBar
			else CtrlScrollBar := TScrollBox(Ctrl).VertScrollBar;
with CtrlScrollBar do	Position := Position - (Sign(WheelDelta) * 64);
end;


procedure TForm_Main.GUI_ShowForm(Sender : TObject);
begin
if first_OnShow then begin
	first_OnShow  := False;
	Timer.Enabled := True;
	Update_Palettes;
end;
end;


procedure TForm_Main.GUI_OnTimer(Sender : TObject);
var	Form		:	TForm;
begin
Timer.Enabled := False;
WindowState   := Last_WindowState;
Set_Zoom(Image_Input , Last_InputZoom );
Set_Zoom(Image_Output, Last_OutputZoom);
with ScrollBox_Output do begin
	Height := Last_OutputSize;
	StatusBar.Top := Top + Height;
end;
Set_OutputSize;
with ScrollBox_Input ,  Last_InputScrollPos do begin  HorzScrollBar.Position := x;  VertScrollBar.Position := y;  end;
with ScrollBox_Output, Last_OutputScrollPos do begin  HorzScrollBar.Position := x;  VertScrollBar.Position := y;  end;
Application.ProcessMessages;
with Form_Palette do  if LastVisible then Show;
with Form_Input   do  if LastVisible then Show;
SetFocus;
Form := TForm(Application.FindComponent(Last_Focused));  if (Form <> NIL) then Form.SetFocus;
Application.ProcessMessages;
if (ParamCount <> 0)	then Form_Input.LoadFromFile(ParamStr(1))
			else Btn_Reload.Click;
end;


procedure TForm_Main.Init_ScrollMode(const Image : TImage;  const x, y : Integer);
var	tmpRect		:	TRect;
	ScrollBox	:	TScrollBox;
begin
   old_Cursor	:= Image.Cursor;
 Image.Cursor	:= crMove;
Screen.Cursor	:= crMove;
Pos_MouseDown	:= Point(x, y);
ScrollBox	:= (Image.Parent as TScrollBox);
with tmpRect do begin
	Right	:= x + ScrollBox.HorzScrollBar.Position;
	Bottom	:= y + ScrollBox.VertScrollBar.Position;
	Left	:= Right  - (Image.Width  - ScrollBox.ClientWidth );
	Top	:= Bottom - (Image.Height - ScrollBox.ClientHeight);
	with Pos_MouseDown do begin
		If (Left > Right ) then begin  Left := x;  Right  := x;  end;
		If (Top  > Bottom) then begin  Top  := y;  Bottom := y;  end;
	end;
	Inc(Right);
	Inc(Bottom);
	TopLeft		:= Image.ClientToScreen(TopLeft);
	BottomRight	:= Image.ClientToScreen(BottomRight);
end;
ClipCursor(@tmpRect);
end;


procedure TForm_Main.Load_Settings;
const	WindowStates	=	[Ord(wsNormal), Ord(wsMinimized), Ord(wsMaximized)];
var	i		:	Integer;
	s		:	String;
begin
BPP			:= BPP_04;
 InputMode		:= imOutput;
OutputMode		:= omScroll;
Last_OutputSize		:= ScrollBox_Output.Height;
Last_WindowState	:= wsMaximized;
with INI do begin
	Section		:= Name;
	Load_Form	(False				);
	Load_FileDialog	(DialogSave_Input		);
	Load_FileDialog	(DialogSave_Output		);
	if Get_Int	('OutputSize'		, i	) then Last_OutputSize		:= i;
	if Get_Str	('Last_Focused'		, s	) then Last_Focused		:= s;
	if Get_Int	('OutPos1.x'		, i	) then OutPos1.x		:= i;
	if Get_Int	('OutPos1.y'		, i	) then OutPos1.y		:= i;
	if Get_Int	('OutPos2.x'		, i	) then OutPos2.x		:= i;
	if Get_Int	('OutPos2.y'		, i	) then OutPos2.y		:= i;
	if Get_Int	( 'PalPos.x'		, i	) then PalPos .x		:= i;
	if Get_Int	( 'PalPos.y'		, i	) then PalPos .y		:= i;
	if Get_Int	('InputZoom'		, i	) then  Last_InputZoom		:= i;
	if Get_Int	('OutputZoom'		, i	) then Last_OutputZoom		:= i;
	if Get_Int	( 'InputScrollPos.x'	, i	) then  Last_InputScrollPos.x	:= i;
	if Get_Int	( 'InputScrollPos.y'	, i	) then  Last_InputScrollPos.y	:= i;
	if Get_Int	('OutputScrollPos.x'	, i	) then Last_OutputScrollPos.x	:= i;
	if Get_Int	('OutputScrollPos.y'	, i	) then Last_OutputScrollPos.y	:= i;
	if Get_Int	('WindowState'		, i	) then  if (i in WindowStates) then Last_WindowState := TWindowState(i);
	if Get_Int	( 'BPP'			, i	) then  if (i in [0..Ord(High( TBPP      ))]) then  BPP       :=  TBPP      (i);
	if Get_Int	( 'InputMode'		, i	) then  if (i in [0..Ord(High( TInputMode))]) then  InputMode :=  TInputMode(i);
	if Get_Int	('OutputMode'		, i	) then  if (i in [0..Ord(High(TOutputMode))]) then OutputMode := TOutputMode(i);
end;
Change_OutputSelection (0, 0, 0, 0);				// clamp to valid values
Change_PaletteSelection(0, 0      );
case BPP of
	BPP_04		:	Set_BPP		(Btn_04bpp		);
	BPP_08		:	Set_BPP		(Btn_08bpp		);
	BPP_15		:	Set_BPP		(Btn_15bpp		);
	BPP_24		:	Set_BPP		(Btn_24bpp		);
end;
case InputMode of
	imOutput	:	Set_InputMode	(Btn_Output		);
	imPalette	:	Set_InputMode	(Btn_Palette		);
	imScroll	:	Set_InputMode	(Btn_InputScroll	);
	imZoom		:	Set_InputMode	(Btn_InputZoom		);
end;
case OutputMode of
	omScroll	:	Set_OutputMode	(Btn_OutputScroll	);
	omZoom		:	Set_OutputMode	(Btn_OutputZoom		);
end;
end;


procedure TForm_Main.Save_Settings;
begin
Last_Focused := Screen.ActiveForm.Name;
with INI do begin
	Section := Name;
	Save_Form;
	Set_Int		('BPP'			, Ord(BPP)				);
	Save_FileDialog	(DialogSave_Input						);
	Save_FileDialog	(DialogSave_Output						);
	Set_Int		('InputMode'		, Ord(InputMode)			);
	Set_Int		('InputScrollPos.x'	, ScrollBox_Input.HorzScrollBar.Position);
	Set_Int		('InputScrollPos.y'	, ScrollBox_Input.VertScrollBar.Position);
	Set_Int		('InputZoom'		, Image_Input.Tag			);
	Set_Str		('Last_Focused'		, Last_Focused				);
	Set_Int		('OutPos1.x'		, OutPos1.x				);
	Set_Int		('OutPos1.y'		, OutPos1.y				);
	Set_Int		('OutPos2.x'		, OutPos2.x				);
	Set_Int		('OutPos2.y'		, OutPos2.y				);
	Set_Int		('OutputMode'		, Ord(OutputMode)			);
	Set_Int		('OutputScrollPos.x'	, ScrollBox_Output.HorzScrollBar.Position);
	Set_Int		('OutputScrollPos.y'	, ScrollBox_Output.VertScrollBar.Position);
	Set_Int		('OutputSize'		, ScrollBox_Output.Height		);
	Set_Int		('OutputZoom'		, Image_Output.Tag			);
	Set_Int		('PalPos.x'		, PalPos .x				);
	Set_Int		('PalPos.y'		, PalPos .y				);
	Set_Int		('WindowState'		, Ord(WindowState)			);
end;
end;


procedure TForm_Main.Set_BPP(const Btn : TToolButton);
begin
with Btn do  if (not Down) then Down := True;
if (Btn = Btn_04bpp) then BPP := BPP_04 else
if (Btn = Btn_08bpp) then BPP := BPP_08 else
if (Btn = Btn_15bpp) then BPP := BPP_15 else
if (Btn = Btn_24bpp) then BPP := BPP_24 else  Assert(False);
case BPP of
	BPP_04	:	PalSize :=  16;
	BPP_08	:	PalSize := 256;
end;
with Image_Output.Picture.Bitmap do  case BPP of
	BPP_04	:	PixelFormat := pf4Bit ;
	BPP_08	:	PixelFormat := pf8Bit ;
	BPP_15	:	PixelFormat := pf15Bit;
	BPP_24	:	PixelFormat := pf24Bit;
end;
end;


procedure TForm_Main.Set_InputMode(const Btn : TToolButton);
begin
with Btn do  if (not Down) then Down := True;
if (Btn = Btn_Output     ) then InputMode := imOutput  else
if (Btn = Btn_Palette    ) then InputMode := imPalette else
if (Btn = Btn_InputScroll) then InputMode := imScroll  else
if (Btn = Btn_InputZoom  ) then InputMode := imZoom    else  Assert(False);
with Image_Input do begin
	case InputMode of
		imOutput	:	Cursor := crCross;
		imPalette	:	Cursor := crCross;
		imScroll	:	Cursor := crHand;
		imZoom		:	Cursor := crZoom;
	end;
	Parent.Cursor := Cursor;
end;
end;


procedure TForm_Main.Set_OutputMode(const Btn : TToolButton);
begin
with Btn do  if (not Down) then Down := True;
if (Btn = Btn_OutputScroll) then OutputMode := omScroll else
if (Btn = Btn_OutputZoom  ) then OutputMode := omZoom   else  Assert(False);
with Image_Output do  case OutputMode of
	omScroll	:	Cursor := crHand;
	omZoom  	:	Cursor := crZoom;
end;
end;


procedure TForm_Main.Set_OutputSize;
var	BMP		:	TBitmap;
	x		:	Integer;
	y		:	Integer;
begin
x := (OutPos2.x - OutPos1.x + 1) * 16;				// VRAM section width in bits
y := (OutPos2.y - OutPos1.y + 1);				// VRAM section height
with Image_Output do begin
	BMP := Picture.Bitmap;
	with BMP do begin
		case BPP of
			BPP_04:	x := x div 04;			// pixels per decoded line
			BPP_08:	x := x div 08;
			BPP_15:	x := x div 16;
			BPP_24:	x := x div 24;
			else	Assert(False);
		end;
		Width	:= x;
		Height	:= y;
	end;
	Width	:= ShiftLeft(x, Tag);
	Height	:= ShiftLeft(y, Tag);
end;
end;


procedure TForm_Main.Set_Selection(x, y : Integer;  const Shift : TShiftState);
var	L, R		:	Boolean;
	Pos1, Pos2	:	^TPoint;
	xDiff, yDiff	:	Integer;
	PalPos2		:	TPoint;
begin
L := (ssLeft  in Shift);
R := (ssRight in Shift);
if (not L) and (not R) then exit;
if (x < 0) then x := 0 else  if (x > 1023) then x := 1023;	// clip to valid values
if (y < 0) then y := 0 else  if (y >  511) then y :=  511;
PalPos2.x := PalPos.x + PalSize - 1;
PalPos2.y := PalPos.y;
if Btn_Output .Down then begin  Pos1 := @OutPos1;  Pos2 := @OutPos2;  end else  // dest. variables
if Btn_Palette.Down then begin  Pos1 := @PalPos ;  Pos2 := @PalPos2;  end else begin  Assert(False);  exit;  end;
if L then begin							// LMB - change starting point
	xDiff := x - Pos1.x;  Inc(Pos1.x, xDiff);  Inc(Pos2.x, xDiff);
	yDiff := y - Pos1.y;  Inc(Pos1.y, yDiff);  Inc(Pos2.y, yDiff);
end else begin							// RMB - move end point
	Pos2.x := x;
	Pos2.y := y;
end;
with Pos2^ do begin						// clip to valid values
	if (x < Pos1.x) then x := Pos1.x else  if (x >   1023) then x := 1023;
	if (y < Pos1.y) then y := Pos1.y else  if (y >    511) then y :=  511;
end;
with Pos1^ do begin						// clip to valid values
	if (x <      0) then x :=      0 else  if (x > Pos2.x) then x := Pos2.x;
	if (y <      0) then y :=      0 else  if (y > Pos2.y) then y := Pos2.y;
end;
Change_PaletteSelection(0, 0);					// clip to valid values
Update_GUI;							// update GUI
end;


procedure TForm_Main.Set_Zoom(const Image : TImage;  const Level : Integer);
begin
with Image do begin
	if (Abs(Tag + Level) > max_ZoomLevel) then exit;
	Tag	:= Tag + Level;
	Width	:= ShiftLeft(Picture.Bitmap.Width , Tag);
	Height	:= ShiftLeft(Picture.Bitmap.Height, Tag);
end;
end;


procedure TForm_Main.Update_GUI;
begin
Update_Input;
Update_Output;
Update_Palettes;
Draw_Selections;
	     Image_Input  .Repaint;  ScrollBox_Input .Repaint;
	     Image_Output .Repaint;  ScrollBox_Output.Repaint;
Form_Palette.Image_Palette.Repaint;
Update_StatusBar;
end;


procedure TForm_Main.Update_Input;
var	BMP		:	TBitmap;
	Bytes		:	^TBytes;
	CopySize	:	Integer;
	i		:	Integer;
	Line		:	^TLine absolute Bytes;
	x		:	Integer;
	y		:	Integer;
begin
BMP := Image_Input.Picture.Bitmap;
InputSource.Position := Form_Input.Offset;
for y := 0 to 511 do begin
	Line := BMP.ScanLine[y];
	with InputSource do  CopySize := Min(LineSize, Size - Position);
	if (CopySize <> 0) then InputSource.Read(Line^, CopySize);
	i := LineSize - CopySize;
	if (i > 0) then FillChar(Bytes[CopySize], i, 0);
	for x := 0 to 1023 do  Line[x] := Convert(Line[x]);
end;
end;


procedure TForm_Main.Update_Output;
var	BMP		:	TBitmap;
	ByteCount	:	Integer;
	Bytes		:	^TBytes;
	CopySize	:	Integer;
	i		:	Integer;
	LastX		:	Integer;
	LastY		:	Integer;
	Line04		:	^TLine04 absolute Bytes ;
	Line08		:	^TLine08 absolute Line04;
	Line15		:	^TLine15 absolute Line04;
	Line24		:	^TLine24 absolute Line04;
	x		:	Integer;
	y		:	Integer;
begin
Set_OutputSize;
BMP       := Image_Output.Picture.Bitmap;
ByteCount := (OutPos2.x - OutPos1.x + 1) * 2;			// bytes per encoded line
LastY     := (OutPos2.y - OutPos1.y + 1) - 1;
LastX     := BMP.Width;  if (BPP = BPP_04) then LastX := LastX div 2;  Dec(LastX);
for y := 0 to LastY do begin
	Bytes := BMP.ScanLine[y];
	i := Form_Input.Offset + ((OutPos1.y + y) * LineSize) + (OutPos1.x * 2);
	InputSource.Position := Min(i, InputSource.Size);
	with InputSource do  CopySize := Min(ByteCount, Size - Position);
	if (CopySize <> 0) then InputSource.Read(Bytes[0], CopySize);
	i := ByteCount - CopySize;
	if (i > 0) then FillChar(Bytes[CopySize], i, 0);
end;
case BPP of							// convert to PC bitmap data
	BPP_04:  for y := 0 to LastY do begin  Line04 := BMP.ScanLine[y];  for x := 0 to LastX do  Line04[x] := Rev_Nybbles (Line04[x]);  end;
	BPP_15:  for y := 0 to LastY do begin  Line15 := BMP.ScanLine[y];  for x := 0 to LastX do  Line15[x] := RevColors_15(Line15[x]);  end;
	BPP_24:  for y := 0 to LastY do begin  Line24 := BMP.ScanLine[y];  for x := 0 to LastX do  Line24[x] :=  RevBytes_24(Line24[x]);  end;
end;
end;


procedure TForm_Main.Update_Palettes;
var	c		:	Word;
	i		:	Integer;
	tmpPal		:	TPalette;
begin
Get_Palette;
for i := $00 to $FF do begin
	c := Convert(Palette[i]);
	with tmpPal[i] do begin
		rgbBlue  := ((c       ) AND Bits5) SHL 3;
		rgbGreen := ((c SHR  5) AND Bits5) SHL 3;
		rgbRed   := ((c SHR 10) AND Bits5) SHL 3;
	end;
end;
if (BPP in [BPP_04, BPP_08]) then
SetDIBColorTable(             Image_Output .Picture.Bitmap.Canvas.Handle, 0, 256, tmpPal[0]);
SetDIBColorTable(Form_Palette.Image_Palette.Picture.Bitmap.Canvas.Handle, 0, 256, tmpPal[0]);
end;


procedure TForm_Main.Update_StatusBar;
var	Size		:	TPoint;
begin
with Size do begin
	x := OutPos2.x - OutPos1.x + 1;
	y := OutPos2.y - OutPos1.y + 1;
end;
with StatusBar do begin
	Panels[0].Text := Get_Magnification(Image_Input .Tag);
	Panels[1].Text := Get_Magnification(Image_Output.Tag);
	Panels[2].Text := ' file offset: '    + IntToStr(Form_Input.Offset);
	Panels[3].Text := ' output: '         + IntToStr(OutPos1.x) + ', ' + IntToStr(OutPos1.y) + ', ' + IntToStr(Size.x ) + 'x' + IntToStr(Size.y);
	Panels[4].Text := ' output palette: ' + IntToStr(PalPos .x) + ', ' + IntToStr(PalPos .y) + ', ' + IntToStr(PalSize) + 'x' + IntToStr(     1);
end;
end;


procedure TForm_Main.Update_Zoom(const Image : TImage;  x, y : Integer;  const Level : Integer);
var	ScrollBox	:	TScrollBox;
begin
with Image do begin
	if (Abs(Tag + Level) > max_ZoomLevel) then exit;
	ScrollBox := (Parent as TScrollBox);
	x := ShiftLeft(x, Level);				// get point in new image
	y := ShiftLeft(y, Level);
	Set_Zoom(Image, Level);					// update image
	with ScrollBox do begin					// update scrollbars
		HorzScrollBar.Position := x - (ClientWidth  div 2);
		VertScrollBar.Position := y - (ClientHeight div 2);
	end;
end;
Update_StatusBar;
end;


//----------------------------------------------------------------------------------------------


end.
