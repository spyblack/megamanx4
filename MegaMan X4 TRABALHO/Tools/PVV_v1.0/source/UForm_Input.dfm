object Form_Input: TForm_Input
  Left = 160
  Top = 192
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'input source'
  ClientHeight = 360
  ClientWidth = 808
  Color = clBtnFace
  Constraints.MinHeight = 384
  Constraints.MinWidth = 640
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
  OnDestroy = GUI_DestroyForm
  OnHide = GUI_HideForm
  OnKeyDown = GUI_KeyDownForm
  OnShow = GUI_ShowForm
  PixelsPerInch = 96
  TextHeight = 13
  object PC: TPageControl
    Left = 0
    Top = 0
    Width = 808
    Height = 360
    ActivePage = TS_Files
    Align = alClient
    HotTrack = True
    Style = tsFlatButtons
    TabOrder = 0
    OnChange = GUI_ChangePC
    OnChanging = GUI_ChangingPC
    object TS_Files: TTabSheet
      Caption = '&1: files'
      object Panel_FilesPath: TPanel
        Left = 0
        Top = 0
        Width = 800
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          800
          25)
        object Btn_BrowsePath: TSpeedButton
          Left = 776
          Top = 0
          Width = 24
          Height = 21
          Hint = 'browse'
          Anchors = [akTop, akRight]
          Caption = '...'
          Flat = True
          ParentShowHint = False
          ShowHint = True
          OnClick = GUI_ClickBrowse
          ExplicitLeft = 600
        end
        object Panel_Path: TPanel
          Left = 0
          Top = 0
          Width = 776
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          BorderStyle = bsSingle
          Color = clWindow
          ParentBackground = False
          TabOrder = 0
          DesignSize = (
            772
            17)
          object Edit_Path: TEdit
            Left = 1
            Top = 1
            Width = 663
            Height = 16
            Anchors = [akLeft, akTop, akRight]
            BorderStyle = bsNone
            TabOrder = 0
            Text = 'C:\'
            OnChange = GUI_ChangedPath
            OnKeyDown = GUI_KeyDownPath
          end
        end
      end
      object Panel_FilesBottom: TPanel
        Left = 0
        Top = 25
        Width = 800
        Height = 304
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Splitter: TSplitter
          Left = 580
          Top = 0
          Width = 4
          Height = 304
          Align = alRight
          AutoSnap = False
          MinSize = 192
          ResizeStyle = rsUpdate
          ExplicitLeft = 300
          ExplicitHeight = 404
        end
        object LV_Files: TListView
          Left = 0
          Top = 0
          Width = 580
          Height = 304
          Align = alClient
          Columns = <
            item
              Caption = 'file'
              Width = 96
            end
            item
              Caption = 'name'
              Width = 160
            end
            item
              Caption = 'disk'
              Width = 48
            end
            item
              Alignment = taRightJustify
              Caption = 'region'
              Width = 64
            end
            item
              Alignment = taRightJustify
              Caption = 'CD'
              Width = 48
            end
            item
              Alignment = taRightJustify
              Caption = 'size'
              Width = 40
            end
            item
              Caption = 'notes'
              Width = 104
            end>
          ColumnClick = False
          Enabled = False
          GridLines = True
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          ParentColor = True
          SmallImages = ImageList_Files
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = GUI_DblClickFiles
          OnKeyDown = GUI_KeyDownFiles
          OnSelectItem = GUI_SelectFile
        end
        object LV_Slots: TListView
          Left = 584
          Top = 0
          Width = 216
          Height = 304
          Align = alRight
          Columns = <
            item
              Caption = 'slot'
              Width = 192
            end>
          ColumnClick = False
          Enabled = False
          GridLines = True
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          ParentColor = True
          SmallImages = ImageList_Slots
          SortType = stText
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = GUI_DblClickSlots
          ExplicitLeft = 592
        end
      end
    end
    object TS_Current: TTabSheet
      Caption = '&2: current input'
      ImageIndex = 1
      object Panel_CurrentBottom: TPanel
        Left = 0
        Top = 233
        Width = 800
        Height = 96
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object GBox_Offset: TGroupBox
          Left = 472
          Top = 0
          Width = 328
          Height = 96
          Align = alRight
          Caption = '&offset'
          TabOrder = 1
          object RBtn_Line: TRadioButton
            Left = 272
            Top = 24
            Width = 40
            Height = 24
            Caption = '&line'
            TabOrder = 2
          end
          object RBtn_Window: TRadioButton
            Left = 208
            Top = 24
            Width = 64
            Height = 24
            Caption = '&window'
            Checked = True
            TabOrder = 1
            TabStop = True
          end
          object Edit_Offset: TEdit
            Left = 16
            Top = 24
            Width = 184
            Height = 21
            Alignment = taRightJustify
            TabOrder = 0
            Text = '0'
            OnChange = GUI_ChangeOffset
            OnKeyPress = GUI_KeyPressOffset
          end
          object Panel_Jump: TPanel
            Left = 16
            Top = 56
            Width = 296
            Height = 24
            BevelOuter = bvNone
            BorderStyle = bsSingle
            TabOrder = 3
            object Btn_Forward: TButton
              Left = 146
              Top = 0
              Width = 146
              Height = 20
              Caption = 'jump &forward'
              Enabled = False
              TabOrder = 1
              OnClick = GUI_ClickJump
            end
            object Btn_Backward: TButton
              Left = 0
              Top = 0
              Width = 146
              Height = 20
              Caption = 'jump &backward'
              Enabled = False
              TabOrder = 0
              OnClick = GUI_ClickJump
            end
          end
        end
        object GBox_Source: TGroupBox
          Left = 0
          Top = 0
          Width = 472
          Height = 96
          Align = alClient
          Caption = '&source'
          TabOrder = 0
          DesignSize = (
            472
            96)
          object Edit_Type: TEdit
            Left = 20
            Top = 24
            Width = 436
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Enabled = False
            ParentColor = True
            ReadOnly = True
            TabOrder = 0
          end
          object Edit_Source: TEdit
            Left = 20
            Top = 56
            Width = 436
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Enabled = False
            ParentColor = True
            ReadOnly = True
            TabOrder = 1
          end
        end
      end
      object Panel_CurrentTop: TPanel
        Left = 0
        Top = 0
        Width = 800
        Height = 233
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object GBox_Blocks: TGroupBox
          Left = 472
          Top = 0
          Width = 328
          Height = 233
          Align = alRight
          Caption = 's&avestate block data'
          TabOrder = 1
          DesignSize = (
            328
            233)
          object LV_Blocks: TListView
            Left = 16
            Top = 24
            Width = 296
            Height = 192
            Anchors = [akLeft, akTop, akRight, akBottom]
            Columns = <
              item
                Caption = 'name'
                Width = 128
              end
              item
                Alignment = taRightJustify
                Caption = 'offset'
                Width = 74
              end
              item
                Alignment = taRightJustify
                Caption = 'size'
                Width = 74
              end>
            ColumnClick = False
            Enabled = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            GridLines = True
            ReadOnly = True
            RowSelect = True
            ParentColor = True
            ParentFont = False
            TabOrder = 0
            ViewStyle = vsReport
            OnSelectItem = GUI_SelectBlock
          end
        end
        object GBox_Preview: TGroupBox
          Left = 0
          Top = 0
          Width = 472
          Height = 233
          Align = alClient
          Caption = 'preview'
          TabOrder = 0
          DesignSize = (
            472
            233)
          object Panel_Preview: TPanel
            Left = 17
            Top = 24
            Width = 436
            Height = 196
            Anchors = [akLeft, akTop, akRight, akBottom]
            BevelOuter = bvNone
            BorderStyle = bsSingle
            TabOrder = 0
            object Image_Preview: TImage
              Left = 0
              Top = 0
              Width = 432
              Height = 192
              Cursor = crHandPoint
              Hint = 'click to save'
              Align = alClient
              ParentShowHint = False
              ShowHint = True
              Stretch = True
              OnClick = GUI_ClickPreview
              ExplicitWidth = 256
            end
          end
        end
      end
    end
  end
  object DialogSave: TSaveDialog
    Filter = 'PNG files|*.png|BMP files|*.bmp|all files|*.*'
    InitialDir = 'C:\'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 720
    Top = 192
  end
  object DialogOpen: TOpenDialog
    Filter = 
      'all supported files|*.000;*.001;*.002;*.003;*.004;*.bin|ePSXe sa' +
      'vestates (*.000;*.001;*.002;*.003;*.004)|*.000;*.001;*.002;*.003' +
      ';*.004|binary files (*.bin)|*.bin|all files|*.*'
    InitialDir = 'C:\'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 640
    Top = 192
  end
  object ImageList_Slots: TImageList
    Height = 96
    Width = 128
    Left = 720
    Top = 136
  end
  object ImageList_Files: TImageList
    Left = 640
    Top = 136
    Bitmap = {
      494C010104000600040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006666
      6600666666006666660066666600666666006666660066666600666666006666
      6600666666006666660066666600666666000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006666660066666600666666006666
      6600666666006666660066666600666666006666660066666600666666006666
      660066666600666666006666660066666600000000000000000066CCCC0066CC
      CC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC0066CCCC00666666000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC006699990066666600000000000000000066CCCC00F1F1
      F10083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70066CCCC006666660066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000ABABA500938E8500938E
      850074635600000000000000000000000000000000000000000000000000ABAB
      A500938E8500938E8500746356000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF70066999900666666000000000066CCCC00F1F1F10083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70066CCCC006666660066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000074635600746356007463
      560074635600AFA49D00AFA49D00AFA49D00AFA49D00AFA49D00AFA49D007463
      56007463560074635600746356000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF70066999900666666000000000066CCCC00F1F1F10083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70066CCCC00666666006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D100DED7
      D100CAC6BC0081756B0081756B0081756B0081756B0081756B0081756B00DBDA
      D600ABA59D00ABA59D00938E85000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF700669999006666660066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70066CCCC00666666006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D100DED7
      D10081756B00F9F7F400C6C0B8009DB77900B7924F00CFBBA500C6C0B8008175
      6B00DBDAD600ABA59D00938E85000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF700669999006666660066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70066CC
      CC0066666600669999006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D1008475
      6700F9F7F400C6C0B800C6C0B8008ECDC4007975F400A9A1ED00C6C0B800C6C0
      B80081756B00DBDAD600938E85000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF700669999006666660066CCCC00F1F1F100F1F1F100F1F1
      F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F10066CC
      CC0066666600669999006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D1008475
      6700F9F7F400C6C0B800C6C0B800C6C0B800C6C0B800C6C0B800C6C0B800C6C0
      B80081756B00DBDAD600938E85000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF70066999900666666000000000066CCCC0099CCCC0099CC
      CC0099CCCC0099CCCC0099CCCC0099CCCC0099CCCC0099CCCC0099CCCC0099CC
      CC006699990071E1EA006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D1008475
      6700F9F7F400C6C0B800C6C0B800C6C0B800C6C0B800C6C0B800C6C0B800C6C0
      B80081756B00DBDAD600938E85000000000066CCCC00F1F1F10083EFF70083EF
      F70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EFF70083EF
      F70083EFF70083EFF70066999900666666000000000066CCCC0071E1EA0071E1
      EA0071E1EA0071E1EA0071E1EA0071E1EA0071E1EA0071E1EA0071E1EA0071E1
      EA0071E1EA0071E1EA006699990066666600000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFDFD00DED7D100DED7
      D10081756B00F9F7F400C6C0B800CAC6BC00CAC6BC00CAC6BC00C6C0B8008175
      6B00DBDAD600ABA59D00938E85000000000066CCCC00F1F1F100F1F1F100F1F1
      F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1F100F1F1
      F100F1F1F100F1F1F10066999900666666000000000066CCCC0071E1EA0071E1
      EA0071E1EA0071E1EA0071E1EA0071E1EA0066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC006699990000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFDFD00DED7D100DED7
      D100DED7D10081756B00F9F7F400F9F7F400F9F7F400F9F7F40081756B00DBDA
      D600ABA59D00ABA59D00938E85000000000066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CCCC0066CC
      CC0066CCCC0066CCCC006699990000000000000000000000000066CCCC0071E1
      EA0071E1EA0071E1EA0071E1EA0066CCCC006699990000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFDFD00FFFDFD00FFFD
      FD00FFFDFD00000000000000000000000000000000000000000000000000DBDA
      D600DBDAD600DBDAD600DBDAD600000000000000000066CCCC0071E1EA0071E1
      EA0071E1EA0071E1EA0066CCCC00669999000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000066CC
      CC0066CCCC0066CCCC0066CCCC00669999000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000066CCCC0066CC
      CC0066CCCC0066CCCC0066999900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFE000FFFFFFFF
      0000C000C00787E10000C000C007000000008000C007000000008000C0070000
      00000000C007000000000000C007000000000000C007000000008000C0070000
      00008000C007000000008001C00700000001C07FC00F000080FFE0FFC01F87E1
      C1FFFFFFC03FFFFFFFFFFFFFFFFFFFFF}
  end
end
