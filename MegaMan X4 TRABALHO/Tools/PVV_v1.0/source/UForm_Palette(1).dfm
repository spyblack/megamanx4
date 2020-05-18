object Form_Palette: TForm_Palette
  Left = 320
  Top = 240
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  ClientHeight = 128
  ClientWidth = 128
  Color = clBtnFace
  Constraints.MinHeight = 150
  Constraints.MinWidth = 134
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = GUI_CreateForm
  OnHide = GUI_HideForm
  OnKeyDown = GUI_KeyDownForm
  OnShow = GUI_ShowForm
  PixelsPerInch = 96
  TextHeight = 13
  object Panel_Palette: TPanel
    Left = 0
    Top = 0
    Width = 128
    Height = 128
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 0
    object Image_Palette: TImage
      Left = 0
      Top = 0
      Width = 124
      Height = 124
      Cursor = crHandPoint
      Hint = 'click to save'
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      OnClick = GUI_ClickImage
      ExplicitWidth = 80
      ExplicitHeight = 80
    end
  end
  object DialogSave: TSaveDialog
    Filter = 
      'JASC palette (*.pal)|*.pal|RAW (5-bit values, 512 bytes)|*.*|RAW' +
      ' (8-bit values, 768 bytes)|*.*|RAW (8-bit values, 1024 bytes)|*.' +
      '*|ZSNES savestate (*.zst;*.zs0 .. *.zs9)|*.zst;*.zs1;*.zs2;*.zs3' +
      ';*.zs4;*.zs5;*.zs6;*.zs7;*.zs8;*.zs9|all files|*.*'
    InitialDir = 'C:\'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 24
    Top = 16
  end
end
