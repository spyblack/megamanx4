unit	UZST;


//	ZSNES savestate structure


interface  //-----------------------------------------------------------------------------------
uses	UShared;


Const	ZST_SigStart	=	'ZSNES Save State File V';
	ZST_SigVer	=	'0.6';
	ZST_SigEnd	=	#26;


type	DWord		=	Cardinal;


	TZST_Signature	=	packed record			// 27 bytes
				Start	:  packed array[0..Length(ZST_SigStart) - 1] of Char;
				Version	:  packed array[0..Length(ZST_SigVer  ) - 1] of Char;
				EndChar	:  packed array[0..Length(ZST_SigEnd  ) - 1] of Char;
				end;


	TZST_BRRs	=	packed record			// 8 bytes
				Place			:	DWord;
				Temp			:	DWord;
				end;


	TZST_BRR	=	packed array[0..7] of TZST_BRRs;


	TZST_dmadata	=	packed array[0..     128] of Byte;
	TZST_hdmadata	=	packed array[0..7, 0..18] of Byte;
	TZST_oamram_unused =	packed array[0..     479] of Byte;
	TZST_tempdat	=	packed array[0..     476] of Byte;
	TZST_spcRam	=	packed array[0..   65471] of Byte;
	TZST_FutureExpandS =	packed array[0..     191] of Byte;
	TZST_FutureExpand  =	packed array[0..     243] of Byte;


	TZST_PreviewLine=	packed array[0..63] of Word;
	TZST_Preview	=	packed array[0..55] of TZST_PreviewLine;  	// 7 KB


	TZST_Data	=	packed record
				zsmesg			:	TZST_Signature;
				versn			:	Byte;
				curcyc			:	Byte;
				curypos			:	Word;
				cacheud			:	Byte;
				ccud			:	Byte;
				intrset			:	Byte;
				cycpl			:	Byte;
				cycphb			:	Byte;
				spcon			:	Byte;
				stackand		:	Word;
				stackor			:	Word;
				xat			:	Word;
				xdbt			:	Byte;
				xpbt			:	Byte;
				xst			:	Word;
				xdt			:	Word;
				xxt			:	Word;
				xyt			:	Word;
				xp			:	Byte;
				xe			:	Byte;
				xpc			:	Word;
				xirqb			:	Byte;
				debugger		:	Byte;
				Curtableaddr		:	DWord;
				curnmi			:	Byte;
				cycpbl			:	DWord;
				cycpblt			:	DWord;
				sndrot			:	Byte;
				sndrot2			:	Byte;
				INTEnab			:	Byte;
				NMIEnab			:	Byte;
				VIRQLoc			:	Word;
				vidbright		:	Byte;
				previdbr		:	Byte;
				forceblnk		:	Byte;
				objptr			:	TDWords2;  	// 8
				objsize			:	TBytes2;
				objmovs1		:	Byte;
				objadds1		:	Word;
				objmovs2		:	Byte;
				objadds2		:	Word;
				oamaddrt		:	Word;
				oamaddrs		:	Word;
				objhipr			:	Byte;
				bgmode			:	Byte;
				bg3highst		:	Byte;
				bgtilesz		:	Byte;
				mosaicon		:	Byte;
				mosaicsz		:	Byte;
				bgptr			:	TWords4;
				bgptrb			:	TWords4;
				bgptrc			:	TWords4;
				bgptrd			:	TWords4;
				bgscsize		:	TBytes4;
				bgobjptr		:	TWords4;
				bgscrolx		:	TWords4;
				bg1sx			:	Word;
				bgscroly		:	TWords4;
				addrincr		:	Word;
				vramincr		:	Byte;
				vramread		:	Byte;
				vramaddr		:	DWord;
				cgaddr			:	Word;
				cgmod			:	Byte;
				scrnon			:	Word;
				scrndist		:	Byte;
				resolutn		:	Word;
				multa			:	Byte;
				diva			:	Word;
				divres			:	Word;
				multres			:	Word;
				latchx			:	Word;
				latchy			:	Word;
				latchxr			:	Byte;
				latchyr			:	Byte;
				frskipper		:	Byte;
				winl1			:	Byte;
				winr1			:	Byte;
				winl2			:	Byte;
				winr2			:	Byte;
				winbgen			:	TBytes4;
				winobjen		:	Byte;
				wincolen		:	Byte;
				winlogica		:	Byte;
				winlogicb		:	Byte;
				winenabm		:	Byte;
				winenabs		:	Byte;
				mode7set		:	Byte;
				mode7A			:	Word;
				mode7B			:	Word;
				mode7C			:	Word;
				mode7D			:	Word;
				mode7X0			:	Word;
				mode7Y0			:	Word;
				JoyAPos			:	Byte;
				JoyBPos			:	Byte;
				compmult		:	DWord;
				joyalt			:	Byte;
				wramrwadr		:	DWord;
				dmadata			:	TZST_dmadata;		// 129
				irqon			:	Byte;
				nexthdma		:	Byte;
				curhdma			:	Byte;
				hdmadata		:	TZST_hdmadata;		// 152
				hdmatype		:	Byte;
				coladdr			:	Byte;
				coladdg			:	Byte;
				coladdb			:	Byte;
				colnull			:	Byte;
				scaddset		:	Byte;
				scaddtype		:	Byte;
				VoiceDisabl2		:	TBytes8;
				oamram			:	{TOAM_Data} TBytes544;	// 544
				oamram_unused		:	TZST_oamram_unused;	// 480
				cgram			:	{TCGRAM_Data} TBytes512;// 512
				pcgram			:	TWords256;		// 512
				vraminctype		:	Byte;
				vramincby8on		:	Byte;
				vramincby8left		:	Byte;
				vramincby8totl		:	Byte;
				vramincby8rowl		:	Byte;
				vramincby8ptri		:	Word;
				nexthprior		:	Byte;
				doirqnext		:	Byte;
				vramincby8var		:	Word;
				screstype		:	Byte;
				extlatch		:	Byte;
				cfield			:	Byte;
				interlval		:	Byte;
				HIRQLoc			:	Word;
				KeyOnStA		:	Byte;
				KeyOnStB		:	Byte;
				SDD1BankA		:	Byte;
				SDD1BankB		:	Byte;
				SDD1BankC		:	Byte;
				SDD1BankD		:	Byte;
				vramread2		:	Byte;
				nosprincr		:	Byte;
				poamaddrs		:	Word;
				ioportval		:	Byte;
				iohvlatch		:	Boolean;
				ppustatus		:	Byte;
				tempdat			:	TZST_tempdat;		// 477
				wram			:	{TWRAM_Data} TBytes128K;// 131072
				vram			:	{TVRAM_Data} TBytes64K;	//  65536
				////////////////////////////////////////////////////////////////
				spcRam			:	TZST_spcRam;		// 65472
				spcRom			:	{TAPU_ROM} tBytes64;	// 64
				spcUnknown		:	TBytes16;		// 16
				spcPCRam		:	DWord;
				spcA			:	DWord;
				spcX			:	DWord;
				spcY			:	DWord;
				spcP			:	DWord;
				spcNZ 			:	DWord;
				spcS			:	DWord;
				spcRamDP		:	DWord;
				spcCycle		:	DWord;
				regread			:	TBytes4;
				timeron 		:	Byte;
				timincr			:	TBytes3;
				timinl	 		:	TBytes3;
				timrcall		:	Byte;
				spcextraram		:	{} TBytes64;
				FutureExpandS		:	TZST_FutureExpandS;	// 192
				BRRBuffer		:	TBytes32;
				BRR			:	TZST_BRR;		// 64
				VoiceFreq		:	packed array[0..7] of DWord;
				VoicePitch		:	packed array[0..7] of Word;
				VoiceStatus		:	packed array[0..7] of Byte;
				VoicePtr 		:	packed array[0..7] of DWord;
				VoiceLoopPtr 		:	packed array[0..7] of DWord;
				VoiceBufPtr 		:	packed array[0..7] of DWord;
				SoundCounter		:	packed array[0..1] of DWord;
				VoicePrev0 		:	packed array[0..7] of DWord;
				VoicePrev1 		:	packed array[0..7] of DWord;
				VoiceLoop		:	packed array[0..7] of Byte;
				VoiceEnd 		:	packed array[0..7] of Byte;
				VoiceNoise 		:	packed array[0..7] of Byte;
				VoiceVolume		:	packed array[0..7] of Byte;
				VoiceVolumeR		:	packed array[0..7] of Byte;
				VoiceVolumeL		:	packed array[0..7] of Byte;
				VoiceEnv 		:	packed array[0..7] of Byte;
				VoiceOut 		:	packed array[0..7] of Byte;
				VoiceState		:	packed array[0..7] of Byte;
				VoiceTime		:	packed array[0..7] of DWord;
				VoiceAttack		:	packed array[0..7] of DWord;
				VoiceDecay		:	packed array[0..7] of DWord;
				VoiceSustainL		:	packed array[0..7] of Byte;
				VoiceSustainL2		:	packed array[0..7] of Byte;
				VoiceSustainR		:	packed array[0..7] of DWord;
				VoiceSustainR2		:	packed array[0..7] of DWord;
				VoiceIncNumber 		:	packed array[0..7] of DWord;
				VoiceSLenNumber 	:	packed array[0..7] of DWord;
				VoiceSEndNumber 	:	packed array[0..7] of DWord;
				VoiceSEndLNumber 	:	packed array[0..7] of DWord;
				VoiceDecreaseNumber 	:	packed array[0..7] of DWord;
				VoiceEnvInc 		:	packed array[0..7] of DWord;
				VoiceGainType		:	packed array[0..7] of Byte;
				VoiceGainTime		:	packed array[0..7] of DWord;
				VoiceStarting 		:	packed array[0..7] of Byte;
				Freqdisp 		:	DWord;
				SBRateb			:	DWord;
				VoiceLooped 		:	packed array[0..7] of Byte;
				FutureExpand		:	TZST_FutureExpand;	// 244
				DSPMem			:	{tAPU_DSP_RAM} TBytes256;// 256
				end;


implementation  //------------------------------------------------------------------------------


end.
