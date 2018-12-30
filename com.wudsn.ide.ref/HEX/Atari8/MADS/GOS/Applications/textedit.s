;@com.wudsn.ide.asm.outputfileextension=.rom

//	Atari 8-bit GOS text editor
//	Stand-alone relocatable MADS binary
//

	icl '../Includes/guidef.s'
	icl '../Includes/macros.s'


	.reloc

JotterApp ; this block is relocated to $4000

	.byte 'Text Editor'
	.byte 0,0,0,0,0
AppFlags
	.byte 0
CodeBank
	.byte 3
PID
	.byte 0
	
	.byte 0 ; pz size

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

	.local MainLoop
Loop
	ldxy #MessageBuffer
	lda #ProcessID.Any ; see if we have a message
	SysCall Kernel.MessageSleepReceive
	bmi NoMessage
	
	cmp #ProcessID.DesktopManager
	bne NoMessage
	lda MessageBuffer
	cmp #DeskResponse.WindUserEvent
	bne NotWindUserEvent
	
	; check window ID here as well
	lda MessageBuffer+2
	cmp #DeskUserEventType.Content
	bne NotContentEvent
	
	.if 0
	
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
	cpy #1 ; process tab?
	bne NotProcessTab2
	cmp #3 ; Update button?
	bne NotProcessTab2
	jmp UpdateProcessTab
	
	.endif
	
NotWindUserEvent
	jmp MainLoop
	
NotContentEvent
	cmp #DeskUserEventType.Close ; close window?
	bne NotClose
	
	mva #Desk.WindClose MessageBuffer
	mva Window1ID MessageBuffer+4
	jsr SendMsgDeskMgr ; close the window

	jsr SleepMsgDeskMgr ; sleep till we get a response

	mva #KernelMsg.DeleteProcess MessageBuffer
	mva PID MessageBuffer+1
	jsr SendMsgKernel ; remove self from process list
AwaitDemise
	jmp AwaitDemise
	

NotClose
NoMessage
	jmp MainLoop
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
	SysCall Kernel.MessageSleepReceive
	rts
	.endl
	
//
//	Send message to kernel
//

	.local SendMsgKernel
	lda #ProcessID.Kernel
	ldxy #MessageBuffer
	SysCall Kernel.MessageSend
	rts
	.endl

//
//	Receive message from Kernel and sleep while waiting
//

	.local GetMsgKernel
	lda #ProcessID.Kernel
	ldxy #MessageBuffer
	SysCall Kernel.MessageSleepReceive
	rts
	.endl

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
	.byte 4
MenuMain1	dta MenuItem [0] (1+4, txtMenuApp, MenuApp, 0)
MenuMain2	dta MenuItem [0] (1+4, txtMenuFile, MenuFile, 0)
MenuMain5	dta MenuItem [0] (1+4, txtMenuWindow, MenuWindow, 0)
MenuMain6	dta MenuItem [0] (1+4, txtMenuHelp, MenuHelp, 0)


txtMenuApp
	.byte 'Jotter',0
txtMenuFile
	.byte 'File',0
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

txtMenuApp1	.byte 'About Jotter',0
txtMenuApp2	.byte 'Preferences',0
txtMenuApp3	.byte 'Quit Jotter',0
	
	
	
MenuFile
	.byte 4 ; # items
	.word 0,0
MenuFile1	dta MenuItem [0] (1, txtMenuFile1, FileExport, 0)
MenuFile2	dta MenuItem [0] (1, txtMenuFile2, FilePrint, 0)
MenuFile3	dta MenuItem [0] (1+8, 0, 0, 0)
MenuFile4	dta MenuItem [0] (1, txtMenuFile4, FilePrintSetup, 0)
	
txtMenuFile1
	.byte 'Open/',CTRL_MODIFIER,'O',0
txtMenuFile2
	.byte '&Print.../',CTRL_MODIFIER,'P',0
txtMenuFile4
	.byte 'Page Setup...',0


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
	

Window1	dta WindowData [0] (0, WindowFlags.CloseBtn + WindowFlags.TitleBar + WindowFlags.SizeAble, \
			0, WindowAppearance.DropShadow, 0, 16, 30, 280, 160, \	; attrib, style, process ID, x, y, width, height
			0, 0, 0, 0, \ ; client x, y, width, height
			0, 0, 320, 400, 96, 96, 320, 200, 0, \		; workxoffs, workyoffs, workwidth, workheight, minwidth, minheight, maxwidth, maxheight, appicon
			txtWindow1Title, 0, Window1ControlList)
			
txtWindow1Title
	.byte 'Jotter',0

Window1ControlList dta ControlGroup [0] (1, 0, Window1Controls, Window1CalculationRule, 0, 0, 0)

Window1Controls
TextControl1	dta ControlData [0] (0, ctl.TextControl, 0, TextControl1Data, 0, 0, $FFFF, $FFFF)


TextControl1Data dta TextControl [0] (TextControl1Buffer)

Window1CalculationRule
TextControl1CalcRule	dta CalcRule [0] (0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0) ; position 0, 0; size = width * 1 / height * 1 (fills entire form)


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




TextControl1Buffer
DemoText
;	.byte 'By William Henry Gates III',155
;	.byte 'February 3, 1976',155
;	.byte 155
;	.byte 'An Open Letter to Hobbyists',155
;	.byte 155
	.byte 'To me, the most critical thing in the hobby market right now is the lack of good software courses, books and software itself. Without good software and an owner who understands programming, a hobby computer is wasted. Will quality software be written for the hobby market?',155
	.byte 155
	.byte 'Almost a year ago, Paul Allen and myself, expecting the hobby market to expand, hired Monte Davidoff and developed Altair BASIC. Though the initial work took only two months, the three of us have spent most of the last year documenting, improving and adding features to BASIC. Now we have 4K, 8K, EXTENDED, ROM and DISK BASIC. The value of the computer time we have used exceeds $40,000.',155
	.byte 155
	.byte 'The feedback we have gotten from the hundreds of people who say they are using BASIC has all been positive. Two surprising things are apparent, however, 1) Most of these "users" never bought BASIC (less than 10% of all Altair owners have bought BASIC), and 2) The amount of royalties we have received from sales to hobbyists makes the time spent on Altair BASIC worth less than $2 an hour.',155
	.byte 155
	.byte 'Why is this? As the majority of hobbyists must be aware, most of you steal your software. Hardware must be paid for, but software is something to share. Who cares if the people who worked on it get paid?',155
	.byte 155
	.byte 'Is this fair? One thing you don',39,'t do by stealing software is get back at MITS for some problem you may have had. MITS doesn',39,'t make money selling software. The royalty paid to us, the manual, the tape and the overhead make it a break-even operation. One thing you do do is prevent good software from being written.'
	.byte ' Who can afford to do professional work for nothing? What hobbyist can put 3-man years into programming, finding all bugs, documenting his product and distribute for free? The fact is, no one besides us has invested a lot of money in hobby software. We have written 6800 BASIC, and are writing 8080 APL and 6800 APL, but there is very little incentive to make this software available to hobbyists. Most directly, the thing you do is theft.',155
	.byte 155
	.byte 'What about the guys who re-sell Altair BASIC, aren',39,'t they making money on hobby software? Yes, but those who have been reported to us may lose in the end. They are the ones who give hobbyists a bad name, and should be kicked out of any club meeting they show up at.',155
	.byte 155
	.byte 'I would appreciate letters from any one who wants to pay up, or has a suggestion or comment. Just write to me at 1180 Alvarado SE, #114, Albuquerque, New Mexico, 87108. Nothing would please me more than being able to hire ten programmers and deluge the hobby market with good software.',155
	.byte 155
	.byte 155
	.byte 'Bill Gates',155
	.byte 155
	.byte 'General Partner, Micro-Soft',155
	.byte 0

MessageBuffer
	.rept MessageSize
	.byte 0
	.endr

	blk update address
	

