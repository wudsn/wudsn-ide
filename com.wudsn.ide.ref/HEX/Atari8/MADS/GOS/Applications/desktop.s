;@com.wudsn.ide.asm.outputfileextension=.rom

//	Atari 8-bit GOS file manager
//	Stand-alone relocatable MADS binary
//

	icl '../Includes/guidef.s'
	icl '../Includes/macros.s'


	.reloc

DesktopApp ; this block is relocated to $4000
	.byte 'Keeper',0,0
	.byte 0,0,0,0,0,0,0,0

AppFlags
	.byte 0
CodeBank ; this is populated with the code's bank number by the loader
	.byte 0
PID ; this is populated with the process's ID
	.byte 0

	.byte 0 ; number of shared page zero locations used by this process (for scheduler)

TextEditor	= 1


	.struct ClientRecord ; custom multi-window structure
		FilesPerColumn .word
		FirstFile		.word
		NumColumns	.word
		CXOffs		.word
		CYOffs		.word
		RowCount		.word
		ColCount		.word
		FileCount		.word
		EntryHeight	.word
		ColumnWidth	.word
		FilesPerRow	.word
		NumRows		.word
		WindowView	.byte
	.ends

NumFiles 		= 64

; ------------------------------------------------------------
; Initialisation
; ------------------------------------------------------------

	.local Init
	
; draw desktop

	ldax #Window0 ; a,x points to window record
	ldy CodeBank ; y holds bank (CodeBank is populated by loader)
	jsr OpenWindow ; draw window and contents (desktop pattern and icons)
;	bmi Error
	sta WindowHandle ; save ID of desktop window

; set up system menu
	
	mva #Desk.UpdateSysMenu MessageBuffer
	mva CodeBank MessageBuffer+1
	mwa #MenuBarSys MessageBuffer+2
	jsr SendMsgDeskMgr
	
; set up application menu

	mva #Desk.InitAppMenu MessageBuffer
	mva CodeBank MessageBuffer+1
	mwa #MenuBarMain MessageBuffer+2
	jsr SendMsgDeskMgr

	jmp MainLoop
	.endl
	
	
; ----------------------------------------------------------------------------
; Worker routine to open a window at a,x in bank y and wait for a response
; ----------------------------------------------------------------------------
	
	.local OpenWindow
	sty MessageBuffer+1 ; bank
	stax MessageBuffer+2 ; address
	mva #Desk.WindOpen MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
	jsr SleepMsgDeskMgr ; sleep till we get a response
	lda MessageBuffer+4 ; get window ID (only valid if status is OK)
	ldy MessageBuffer ; get status (bit 7 set if there was an error)
	rts
	.endl

; ----------------------------------------------------------------------------
; Send message to the desktop manager
; ----------------------------------------------------------------------------

	.local SendMsgDeskMgr
	lda #ProcessID.DesktopManager ; receiver ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend ; send message		
	rts
	.endl

; ----------------------------------------------------------------------------
; Sleep on message from desktop manager
; ----------------------------------------------------------------------------

	.local SleepMsgDeskMgr
	lda #ProcessID.DesktopManager ; sender ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSleepReceive ; sleep on response from desktop manager only
	rts
	.endl
	
; ----------------------------------------------------------------------------
; Send message to the system manager
; ----------------------------------------------------------------------------
	
	.local SendMsgSysMgr
	lda #ProcessID.SystemManager ; receiver ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend ; send message		
	rts
	.endl
	
; ----------------------------------------------------------------------------
; Send message to the kernel
; ----------------------------------------------------------------------------

	.local SendMsgKernel
	lda #ProcessID.Kernel ; receiver ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend ; send message	
	.endl

; ----------------------------------------------------------------------------
; Get message from the kernel
; ----------------------------------------------------------------------------

	.local GetMsgKernel
	lda #ProcessID.Kernel ; sender ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageReceive ; receive message
	rts
	.endl
	
; ----------------------------------------------------------------------------
; Main Loop
; ----------------------------------------------------------------------------
	
	.local MainLoop
	jsr SleepMsgDeskMgr ; sleep until the desktop manager sends us a message
	cpy #KernelStatus.OK
	beq GotMessage
	jmp MainLoop ; if process was woken up for some other reason, handle it here

GotMessage
	cmp #ProcessID.DesktopManager ; if not from desktop manager, ignore for now (this shouldn't happen, so we should be able to remove the check)
	bne MainLoop
	lda MessageBuffer ; see what happened
	cmp #DeskResponse.MenuSelection
	beq MenuSelection
	cmp #DeskResponse.WindUserEvent
	bne NotUserEvent

; handle user click events

	mva MessageBuffer+1 _WindowID ; get window ID
	lda MessageBuffer+2 ; get action type
	cmp #DeskUserEventType.Close ; Window closer clicked
	beq CloseWindow
	cmp #DeskUserEventType.Content ; Window content action
	beq ClientEvent
	cmp #DeskUserEventType.Key ; Key pressed
	beq KeyboardEvent
	cmp #DeskUserEventType.Tool ; toolbar icon clicked
	beq ToolBarEvent
	
	
	
MenuSelection ; handle menu item selection
	mwa MessageBuffer+1 MenuVec+1
MenuVec
	jsr $FFFF
;MenuVec = *-2
	jmp MainLoop

	
ClientEvent ; handle window client events
	
	
	
CloseWindow ; window closer was clicked
	


KeyboardEvent ; key pressed
	jmp MainLoop ; do nothing for now
	
	
ToolBarEvent ; toolbar icon clicked
	jmp MainLoop ; do nothing for now
	
	
NotUserEvent ; not a click event, so check other events
	cmp #DeskResponse.WindFocus ; received or lost focus?
	bne NotFocusEvent
	
	
	
	
	
NotFocusEvent
	cmp #DeskResponse.WindSize ; resized window?
	jmp MainLoop
	
	
NotSizeEvent
	cmp #DeskResponse.WindScroll ; scrolled content?
	bne NotScrollEvent
	
	
	
	
	
NotScrollEvent
	jmp MainLoop ; nothing to do, so just sleep on the next message
	.endl

	
	
_WindowID
	.byte 0
WindowHandle
	.byte 0
	

	

; ****************************** event code **********************************

	.local do_file_new ; window test code
	rts
	.endl


	.local CreateDesktop
	rts
	.endl
	
	


	.local FindWindowNumber ; return Window number (0-3) by looking up window handle (passed in WindowHandle)
	rts
	.endl


	.local GetMyClientXYWH
	rts
	.endl
	


AppAbout
AppPreferences
AppQuit
	rts

	.local FileNew
	rts
	.endl





FileOpen
FileClose
FilePrint
FileInfo
FileExit
FilePSetup
FilePDir
	rts


EditUndo
EditRedo
EditCut
EditCopy
EditPaste
EditDelete
EditFind
EditFindNext
EditReplace
EditSelectAll
	rts


ViewShowIcons
ViewShowText
	rts
	
	

ViewSortByName
ViewSortBySize
ViewSortByDate
ViewSortByType
	rts


ToolsOptions
	rts



HelpView
	rts
	


SysAbout
SysShutDown
SysRestart
	rts
	
	
SysTaskManager
	ldax #ProfilerName
	ldy #4
	SysCall Kernel.ProcessRun
	rts
	
SysFontViewer
	ldax #JotterName
	ldy #4
	SysCall Kernel.ProcessRun
	rts
	
ProfilerName
	.byte 'profiler.app',0
JotterName
	.byte 'jotter.app',0
	
window_hand
	.word 0
window_handles ; table of window handles (maximum of eight)
	.word 0,0,0,0,0,0,0,0



	
; ----------------------------------------------------------------------------------------------------
; Resources
; ----------------------------------------------------------------------------------------------------


; ----------------------------------------------------------------------------------------------------
; System menu bar
; ----------------------------------------------------------------------------------------------------

MenuBarSys
	.byte 1 ; # items (bit 6 = formatted, bit 7 = invalid: do not open)
MenuSys1	dta MenuItem [0] (1+4, txtMenuSys, MenuSys, 0)

txtMenuSys
	.byte 135,0

MenuSys
	.byte 6 ; # items
	.word 0,0 ; for internal use
MenuSys1	dta MenuItem [0] (1, txtMenuSys1, SysAbout, 0)
MenuSys2	dta MenuItem [0] (1+8, 0, 0, 0) ; separator line
MenuSys3	dta MenuItem [0] (1, txtMenuSys2, SysShutDown, 0)
MenuSys4	dta MenuItem [0] (1, txtMenuSys3, SysRestart, 0)
MenuSys5	dta MenuItem [0] (1, txtMenuSys4, SysTaskManager, 0)
MenuSys6	dta MenuItem [0] (1, txtMenuSys5, SysFontViewer, 0)
	
txtMenuSys1	.byte '&About this Atari',0
txtMenuSys2	.byte 'Shut down',0
txtMenuSys3	.byte 'Restart',0
txtMenuSys4	.byte 'Profiler',0
txtMenuSys5	.byte 'Jotter',0



; ----------------------------------------------------------------------------------------------------
; Application menu bar
; ----------------------------------------------------------------------------------------------------

MenuBarMain
	.byte 6
MenuMain1	dta MenuItem [0] (1+4, txtMenuApp, MenuApp, 0)
MenuMain2	dta MenuItem [0] (1+4, txtMenuFile, MenuFile, 0)
MenuMain3	dta MenuItem [0] (1+4, txtMenuEdit, MenuEdit, 0)
MenuMain4	dta MenuItem [0] (1+4, txtMenuView, MenuView, 0)
MenuMain5	dta MenuItem [0] (1+4, txtMenuTools, MenuTools, 0)
MenuMain6	dta MenuItem [0] (1+4, txtMenuHelp, MenuHelp, 0)


txtMenuApp
	.byte '&Keeper',0
txtMenuFile
	.byte '&File',0
txtMenuEdit
	.byte '&Edit',0
txtMenuView
	.byte '&View',0
txtMenuTools
	.byte '&Tools',0
txtMenuHelp
	.byte '&Help',0



MenuApp
	.byte 4
	.word 0,0
MenuApp1	dta MenuItem [0] (1, txtMenuApp1, AppAbout, 0)
MenuApp2	dta MenuItem [0] (1+8, 0, 0, 0)
MenuApp3	dta MenuItem [0] (1, txtMenuApp2, AppPreferences, 0)
MenuApp4	dta MenuItem [0] (1, txtMenuApp3, AppQuit, 0)

txtMenuApp1	.byte 'About Keeper',0
txtMenuApp2	.byte 'Preferences',0
txtMenuApp3	.byte 'Quit Keeper',0

	
	
	
MenuFile
	.byte 10 ; # items
	.word 0,0
MenuFile1	dta MenuItem [0] (1, txtMenuFile1, FileNew, 0)
MenuFile2	dta MenuItem [0] (1, txtMenuFile2, FileOpen, 0)
MenuFile3 	dta MenuItem [0] (0, txtMenuFile3, FilePrint, 0)
MenuFile4	dta MenuItem [0] (1, txtMenuFile4, FileClose, 0)
MenuFile5	dta MenuItem [0] (0, txtMenuFile5, FileInfo, 0)
MenuFile6	dta MenuItem [0] (1+8, 0, 0, 0)
MenuFile7	dta MenuItem [0] (1, txtMenuFile6, FilePSetup, 0)
MenuFile8	dta MenuItem [0] (1, txtMenuFile7, FilePDir, 0)
MenuFile9	dta MenuItem [0] (1+8, 0, 0, 0)
MenuFile10	dta MenuItem [0] (1, txtMenuFile8, FileExit, 0)
	
txtMenuFile1
	.byte '&New Window/',CTRL_MODIFIER,'N',0
txtMenuFile2
	.byte '&Open/',CTRL_MODIFIER,'O',0
txtMenuFile3
	.byte '&Print.../',CTRL_MODIFIER,'P',0
txtMenuFile4
	.byte '&Close',0
txtMenuFile5
	.byte 'Properties...',0
txtMenuFile6
	.byte 'Page Setup...',0
txtMenuFile7
	.byte 'Print Directory',0
txtMenuFile8
	.byte 'E&xit',0


MenuEdit
	.byte 13
	.word 0,0
MenuEdit1	dta MenuItem [0] (0, txtMenuEdit1, EditUndo, 0)
MenuEdit2	dta MenuItem [0] (0, txtMenuEdit2, EditRedo, 0)
MenuEdit3	dta MenuItem [0] (1+8, 0, 0, 0)
MenuEdit4	dta MenuItem [0] (0, txtMenuEdit3, EditCut, 0)
MenuEdit5	dta MenuItem [0] (0, txtMenuEdit4, EditCopy, 0)
MenuEdit6	dta MenuItem [0] (1, txtMenuEdit5, EditPaste, 0)
MenuEdit7	dta MenuItem [0] (0, txtMenuEdit6, EditDelete, 0)
MenuEdit8	dta MenuItem [0] (1+8, 0, 0, 0)
MenuEdit9	dta MenuItem [0] (1, txtMenuEdit7, EditFind, 0)
MenuEdit10	dta MenuItem [0] (1, txtMenuEdit8, EditFindNext, 0)
MenuEdit11	dta MenuItem [0] (1, txtMenuEdit9, EditReplace, 0)
MenuEdit12	dta MenuItem [0] (1+8, 0, 0, 0)
MenuEdit13	dta MenuItem [0] (1, txtMenuEdit10, EditSelectAll, 0)

txtMenuEdit1
	.byte '&Undo/',CTRL_MODIFIER,'Z',0
txtMenuEdit2
	.byte '&Redo/',CTRL_MODIFIER,'Y',0
txtMenuEdit3
	.byte 'Cu&t/',CTRL_MODIFIER,'X',0
txtMenuEdit4
	.byte '&Copy/',CTRL_MODIFIER,'C',0
txtMenuEdit5
	.byte '&Paste/',CTRL_MODIFIER,'V',0
txtMenuEdit6
	.byte 'De&lete/Del',0
txtMenuEdit7
	.byte '&Find.../',CTRL_MODIFIER,'F',0
txtMenuEdit8
	.byte 'Find &Next',0
txtMenuEdit9
	.byte '&Replace...',0
txtMenuEdit10
	.byte 'Select &All/',CTRL_MODIFIER,'A',0



MenuView
	.byte 3
	.word 0,0
MenuView1	dta MenuItem [0] (1, txtMenuView1, ViewShowIcons, 0)
MenuView2	dta MenuItem [0] (1+2, txtMenuView2, ViewShowText, 0)
MenuView3	dta MenuItem [0] (1+4, txtMenuView3, MenuViewSortBy, 0)

txtMenuView1
	.byte 'Show as Icons',0
txtMenuView2
	.byte 'Show as Text',0
txtMenuView3
	.byte 'Sort By',0


MenuViewSortBy ; cascading menu
	.byte 4
	.word 0,0
MenuViewSortBy1		dta MenuItem [0] (1+2, txtMenuViewSortBy1, ViewSortByName, 0)
MenuViewSortBy2		dta MenuItem [0] (1, txtMenuViewSortBy2, ViewSortByType, 0)
MenuViewSortBy3		dta MenuItem [0] (1, txtMenuViewSortBy3, ViewSortByDate, 0)
MenuViewSortBy4		dta MenuItem [0] (1, txtMenuViewSortBy4, ViewSortBySize, 0)

txtMenuViewSortBy1
	.byte 'Name',0
txtMenuViewSortBy2
	.byte 'Type',0
txtMenuViewSortBy3
	.byte 'Date',0
txtMenuViewSortBy4
	.byte 'Size',0
;

MenuTools
	.byte 1
	.word 0,0
MenuTools1	dta MenuItem [0] (1, txtMenuTools1, ToolsOptions, 0)	

txtMenuTools1
	.byte '&Options',0


MenuHelp
	.byte 1
	.word 0,0
MenuHelp1	dta MenuItem [0] (1, txtMenuHelp1, HelpView, 0)

txtMenuHelp1
	.byte 'View &Help',0


; ----------------------------------------------------------------------------------------------------
; Window records
; ----------------------------------------------------------------------------------------------------

WindowHandles ; table of main window handles
	.word Window0,Window1,Window2,Window3,Window4
WindowActiveList ; table of flags to say which window is active and which isn't (bit 7 set means window is in use)
	.byte 0,0,0,0,0

; ----------------------------------------------------------------------------------------------------
; The first window (Window0) is the desktop Window
; ----------------------------------------------------------------------------------------------------


Window0	dta WindowData [0] (0, 0, \ ; Status, Flags
			WindowAttributes.Desktop, 0, 0, 0, 14, 320, 186, \	; attrib, style, process ID, x, y, width, height
			0, 0, 320, 186, \ ; client x, y, width, height
			0, 0, 320, 186, 320, 186, 320, 186, 0, \	; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			0, 0, DesktopControlList)

Window1	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar , \
			0, WindowAppearance.DropShadow, 0, 32, 30, 248, 150, \	; attrib, style, process ID, x, y, width, height
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \		; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			txtWindow1Title, txtWindow1Info, 0)
			
Window2	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar , \
			0, WindowAppearance.DropShadow, 0, 40, 35, 248, 150, \	; attrib, style, process ID, x, y, width, height
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \		; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			txtWindow1Title, txtWindow1Info, Window2Content)
			
Window3	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar , \
			0, WindowAppearance.DropShadow, 0, 48, 40, 248, 150, \	; attrib, style, process ID, x, y, width, height
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \		; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			txtWindow1Title, txtWindow1Info, Window3Content)

	.if 0
Window2	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar , \ ; + WindowFlags.InfoBar, \
			0, WindowAppearance.DropShadow, 0, 88, 16, 200, 150,  \
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \	
			txtWindow2Title, txtWindow2Info, Window2Content)	
			
Window3	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar , \ ;  + WindowFlags.InfoBar, \
			0, WindowAppearance.DropShadow, 0, 96, 28, 200, 150, \
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \	
			txtWindow3Title, txtWindow3Info, Window3Content)
	.endif

Window4	dta WindowData [0] (0, WindowFlags.Sizeable + WindowFlags.CloseBtn + WindowFlags.RestoreBtn + WindowFlags.TitleBar + WindowFlags.InfoBar, \
			0, WindowAppearance.DropShadow, 0, 104, 32, 200, 150, \
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 400, 300, 96, 96, 320, 200, 0, \	
			txtWindow4Title, txtWindow4Info, Window4Content)
			
; ----------------------------------------------------------------------------------------------------
; Desktop Controls
; ----------------------------------------------------------------------------------------------------

DesktopControlList dta ControlGroup [0] (10, 0, DesktopControlRecords, 0, 0, 0, 0)

DesktopControlRecords
;DeskPattern	dta ControlData [0] (0, ctl.DesktopBackground, 0, 0, 0, 0, 319, 199)
DesktopIcon1	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon1Data, 16, 4, 16, 16)
DesktopIcon2	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon2Data, 16, 40, 16, 16)
DesktopIcon3	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon3Data, 16, 76, 16, 16)
DesktopIcon5	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon5Data, 16, 112, 16, 16)
DesktopIcon6	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon6Data, 288, 4, 16, 16)
DesktopIcon7	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon7Data, 288, 40, 16, 16)
DesktopIcon8	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon8Data, 288, 76, 16, 16)
DesktopIcon9	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon9Data, 288, 112, 16, 16)
DesktopIcon10	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon10Data, 16, 148, 16, 16)
DesktopIcon11	dta ControlData [0] (0, ctl.IconControl, 0, DesktopIcon11Data, 288, 148, 16, 16)

DesktopIcon1Data 	dta IconControl [0] (0, :ico_drivehard00, DesktopIcon1Txt)
DesktopIcon2Data 	dta IconControl [0] (0, :ico_drive5Floppy, DesktopIcon2Txt)
DesktopIcon3Data 	dta IconControl [0] (0, :ico_drive3Floppy01, DesktopIcon3Txt)
DesktopIcon5Data 	dta IconControl [0] (0, :ico_doctext, DesktopIcon5Txt)
DesktopIcon6Data 	dta IconControl [0] (0, :ico_drivehard00, DesktopIcon6Txt)
DesktopIcon7Data 	dta IconControl [0] (0, :icoProfiler316, DesktopIcon7Txt)
DesktopIcon8Data 	dta IconControl [0] (0, :icoJotter16, DesktopIcon8Txt)
DesktopIcon9Data	dta IconControl [0] (0, :icoKeeper16, DesktopIcon9Txt)
DesktopIcon10Data 	dta IconControl [0] (0, :ico_doctext, DesktopIcon10Txt)
DesktopIcon11Data 	dta IconControl [0] (0, :ico_trash3dempty, DesktopIcon11Txt)

DesktopIcon1Txt .byte 'HDD1',0
DesktopIcon2Txt .byte 'Floppy A',0
DesktopIcon3Txt .byte 'Floppy B',0
DesktopIcon5Txt .byte 'kernel',0
DesktopIcon6Txt .byte 'HDD2',0
DesktopIcon7Txt .byte 'Profiler',0
DesktopIcon8Txt .byte 'Jotter',0
DesktopIcon9Txt .byte 'Keeper',0
DesktopIcon10Txt .byte 'APINotes',0
DesktopIcon11Txt .byte 'Trash',0

; ----------------------------------------------------------------------------------------------------
; Dummy Window Content
; ----------------------------------------------------------------------------------------------------

txtWindow1Title
txtWindow2Title
txtWindow3Title
txtWindow4Title
	.byte 0

txtWindow1Info
txtWindow2Info
txtWindow3Info
txtWindow4Info
	.byte 0
	
Window0Content ; desktop content
	.word DesktopContent
	
DesktopContent


Window1Content
ClientControlList1 dta ControlGroup [0] (1, 0, ClientControlRecords1, 0, 0, 0, 0)

ClientControlRecords1
DemoTextControl1	dta ControlData [0] (0, ctl.TextControl, 0, DemoTextExt1, 0, 14, 240, 128)
	
DemoTextExt1 dta TextControl [0] (DemoText)

Window2Content
ClientControlList2 dta ControlGroup [0] (1, 0, ClientControlRecords2, 0, 0, 0, 0)

ClientControlRecords2
DemoTextControl2	dta ControlData [0] (0, ctl.TextControl, 0, DemoTextExt2, 0, 14, 240, 128)
	
DemoTextExt2 dta TextControl [0] (DemoText)

Window3Content
ClientControlList3 dta ControlGroup [0] (1, 0, ClientControlRecords3, 0, 0, 0, 0)

ClientControlRecords3
DemoTextControl3	dta ControlData [0] (0, ctl.TextControl, 0, DemoTextExt3, 0, 14, 240, 128)
	
DemoTextExt3 dta TextControl [0] (DemoText)

Window4Content


WindowHandleLUT
	.byte <Window0, < Window1,< Window2,< Window3,< Window4
	.byte >Window0, > Window1,> Window2,> Window3,> Window4

WindowClientDataLUT
	.byte <WindowClientData0, <WindowClientData1, <WindowClientData2, <WindowClientData3, <WindowClientData4
	.byte >WindowClientData0, >WindowClientData1, >WindowClientData2, >WindowClientData3, >WindowClientData4	

WindowClientData0 dta ClientRecord [0] (0,0,0,0,0,0,0,0,0,0,0,0,0) ; pointer to user-specific data
WindowClientData1 dta ClientRecord [0] (0,0,0,0,0,0,0,0,0,0,0,0,0) 
WindowClientData2 dta ClientRecord [0] (0,0,0,0,0,0,0,0,0,0,0,0,0) 
WindowClientData3 dta ClientRecord [0] (0,0,0,0,0,0,0,0,0,0,0,0,0) 
WindowClientData4 dta ClientRecord [0] (0,0,0,0,0,0,0,0,0,0,0,0,0) 
	
do_sys_about
	rts
	
	icl 'icondata2.s'
	
DemoText
	.byte 0
LineLength
	.byte 0



column	.byte 0
myevent dta eventrecord [0] (0,0,0,0,0,0,0,0,0)
window_count	.byte 0
winhandle1 .word 0
winhandle2 .word 0
mywinx .word 0
mywiny .byte 0
mywinwidth .word 0
mywinheight .word 0
myclientx	.word 0
myclienty	.word 0
myclientw .word 0
myclienth .word 0
myclientx2 .word 0
myclienty2 .byte 0
mydocwidth .word 0
mydocheight .word 0
windowx	.word 64
windowy	.word 20
mychar	.byte 0


;WindowNum	.byte 0
FilesPerColumn .word 0
FirstFile	.word 0
NumColumns	.word 0
CXOffs .word 0
CYOffs .word 0
RowCount	.word 0
ColCount	.word 0
FileCount	.word 0
EntryHeight .word 14 ; 10
ColumnWidth .word 68+4+14 ; 68+4
FilesPerRow	.word 0
NumRows	.word 0
	.if .def TextEditor
WindowView	.byte 0
	.else
WindowView	.byte 1 ; 0 = icon view, 1 = list view
	.endif

MyWindowHandle	.word 0

MessageBuffer
	.rept 16
	.byte 0
	.endr
	
	.byte 0 ; this is required, otherwise prior buffer is not filled

; ********************************* end of resources **********************************

	blk update address
	
