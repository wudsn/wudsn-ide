;@com.wudsn.ide.asm.outputfileextension=.rom

//	Atari 8-bit GOS clock process
//	Stand-alone relocatable MADS binary
//

	icl '../Includes/guidef.s'
	icl '../Includes/macros.s'

	.reloc
	
	.byte 'Clock'
	.byte 0,0,0,0,0,0,0,0,0,0,0
AppFlags
	.byte 128 ; service
CodeBank
	.byte 2
PID
	.byte 0
	
	.byte 0 ; # of shared PZ locations


	mva #Desk.RegisterMenulet MessageBuffer ; set up menulet
	mva CodeBank MessageBuffer+1
	mwa #MenuletMain MessageBuffer+2
	jsr SendMsgDeskMgr

MainLoop
	ldxy #MessageBuffer
	lda #ProcessID.Any ; see if we have a message
	SysCall Kernel.MessageSleepReceive
	jmp MainLoop


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
	


	.local SetDateAndTime
	rts
	.endl
	
	.local SetPreferences
	rts
	.endl
	
	
; ----------------------------------------------------------------------------------------------------
; Application menulet
; ----------------------------------------------------------------------------------------------------

MenuletMain
	.byte 1 ; only one item
MenuMain1	dta MenuItem [0] (1+4, txtMenuMain, MenuMain, 0)


txtMenuMain
	.byte '00:00',0

MenuMain
	.byte 2
	.word 0,0
MenuMain1	dta MenuItem [0] (1, txtMenuMain1, SetDateAndTime, 0)
MenuMain2	dta MenuItem [0] (1, txtMenuMain2, SetPreferences, 0)

txtMenuMain1	.byte 'Set Date && Time...',0
txtMenuMain2	.byte 'Preferences...',0
	
MessageBuffer
	.rept MessageSize
	.byte 0
	.endr
	
	blk update address
	
	