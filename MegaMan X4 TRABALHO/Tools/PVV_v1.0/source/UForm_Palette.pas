unit	UForm_Palette;


interface  //-----------------------------------------------------------------------------------
uses	Windows, Classes, Controls, Dialogs, ExtCtrls, Forms, Graphics, SysUtils,
	UShared;


type	TForm_Palette			=	class(TForm)
	DialogSave			:	TSaveDialog;
	Image_Palette			:	TImage;
	Panel_Palette			:	TPanel;
	procedure	GUI_ClickImage		(Sender : TObject);
	procedure	GUI_CreateForm		(Sender : TObject);
	procedure	GUI_HideForm		(Sender : TObject);
	procedure	GUI_KeyDownForm		(Sender : TObject;  var Key : Word;  Shift : TShiftState);
	procedure	GUI_ShowForm		(Sender : TObject);
	public
	LastVisible			:	Boolean;
	procedure	Load_Settings		;
	procedure	Save_Palette		;
	procedure	Save_Settings		;
	end;


var	Form_Palette			:	TForm_Palette;
	Palette				:	TWords256;


implementation  //------------------------------------------------------------------------------
uses	UForm_Main, UINI, UZST;


{$R *.dfm}


// tools


function Get_Str3(Value : Integer) : String;			// at least 3 characters
begin
Result := IntToStr(Value);
Result := StringOfChar('0', 3 - Length(Result)) + Result;
end;


//  TForm_Palette


procedure TForm_Palette.GUI_ClickImage(Sender : TObject);
begin
Save_Palette;
end;


procedure TForm_Palette.GUI_CreateForm(Sender : TObject);
var	i		:	Integer;
	x		:	Integer;
	y		:	Integer;
begin
with Image_Palette.Picture.Bitmap do begin
	PixelFormat	:= pf8Bit;
	Width		:= 16;
	Height		:= 16;
	i := 0;
	for y := 0 to 15 do
	for x := 0 to 15 do begin
		pBytes(ScanLine[y])[x] := i;
		Inc(i);
	end;
end;
Load_Settings;
end;


procedure TForm_Palette.GUI_HideForm(Sender: TObject);
begin
with Form_Main.Btn_ShowPalette do begin
	if Down then Down := False;
end;
end;


procedure TForm_Palette.GUI_KeyDownForm(Sender : TObject;  var Key : Word;  Shift : TShiftState);
begin
if (Key = VK_F4) and (ssAlt in Shift) then Form_Main.Close;
end;


procedure TForm_Palette.GUI_ShowForm(Sender: TObject);
begin
with Form_Main.Btn_ShowPalette do begin
	if (not Down) then Down := True;
end;
end;


procedure TForm_Palette.Load_Settings;
begin
with INI do begin
	Section := Name;
	Load_Form	(False			);
	Get_Bool	('Visible', LastVisible	);
	Load_FileDialog	(DialogSave		);
end;
end;


procedure TForm_Palette.Save_Palette;
var	c		:	Word;
	i		:	Integer;
	List		:	TStringList;
	Palette_768	:	packed array[Byte, 0..2] of Byte;
	Palette_1024	:	packed array[Byte, 0..3] of Byte;
	ZST		:	TZST_Data;
	tmpStream	:	TMemoryStream;
begin
if (not Exec_FileDlg(DialogSave)) then exit;
tmpStream := TMemoryStream.Create;
case DialogSave.FilterIndex of
	1:	begin						// JASC palette
		List := TStringList.Create;
		try
			with List do begin
				Add('JASC-PAL'	);
				Add('0100'	);
				Add('256'	);
				for i := 0 to $FF do begin
					c := Palette[i];
					Add(	Get_Str3(((c SHR 00) AND $1F) SHL 3) + ' ' +
						Get_Str3(((c SHR 05) AND $1F) SHL 3) + ' ' +
						Get_Str3(((c SHR 10) AND $1F) SHL 3));
				end;
				SaveToFile(Dlg_FullPath);
			end;
		finally
			List.Free;
		end;
		end;
	2:	tmpStream.Write(Palette, 512);			// 5-bit values, 512 bytes
	3:	begin						// 8-bit values, 768 bytes
		for i := $00 to $FF do begin
			Palette_768[i, 0] := ((Palette[i]       ) AND Bits5) SHL 3;
			Palette_768[i, 1] := ((Palette[i] SHR 5 ) AND Bits5) SHL 3;
			Palette_768[i, 2] := ((Palette[i] SHR 10) AND Bits5) SHL 3;
		end;
		tmpStream.Write(Palette_768, 768);
		end;
	4:	begin						// 8-bit values, 1024 bytes
		MemClear(Palette_1024, 1024);
		for i := $00 to $FF do begin
			Palette_1024[i, 0] := ((Palette[i]       ) AND Bits5) SHL 3;
			Palette_1024[i, 1] := ((Palette[i] SHR 5 ) AND Bits5) SHL 3;
			Palette_1024[i, 2] := ((Palette[i] SHR 10) AND Bits5) SHL 3;
			Palette_1024[i, 3] := 0;
		end;
		tmpStream.Write(Palette_1024, 1024);
		end;
	5:	begin						// ZST savestate
		MemClear(ZST, SizeOf(ZST));
		ZST.zsmesg.Start	:= ZST_SigStart	;
		ZST.zsmesg.Version	:= ZST_SigVer	;
		ZST.zsmesg.EndChar	:= ZST_SigEnd	;
		MemCopy(Palette, ZST.cgram, SizeOf(Palette));
		tmpStream.Write(ZST, SizeOf(ZST));
		end;
	else	Assert(False);
end;
if (tmpStream.Size <> 0) then tmpStream.SaveToFile(Dlg_FullPath);
tmpStream.Free;
end;


procedure TForm_Palette.Save_Settings;
begin
with INI do begin
	Section := Name;
	Save_Form;
	Set_Bool	('Focused', Focused	);
	Set_Bool	('Visible', Visible	);
	Save_FileDialog	(DialogSave		);
end;
end;


//----------------------------------------------------------------------------------------------


end.

