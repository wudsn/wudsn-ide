;MyNESGame
;James "dbozan99" Santucci
;2012

;---------------------------------------------------------------- 
; constants 
;---------------------------------------------------------------- 

PRG_COUNT	EQU		1 ;1 = 16KB, 2 = 32KB 
MIRRORING	EQU		%0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen 

;-------------------------------------[ Hardware defines ]-------------------------------------------

PPUCONTROL0	EQU	$2000	;
PPUCONTROL1	EQU	$2001	;
PPUSTATUS	EQU	$2002	;
SPRADDRESS	EQU	$2003	;PPU HARDWARE CONTROL REGISTERS.
SPRIOREG	EQU	$2004	;
PPUSCROLL	EQU	$2005	;
PPUADDRESS	EQU	$2006	;
PPUIOREG	EQU	$2007	;

SQ1CNTRL0	EQU	$4000	;
SQ1CNTRL1	EQU	$4001	;SQ1 HARDWARE CONTROL REGISTERS.
SQ1CNTRL2	EQU	$4002	;
SQ1CNTRL3	EQU	$4003	;

SQ2CNTRL0	EQU	$4004	;
SQ2CNTRL1	EQU	$4005	;SQ2 HARDWARE CONTROL REGISTERS.
SQ2CNTRL2	EQU	$4006	;
SQ2CNTRL3	EQU	$4007	;

TRIANGLECNTRL0	EQU	$4008	;
TRIANGLECNTRL1	EQU	$4009	;TRIANGLE HARDWARE CONTROL REGISTERS.
TRIANGLECNTRL2	EQU	$400A	;
TRIANGLECNTRL3	EQU	$400B	;

NOISECNTRL0	EQU	$400C	;
NOISECNTRL1	EQU	$400D	;NOISE HARDWARE CONTROL REGISTERS.
NOISECNTRL2	EQU	$400E	;
NOISECNTRL3	EQU	$400F	;

DMCCNTRL0	EQU	$4010	;
DMCCNTRL1	EQU	$4011	;DMC HARDWARE CONTROL REGISTERS.
DMCCNTRL2	EQU	$4012	;
DMCCNTRL3	EQU	$4013	;

SPRDMAREG	 EQU	$4014	;SPRITE RAM DMA REGISTER.
APUCOMMONCNTRL0  EQU		$4015	;APU COMMON CONTROL 1 REGISTER.
CPUJOYPAD1  	 EQU	$4016	;JOYPAD1 REGISTER.
APUCOMMONCNTRL1	 EQU		$4017	;JOYPAD2/APU COMMON CONTROL 2 REGISTER.

;---------------------------------------------------------------- 
; variables 
;---------------------------------------------------------------- 

enum $0000 

;NOTE: declare variables using the DSB and DSW directives, like this: 

pointerLo			dsb 1 
pointerHi			dsb 1
GameState			dsb 2				;current game state, and state that is saved
GameStateOld		dsb 1				;old game state

bIsSleeping			dsb 1						;main program flag
updating_background	dsb 2				;0 = nothing, 1 = main program is updating the room

Enemy_Animation		dsb 4				;Animation Countedsb
Enemy_Frame			dsb 4				;Animation Frame Number

;enemy_direction		dsb 4				;direction for enemys; 0=up,1=down,2=right,3=left
;enemy_number		dsb 1				;enemy number for direction routine 0=Crewman, 1=punisher, 2=McBoobins, 3=AdsbeFace
;enemy_ptrnumber		dsb 1				;enemy pointer number (i.e. 2x the enemy number, 0=Crewman, 2=punisher, 4=McBoobins, 6=AdsbeFace)

Joy1Status				dsb 1				;see the "strobe controlledsb" routine
Joy1Previous			dsb 1
Joy1Change		dsb 1

ende

;NOTE: you can also split the variable declarations into individual pages, like this: 

;enum $0100 
;ende 

;enum $0200 
;ende 

;---------------------------------------------------------------- 
; iNES header 
;---------------------------------------------------------------- 

db "NES", $1a ;identification of the iNES header 
db PRG_COUNT ;number of 16KB PRG-ROM pages 
db $01 ;number of 8KB CHR-ROM pages 
db $00|MIRRORING ;mapper 0 and mirroring 
dsb 9, $00 ;clear the remaining bytes 

;---------------------------------------------------------------- 
; program bank(s) 
;---------------------------------------------------------------- 

include "MyNESGame-MainPRG.asm"

;---------------------------------------------------------------- 
; interrupt vectodsb 
;---------------------------------------------------------------- 

org $FFFA     ;first of the three vectors starts here
dw NMI        ;when an NMI happens (once per frame if enabled) the 
									 ;processor will jump to the label NMI:
dw RESET      ;when the processor first turns on or is reset, it will jump
									 ;to the label RESET:
dw 0          ;external interrupt IRQ is not used

;---------------------------------------------------------------- 
; CHR-ROM bank
;---------------------------------------------------------------- 
base $0000
incbin "mario.chr"