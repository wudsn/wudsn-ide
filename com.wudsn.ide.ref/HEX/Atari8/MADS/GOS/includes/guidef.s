//	OS and UI Definitions
//
	.enum Hardware
	Ultimate1MB
	SIDE
	SIDE2
	SicCart
	MaxFlash1Mbit
	MaxFlash8Mbit
	MaxFlashIDE
	MyIDE2
	.ende
	
	.enum PointerDevice
		STMouse
		AmigaMouse
		Joystick
	.ende
	

MaxQueueEntries	equ 32
MaxMenuDepth	equ 4
MessageSize	equ 12
MaxTasks	equ 16
MaxWindows	equ 16
MaxFonts	equ 16 ; maximum number of fonts present in RAM at any time
MaxWindowRects	equ 64
MaxMenuBars	equ 8
PagesPerBank	equ 64 ; number of 256 byte pages per extended RAM bank (including header bank)

	org $E0

; User Page Zero Space

UserPageZero ; this area is always swapped out during context switches

ptr1	.ds 2
ptr2	.ds 2
ptr3	.ds 2
ptr4	.ds 2
ptr5	.ds 2 ; unused
ptr6	.ds 2
ptr7	.ds 2
tmp1	.ds 1
tmp2	.ds 1
tmp3	.ds 1
tmp4	.ds 1
tmp5	.ds 1
tmp6	.ds 1
temp	.ds 2
temp2	.ds 2

;pz1	equ ptr1
;pz2	equ ptr2
;pz3	equ ptr3
;pz4	equ ptr4

EndUserPageZero

; --------------------------------------------------------------------------------------------------------------------
; GUI object definitions
; --------------------------------------------------------------------------------------------------------------------

dlg_closer_flag		equ	1
dlg_title_flag		equ	2

	.enum MenuFlags
		Active		=	1
		Checked		=	2
		Sub		=	4
		Separator	=	8
	.ende
	
	


objSelectedFlag	equ 128

button_default		equ	1


MAX_OBJECTS equ 127 ; for testing only!

	.enum EventStates ; internal state for event handler
		Idle			; nothing
		TopEvent		; event happening to top window
		DesktopRedraw  	; redrawing all windows
		WindowTop		; topping window
		WindowTopDraw	; redraw event for topped window
		MouseAction	; mouse
	.ende

	.enum MaskType ; status for screen mask
		Transparent	; entirely transparent mask
		Opaque		; entirely opaque mask
		AllWindows	; mask comprises all windows on desktop
		Update		; mask comprises update region only
	.ende

	.enum message ; messages for objects
		DRAW
		CLICK
		DOUBLE_CLICK
		DRAG
		GET_FOCUS
		LOSE_FOCUS
	.ende

	.struct EVENTRECORD ; event structure
	what		.byte ; type of event (see below)
	message	.word ; additional message information
	handle	.word ; pointer to object event happened to
	x		.word ; coordinates
	y		.word
	width	.word ; size
	height	.word
	when		.word ; elapsed time
	flags	.byte ; additional flags
	.ends
;
	
	.struct EVENT	; event pipe events (low-level, before system event handler processes them)
	what 	.byte ; type of event (EventType)
	message	.byte ; message (e.g. keycode for KEYDOWN)
	x		.word ; coordinates (only for mouse events)
	y		.byte ; low-level events don't use virtual coordinate system, so y is 8 bit
	when		.long ; 24 bit elapsed ticks counter
	.ends
;
	.enum EventType ; low-level events
		NULL
		HOVER
		MOUSEDOWN
		MOUSEUP
		DOUBLECLICK
		DRAG
		KEYDOWN
		KEYUP
	.ende


	.enum GUIEventType ; events returned in EVENTRECORD.what
		NULL
		HOVER
		MOUSEDOWN
		MOUSEUP
		CLICK
		DOUBLECLICK
		DRAG
		KEYDOWN
		KEYUP
		WM_ARROW
		WM_HSLIDE
		WM_VSLIDE
		WM_CLOSE
		WM_ACTIVATE
		WM_UNTOPPED
		WM_TOPPED
		WM_SIZE
		WM_FULL
		WM_MOVE
		WM_REDRAW
		DM_REDRAW
		MN_SELECTED
	.ende
	
	.enum wm_arrow ; arrow scroll types (returned in EVENTRECORD.message)
COL_UP
COL_DOWN
COL_LEFT
COL_RIGHT
PAGE_UP
PAGE_DOWN
PAGE_LEFT
PAGE_RIGHT
	.ende


FONT		.struct ; GUI proportional font header structure
	revision	.byte
	ID		.word
	encoding	.word
	type		.byte
	firstchar	.byte
	lastchar	.byte
	height		.byte
	ascent		.byte
	descent		.byte
	bitmap_size	.word
	xoffset		.byte
	kern_tab_size	.word
	.ends
	
	.struct RECT ; rectangle structure
	left	.word
	right	.word
	top		.word
	bottom	.word
	.ends
	
	
	.enum ctl ; control data types
	Nul
	WindowTitleBar
	WindowInfoBar
	WindowStatusBar
	WindowIconBar
	WindowVerticalScrollBar
	WindowHorizontalScrollBar
	WindowSizeBox
	WindowCloseButton
	WindowRestoreButton
	WindowClientArea
	Icon
	IconControl
	CommandButton
	DesktopBackground
	TextControl
	BitMap
	TitledFrame
	TextString
	Number
	TabControl
	ListComplete
	ListTitle
	ListContent
	ListDropDown
	SolidRect
	Disabled	= 64
	Hidden		= 128
	.ende
	
	
	.enum WinStatus ; Window status
		Closed 		= 0
		Normal		= 1
		Maximized	= 2
		Minimized	= 3
		Centred		= 128
	.ende


HSCRL_SLIDER	.struct
	MaxValue	.word ; maximum scrollbar value
	Current	.word ; current value
	ThumbSize	.word
	
	MaxPos	.word ; maximum position in pixels (internal)
	CurPos	.word
	Scale	.word ; scaling factor (internal)
	.ends
	
	
VSCRL_SLIDER		.struct
	MaxValue	.word ; maximum scrollbar value
	Current	.word ; current value
	ThumbSize .word
	
	MaxPos	.word ; maximum position in pixels (internal)
	CurPos	.word
	Scale	.word ; scaling factor (internal)
	.ends



ButtonState	.enum ; button states
	Up
	Down
	.ende

DIALOGUE		.struct	;	dialogue resource
	title	.word ; dialogue title
	flags	.word ; flags describing dialogue elements
	def_btn	.word ; button with default focus
	focus	.word ; control with initial focus
	.ends
;

; memory management definitions
;
MEM	.struct ; node for free memory list
	size		.word
	next		.word
.ends

TYPE_HEAD 	equ 	1 ; head of memory linked list
TYPE_FREE 	equ  2 ; free memory
TYPE_USED		equ  4 ; used memory

CTRL_MODIFIER 	equ 132


; Broadly SymbOS compatible control structures

MenuItem	.struct
	Flags	.byte ; Bit usage as follows:
;	0 - menu is active
;	1 - menu has a check mark
;	2 - item opens a sub-menu
;	3 - item is a separator line
	Text	.word ; can be 0 if bit 3 of flags is set
	Value	.word ; return click value or address of sub-menu
	Size	.word ; LSB: size of menu entry in pixels (width for horizontal menu, height for vertical), MSB: tabulation offset
	.ends


WindowData	.struct
	Status			.byte	; (0=closed, 1=normal, 2=maximized, 3=minimized, +128=open window centered [will be always reset after opening])
	flags			.byte	; [bit0]=display 8x8 pixel application icon (in the upper left edge)
					; [bit1]=window is resizeable
					; [bit2]=display close button
					; [bit3]=display tool bar (below the menu bar)
					; [bit4]=display title bar
					; [bit5]=display info bar (below the title bar)
					; [bit6]=display status bar (at the bittom of the window)
					; [bit7]=internal - set to 0 before opening for the first time
	attributes		.byte	; [bit0]=adjust x size of the window content to the x size of the window
					; [bit1]=adjust y size of the window content to the y size of the window
					; [bit2]=Window will not be displayed in the task bar
					; [bit3]=Window is not moveable
					; [bit4]=Window is a super window: other windows, who point on it (see byte 51), can't get the focus position
					; [bit5]=*reserved* (set to 0)
					; [bit6]=Window has a horizontal scroll bar
					; [bit7]=Window has a vertical scroll bar
	Appearance		.byte	; [bit0]=Drop Shadow Border
					; [bit1]=Double Border
	ProcessID		.byte	; Process ID of the window's owner
	x			.word	; x position, if window is not maximized
	y			.word	; y position, if window is not maximized
	Width			.word	; width, if window is not maximized
	Height			.word	; height, if window is not maximized
	ClientX			.word
	ClientY			.word
	ClientWidth		.word
	ClientHeight		.word
	WorkXOffs		.word	; x offset of the displayed window content
	WorkYOffs		.word	; y offset of the displayed window content
	WorkWidth		.word	; width of the total window content
	WorkHeight		.word	; height of the total window content
	MinWidth		.word	; minimal possible width of the window
	MinHeight		.word	; minimal possible height of the window
	MaxWidth		.word	; maximum possible width of the window
	MaxHeight		.word 	; maximum possible height of the window
	RectList		.byte	; first node of window's rectangle list
	Title			.word	; address of the title line text (terminated by 0)
	Info			.word	; address of the info line text (terminated by 0)
	WinContent		.word 	; address of the CONTROL GROUP DATA RECORD for the window content
;	ToolControls		.word	; address of the CONTROL GROUP DATA RECORD of the tool bar content
;	ToolHeight		.word	; height of the tool bar
	.ends
	

	.enum WindowFlags
;		AppIcon		=	1
		Sizeable	=	2
		CloseBtn	=	4
		RestoreBtn	=	8
		ToolBar		=	16
		TitleBar	=	32
		InfoBar		= 	64
		StatusBar	=	128
	.ende
	
	.enum WindowAttributes
		XAdjust		= 1
		YAdjust		= 2
		NoTask		= 4
		NoMove		= 8
		Super		= 16
		Desktop		= 32 ; do we need this?
		HScrollBar	= 64
		VScrollBar	= 128
	.ende
	
	.enum WindowAppearance
		DropShadow		= 1
		DoubleBorder	= 2
	.ende
	


ControlGroup	.struct
	Controls	.byte ; number of controls - must be non-zero
	ProcessID	.byte ; process ID of the control group owner
	Data		.word ; address of the CONTROL DATA RECORDS
	Calc		.word ; address of the position / size calculation rule data record (0 means not present)
	ReturnObj	.byte ; object to click when user hits return (1-255, 0=not defined)
	EscObj		.byte ; object to click when user hits escape (1-255, 0=not defined)	
	FocusObj	.byte ; focus object (1-255, 0=no focus)
	.ends
	

ControlData		.struct
	Value		.word	; control ID/value; this will be sent to the application, if the user
				; clicks or modifies the control. As an example you could store the
				; address of a sub routine here, which you call, if the user clicks the
				; control.
	Type		.byte	; for the type IDs see below. The IDs are between 0 and
				; 63. IDs > 63 will be ignored, so you can set bit 6 and/or 7 to 1, if
				; you want to hide an object, and reset it to 0 if you want to show it
				; again.
	Bank		.byte	; bank number, where the extended control data record is located (0-8;
				; -1 means, that the control is placed in the same bank like the window
				; data record, so normally you can use -1 here)
	ObSpec		.word	; either a parameter to specify the control properties or, if one word is
				; not enough, a pointer to the extended control data record; this depends
				; on the control, so see the control description for information, what to
				; write here.
	x		.word	; x position of the control (related to the upper left edge of the content or tool bar)
				; if the window is using a CALCULATION RULE DATA RECORD, you can write 0 here
	y		.word	; y position of the control
	Width		.word	; Width of the control. If the window is using a CALCULATION RULE DATA RECORD, you can write 0 here
	Height		.word	; Height of the control
	.ends


;===============================================================================
;CALCULATION RULE DATA RECORD
;-------------------------------------------------------------------------------
;00  1W  x position (static part)
;02  1B  window x size multiplier
;03  1B  window x size divider
;04  1W  y position (static part)
;06  1B  window y size multiplier
;07  1B  window y size divider
;08  1W  x size (static part)
;10  1B  window x size multiplier
;12  1B  window x size divider
;13  1W  y size (static part)
;14  1B  window y size multiplier
;15  1B  window y size divider

;Description:
;If "recalculation" for a control group is activated every coordinate and size
;value of a control will be recalculated, if the user changes the size of the
;window.
;The calculation is:
;position or size = static_part + window_size * multiplier / divider

;Example:
;centered_x_position = 0 + window_x_size * 1 / 2
;quartered_y_size    = 0 + window_y_size * 1 / 4
;-------------------------------------------------------------------------------

CalcRule	.struct
	XStatic		.word
	XMulX		.byte
	XDivX		.byte
	YStatic		.word
	YMulY		.byte
	YDivY		.byte
	WStatic		.word
	WMulX		.byte
	WDivX		.byte
	HStatic		.word
	HMulY		.byte
	HDivY		.byte
	.ends



ScrollBarData		.struct
	MaxValue	.word	; maximum scrollbar value
	Current		.word	; current value
	ThumbSize	.word	; pixel width of thumb
	MaxPos		.word	; maximum position in pixels (internal)
	CurPos		.word	; current position in pixels (internal)
	Scale		.word	; scaling factor (internal)
	Enabled		.byte	; bit 7 = scroll bar enabled
	.ends
	

DesktopData			.struct
	Status			.byte
	flags			.byte
	attrib			.byte
	ProcessID		.byte	; Process ID of the window's owner
	x			.word	; x position (usually 0)
	y			.word	; y position
	Width			.word	; width (usually 320)
	Height			.word	; height
	WinControls		.word	; address of the CONTROL GROUP DATA RECORD of the desktop content
	.ends
	
CommandButton	.struct
	Flags	.byte ; button flags
	Text	.word ; pointer to button text
	.ends

Icon			.struct
	Flags		.byte ; size, flags
	Image		.word ; pointer to bitmap and mask
	.ends
	
IconControl		.struct
	Flags		.byte ; size, flags
	Image		.word ; pointer to bitmap and mask
	Text		.word ; pointer to label text
	.ends
	
TextControl	.struct
	Text		.word ; pointer to text
	.ends
	
TextStringControl	.struct
	Text		.word
	Flags		.byte ; bit 0: 0 = transparent, 1 = opaque, bits 6-7: 0 = left align, 1 = centre, 2 = right align
	FGColour	.byte ; text colour
	BGColour	.byte
	.ends
	
	
NumberControl	.struct
	Data		.word ; address of value if >16-bit, or value if <= 16-bit (check this)
	Type		.byte ; 0 = 8-bit, 1 = 16-bit, 2 = 24-bit, 3 = 32-bit
	Alignment	.byte ; 0 = left, 64 = centre, 128 = right
	Flags		.byte ; 128 = comma-separated thousands
	.ends
	
BitMap	.struct
	ByteWidth	.byte
	Width		.word
	Height		.word
	.ends
	
ListItemHeight	equ 9
	
ListTitle	.struct
	Lines		.word ; number of lines in list
	First		.word ; first displayed line in list
	ListData	.word ; pointer to data record for list content
	Columns		.byte ; number of columns (1-64)
	SortOnColumn	.byte ; number of column to sort on (bit 6 = sort list on start, bit 7 = sort order - 0 = ascending, 1 = descending)
	ColumnData	.word ; pointer to data record for columns
	LastClickedLine	.word ; last clicked line
	Options		.byte ; bit 6 = flag (display slider), bit 7 = flag (allow multiselections)
	Flags		.byte ; internal flags (clear bit 7 after changing list)
	.ends


ListComplete	.struct
	Lines		.word ; number of lines in list
	First		.word ; first displayed line in list
	ListData	.word ; pointer to data record for list content
	Columns		.byte ; number of columns (1-64)
	SortOnColumn	.byte ; number of column to sort on (bit 6 = sort list on start, bit 7 = sort order - 0 = ascending, 1 = descending)
	ColumnData	.word ; pointer to data record for columns
	LastClickedLine	.word ; last clicked line
	Options		.byte ; bit 6 = flag (display slider), bit 7 = flag (allow multiselections)
	Flags		.byte ; internal flags (clear bit 7 after changing list)
	.ends



ListColumn	.struct ; * number of columns
	Flags		.byte ; bits 0-2: type (0 = text, 1 = graphic, 2 = 8-bit num, 3 = 16-bit num, 4 = 24-bit num, 5 = 32-bit num), bits 6-7: alignment (0 = left, 1 = right, 2 = centre)
	Width		.word ; width of column in pixels
	Data		.word ; pointer to title (0 terminated string)
	.ends
	
ListRecord	.struct ; * number of lines
	Value	.word	; bits 0-12 = value of this line, bit 13 = colour of first row, bit 14 = selection update, bit 15 = this line selected
	.ends ; followed by columns * word address of cell data



	
	
	.enum ListFlags
		Changed		= 128
	.ende
	
	.enum ListColumnType
		Text
		Graphic
		Num8Bit
		Num16Bit
		Num24Bit
		Num32Bit
	.ende
	
	.enum ListOptions
		Slider		= 64
		MultiSelections	= 128
	.ende
	
		
	.enum ListColumnAlignment
		Left	= 0
		Right	= 64
		Centre	= 128
	.ende
	
	
	.enum NumberType
		w8Bit
		w16Bit
		w24Bit
		w32Bit
	.ende
	
	
	.enum NumberAlignment
		Left	= 0
		Right	= 1
		Centre	= 2
	.ende
	
	
	.enum	NumberFlags
		Commas	= 128
	.ende
	
	
	.enum	TextStringFlags
		Transparent	= 1
		CentreAlign	= 64
		RightAlign	= 128
	.ende
	
	
	
; Kernel definitions

	.enum Kernel
		MessageSend
		MessageSendFrom
		MessageReceive
		MessageSleepReceive
		Sleep
		SoftInterrupt
		Yield
		ProcessStart
		ProcessRun
		Malloc
		Free
		GetProcessInfo
		GetSystemInfo
		ConvertNumToString
		ConvertStringToNum
		FileOpen
		FileGet
		FileRead
		FileClose
		FileGetSize
		FileSeek
		Debug
		RegIRQTimer
		RegNMIHand
	.ende
	
	
	.enum KernelMsg
		AddProcess
		DeleteProcess
		AddService
		AddTimer
	.ende
	
	
	.enum KernelResponse
		AddProcess
		DeleteProcess
		AddService
		AddTimer
	.ende
	
	
	.enum WindowID
		Desktop	= 1
	.ende
	
	
	.enum KernelStatus
		OK			= 0
		QueueFull		= 128
		NonexistentProcess	= 129
		NoMessageAvailable	= 130
		TooManyTasks		= 131
		InsufficientRAM		= 132
		PIDMismatch		= 133
		FileNotFound		= 134
		InvalidExecutable	= 135
	.ende
	
	

	
	.enum ProcessID
		Kernel		= 1
		Idle		= 2
		SystemManager	= 3
		DesktopManager	= 4
		Finder		= 5
		Any		= 255
	.ende
	
	
	.enum ProcessType
		Application	= 0
		Service		= 1
		Timer		= 2
		Interrupt	= 3
		Driver		= 4
		RAM		= 0
		ROM		= 128
	.ende
	
	
	.enum ProcessState
		Sleep
		Idle
		Ready
		Free		= 255
	.ende
	
	
	.enum System ; system manager functions
		ProgramRun
		FileOpen
		FileGetByte
		FileGetBuffer
	.ende
	

	.enum Desk ; desktop manager functions
		WindOpen
		InitAppMenu
		UpdateAppMenu
		UpdateSysMenu
		RegisterMenulet
		UpdateMenulet
		WindSetXOff
		WindSetYOff
		WindSetFocus
		WindMaximize
		WindRestore
		WindMinimize
		WindSetSize
		WindSetPos
		WindClose
		WindRedrawSlider
		WindRedrawArea
		WindRedrawControl
		ClientRedraw
		ToolbarRedraw
		TitleRedraw
		InfoRedraw
		StatusRedraw
		MouseEvent
	.ende
	
	
	.enum DeskResponse ; desktop manager response messages
		WindOpenOK
		WindUserEvent
		WindScroll
		WindSize
		WindMove
		WindClose
		WindFocus
		MenuSelection
		TooManyWindows = 128
	.ende
	
	
	
	.enum FileResponse
		OK			= 0
		QueueFull		= 128
		NonexistentProcess	= 129
		NoMessageAvailable	= 130
		TooManyTasks		= 131
		InsufficientRAM		= 132
		PIDMismatch		= 133
		FileNotFound		= 134
		InvalidExecutable	= 135
		EOF			= 136
		NoFunction		= 137
		NAK			= 138
	.ende
	
;	File System Function Calls
	
	.enum FSFunc
	Open		; functions requiring a dev/path
	FFirst
	ChMod
	Rename
	Delete
	MkDir
	RmDir
	ChDir
	GetCWD
	GetDFree
	ChVol

	Read		; functions requiring a file handle
	Write
	FTell
	FSeek
	FNext
	FLen
	Close
	.ende
	
	
	.enum DeskUserEventType ; desktop manager user event types
		Close	; close box
		Menu	; menu selection
		Content	; client area control
		Tool	; tool bar
		Key	; keystroke
	.ende
	
	.enum ModalState
		Off
		Slider
		UpArrow
		DownArrow
		WindowMove
		WindowSize
	.ende
	
	
	.enum ScrollBarCallBack
		None
		List
	.ende
	
	
	.enum DeskUserEventSub ; desktop manager user event sub specifications
		LeftMouseClick
		RightMouseClick
		MouseDoubleClick
		Key
	.ende
	
	
	
	
	.struct SystemInfo
PlatformID		.byte
CPUType			.byte
CPUSpeed		.word
TotalRAM		.word
FreeRAM			.word
Processes		.byte
Applications		.byte
Services		.byte
Timers			.byte
CPULoad			.byte
	.ends
	
	

	.struct ProcessInfo
Name		.dword
Name2		.dword
Name3		.dword
Name4		.dword
PID		.byte
Type		.byte
Priority	.byte
State		.byte
CPUUsage	.byte
RAMUsage	.byte
SequenceID	.word
Rsvd		.dword
Rsvd2		.dword
	.ends
	
	
	
//
//	Character attributes
//

	.enum CharStyle
Plain		= 0
Bold		= 1
Italic		= 2
Underline	= 4
Outline		= 8
Glow		= 16
Dimmed		= 32
	.ende
	
	
//
//	Render Colour
//
	
	.enum DrawColour
White		= 0
Black		= 1
	.ende
	
//
//	Directory entry offsets
//

	.enum DirEntry
		Name		= $00
		Ext		= $08
		Attrib		= $0B
		Case		= $0C
		CreationTimeMS	= $0D
		CreationTime	= $0E
		CreationDate	= $10
		LastAccessDate	= $12
		ClusterHi	= $14 ; high word of start cluster for FAT32
		Time		= $16
		Date		= $18
		ClusterLo	= $1A
		Size		= $1C
	.ende
	
	


KernelCall .extrn .word

