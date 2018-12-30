;@com.wudsn.ide.asm.outputfileextension=.rom

//	Atari 8-bit GOS process manager
//	Stand-alone relocatable MADS binary
//

	icl '../Includes/guidef.s'
	icl '../Includes/macros.s'

	.reloc
	
; page zero variables
	
.extrn	@@pz1	.byte
.extrn	@@pz2	.byte
.extrn	@@pz3	.byte
.extrn	@@pz4	.byte
.extrn	@@ptr1	.byte
.extrn	@@ptr2	.byte
.extrn	@@ptr3	.byte
.extrn	@@ptr4	.byte
	
ProfilerApp
	.byte 'Profiler'
	.byte 0,0,0,0,0,0,0,0
AppFlags
	.byte 0
CodeBank
	.byte 2
PID
	.byte 0
	
	.byte 16 ; number of page zero locations used by this process
	
	jsr UpdateStats
	
	ldxy #SysInfoBuffer
	SysCall Kernel.GetSystemInfo
	
	ldxy #SampleBuffer
	SysCall Kernel.GetProcessInfo
	jsr CreateProcessList
	jsr CreateAppList
	
	mva #Desk.InitAppMenu MessageBuffer ; set up menu
	mva CodeBank MessageBuffer+1
	mwa #MenuBarMain MessageBuffer+2
	jsr SendMsgDeskMgr

	mva CodeBank MessageBuffer+1 ; bank
	mwa #Window1 MessageBuffer+2 ; address
	mva #Desk.WindOpen MessageBuffer ; function
	jsr SendMsgDeskMgr ; set up window

	jsr SleepMsgDeskMgr ; sleep till we get a response
	mva MessageBuffer+4 Window1ID ; get window ID (only valid if status is OK)
	lda MessageBuffer ; get status (bit 7 set if there was an error)
	; branch on error here

Loop
	ldxy #MessageBuffer
	lda #ProcessID.Any ; see if we have a message
	SysCall Kernel.MessageReceive
	jmi NoMessage
	
	cmp #ProcessID.DesktopManager
	jne NoMessage
	lda MessageBuffer
	cmp #DeskResponse.WindUserEvent
	jne NotWindUserEvent
	
	; check window ID here as well
	lda MessageBuffer+2
	cmp #DeskUserEventType.Content
	bne NotContentEvent
	
	cpb MessageBuffer+6 #1 ; tab control?
	bne NotTab

	lda MessageBuffer+7 ; get # of clicked tab
	sta Tab1Data+1 ; set selected tab
	asl
	tax
	lda TabLUT,x
	sta Window1[0].WinContent
	lda TabLUT+1,x
	sta Window1[0].WinContent+1

	mva #Desk.WindRedrawControl MessageBuffer
	mva Window1ID MessageBuffer+1
	mva #0 MessageBuffer+2 ; first control ID
	mva #255 MessageBuffer+3 ; redraw all controls
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message	
	jmp Finished

NotTab ; user didn't click tab, so check for buttons
	ldy Tab1Data+1 ; see which tab we're in
	cpy #1	; process tab?
	bne NotProcessTab2
	cmp #2	; List title?
	bne @+
	mva Window1ID MessageBuffer+1 ; redraw list control
	mva #3 MessageBuffer+2 ; list content ID
	mva #0 MessageBuffer+3 ; number of controls - 1
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
	jmp Finished
@
	cmp #3 ; Update button?
	bne NotProcessTab2
	jmp UpdateProcessTab
	
NotContentEvent
	cmp #DeskUserEventType.Close ; close window?
	mva #Desk.WindClose MessageBuffer
	mva Window1ID MessageBuffer+4
	jsr SendMsgDeskMgr

	jsr SleepMsgDeskMgr ; sleep till we get a response
	
	mva #KernelMsg.DeleteProcess MessageBuffer
	mva PID MessageBuffer+1
	jsr SendMsgKernel ; remove self from process list
AwaitDemise
	jmp AwaitDemise
	
NotWindUserEvent
	
NotProcessTab2
	cmp #2
	bne NotAppTab
	cmp #2	; List title?
	bne @+
	mva Window1ID MessageBuffer+1 ; redraw list control
	mva #3 MessageBuffer+2 ; list content ID
	mva #0 MessageBuffer+3 ; number of controls - 1
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
@
	jmp Finished	
NotAppTab
	jmp Finished

NoMessage ; no message received, so just get process info and update dialog
	ldxy #SampleBuffer
	SysCall Kernel.GetProcessInfo
	ldxy #SysInfoBuffer
	SysCall Kernel.GetSystemInfo
	jsr CalculateMemoryLoad
	sta PercentUsedRAM
	lsr @
	sta Temp3
	jsr GetCPULoad ; get the CPU load percentage
	sta CPUPercentage
	lsr @ ; divide it by 2
	sta Temp1
	jsr ShiftBitMap1Left
	jsr ShiftBitMap2Left
	jsr UpdateStats

	ldx Temp1 ; draw CPU graph
	cpx PreviousCPUPercentage
	bcs IsHigher
Loop1
	ldy Lookup,x
	lda BitMap1Data-1,y
	and #$FD
	sta BitMap1Data-1,y
	inx
	cpx PreviousCPUPercentage
	bcc Loop1
	jmp Done
IsHigher
	ldy Lookup,x
	lda BitMap1Data-1,y
	and #$FD
	sta BitMap1Data-1,y
	dex
	cpx PreviousCPUPercentage
	beq Done
	bcs IsHigher
Done
	mva Temp1 PreviousCPUPercentage
	
	ldx Temp3 ; draw memory graph
	cpx PreviousPercentUsedRAM
	bcs IsHigher2
Loop2
	ldy Lookup,x
	lda BitMap2Data-1,y
	and #$FD
	sta BitMap2Data-1,y
	inx
	cpx PreviousPercentUsedRAM
	bcc Loop2
	jmp Done2
IsHigher2
	ldy Lookup,x
	lda BitMap2Data-1,y
	and #$FD
	sta BitMap2Data-1,y
	dex
	cpx PreviousPercentUsedRAM
	beq Done2
	bcs IsHigher2
Done2
	mva Temp3 PreviousPercentUsedRAM
	
	lda Tab1Data+1 ; see which tab we're on
	cmp #2
	bne NotMetersTab
	
	lda CPUPercentage
	ldxy #String4Text
	jsr PrintPercentage
	sta String4[0].Width
	lda PercentUsedRAM
	ldxy #String5Text
	jsr PrintPercentage
	sta String5[0].Width
	mva Window1ID MessageBuffer+1 ; redraw 4 controls
	mva #4 MessageBuffer+2 ; first control ID
	mva #9 MessageBuffer+3 ; number of controls - 1
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
	jmp Finished	

NotMetersTab
	cmp #1
	bne NotProcessTab
	
UpdateProcessTab
	jsr CreateProcessList
	beq Finished ; if nothing's changed, just exit

	mva Window1ID MessageBuffer+1 ; redraw list control
	mva #3 MessageBuffer+2
	mva #0 MessageBuffer+3 ; number of controls - 1
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
	jmp Finished

NotProcessTab ; we're on the application tab
	jsr CreateAppList
	beq Finished

	mva Window1ID MessageBuffer+1 ; redraw list control
	mva #3 MessageBuffer+2
	mva #0 MessageBuffer+3 ; number of controls - 1
	mva #Desk.WindRedrawControl MessageBuffer ; function
	jsr SendMsgDeskMgr ; send message
	
Finished
	lda #150
	ldxy #0
	SysCall Kernel.Sleep
	jmp Loop

; ----------------------------------------------------------------------------
; Send message to the desktop manager
; ----------------------------------------------------------------------------

	.proc SendMsgDeskMgr
	lda #ProcessID.DesktopManager ; receiver ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend ; send message		
	rts
	.endp

; ----------------------------------------------------------------------------
; Sleep on message from desktop manager
; ----------------------------------------------------------------------------

	.proc SleepMsgDeskMgr
	lda #ProcessID.DesktopManager ; sender ID
	ldxy #MessageBuffer
	SysCall Kernel.MessageSleepReceive ; sleep on response from desktop manager only
	rts
	.endp
	
//
//	Send message to kernel
//

	.proc SendMsgKernel
	lda #ProcessID.Kernel
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend
	rts
	.endp

//
//	Receive message from Kernel and sleep while waiting
//

	.proc GetMsgKernel
	lda #ProcessID.Kernel
	ldxy #MessageBuffer
	SysCall Kernel.MessageSleepReceive
	rts
	.endp
	
; ----------------------------------------------------------------------------
; Update Meter tab stats
; ----------------------------------------------------------------------------
	
	.proc UpdateStats

	lda SysInfoBuffer+SystemInfo.Processes
	sta NumTasks
	lda SysInfoBuffer+SystemInfo.Applications
	sta NumApps
	lda SysInfoBuffer+SystemInfo.Timers
	sta NumTimers
	mwa SysInfoBuffer+SystemInfo.TotalRAM TotalRAM
	mwa SysInfoBuffer+SystemInfo.FreeRAM FreeRAM
	sbw TotalRAM FreeRAM UsedRAM
;	lda SysInfoBuffer+SystemInfo.Services
;	sta NumServices

	lda #NumberType.w8Bit
	ldx #0
	SysCall Kernel.ConvertNumToString
	.word NumApps,String9Text

	lda #NumberType.w8Bit
	ldx #0
	SysCall Kernel.ConvertNumToString
	.word NumTasks,String10Text

	lda #NumberType.w8Bit
	ldx #0
	SysCall Kernel.ConvertNumToString
	.word NumTimers,String11Text
	
	lda #NumberType.w16Bit
	ldx #128
	SysCall Kernel.ConvertNumToString
	.word TotalRAM,String12Text
	
	lda #NumberType.w16Bit
	ldx #128
	SysCall Kernel.ConvertNumToString
	.word UsedRAM,String13Text
	
	lda #NumberType.w16Bit
	ldx #128
	SysCall Kernel.ConvertNumToString
	.word FreeRAM,String14Text
	
	rts

NumTasks
	.byte 0
NumApps
	.byte 0
NumTimers
	.byte 0
NumServices
	.byte 0
TotalRAM
	.word 0
FreeRAM
	.word 0
UsedRAM
	.word 0
	.endp
	
	
; ----------------------------------------------------------------------------
; Rotate bitmap left
; ----------------------------------------------------------------------------

	.proc ShiftBitmap1Left
	ldy #51
Loop
	ldx LookUp,y
	lda BitMap1Data+4,x
	pha
	and #1 ; keep low bit
	sta @@ptr4
	pla
	asl
	ora #2
	ora @@ptr4
	sta BitMap1Data+4,x
	rol BitMap1Data+3,x
	rol BitMap1Data+2,x
	rol BitMap1Data+1,x
	lda BitMap1Data,x
	pha
	and #128
	sta @@ptr4
	pla
	rol
	and #127
	ora @@ptr4
	sta BitMap1Data,x
	dey
	bpl Loop
	rts
	.endp

	
; ----------------------------------------------------------------------------
; Rotate bitmap left
; ----------------------------------------------------------------------------

	.proc ShiftBitmap2Left
	ldy #51
Loop
	ldx LookUp,y
	lda BitMap2Data+4,x
	pha
	and #1 ; keep low bit
	sta @@ptr4
	pla
	asl
	ora #2
	ora @@ptr4
	sta BitMap2Data+4,x
	rol BitMap2Data+3,x
	rol BitMap2Data+2,x
	rol BitMap2Data+1,x
	lda BitMap2Data,x
	pha
	and #128
	sta @@ptr4
	pla
	rol
	and #127
	ora @@ptr4
	sta BitMap2Data,x
	dey
	bpl Loop
	rts
	.endp
	
; ----------------------------------------------------------------------------
; Get Idle process CPU usage
; ----------------------------------------------------------------------------

	.proc GetCPULoad
	mwa #SampleBuffer @@pz1
Loop
	ldy #ProcessInfo.PID
	lda (@@pz1),y
	cmp #ProcessID.Idle ; look for Idle process in list
	beq GotIdle
	adw @@pz1 #.len[ProcessInfo]
	bne Loop
GotIdle
	ldy #ProcessInfo.CPUUsage
	lda #100
	sec
	sbc (@@pz1),y
	cmp #101
	bcc @+
	lda #100
@
	rts
	.endp
	
//
//	Calculate percentage memory load
//

	.proc CalculateMemoryLoad
	sbw SysInfoBuffer[0].TotalRAM SysInfoBuffer[0].FreeRAM UsedRAM
	lda UsedRAM ; multiply used RAM by 64
	ldy #5
@
	asl @
	rol UsedRAM+1
	dey
	bpl @-
	sta UsedRAM
	mwa UsedRAM @@ptr1
	mwa SysInfoBuffer[0].TotalRAM @@ptr2
	jsr DivWord
	stax @@ptr1
	mwa #100 @@ptr2
	jsr MulWord
	lda @@ptr3
	ldy #5 ; divide result by 64
@
	lsr @@ptr3+1
	ror @
	dey
	bpl @-
	clc
	adc #1 ; kludge!
	cmp #101
	bcc @+
	lda #100
@
	rts
	.endp
	
	
//
//	Divide @@ptr1 by @@ptr2 and place result in @@ptr3 and a,x
//	Remainder is left in @@ptr4
//

	.proc DivWord
	lda #0	        ;preset remainder to 0
	sta @@ptr4
	sta @@ptr4+1
	ldx #16	        ;repeat for each bit: ...
divloop
	asl @@ptr1	;dividend lb & hb*2, msb -> Carry
	rol @@ptr1+1	
	rol @@ptr4	;remainder lb & hb * 2 + msb from carry
	rol @@ptr4+1
	lda @@ptr4
	sec
	sbc @@ptr2	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda @@ptr4+1
	sbc @@ptr2+1
	bcc skip	;if carry=0 then divisor didn't fit in yet

	sta @@ptr4+1	;else save substraction result as new remainder,
	sty @@ptr4	
	inc @@ptr1	;and INCrement result cause divisor fit in 1 times

skip	dex
	bne divloop	
	lda @@ptr1
	sta @@ptr3
	ldx @@ptr1+1
	stx @@ptr3+1
	rts
	.endp
	

//
//	Multiply @@ptr1 by @@ptr2, storing result in @@ptr3 and a,x
//

	.proc MulWord
	lda #0
	sta @@ptr3+2 ; clear upper bits of product
	sta @@ptr3+3
	ldx #16 ; loop for each bit
multloop
	lsr @@ptr1+1 ; divide multiplier by 2
	ror @@ptr1
	bcc rotate

	lda @@ptr3+2 ; get upper half of product and add multiplicand
	clc
	adc @@ptr2
	sta @@ptr3+2

	lda @@ptr3+3
	adc @@ptr2+1
rotate
	ror ; rotate partial product 
	sta @@ptr3+3
	ror @@ptr3+2
	ror @@ptr3+1
	ror @@ptr3
	dex
	bne multloop
	lda @@ptr3
	ldx @@ptr3+1
	rts
	.endp	
	
; ----------------------------------------------------------------------------
; Update percentage value
; pass value in A
; buffer in x,y
; ----------------------------------------------------------------------------

	.proc PrintPercentage
	stxy @@pz1
	sta @@pz2
	ldx #0 ; tens counter
	ldy #0
	cmp #100
	bcc @+
	pha
	lda #'1'
	sta (@@pz1),y
	iny
	pla
	sec
	sbc #100
@
	cmp #10
	bcc @+
	sbc #10
	inx ; bump tens
	bne @-
@
	cpx #0
	bne GotTens
	cpy #0
	beq Units
GotTens
	pha
	txa
	clc
	adc #'0'
	sta (@@pz1),y
	iny
	pla
Units
	clc
	adc #'0'
	sta (@@pz1),y
	iny
	lda #'%'
	sta (@@pz1),y
	iny
	lda #0
	sta (@@pz1),y
	lda StringLengthTable-2,y
	rts
	.endp
	
	
; ----------------------------------------------------------------------------
; Create application list
; ----------------------------------------------------------------------------

	.proc CreateAppList
	mva #128 ListTitle2Data[0].Flags
	lsr SelectionFlag
	mwa #List2Data @@pz2
	ldx ListTitle2Data[0].Lines ; first we need to see if any item has selection flag set
	ldy #1 ; checking bit 15 (selection flag)
Loop
	lda (@@pz2),y
	bmi @+ ; found it
	adw @@pz2 #8 ; next item
	dex
	bne Loop
	beq BuildList
@
	and #$7F
	sta @@pz4+1
	dey
	lda (@@pz2),y ; get lsb of ID
	sta @@pz4
	sec
	ror SelectionFlag
	
BuildList	
	mwa #SampleBuffer @@pz1 ; source data
	mwa #List2Data @@pz2 ; list pointers
	mwa #List2DataBuffer @@pz3 ; strings
	mva #0 Temp1 ; number of items
Loop1
	ldy #17 ; get process type
	lda (@@pz1),y
	and #127
	jne Next ; if not application
	ldy #0
	lda (@@pz1),y
	jeq Done
Loop2
	lda (@@pz1),y ; copy task name
	sta (@@pz3),y
	beq @+
	iny
	cpy #16
	bcc Loop2
@
	lda #0
	sta (@@pz3),y
	iny
	tya
	pha ; save length

	ldy #ProcessInfo.SequenceID+1 ; see if this is the item selected in the list
	lda (@@pz1),y
	tax ; save MSB
	dey
	lda (@@pz1),y ; get LSB
	ldy #0
	sta (@@pz2),y ; set item ID
	bit SelectionFlag
	bpl @+
	cmp @@pz4
	bne @+
	cpx @@pz4+1
	bne @+
	txa
	ora #$80
	tax
	lsr SelectionFlag
@
	iny
	txa
	sta (@@pz2),y

	lda @@pz3 ; get pointer to string
	ldy #2 ; first data pointer for this row
	sta (@@pz2),y
	iny
	lda @@pz3+1
	sta (@@pz2),y
	
	pla
	clc
	adc @@pz3
	sta @@pz3
	bcc @+
	inc @@pz3+1
@
	ldy #16 ; get PID - this is stored directly in the row data (no pointer needed)
	lda (@@pz1),y
	ldy #4
	sta (@@pz2),y
	lda #0
	iny
	sta (@@pz2),y
	
	ldy #21 ; get RAM
	lda (@@pz1),y
	ldy #7
	sta (@@pz2),y
	lda #0
	dey
	sta (@@pz2),y
	
	inc Temp1
	adw @@pz2 #8
Next
	adw @@pz1 #.len[ProcessInfo]
	jmp Loop1
Done
	mva Temp1 ListTitle2Data[0].Lines
	mva #255 ListTitle2Data[0].LastClickedLine
	mva #64 ListTitle2Data[0].Flags
	lda #1
	rts
	.endp
	

SelectionFlag
	.byte 0
List2DataBuffer
	.rept 513
	.byte 0
	.endr

; ----------------------------------------------------------------------------
; Create Processes List
; ----------------------------------------------------------------------------

	.proc CreateProcessList
	mva #128 ListTitle1Data[0].Flags
	lsr SelectionFlag
	mwa #List1Data @@pz2
	ldx ListTitle1Data[0].Lines ; first we need to see if any item has selection flag set
	ldy #1 ; checking bit 15 (selection flag)
Loop
	lda (@@pz2),y
	bmi @+ ; found it
	adw @@pz2 #12 ; next item
	dex
	bne Loop
	beq BuildList
@
	and #$7F
	sta @@pz4+1
	dey
	lda (@@pz2),y ; get lsb of ID
	sta @@pz4
	sec
	ror SelectionFlag ; set flag
	
BuildList
	mwa #SampleBuffer @@pz1 ; source data
	mwa #List1Data @@pz2 ; list pointers
	mwa #List1DataBuffer @@pz3 ; strings
	mva #0 Temp1 ; number of items
Loop1
	ldy #0
	lda (@@pz1),y
	jeq Done
Loop2
	lda (@@pz1),y
	sta (@@pz3),y
	beq @+
	iny
	cpy #16
	bcc Loop2
@
	lda #0
	sta (@@pz3),y
	iny
	tya
	pha ; save length

	ldy #ProcessInfo.SequenceID+1 ; see if this is the item selected in the list
	lda (@@pz1),y
	tax ; save MSB
	dey
	lda (@@pz1),y ; get LSB
	ldy #0
	sta (@@pz2),y ; set item ID
	bit SelectionFlag
	bpl @+
	cmp @@pz4
	bne @+
	cpx @@pz4+1
	bne @+
	txa
	ora #$80
	tax
	lsr SelectionFlag
@
	iny
	txa
	sta (@@pz2),y

	lda @@pz3 ; get pointer to string
	ldy #2 ; first data pointer for this row
	sta (@@pz2),y
	iny
	lda @@pz3+1
	sta (@@pz2),y
	
	pla ; get string length
	clc
	adc @@pz3
	sta @@pz3
	bcc @+
	inc @@pz3+1
@
	ldy #16 ; get PID - this is stored directly in the row data (no pointer needed)
	lda (@@pz1),y
	ldy #4
	sta (@@pz2),y
	lda #0
	iny
	sta (@@pz2),y
	
	ldy #18 ; get priority
	lda (@@pz1),y
	ldy #6
	sta (@@pz2),y
	lda #0
	iny
	sta (@@pz2),y
	
	ldy #19
	lda (@@pz1),y ; get status
	asl
	asl
	asl
	clc
	adc < ProcessStatusTab
	ldy #8
	sta (@@pz2),y
	lda #0
	adc > ProcessStatusTab
	iny
	sta (@@pz2),y
	
	ldy #20 ; get CPU load
	lda (@@pz1),y
	ldy #10
	sta (@@pz2),y
	iny
	lda #0
	sta (@@pz2),y
	
	inc Temp1
	adw @@pz1 #.len[ProcessInfo]
	adw @@pz2 #12
	jmp Loop1
Done
	mva Temp1 ListTitle1Data[0].Lines
	mva #255 ListTitle1Data[0].LastClickedLine
	mva #64 ListTitle1Data[0].Flags
	lda #1
	rts
	.endp
	
	
ProcessStatusTab
	.byte 'Sleep',0,0,0
	.byte 'Idle',0,0,0,0
	.byte 'Ready',0,0,0
	
List1DataBuffer
	.rept 513
	.byte 0
	.endr
	
StringLengthTable
	.byte 13,19,25
	

AppAbout
AppPreferences
AppQuit
	rts
	
	
FileExport
FilePrint
FilePrintSetup
	rts
	
	
EditCopy
EditCut
EditPaste
EditSelectAll
	rts
	
	
ViewFilterProcesses
ViewProcessInfo
ViewSampleProcess
ViewKillProcess
ViewSendMessage
ViewClearHistory
	rts
	
	
ViewGraphStyleLine
ViewGraphStyleBlock
	rts
	
ViewUpdateFrequencySlow
ViewUpdateFrequencyNormal
ViewUpdateFrequencyFast
	rts
	
	
WindowDefault
	rts
	
HelpView
	rts

; ----------------------------------------------------------------------------------------------------
; Application menu bar
; ----------------------------------------------------------------------------------------------------

MenuBarMain
	.byte 6
MenuMain1	dta MenuItem [0] (1+4, txtMenuApp, MenuApp, 0)
MenuMain2	dta MenuItem [0] (1+4, txtMenuFile, MenuFile, 0)
MenuMain3	dta MenuItem [0] (1+4, txtMenuEdit, MenuEdit, 0)
MenuMain4	dta MenuItem [0] (1+4, txtMenuView, MenuView, 0)
MenuMain5	dta MenuItem [0] (1+4, txtMenuWindow, MenuWindow, 0)
MenuMain6	dta MenuItem [0] (1+4, txtMenuHelp, MenuHelp, 0)


txtMenuApp
	.byte 'Profiler',0
txtMenuFile
	.byte 'File',0
txtMenuEdit
	.byte 'Edit',0
txtMenuView
	.byte 'View',0
txtMenuWindow
	.byte 'Window',0
txtMenuHelp
	.byte 'Help',0


MenuApp
	.byte 4
	.word 0,0
MenuApp1	dta MenuItem [0] (1, txtMenuApp1, AppAbout, 0)
MenuApp2	dta MenuItem [0] (1+8, 0, 0, 0)
MenuApp3	dta MenuItem [0] (1, txtMenuApp2, AppPreferences, 0)
MenuApp4	dta MenuItem [0] (1, txtMenuApp3, AppQuit, 0)

txtMenuApp1	.byte 'About Profiler',0
txtMenuApp2	.byte 'Preferences',0
txtMenuApp3	.byte 'Quit Profiler',0
	
	
	
MenuFile
	.byte 4 ; # items
	.word 0,0
MenuFile1	dta MenuItem [0] (1, txtMenuFile1, FileExport, 0)
MenuFile2	dta MenuItem [0] (1, txtMenuFile2, FilePrint, 0)
MenuFile3	dta MenuItem [0] (1+8, 0, 0, 0)
MenuFile4	dta MenuItem [0] (1, txtMenuFile4, FilePrintSetup, 0)
	
txtMenuFile1
	.byte 'Export/',CTRL_MODIFIER,'E',0
txtMenuFile2
	.byte '&Print.../',CTRL_MODIFIER,'P',0
txtMenuFile4
	.byte 'Page Setup...',0



MenuEdit
	.byte 5
	.word 0,0
MenuEdit1	dta MenuItem [0] (0, txtMenuEdit1, EditCut, 0)
MenuEdit2	dta MenuItem [0] (0, txtMenuEdit2, EditCopy, 0)
MenuEdit3	dta MenuItem [0] (1, txtMenuEdit3, EditPaste, 0)
MenuEdit4	dta MenuItem [0] (1+8, 0, 0, 0)
MenuEdit5	dta MenuItem [0] (1, txtMenuEdit5, EditSelectAll, 0)

txtMenuEdit1
	.byte 'Cu&t/',CTRL_MODIFIER,'X',0
txtMenuEdit2
	.byte '&Copy/',CTRL_MODIFIER,'C',0
txtMenuEdit3
	.byte '&Paste/',CTRL_MODIFIER,'V',0
txtMenuEdit5
	.byte 'Select &All/',CTRL_MODIFIER,'A',0



MenuView
	.byte 10
	.word 0,0
MenuView1	dta MenuItem [0] (1+4, txtMenuView1, MenuViewGraphStyle, 0)
MenuView2	dta MenuItem [0] (1+4, txtMenuView2, MenuViewUpdateFrequency, 0)
MenuView3	dta MenuItem [0] (1+8, 0, 0, 0)
MenuView4	dta MenuItem [0] (1, txtMenuView4, ViewFilterProcesses, 0)
MenuView5	dta MenuItem [0] (1, txtMenuView5, ViewProcessInfo, 0)
MenuView6	dta MenuItem [0] (1, txtMenuView6, ViewSampleProcess, 0)
MenuView7	dta MenuItem [0] (1, txtMenuView7, ViewKillProcess, 0)
MenuView8	dta MenuItem [0] (1, txtMenuView8, ViewSendMessage, 0)
MenuView9	dta MenuItem [0] (1+8, 0, 0, 0)
MenuView10	dta MenuItem [0] (1, txtMenuView10, ViewClearHistory, 0)


txtMenuView1
	.byte 'Graph Style',0
txtMenuView2
	.byte 'Update Frequency',0
txtMenuView4
	.byte 'Filter Processes',0
txtMenuView5
	.byte 'Process Info',0
txtMenuView6
	.byte 'Sample Process',0
txtMenuView7
	.byte 'Kill Process',0
txtMenuView8
	.byte 'Send Message',0
txtMenuView10
	.byte 'Clear History',0
	



MenuViewGraphStyle ; cascading menu
	.byte 2
	.word 0,0
MenuViewGraphStyle1	dta MenuItem [0] (1+2, txtMenuViewGraphStyle1, ViewGraphStyleLine, 0)
MenuViewGraphStyle2	dta MenuItem [0] (1, txtMenuViewGraphStyle2, ViewGraphStyleBlock, 0)

txtMenuViewGraphStyle1
	.byte 'Line Graph',0
txtMenuViewGraphStyle2
	.byte 'Block Graph',0



MenuViewUpdateFrequency ; cascading menu
	.byte 3
	.word 0,0
MenuViewUpdateFrequency1	dta MenuItem [0] (1, txtMenuViewUpdateFrequency1, ViewUpdateFrequencySlow, 0)
MenuViewUpdateFrequency1	dta MenuItem [0] (1+2, txtMenuViewUpdateFrequency2, ViewUpdateFrequencyNormal, 0)
MenuViewUpdateFrequency2	dta MenuItem [0] (1, txtMenuViewUpdateFrequency3, ViewUpdateFrequencyFast, 0)

txtMenuViewUpdateFrequency1
	.byte 'Slow',0
txtMenuViewUpdateFrequency2
	.byte 'Normal',0
txtMenuViewUpdateFrequency3
	.byte 'Fast',0


MenuWindow
	.byte 1
	.word 0,0
MenuWindow1	dta MenuItem [0] (1, txtMenuWindow1, WindowDefault, 0)	

txtMenuWindow1
	.byte 'Default',0


MenuHelp
	.byte 1
	.word 0,0
MenuHelp1	dta MenuItem [0] (1, txtMenuHelp1, HelpView, 0)

txtMenuHelp1
	.byte 'View &Help',0




; ----------------------------------------------------------------------------------------------------
; Window records
; ----------------------------------------------------------------------------------------------------

		
Window1ID
	.byte 0
	

Window1	dta WindowData [0] (0, WindowFlags.CloseBtn + WindowFlags.TitleBar , \
			0, WindowAppearance.DropShadow, 0, 170, 30, 144, 148, \	; attrib, style, process ID, x, y, width, height
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 144, 128, 96, 96, 320, 200, 0, \		; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			txtWindow1Title, 0, Window1ControlListTab2)
			
txtWindow1Title
	.byte 'Profiler',0
	
; ----------------------------------------------------------------------------------------------------
; Programs tab
; ----------------------------------------------------------------------------------------------------

Window1ControlListTab0 dta ControlGroup [0] (7, 0, Tab0Controls, 0, 0, 0, 0)

Tab0Controls
Tab0Background	dta ControlData [0] (0, ctl.SolidRect, 0, 0, 0, 0, $FFFF, $FFFF) ; fill whole client with solid white rectangle
Tab0Tab1	dta ControlData [0] (0, ctl.TabControl, 0, Tab1Data, 0, 1, 144, 14)

ListBoxTTl2	dta ControlData [0] (0, ctl.ListTitle, 0, ListTitle2Data, 3, 19, 138, 13)
ListBox2	dta ControlData [0] (0, ctl.ListContent, 0, ListTitle2Data, 3, 30, 138, 78)
CmdButton4	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton4Data, 3, 112, 42, 16)
CmdButton5	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton5Data, 51, 112, 42, 16)
CmdButton6	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton6Data, 99, 112, 42, 16)

ListTitle2Data	dta ListTitle [0] (0, 0, List2Data, 3, 0, List2ColumnData, 255, ListOptions.Slider, 0)

List2ColumnData
List2Column1 dta ListColumn [0] (ListColumnType.Text + ListColumnAlignment.Left, 72, List2Column1Data) ; string, left aligned, 9 bytes
List2Column2 dta ListColumn [0] (ListColumnType.Num8Bit + ListColumnAlignment.Centre, 16, List2Column2Data) ; 8-bit number, centre aligned, 1 byte
List2Column3 dta ListColumn [0] (ListColumnType.Num16Bit + ListColumnAlignment.Right, 38, List2Column3Data) ; 16-bit number, right aligned, 2 bytes

List2Column1Data
	.byte 'Name',0
List2Column2Data
	.byte 'PID',0
List2Column3Data
	.byte 'RAM',0
	
List2Data ; actual list data starts here
	.rept 256
	.byte 0
	.endr

	
CmdButton4Data dta CommandButton [0] (0, CmdButton4Text)
CmdButton4Text
	.byte 'Update',0
	
CmdButton5Data dta CommandButton [0] (0, CmdButton5Text)
CmdButton5Text
	.byte 'Switch',0
	
CmdButton6Data dta CommandButton [0] (0, CmdButton6Text)
CmdButton6Text
	.byte 'Close',0

; ----------------------------------------------------------------------------------------------------
; Processes tab
; ----------------------------------------------------------------------------------------------------

Window1ControlListTab1 dta ControlGroup [0] (7, 0, Tab1Controls, 0, 0, 0, 0)

Tab1Controls
Tab1Background	dta ControlData [0] (0, ctl.SolidRect, 0, 0, 0, 0, $FFFF, $FFFF) ; fill whole client with solid white rectangle
Tab1Tab1	dta ControlData [0] (0, ctl.TabControl, 0, Tab1Data, 0, 1, 144, 14)

ListBoxTTl1	dta ControlData [0] (0, ctl.ListTitle, 0, ListTitle1Data, 3, 19, 138, 13)
ListBox1	dta ControlData [0] (0, ctl.ListContent, 0, ListTitle1Data, 3, 30, 138, 78)
CmdButton1	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton1Data, 3, 112, 42, 16)
CmdButton2	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton2Data, 51, 112, 42, 16)
CmdButton3	dta ControlData [0] (0, ctl.CommandButton, 0, CmdButton3Data, 99, 112, 42, 16)

ListTitle1Data	dta ListTitle [0] (0, 0, List1Data, 5, 0, List1ColumnData, 255, ListOptions.Slider, 0)

List1ColumnData
List1Column1 dta ListColumn [0] (ListColumnType.Text + ListColumnAlignment.Left, 42, List1Column1Data) ; string, left aligned, 9 bytes
List1Column2 dta ListColumn [0] (ListColumnType.Num8Bit + ListColumnAlignment.Centre, 13, List1Column2Data) ; 8-bit number, centre aligned, 1 byte
List1Column3 dta ListColumn [0] (ListColumnType.Num8Bit + ListColumnAlignment.Centre, 14, List1Column3Data) ; 8-bit number, centre aligned, 1 byte
List1Column4 dta ListColumn [0] (ListColumnType.Text + ListColumnAlignment.Left, 30, List1Column4Data) ; string, left aligned, 6 bytes
List1Column5 dta ListColumn [0] (ListColumnType.Num8Bit + ListColumnAlignment.Right, 25, List1Column5Data) ; 8-bit number, right aligned, 1 byte

List1Column1Data
	.byte 'Name',0
List1Column2Data
	.byte 'ID',0
List1Column3Data
	.byte 'Pri',0
List1Column4Data
	.byte 'Status',0
List1Column5Data
	.byte '%CPU',0
	
List1Data ; list row data records start here
	.rept 16*12 ; max sixteen processes, each with 5 columns plus 2 byte row header
	.byte 0
	.endr
	
CmdButton1Data dta CommandButton [0] (0, CmdButton1Text)
CmdButton1Text
	.byte 'Update',0
	
CmdButton2Data dta CommandButton [0] (0, CmdButton2Text)
CmdButton2Text
	.byte 'Sleep',0
	
CmdButton3Data dta CommandButton [0] (0, CmdButton3Text)
CmdButton3Text
	.byte 'Kill',0


; ----------------------------------------------------------------------------------------------------
; Meters tab
; ----------------------------------------------------------------------------------------------------

Window1ControlListTab2 dta ControlGroup [0] (26, 0, Tab2Controls, 0, 0, 0, 0)

Tab2Controls
Tab2Background	dta ControlData [0] (0, ctl.SolidRect, 0, 0, 0, 0, $FFFF, $FFFF) ; fill whole client with solid white rectangle
Tab2Tab1	dta ControlData [0] (0, ctl.TabControl, 0, Tab1Data, 0, 1, 144, 14)
Frame1	dta ControlData [0] (0, ctl.TitledFrame, 0 , Frame1Data, 5, 22, 63, 65)
Frame2	dta ControlData [0] (0, ctl.TitledFrame, 0 , Frame2Data, 76, 22, 63, 65)

BitMap1	dta ControlData [0] (0, ctl.BitMap, 0, BitMap1Hdr, 24, 28, 40, 53)
String4	dta ControlData [0] (0, ctl.TextString, 0, String4Data, 24, 28, 40, 8)

BitMap2	dta ControlData [0] (0, ctl.BitMap, 0, BitMap2Hdr, 95, 28, 40, 52)
String5	dta ControlData [0] (0, ctl.TextString, 0, String5Data, 95, 28, 40, 8)

String9	dta ControlData [0] (0, ctl.TextString, 0, String9Data, 52, 98, 12, 8)
String10 dta ControlData [0] (0, ctl.TextString, 0, String10Data, 52, 107, 12, 8)
String11 dta ControlData [0] (0, ctl.TextString, 0, String11Data, 52, 116, 12, 8)

String12 dta ControlData [0] (0, ctl.TextString, 0, String12Data, 110, 98, 25, 8)
String13 dta ControlData [0] (0, ctl.TextString, 0, String13Data, 110, 107, 25, 8)
String14 dta ControlData [0] (0, ctl.TextString, 0, String14Data, 110, 116, 25, 8)

String1	dta ControlData [0] (0, ctl.TextString, 0, String1Data, 8, 98, 40, 8)
String2 dta ControlData [0] (0, ctl.TextString, 0, String2Data, 8, 107, 40, 8)
String3 dta ControlData [0] (0, ctl.TextString, 0, String3Data, 8, 116, 40, 8)

String6	dta ControlData [0] (0, ctl.TextString, 0, String6Data, 79, 98, 32, 8)
String7	dta ControlData [0] (0, ctl.TextString, 0, String7Data, 79, 107, 32, 8)
String8 dta ControlData [0] (0, ctl.TextString, 0, String8Data, 79, 116, 32, 8)

BitMap3 dta ControlData [0] (0, ctl.BitMap, 0, BitMap4Hdr, 10, 28, 14, 53) 
BitMap4	dta ControlData [0] (0, ctl.BitMap, 0, BitMap4Hdr, 81, 28, 14, 53)

Frame3	dta ControlData [0] (0, ctl.TitledFrame, 0, Frame3Data, 5, 93, 63, 35)
Frame4	dta ControlData [0] (0, ctl.TitledFrame, 0, Frame4Data, 76, 93, 63, 35)


String1Data dta TextStringControl [0] (String1Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String1Text	.byte 'Apps',0

String2Data dta TextStringControl [0] (String2Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String2Text	.byte 'Tasks',0

String3Data dta TextStringControl [0] (String3Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String3Text	.byte 'Timers',0

String6Data dta TextStringControl [0] (String6Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String6Text	.byte 'Total',0

String7Data dta TextStringControl [0] (String7Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String7Text	.byte 'Used',0

String8Data dta TextStringControl [0] (String8Text, TextStringFlags.Transparent, DrawColour.Black, 0)
String8Text	.byte 'Free',0


; ----------------------------------------------------------------------------------------------------
; Task and memory totals
; ----------------------------------------------------------------------------------------------------

String9Data dta TextStringControl [0] (String9Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String9Text	.byte 0,0,0,0

String10Data dta TextStringControl [0] (String10Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String10Text	.byte 0,0,0,0

String11Data dta TextStringControl [0] (String11Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String11Text	.byte 0,0,0,0
	
String12Data dta TextStringControl [0] (String12Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String12Text	.byte 0,0,0,0,0,0,0,0

String13Data dta TextStringControl [0] (String13Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String13Text	.byte 0,0,0,0,0,0,0,0

String14Data dta TextStringControl [0] (String14Text, TextStringFlags.RightAlign, DrawColour.Black, DrawColour.White)
String14Text	.byte 0,0,0,0,0,0,0,0

; overlays for graphs

String4Data dta TextStringControl [0] (String4Text, 0, DrawColour.White, DrawColour.Black)
String4Text	.byte 0,0,0,0,0

String5Data dta TextStringControl [0] (String5Text, 0, DrawColour.White, DrawColour.Black)
String5Text	.byte 0,0,0,0,0
	
	

Tab1Data
	.byte 3 ; number of tabs
	.byte 2 ; selected tab
	.word Tab1Label1Text
	.byte 0 ; tab width (computed by UI)
	.word Tab1Label2Text
	.byte 0
	.word Tab1Label3Text
	.byte 0
	
Tab1Label1Text
	.byte 'Applications',0
Tab1Label2Text
	.byte 'Processes',0
Tab1Label3Text
	.byte 'Monitor',0

Frame1Data
	.word Frame1Text
	.byte 0 ; colour information (currently unused)

Frame1Text
	.byte 'CPU',0

BitMap1Hdr	dta BitMap [0] (5, 40, 53)
	.byte 255,255,255,255,255
BitMap1Data
	.rept 260
	.byte 255
	.endr
	
Frame2Data
	.word Frame2Text
	.byte 0 ; colour information (currently unused)

Frame2Text
	.byte 'Memory',0

BitMap2Hdr	dta BitMap [0] (5, 40, 53)
	.byte 255,255,255,255,255
BitMap2Data
	.rept 260
	.byte 255
	.endr


BitMap3Hdr	dta BitMap [0] (1, 3, 53)
	.byte %11100000
	.byte %10100000
	.rept 12
	.byte %11100000
	.endr
	.byte %10100000
	.rept 11
	.byte %11100000
	.endr
	.byte %10100000
	.rept 11
	.byte %11100000
	.endr
	.byte %10100000
	.rept 12
	.byte %11100000
	.endr
	.byte %10100000
	.byte %11100000
	
	
BitMap4Hdr	dta BitMap [0] (2, 14, 53)
	.byte %01000100,%01000000
	.byte %11001010,%10100000
	.byte %01001010,%10100100
	.byte %01001010,%10100000
	.byte %11100100,%01000000
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0
	.byte %00001110,%11100000
	.byte %00000010,%10000000
	.byte %00000100,%11000100
	.byte %00000100,%00100000
	.byte %00000100,%11000000
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0
	.byte %00001110,%01000000
	.byte %00001000,%10100000
	.byte %00001100,%10100100
	.byte %00000010,%10100000
	.byte %00001100,%01000000
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0
	.byte %00001100,%11100000
	.byte %00000010,%10000000
	.byte %00000100,%11000100
	.byte %00001000,%00100000
	.byte %00001110,%11000000
	.byte 0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0
	.byte %00000000,%01000000
	.byte %00000000,%10100000
	.byte %00000000,%10100100
	.byte %00000000,%10100000
	.byte %00000000,%01000000

Frame3Data
	.word Frame3Text
	.byte 0
	
Frame3Text
	.byte 'Totals',0
	
Frame4Data
	.word Frame4Text
	.byte 0

Frame4Text
	.word 'RAM (KB)',0
	

TabLUT
	.word Window1ControlListTab0
	.word Window1ControlListTab1
	.word Window1ControlListTab2
	
Lookup
	.byte 255
	.byte 250,245,240,235,230,225,220,215,210,205
	.byte 200,195,190,185,180,175,170,165,160,155
	.byte 150,145,140,135,130,125,120,115,110,105
	.byte 100,95,90,85,80,75,70,65,60,55
	.byte 50,45,40,35,30,25,20,15,10,5,0

CPUSampleCount
	.byte 0
MemorySampleCount
	.byte 0
CPUPercentage
	.byte 0
RAMPercentage
	.byte 0
PreviousCPUPercentage
	.byte 0
PreviousMemoryPercentage
	.byte 0
Temp1
	.byte 0
Temp3
	.byte 0

UsedRAM
	.word 0
PercentUsedRAM
	.byte 0
PreviousPercentUsedRAM
	.byte 0

SysInfoBuffer dta SystemInfo [0]

SampleBuffer
	.ds 512
MessageBuffer
	.ds MessageSize

	blk update address
	blk update extern
	

