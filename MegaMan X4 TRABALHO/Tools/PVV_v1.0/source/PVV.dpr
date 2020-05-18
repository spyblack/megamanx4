program	PVV;
uses	Forms,
	UForm_Main	in 'UForm_Main.pas'	{Form_Main}	,
	UForm_Input	in 'UForm_Input.pas'	{Form_Input}	,
	UForm_Palette	in 'UForm_Palette.pas'	{Form_Palette}	,
	ePSXe		in 'ePSXe.pas'				,
	pSX		in 'pSX.pas'				,
	PCSX15		in 'PCSX15.pas'				,
	PCSX19		in 'PCSX19.pas'				,
	UINI		in 'UINI.pas'				,
	UShared		in 'UShared.pas'			,
	UStreamTools	in 'UStreamTools.pas'			,
	UStringLists	in 'UStringLists.pas'			,
	UZST		in 'UZST.pas'				;


{$R *.res}


begin
Application.Initialize;
Application.Title := 'PVV v1.0';
Application.CreateForm(TForm_Main	, Form_Main	);
Application.CreateForm(TForm_Input	, Form_Input	);
Application.CreateForm(TForm_Palette	, Form_Palette	);
Application.Run;
end.

