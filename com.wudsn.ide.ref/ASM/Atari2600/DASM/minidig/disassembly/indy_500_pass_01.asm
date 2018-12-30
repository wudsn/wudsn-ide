; Disassembly of indy_500.bin
; Disassembled Mon Jan 05 13:39:30 2004
; Using DiStella v3.0
; initial comments/labels by Glenn Saunders
;
	processor 6502
	include vcs.h


;===============================================================================
; CONSTANTS
;===============================================================================

LAST_SCANLINE 		= $DE

;===============================================================================
; RAM
;===============================================================================

      ; SEG.U	variables
      ; ORG $80
      
GAME_STATE		= $80
GAME_STATE2		= $81

P0_ATTRIBUTE2		= $82
P1_ATTRIBUTE2		= $83

P1_SCORE 		= $84
P0_SCORE 		= $85

P1_SCORE_GFX 		= $86
;? 			= $87
P0_SCORE_GFX 		= $88
;? 			= $89
;?			= $90

P0_ATTRIBUTE3		= $91
P1_ATTRIBUTE3		= $92

P0_SPEED_SETTING   	= $8A
P1_SPEED_SETTING   	= $8B

P0_SPEED_SETTING2	= $8C
P1_SPEED_SETTING2	= $8D

;?			= $90
;? 			= $95

GAME_STATE3		= $98

LAST_COLLISION_STATE 	= $99; tentative

AUDIO_CHANNEL1 		= $9B
AUDIO_CHANNEL2 		= $9C

P0_X			= $A1
P1_X			= $A2

SWCHB_BUFFER 		= $A3



SCANLINE_COUNTER 	= $A7

TEMP_01			= $A0
TEMP_02			= $AD

COUNTER_01 		= $A6

P0_SPEED 		= $A8
P1_SPEED 		= $A9
SWCHB_BUFFER2 		= $AC

CAR_GFX 		= $AF

FRAME_COUNTER		= $BF


;? 			= $C0
;? 			= $C1
;? 			= $C2
P0_ATTRIBUTE 		= $C3
P1_ATTRIBUTE 		= $C4

P0_ATTRIBUTE5		= $C9
P1_ATTRIBUTE5		= $CA

P0_ATTRIBUTE4		= $CB
P1_ATTRIBUTE4		= $CC

;? 			= $CD
;? 			= $CE

TAG_TARGET_START 	= $D1

PF0_POINTER 		= $D3; two bytes
PF1_POINTER 		= $D5; two bytes
PF2_POINTER 		= $D7; two bytes





;===============================================================================
; ROM
;===============================================================================

       ORG $F000

START:
       SEI            
       CLD            
       LDA    #$00    
       LDX    #$00    
CLEAR_RAM: 
       STA    VSYNC,X 
       STA    SWCHA,X 
       INX            
       BNE    CLEAR_RAM
       LDA    #$20    ; initialize player sprite options
       STA    NUSIZ0  
       STA    NUSIZ1  
       LDX    #$FF    
       TXS            
       JSR    LF1FF   
       JSR    END_GAME   
       JSR    LF246   
LF020: JSR    LF096   
       JSR    LOAD_CAR_GFX   
       LDA    FRAME_COUNTER     
       AND    #$3F    
       BNE    LF048   
       INC    $90     
       LDA    SWCHB_BUFFER     
       BEQ    LF048   
       LDA    $90     
       CMP    #$40    
       BEQ    LF043   
       BIT    GAME_STATE2     
       BVS    LF048   
       LDX    #$01    
       JSR    LF48D   
       BNE    LF048   
LF043: LDA    #$00    
       JSR    GAME_OVER   
LF048: LDA    SWCHB_BUFFER     
       BEQ    LF087   
       JSR    LF4F7   
       JSR    LF2AC   
       JSR    LF334   
       JSR    LF568   
       LDA    GAME_STATE     
       CMP    #$04    
       BCC    LF06F   
       CMP    #$0A    
       BCS    LF06F   
       CMP    #$08    
       BCS    LF078   
       JSR    LF59C   
       JSR    LF496   
       JMP    LF087   
LF06F: JSR    LF59C   
       JSR    LF41C   
       JMP    LF087   
LF078: JSR    LF5D1   
       LDX    $95     
       LDA    FRAME_COUNTER     
       AND    #$02    
       BEQ    LF087   
       LDA    #$FF    
       STA    P0_ATTRIBUTE,X   
LF087: JSR    LF609   
       JSR    FRAME_SETUP   
       JSR    LF1BF   
       JSR    LF217   
       JMP    LF020   
LF096: LDA    INTIM   
       BNE    LF096   
       STA    WSYNC   
       LDA    #$16    
       STA    VSYNC   
       STA    TIM8T   
       INC    FRAME_COUNTER     
LF0A6: LDA    INTIM   
       BNE    LF0A6   
       STA    WSYNC   
       STA    VSYNC   
       LDA    #$24    
       STA    TIM64T  
       RTS            

FRAME_SETUP: 
       LDA    #$00    
       STA    CXCLR   
       STA    SCANLINE_COUNTER
       STA    P0_SCORE_GFX  
       STA    P0_SCORE_GFX+1     
       LDA    #$02    
       STA    CTRLPF  ;set playfield to mirror-symmetric, inherits player color registers on each side
       TSX            
       STX    TEMP_01
       
TIMER_CHECK: 
       LDA    INTIM   
       BNE    TIMER_CHECK   
       STA    WSYNC   
       STA    VBLANK 

BLANK_LINES: 
       INC    SCANLINE_COUNTER     
       STA    WSYNC   
       LDA    SCANLINE_COUNTER     
       CMP    #$02    
       BCC    BLANK_LINES   

DRAW_SCORE: 
       STA    WSYNC   
       LDA    P0_SCORE_GFX
       STA    PF1     
       LDY    P1_SCORE_GFX     
       LDA    SCORE_DIGITS,Y 
       AND    #$F0 ;mask bits 
       STA    P0_SCORE_GFX     
       LDY    P1_SCORE     
       LDA    SCORE_DIGITS,Y 
       AND    #$0F ;mask bits 
       ORA    P0_SCORE_GFX     
       STA    P0_SCORE_GFX     
       LDA    P0_SCORE_GFX+1     
       STA    PF1     
       LDY    P1_SCORE_GFX+1     
       LDA    SCORE_DIGITS,Y 
       AND    #$F0 ;mask bits 
       STA    P0_SCORE_GFX+1     
       LDY    P0_SCORE     
       LDA    SCORE_DIGITS,Y 
       AND    #$0F ;mask bits 
       ORA    P0_SCORE_GFX+1     
       STA    P0_SCORE_GFX+1     
       NOP            
       NOP            
       NOP            
       NOP            
       INC    SCANLINE_COUNTER  ;NOTE, this is an INC rather than a DEC loop.  Somewhat inefficient. 
       LDA    SCANLINE_COUNTER     
       CMP    #$08 ; see if we're done drawing all of the score scanlines 
       BCS    END_SCORE   
       LDA    P0_SCORE_GFX     
       STA    PF1     
       INC    P1_SCORE     
       INC    P1_SCORE_GFX     
       INC    P0_SCORE     
       INC    P1_SCORE_GFX+1     
       LDA    P0_SCORE_GFX+1     
       STA    PF1     
       JMP    DRAW_SCORE   
END_SCORE: 
       LDA    #$00    
       STA    PF1     
       LDA    ($00,X) ;what is this?  reading off the stack? the LDA after this makes this instruction pointless
       LDA    #$20    
       STA    SCANLINE_COUNTER ;reset scanline counter
       LDA    #$01    
       STA    CTRLPF		;set playfield to mirror-symmetric, normal colors
SET_UP_MAIN_KERNEL: 
       LDX    #$1E    
       TXS            
       SEC            
       LDA    $CD     
       SBC    SCANLINE_COUNTER     
       AND    #$FE    
       TAX            
       AND    P0_ATTRIBUTE     
       BEQ    LOAD_CAR_GFX1   
       LDA    #$00    
       BEQ    END_LINE1   
LOAD_CAR_GFX1: 
       LDA    CAR_GFX,X   
END_LINE1: 
       STA    WSYNC   
       STA    GRP0    
       CLC            
       LDA    GAME_STATE3     
       SBC    SCANLINE_COUNTER     
       AND    #$F8    
       PHP            
       PHP            
       LDA    SCANLINE_COUNTER     
       BPL    TAG_TARGET_ENABLE   
       EOR    #$F8    
TAG_TARGET_ENABLE:
       LSR            
       LSR            
       LSR            
       TAY            
       INC    P1_SCORE 
       NOP            
       LDA    SCANLINE_COUNTER     
       CMP    TAG_TARGET_START     
       BCC    CAR_LOGIC   
       STA    ENABL   
CAR_LOGIC: 
       LDA    $CE  ;where is this initialized??
       SEC            
       SBC    SCANLINE_COUNTER     
       ORA    #$01    
       TAX            
       AND    P1_ATTRIBUTE     
       BEQ    LOAD_CAR_GFX2; figure out whether or not to draw the car
       LDA    #$00 ; if it isn't going to draw the car, blank it out
       BEQ    DRAW_RACETRACK   
LOAD_CAR_GFX2: 
       LDA    CAR_GFX,X   
DRAW_RACETRACK: 
       STA    GRP1
       ;draw the racetrack (mirror-symmetrical playfield)
       LDA    (PF0_POINTER),Y 
       STA    PF0 ; draw outer borders
       LDA    (PF1_POINTER),Y 
       STA    PF1 ; draw left side
       LDA    (PF2_POINTER),Y 
       STA    PF2 ; draw middles
       CLC            
       LDA    SCANLINE_COUNTER     
       ADC    #$02    
       STA    SCANLINE_COUNTER     
       CMP    #LAST_SCANLINE ;figure out if we are at the bottom of the display yet
       BCC    SET_UP_MAIN_KERNEL   

       ;perform housecleaning to end the kernel
       LDX    TEMP_01     
       TXS            
       LDA    #$F0    
       STA    P0_ATTRIBUTE     
       STA    P1_ATTRIBUTE     
       LDA    #$00    
       STA    ENAM0   
       STA    ENAM1   
       STA    ENABL   
       STA    GRP0    
       STA    GRP1    
       STA    GRP0    
       STA    PF2     
       STA    PF1     
       STA    PF0     
       LDA    #$D2    
       STA    TIM8T   
       STA    VBLANK  
       RTS            

LF1BF: LDA    SWCHB   
       LSR            
       BCS    LF1E3   
       LDA    #$FF    
       STA    SWCHB_BUFFER     
       LDA    #$00    
       LDX    #$20    
LF1CD: STA    P0_ATTRIBUTE2,X   
       DEX            
       BPL    LF1CD   
       LDA    FRAME_COUNTER     
       AND    #$01    
       STA    FRAME_COUNTER     
       LDA    #$60    
       BIT    GAME_STATE2     
       BVS    LF1E0   
       STA    P1_ATTRIBUTE2     
LF1E0: LDA    #$00    
       RTS            

LF1E3: LSR            
       BCS    LF20F   
       LDA    $C0     
       BNE    LF214   
       LDA    #$1E    
       STA    $C0     
       LDA    GAME_STATE     
       CMP    #$0D    
       BCC    LF1F8   
       LDA    #$FF    
       STA    GAME_STATE     
LF1F8: INC    GAME_STATE     
       JSR    END_GAME   
       STA    P1_ATTRIBUTE2  
       
LF1FF: SED            
       CLC            
       LDA    GAME_STATE     
       TAX            
       ADC    #$01    
       STA    P0_ATTRIBUTE2     
       CLD            
       LDA    TABLE_01,X 
       STA    GAME_STATE2     
       RTS            

LF20F: LDA    #$00    
       STA    $C0     
       RTS            

LF214: DEC    $C0     
       RTS            

LF217: LDY    #$18    
       SEC            
       LDA    SWCHB   
       AND    #$08    
       BEQ    LF227   
       LDA    GAME_STATE2     
       AND    #$38    
       LSR            
       TAY            
LF227: LDX    #$03    
LF229: LDA    COLOR_TABLE,Y 

       
       BIT    SWCHB_BUFFER     
       BVS    LF232   
       EOR    $90     
LF232: BCC    LF236   
       AND    #$0F    
LF236: STA    COLUP0,X
       DEY            
       DEX            
       BPL    LF229   
       LDA    SWCHB   
       AND    #$03    
       EOR    #$03    
       BNE    LF246   
       RTS            

LF246: LDA    LF6AC   
       STA    PF0_POINTER     
       LDA    #>PLAYFIELD_SHAPES;#$F7    

       ;store the high byte address into these RAM pointers
       STA    PF0_POINTER+1     
       STA    PF1_POINTER+1     
       STA    PF2_POINTER+1     

       LDA    GAME_STATE2     
       AND    #$07    
       TAY            
       CMP    #$01    
       BNE    LF261   
       LDA    LF6AD   
       STA    PF0_POINTER     
LF261: LDA    LF6A3,Y 
       TAX            
       LDA    LF6AE,X 
       STA    PF1_POINTER     
       LDA    LF6B2,Y 
       STA    PF2_POINTER     
       LDX    #$06    
       LDY    #$06    
       LDA    GAME_STATE2     
       AND    #$02    
       BEQ    LF27B   
       LDY    #$0D    
LF27B: LDA    LF78B,Y 
       STA    P0_ATTRIBUTE4,X   
       DEY            
       DEX            
       BPL    LF27B   
       INX            
       JSR    LF537   
       INX            
       LDA    $CC     
       JSR    LF537   
       LDX    #$04    
       LDA    #$55    
       JSR    LF537   
       STA    WSYNC   
       STA    HMOVE   
       LDA    GAME_STATE     
       TAY            
       LDA    LF6B7,Y 
       TAY            
       LDX    #$03    
LF2A2: LDA    LF799,Y 
       STA    $C5,X   
       DEY            
       DEX            
       BPL    LF2A2   
       RTS            

LF2AC: LDX    #$01    
       LDA    SWCHB   
       STA    SWCHB_BUFFER2     
       LDA    SWCHA   
       BIT    GAME_STATE2     
       BVC    LF311   
       
;handle accelleration for both cars
;somewhere in here is the ice and skid stuff
ACCELERATION: 
       AND    #$03    
       STA    $9E,X   
       LDA    INPT4,X 
       BPL    LF2D6   
       LDA    P0_SPEED,X   
       BNE    LF31E   
       LDA    P0_SPEED_SETTING,X   
       BEQ    LF2F0   
       DEC    P0_SPEED_SETTING,X   
       LDA    $C6     
       STA    P0_SPEED,X   
       JSR    SPEED_CONVERSION   
       JMP    LF2F0   
LF2D6: LDA    P0_SPEED,X   
       BNE    LF31E   
       LDA    $C7     
       BIT    SWCHB_BUFFER2     
       BMI    LF2E3   
       SEC            
       SBC    #$02    
LF2E3: CMP    P0_SPEED_SETTING,X   
       BCC    LF2F0   
       INC    P0_SPEED_SETTING,X   
       LDA    $C5     
       STA    P0_SPEED,X   
       JSR    SPEED_CONVERSION   
LF2F0: LDA    $9E,X   
       ASL            
       ASL            
       ORA    $AA,X   
       TAY            
       LDA    $CF,X   
       CMP    P0_X,X   
       BNE    LF323   
       LDA    LF7A9,Y 
       STA    P0_ATTRIBUTE3,X   
LF302: CLC            
       ADC    $CF,X   
       AND    #$0F    
       STA    $CF,X   
       TYA            
       LSR            
       LSR            
       STA    $AA,X   
       JSR    LF3AD   
LF311: ASL    SWCHB_BUFFER2     
       LDA    SWCHA   
       LSR            
       LSR            
       LSR            
       LSR            
       DEX            
       BEQ    ACCELERATION   
       RTS            

LF31E: DEC    P0_SPEED,X   
       JMP    LF2F0   
LF323: LDA    LF7A9,Y 
       JMP    LF302   
       
;this looks like it's doing some kind of lookup and/or constraings related to speed settings
SPEED_CONVERSION: 
       LDA    P0_SPEED_SETTING,X   
       AND    #$07    
       TAY            
       LDA    GEAR_TABLE,Y 
       STA    P0_SPEED_SETTING2,X   
       RTS            


LF334: LDX    #$01    
LF336: LDA    P0_SPEED_SETTING,X   
       AND    #$08    
       BEQ    LF33F   
       JSR    LF351   
LF33F: LDA    P0_SPEED_SETTING2,X   
       SEC            
       BMI    LF345   
       CLC            
LF345: ROL            
       STA    P0_SPEED_SETTING2,X   
       BCC    LF34D   
       JSR    LF351   
LF34D: DEX            
       BEQ    LF336   
       RTS            

LF351: INC    P0_ATTRIBUTE5,X   
       STA    HMCLR   
       LDA    P0_X,X   
       SEC            
       SBC    #$02    
       AND    #$03    
       BNE    LF364   
       LDA    P0_ATTRIBUTE5,X   
       AND    #$03    
       BEQ    LF3AC   
LF364: LDA    P0_ATTRIBUTE5,X   
       AND    #$01    
       BEQ    LF36C   
       LDA    #$10    
LF36C: ORA    P0_X,X   
       TAY            
       LDA    TABLE_02,Y 
       STA    HMP0,X  
       AND    #$0F    
       SEC            
       SBC    #$08    
       STA    $AE     
       CLC            
       ADC    $CD,X   
       STA    $CD,X   
       BIT    $AE     
       BMI    LF38C   
       CMP    #$E8    
       BCC    LF392   
       LDA    #$2E    
       BNE    LF392   
LF38C: CMP    #$28    
       BCS    LF392   
       LDA    #$DD    
LF392: STA    $CD,X   
       STA    VDELP0,X
       LDA    TABLE_02,Y 
       LSR            
       LSR            
       LSR            
       LSR            
       CMP    #$08    
       BCC    LF3A4   
       ORA    #$F0    
       CLC            
LF3A4: ADC    P0_ATTRIBUTE4,X   
       STA    P0_ATTRIBUTE4,X   
       STA    WSYNC   
       STA    HMOVE   
LF3AC: RTS            

LF3AD: LDA    P0_SPEED_SETTING,X   
       CMP    $C8     
       BCC    LF3DD   
       LDA    $93,X   
       BNE    LF3E2   
       LDA    $CF,X   
       CMP    P0_X,X   
       BEQ    LF3D4   
       LDA    P0_ATTRIBUTE3,X   
       BMI    LF3D8   
       INC    P0_X,X   
LF3C3: LDA    P0_X,X   
       AND    #$0F    
       STA    P0_X,X   
       LDA    GAME_STATE     
       CMP    #$0A    
       LDA    P0_SPEED_SETTING,X   
       BCS    LF3D5   
       LSR            
LF3D2: STA    $93,X   
LF3D4: RTS            

LF3D5: ASL            
       BNE    LF3D2   
LF3D8: DEC    P0_X,X   
       JMP    LF3C3   
LF3DD: LDA    $CF,X   
       STA    P0_X,X   
       RTS            

LF3E2: DEC    $93,X   
       RTS            

LOAD_CAR_GFX: 
       LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       LDA    $CF,X   
       STA    REFP0,X 
       ASL            
       ASL            
       ASL            
       CMP    #$3F    
       CLC            
       BMI    LF3F9   
       SEC            
       EOR    #$47    
LF3F9: TAY            
       STX    $9D     
       TXA            
       EOR    #$0E    
       TAX            
LF400: TXA            
       AND    #$01    
       BEQ    LF40D   
       BIT    GAME_STATE2     
       BVS    LF40D   
       LDA    #$00    
       BEQ    LF410   
LF40D: LDA    CAR_ROTATIONS,Y 
LF410: STA    CAR_GFX,X   
       BCC    LF416   
       DEY            
       DEY            
LF416: INY            
       DEX            
       DEX            
       BPL    LF400   
       RTS            

LF41C: LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       LDA    $96,X   
       ASL            
       BPL    LF464   
       LDA    $CD,X   
       CMP    #$80    
       LDA    #$00    
       BCS    LF430   
       LDA    #$01    
LF430: STA    $9D     
       LDA    P0_ATTRIBUTE4,X   
       CMP    #$CD    
       LDA    $9D     
       BCC    LF43C   
       ORA    #$02    
LF43C: TAY            
       LDA    LF6A8,Y 
       ORA    $8E,X   
       STA    $8E,X   
       CMP    #$0F    
       BNE    LF463   
       LDA    CXP0FB,X
       AND    #$40    
       BEQ    LF46B   
       LDA    $96,X   
       BMI    LF463   
       LDA    #$C6    
       STA    $96,X   
       STA    P0_ATTRIBUTE4,X   
       LDA    #$00    
       STA    $8E,X   
       JSR    LF47F   
       CMP    #$25    
       BEQ    END_GAME   
LF463: RTS            

LF464: LDA    CXP0FB,X
       AND    #$40    
       STA    $96,X   
       RTS            

LF46B: LDA    #$40    
       STA    $96,X   
       RTS            

END_GAME: 
       LDA    #$00    
       STA    GAME_STATE3     
GAME_OVER: 
       STA    SWCHB_BUFFER     
       STA    AUDV0   
       STA    AUDV1   
       STA    $90     
       STA    FRAME_COUNTER     
       RTS            

LF47F: LDA    #$00    
       STA    $90     
       SED            
       CLC            
       LDA    P0_ATTRIBUTE2,X   
       ADC    #$01    
LF489: STA    P0_ATTRIBUTE2,X   
       CLD            
       RTS            

LF48D: SED            
       LDA    P1_ATTRIBUTE2     
       SEC            
       SBC    #$01    
       JMP    LF489   
LF496: STA    HMCLR   
       LDA    $8E     
       BEQ    LF4EF   
       LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       LDA    CXM0FB,X
       BMI    LF4DF   
       LDA    LAST_COLLISION_STATE,X   
       BNE    LF4E6   
       LDA    CXM0P,X 
       ASL            
       BPL    LF4B1   
       JSR    LF4B2   
LF4B1: RTS            

LF4B2: LDA    #$08    
       STA    LAST_COLLISION_STATE,X   
       JSR    LF47F   
       CMP    #$50    
       BEQ    LF4E9   
       LDA    FRAME_COUNTER     
LF4BF: AND    #$7F    
       ADC    #$40    
       STA    GAME_STATE3     
       EOR    CAR_GFX,X   
       AND    #$7F    
       ADC    #$10    
LF4CB: STA    $D2     
       STA    $8E     
       LDX    #$02    
       PHA            
       JSR    LF537   
       INX            
       PLA            
       JSR    LF537   
       STA    WSYNC   
       STA    HMOVE   
       RTS            

LF4DF: LDA    FRAME_COUNTER     
       ADC    #$0A    
       JMP    LF4BF   
LF4E6: DEC    LAST_COLLISION_STATE,X   
       RTS            

LF4E9: LDA    #$00    
       JSR    GAME_OVER   
       RTS            

LF4EF: LDA    #$84    
       STA    GAME_STATE3     
       LDA    #$56    
       BNE    LF4CB   
LF4F7: LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       STX    $9D     
       LDA    AUDIO_CHANNEL1,X   
       BNE    LF533   
       LDA    LAST_COLLISION_STATE,X   
       BNE    LF52F   
       LDA    P0_SPEED_SETTING,X   
       LSR            
       TAY            
       BNE    LF519   
       LDA    $C1,X   
       BEQ    LF515   
       DEC    $C1,X   
       JMP    LF51D   
LF515: LDY    #$06    
       BNE    LF51D   
LF519: LDA    #$3F    
       STA    $C1,X   
LF51D: LDA    LF6D7,Y 
       STA    AUDV0,X 
LF522: LDA    LF6C5,Y 
       ORA    $9D     
       STA    AUDF0,X 
       LDA    LF6CE,Y 
       STA    AUDC0,X 
       RTS            

LF52F: LDY    #$07    
       BNE    LF51D   
LF533: LDY    #$08    
       BNE    LF522   
LF537: CLC            
       ADC    #$31    
       PHA            
       LSR            
       LSR            
       LSR            
       LSR            
       TAY            
       PLA            
       AND    #$0F    
       STY    $9D     
       CLC            
       ADC    $9D     
       CMP    #$0E    
       BCC    LF550   
       SEC            
       SBC    #$0E    
       INY            
LF550: CMP    #$08    
       EOR    #$0F    
       BCS    LF559   
       ADC    #$01    
       DEY            
LF559: INY            
       ASL            
       ASL            
       ASL            
       ASL            
       STY    WSYNC   
LF560: DEY            
       BNE    LF560   
       STA    RESP0,X 
       STA    HMP0,X  
       RTS            

LF568: LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       LDA    CXP0FB,X
       BPL    LF58B   
       LDA    GAME_STATE2     
       AND    #$02    
       BNE    LF590   
       LDA    $A4,X   
       BNE    LF590   
       INC    $A4,X   
       LDA    #$00    
       STA    P0_SPEED_SETTING,X   
       JSR    SPEED_CONVERSION   
       LDA    #$0F    
       STA    AUDIO_CHANNEL1,X   
       STA    AUDV0,X 
LF58A: RTS            

LF58B: LDA    #$00    
       STA    $A4,X   
       RTS            

LF590: LDA    #$02    
       CMP    P0_SPEED_SETTING,X   
       BCS    LF58A   
       LSR    P0_SPEED_SETTING,X   
       JSR    SPEED_CONVERSION   
       RTS            

LF59C: LDA    CXPPMM  
       BPL    RESET_COUNTER_01   
       LDA    COUNTER_01   

       
       BNE    LF5CB   
       INC    COUNTER_01  
      
       
       LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       INC    $CF,X   
       INC    P0_X,X   
       LSR    P0_SPEED_SETTING,X   
       JSR    SPEED_CONVERSION   
       TXA            
       EOR    #$01    
       TAX            
       DEC    $CF,X   
       DEC    P0_X,X   
       LSR    P0_SPEED_SETTING,X   
       JSR    SPEED_CONVERSION   
       LDA    #$0F    
       STA    AUDIO_CHANNEL1     
       STA    AUDIO_CHANNEL2     
       STA    AUDV0   
       STA    AUDV1   
LF5CB: RTS            

RESET_COUNTER_01:
       LDA    #$00    
       STA    COUNTER_01     
       RTS            

LF5D1: LDA    LAST_COLLISION_STATE     
       ORA    $9A     
       BNE    LF5EF   
       LDA    CXPPMM  
       BMI    LF5FB   
       LDA    FRAME_COUNTER     
       AND    #$3F    
       BNE    LF5EA   
       LDX    $95     
       JSR    LF47F   
       CMP    #$99    
       BEQ    LF5EB   
LF5EA: RTS            

LF5EB: JSR    END_GAME   
       RTS            

LF5EF: LDA    #$00    
       LDX    TEMP_02     
       STA    P0_SPEED_SETTING,X   
       JSR    SPEED_CONVERSION   
       DEC    LAST_COLLISION_STATE,X   
       RTS            

LF5FB: LDA    $95     
       STA    TEMP_02     
       TAX            
       EOR    #$01    
       STA    $95     
       LDA    #$3F    
       STA    LAST_COLLISION_STATE,X   
       RTS            

LF609: LDA    FRAME_COUNTER     
       AND    #$01    
       TAX            
       LDA    AUDIO_CHANNEL1,X   
       BEQ    LF619   
       SEC            
       SBC    #$01    
       STA    AUDV0,X 
       STA    AUDIO_CHANNEL1,X   
LF619: LDX    #$01    
LF61B: LDA    P0_ATTRIBUTE2,X   
       AND    #$0F    
       STA    $9D     
       ASL            
       ASL            
       CLC            
       ADC    $9D     
       STA    P1_SCORE,X   
       LDA    P0_ATTRIBUTE2,X   
       AND    #$F0    
       LSR            
       LSR            
       STA    $9D     
       LSR            
       LSR            
       CLC            
       ADC    $9D     
       STA    P1_SCORE_GFX,X   
       DEX            
       BEQ    LF61B   
       RTS            

SCORE_DIGITS: 
       .byte $0E ; |    XXX | $F63B
       .byte $0A ; |    X X | $F63C
       .byte $0A ; |    X X | $F63D
       .byte $0A ; |    X X | $F63E
       .byte $0E ; |    XXX | $F63F
       
       .byte $22 ; |  X   X | $F640
       .byte $22 ; |  X   X | $F641
       .byte $22 ; |  X   X | $F642
       .byte $22 ; |  X   X | $F643
       .byte $22 ; |  X   X | $F644
       
       .byte $EE ; |XXX XXX | $F645
       .byte $22 ; |  X   X | $F646
       .byte $EE ; |XXX XXX | $F647
       .byte $88 ; |X   X   | $F648
       .byte $EE ; |XXX XXX | $F649
       
       .byte $EE ; |XXX XXX | $F64A
       .byte $22 ; |  X   X | $F64B
       .byte $66 ; | XX  XX | $F64C
       .byte $22 ; |  X   X | $F64D
       .byte $EE ; |XXX XXX | $F64E
       
       .byte $AA ; |X X X X | $F64F
       .byte $AA ; |X X X X | $F650
       .byte $EE ; |XXX XXX | $F651
       .byte $22 ; |  X   X | $F652
       .byte $22 ; |  X   X | $F653
       
       .byte $EE ; |XXX XXX | $F654
       .byte $88 ; |X   X   | $F655
       .byte $EE ; |XXX XXX | $F656
       .byte $22 ; |  X   X | $F657
       .byte $EE ; |XXX XXX | $F658
       
       .byte $EE ; |XXX XXX | $F659
       .byte $88 ; |X   X   | $F65A
       .byte $EE ; |XXX XXX | $F65B
       .byte $AA ; |X X X X | $F65C
       .byte $EE ; |XXX XXX | $F65D
       
       .byte $EE ; |XXX XXX | $F65E
       .byte $22 ; |  X   X | $F65F
       .byte $22 ; |  X   X | $F660
       .byte $22 ; |  X   X | $F661
       .byte $22 ; |  X   X | $F662
       
       .byte $EE ; |XXX XXX | $F663
       .byte $AA ; |X X X X | $F664
       .byte $EE ; |XXX XXX | $F665
       .byte $AA ; |X X X X | $F666
       .byte $EE ; |XXX XXX | $F667
       
       .byte $EE ; |XXX XXX | $F668
       .byte $AA ; |X X X X | $F669
       .byte $EE ; |XXX XXX | $F66A
       .byte $22 ; |  X   X | $F66B
       .byte $EE ; |XXX XXX | $F66C
       
TABLE_01: 
       .byte $48 ; | X  X   | $F66D
       .byte $08 ; |    X   | $F66E
       .byte $D1 ; |XX X   X| $F66F
       .byte $91 ; |X  X   X| $F670
       .byte $5A ; | X XX X | $F671
       .byte $1A ; |   XX X | $F672
       .byte $DB ; |XX XX XX| $F673
       .byte $9B ; |X  XX XX| $F674
       .byte $62 ; | XX   X | $F675
       .byte $E3 ; |XXX   XX| $F676
       .byte $6C ; | XX XX  | $F677
       .byte $2C ; |  X XX  | $F678
       .byte $E8 ; |XXX X   | $F679
       .byte $A8 ; |X X X   | $F67A
TABLE_02: 
       .byte $F8 ; |XXXXX   | $F67B
       .byte $F7 ; |XXXX XXX| $F67C
       .byte $F6 ; |XXXX XX | $F67D
       .byte $06 ; |     XX | $F67E
       .byte $06 ; |     XX | $F67F
       .byte $06 ; |     XX | $F680
       .byte $16 ; |   X XX | $F681
       .byte $17 ; |   X XXX| $F682
       .byte $18 ; |   XX   | $F683
       .byte $19 ; |   XX  X| $F684
       .byte $1A ; |   XX X | $F685
       .byte $0A ; |    X X | $F686
       .byte $0A ; |    X X | $F687
       .byte $0A ; |    X X | $F688
       .byte $FA ; |XXXXX X | $F689
       .byte $F9 ; |XXXXX  X| $F68A
       .byte $F8 ; |XXXXX   | $F68B
       .byte $F7 ; |XXXX XXX| $F68C
       .byte $F6 ; |XXXX XX | $F68D
       .byte $F6 ; |XXXX XX | $F68E
       .byte $06 ; |     XX | $F68F
       .byte $16 ; |   X XX | $F690
       .byte $16 ; |   X XX | $F691
       .byte $17 ; |   X XXX| $F692
       .byte $18 ; |   XX   | $F693
       .byte $19 ; |   XX  X| $F694
       .byte $1A ; |   XX X | $F695
       .byte $1A ; |   XX X | $F696
       .byte $0A ; |    X X | $F697
       .byte $FA ; |XXXXX X | $F698
       .byte $FA ; |XXXXX X | $F699
       .byte $F9 ; |XXXXX  X| $F69A
       
       
       
GEAR_TABLE: 
       .byte $00 ; |        | $F69B
       .byte $01 ; |       X| $F69C
       .byte $11 ; |   X   X| $F69D
       .byte $25 ; |  X  X X| $F69E
       .byte $55 ; | X X X X| $F69F
       .byte $DA ; |XX XX X | $F6A0
       .byte $EE ; |XXX XXX | $F6A1
       .byte $EF ; |XXX XXXX| $F6A2

LF6A3: .byte $00 ; |        | $F6A3
       .byte $03 ; |      XX| $F6A4
       .byte $00 ; |        | $F6A5
       .byte $02 ; |      X | $F6A6
       .byte $01 ; |       X| $F6A7
LF6A8: .byte $08 ; |    X   | $F6A8
       .byte $01 ; |       X| $F6A9
       .byte $04 ; |     X  | $F6AA
       .byte $02 ; |      X | $F6AB
LF6AC: .byte $1B ; |   XX XX| $F6AC
LF6AD: .byte $1C ; |   XXX  | $F6AD
LF6AE: .byte $28 ; |  X X   | $F6AE
       .byte $34 ; |  XX X  | $F6AF
       .byte $3A ; |  XXX X | $F6B0
       .byte $46 ; | X   XX | $F6B1
LF6B2: .byte $51 ; | X X   X| $F6B2
       .byte $5D ; | X XXX X| $F6B3
       .byte $69 ; | XX X  X| $F6B4
       .byte $6F ; | XX XXXX| $F6B5
       .byte $7B ; | XXXX XX| $F6B6
LF6B7: .byte $03 ; |      XX| $F6B7
       .byte $03 ; |      XX| $F6B8
       .byte $0B ; |    X XX| $F6B9
       .byte $0B ; |    X XX| $F6BA
       .byte $03 ; |      XX| $F6BB
       .byte $03 ; |      XX| $F6BC
       .byte $0B ; |    X XX| $F6BD
       .byte $0B ; |    X XX| $F6BE
       .byte $03 ; |      XX| $F6BF
       .byte $0B ; |    X XX| $F6C0
       .byte $07 ; |     XXX| $F6C1
       .byte $07 ; |     XXX| $F6C2
       .byte $0F ; |    XXXX| $F6C3
       .byte $0F ; |    XXXX| $F6C4
LF6C5: .byte $0E ; |    XXX | $F6C5
       .byte $08 ; |    X   | $F6C6
       .byte $06 ; |     XX | $F6C7
       .byte $04 ; |     X  | $F6C8
       .byte $1A ; |   XX X | $F6C9
       .byte $18 ; |   XX   | $F6CA
       .byte $0F ; |    XXXX| $F6CB
       .byte $00 ; |        | $F6CC
       .byte $37 ; |  XX XXX| $F6CD
LF6CE: .byte $02 ; |      X | $F6CE
       .byte $02 ; |      X | $F6CF
       .byte $02 ; |      X | $F6D0
       .byte $02 ; |      X | $F6D1
       .byte $07 ; |     XXX| $F6D2
       .byte $07 ; |     XXX| $F6D3
       .byte $02 ; |      X | $F6D4
       .byte $0A ; |    X X | $F6D5
       .byte $08 ; |    X   | $F6D6
LF6D7: .byte $0C ; |    XX  | $F6D7
       .byte $0C ; |    XX  | $F6D8
       .byte $0C ; |    XX  | $F6D9
       .byte $09 ; |    X  X| $F6DA
       .byte $06 ; |     XX | $F6DB
       .byte $08 ; |    X   | $F6DC
       .byte $06 ; |     XX | $F6DD
       .byte $0A ; |    X X | $F6DE

CAR_ROTATIONS: 

	;DEATH DERBY CAR [ swap this in if you want :) ]
	;.byte %00000000; ........
	;.byte %11101110; XXX.XXX.
	;.byte %01100100; .XX..X..
	;.byte %11011111; XX.XXXXX
	;.byte %11011111; XX.XXXXX
	;.byte %01100100; .XX..X..
	;.byte %11101110; XXX.XXX.
	;.byte %00000000; ........


	;.byte %00000100; .....X..
	;.byte %00011100; ...XXX..
	;.byte %11000111; XX...XXX
	;.byte %11111111; XXXXXXXX
	;.byte %01011110; .X.XXXX.
	;.byte %01100011; .XX...XX
	;.byte %00110100; ..XX.X..
	;.byte %00110000; ..XX....


	;.byte %00010000; ...X....
	;.byte %00110110; ..XX.XX.
	;.byte %00011110; ...XXXX.
	;.byte %11011100; XX.XXX..
	;.byte %11011011; XX.XX.XX
	;.byte %01000010; .X....X.
	;.byte %01111000; .XXXX...
	;.byte %00011000; ...XX...
	

	;.byte %00101100; ..X.XX..
	;.byte %00111100; ..XXXX..
	;.byte %01011111; .X.XXXXX
	;.byte %00011010; ...XX.X.
	;.byte %11011010; XX.XX.X.
	;.byte %11101000; XXX.X...
	;.byte %00111100; ..XXXX..
	;.byte %00001100; ....XX..
	
	;.byte %00011000; ...XX...
	;.byte %01011010; .X.XX.X.
	;.byte %01111110; .XXXXXX.
	;.byte %01011010; .X.XX.X.
	;.byte %00011000; ...XX...
	;.byte %01100110; .XX..XX.
	;.byte %01111110; .XXXXXX.
	;.byte %01011010; .X.XX.X.

	;.byte %00110100; ..XX.X..
	;.byte %00111100; ..XXXX..
	;.byte %11111010; XXXXX.X.
	;.byte %01011000; .X.XX...
	;.byte %01011011; .X.XX.XX
	;.byte %00010111; ...X.XXX
	;.byte %00111100; ..XXXX..
	;.byte %00110000; ..XX....

       

	;.byte %00001000; ....X...
	;.byte %01101100; .XX.XX..
	;.byte %01111000; .XXXX...
	;.byte %00111011; ..XXX.XX
	;.byte %11011011; XX.XX.XX
	;.byte %01000010; .X....X.
	;.byte %00011110; ...XXXX.
	;.byte %00011000; ...XX...
	
       
	;.byte %00100000; ..X.....
	;.byte %00111000; ..XXX...
	;.byte %11100011; XXX...XX
	;.byte %11111111; XXXXXXXX
	;.byte %01111010; .XXXX.X.
	;.byte %11000110; XX...XX.
	;.byte %00101100; ..X.XX..
	;.byte %00001100; ....XX..
       
       

       .byte $EE ; |XXX XXX | $F6DF
       .byte $EE ; |XXX XXX | $F6E0
       .byte $44 ; | X   X  | $F6E1
       .byte $7F ; | XXXXXXX| $F6E2
       .byte $7F ; | XXXXXXX| $F6E3
       .byte $44 ; | X   X  | $F6E4
       .byte $EE ; |XXX XXX | $F6E5
       .byte $EE ; |XXX XXX | $F6E6
       
       .byte $18 ; |   XX   | $F6E7
       .byte $D8 ; |XX XX   | $F6E8
       .byte $CB ; |XX  X XX| $F6E9
       .byte $5E ; | X XXXX | $F6EA
       .byte $7E ; | XXXXXX | $F6EB
       .byte $64 ; | XX  X  | $F6EC
       .byte $36 ; |  XX XX | $F6ED
       .byte $36 ; |  XX XX | $F6EE
       
       .byte $30 ; |  XX    | $F6EF
       .byte $32 ; |  XX  X | $F6F0
       .byte $CC ; |XX  XX  | $F6F1
       .byte $DC ; |XX XXX  | $F6F2
       .byte $3B ; |  XXX XX| $F6F3
       .byte $33 ; |  XX  XX| $F6F4
       .byte $0C ; |    XX  | $F6F5
       .byte $0C ; |    XX  | $F6F6
       
       .byte $04 ; |     X  | $F6F7
       .byte $CC ; |XX  XX  | $F6F8
       .byte $F8 ; |XXXXX   | $F6F9
       .byte $1F ; |   XXXXX| $F6FA
       .byte $DB ; |XX XX XX| $F6FB
       .byte $F0 ; |XXXX    | $F6FC
       .byte $3E ; |  XXXXX | $F6FD
       .byte $06 ; |     XX | $F6FE
       
       .byte $18 ; |   XX   | $F6FF
       .byte $DB ; |XX XX XX| $F700
       .byte $FF ; |XXXXXXXX| $F701
       .byte $DB ; |XX XX XX| $F702
       .byte $18 ; |   XX   | $F703
       .byte $DB ; |XX XX XX| $F704
       .byte $FF ; |XXXXXXXX| $F705
       .byte $C3 ; |XX    XX| $F706
       
       .byte $20 ; |  X     | $F707
       .byte $33 ; |  XX  XX| $F708
       .byte $1F ; |   XXXXX| $F709
       .byte $F8 ; |XXXXX   | $F70A
       .byte $DB ; |XX XX XX| $F70B
       .byte $0F ; |    XXXX| $F70C
       .byte $7C ; | XXXXX  | $F70D
       .byte $60 ; | XX     | $F70E
       
       .byte $0C ; |    XX  | $F70F
       .byte $4C ; | X  XX  | $F710
       .byte $33 ; |  XX  XX| $F711
       .byte $3B ; |  XXX XX| $F712
       .byte $DC ; |XX XXX  | $F713
       .byte $CC ; |XX  XX  | $F714
       .byte $30 ; |  XX    | $F715
       .byte $30 ; |  XX    | $F716
       
       .byte $18 ; |   XX   | $F717
       .byte $1B ; |   XX XX| $F718
       .byte $D3 ; |XX X  XX| $F719
       .byte $7A ; | XXXX X | $F71A
       .byte $3E ; |  XXXXX | $F71B
       .byte $26 ; |  X  XX | $F71C
       .byte $6C ; | XX XX  | $F71D
       .byte $6C ; | XX XX  | $F71E
PLAYFIELD_SHAPES:
       
       .byte $F0 ; |XXXX    | $F71F
       .byte $F0 ; |XXXX    | $F720
       .byte $70 ; | XXX    | $F721
       .byte $30 ; |  XX    | $F722
       .byte $30 ; |  XX    | $F723
       .byte $30 ; |  XX    | $F724
       .byte $30 ; |  XX    | $F725
       .byte $30 ; |  XX    | $F726
       .byte $30 ; |  XX    | $F727
       .byte $30 ; |  XX    | $F728
       .byte $30 ; |  XX    | $F729
       .byte $30 ; |  XX    | $F72A
       .byte $F0 ; |XXXX    | $F72B
       .byte $FF ; |XXXXXXXX| $F72C
       .byte $00 ; |        | $F72D
       .byte $00 ; |        | $F72E
       .byte $00 ; |        | $F72F
       .byte $00 ; |        | $F730
       .byte $00 ; |        | $F731
       .byte $00 ; |        | $F732
       .byte $01 ; |       X| $F733
       .byte $01 ; |       X| $F734
       .byte $01 ; |       X| $F735
       .byte $01 ; |       X| $F736
       .byte $01 ; |       X| $F737
       .byte $FF ; |XXXXXXXX| $F738
       .byte $00 ; |        | $F739
       .byte $00 ; |        | $F73A
       .byte $00 ; |        | $F73B
       .byte $00 ; |        | $F73C
       .byte $00 ; |        | $F73D
       .byte $00 ; |        | $F73E
       .byte $00 ; |        | $F73F
       .byte $00 ; |        | $F740
       .byte $00 ; |        | $F741
       .byte $00 ; |        | $F742
       .byte $00 ; |        | $F743
       .byte $03 ; |      XX| $F744
       .byte $03 ; |      XX| $F745
       .byte $00 ; |        | $F746
       .byte $00 ; |        | $F747
       .byte $00 ; |        | $F748
       .byte $00 ; |        | $F749
       .byte $FF ; |XXXXXXXX| $F74A
       .byte $00 ; |        | $F74B
       .byte $00 ; |        | $F74C
       .byte $00 ; |        | $F74D
       .byte $00 ; |        | $F74E
       .byte $00 ; |        | $F74F
       .byte $03 ; |      XX| $F750
       .byte $00 ; |        | $F751
       .byte $00 ; |        | $F752
       .byte $00 ; |        | $F753
       .byte $00 ; |        | $F754
       .byte $FF ; |XXXXXXXX| $F755
       .byte $E0 ; |XXX     | $F756
       .byte $C0 ; |XX      | $F757
       .byte $80 ; |X       | $F758
       .byte $00 ; |        | $F759
       .byte $00 ; |        | $F75A
       .byte $00 ; |        | $F75B
       .byte $01 ; |       X| $F75C
       .byte $03 ; |      XX| $F75D
       .byte $07 ; |     XXX| $F75E
       .byte $FF ; |XXXXXXXX| $F75F
       .byte $FF ; |XXXXXXXX| $F760
       .byte $FF ; |XXXXXXXX| $F761
       .byte $00 ; |        | $F762
       .byte $00 ; |        | $F763
       .byte $00 ; |        | $F764
       .byte $00 ; |        | $F765
       .byte $00 ; |        | $F766
       .byte $FF ; |XXXXXXXX| $F767
       .byte $E0 ; |XXX     | $F768
       .byte $C0 ; |XX      | $F769
       .byte $80 ; |X       | $F76A
       .byte $80 ; |X       | $F76B
       .byte $80 ; |X       | $F76C
       .byte $F0 ; |XXXX    | $F76D
       .byte $00 ; |        | $F76E
       .byte $00 ; |        | $F76F
       .byte $00 ; |        | $F770
       .byte $00 ; |        | $F771
       .byte $00 ; |        | $F772
       .byte $00 ; |        | $F773
       .byte $00 ; |        | $F774
       .byte $00 ; |        | $F775
       .byte $00 ; |        | $F776
       .byte $00 ; |        | $F777
       .byte $00 ; |        | $F778
       .byte $80 ; |X       | $F779
       .byte $80 ; |X       | $F77A
       .byte $00 ; |        | $F77B
       .byte $00 ; |        | $F77C
       .byte $00 ; |        | $F77D
       .byte $00 ; |        | $F77E
       .byte $FF ; |XXXXXXXX| $F77F
       .byte $00 ; |        | $F780
       .byte $00 ; |        | $F781
       .byte $00 ; |        | $F782
       .byte $00 ; |        | $F783
       .byte $00 ; |        | $F784
       .byte $00 ; |        | $F785
       .byte $00 ; |        | $F786
       .byte $00 ; |        | $F787
       .byte $00 ; |        | $F788
       .byte $07 ; |     XXX| $F789
       .byte $FF ; |XXXXXXXX| $F78A
       
LF78B: .byte $86 ; |X    XX | $F78B
       .byte $86 ; |X    XX | $F78C
       .byte $C0 ; |XX      | $F78D
       .byte $D2 ; |XX X  X | $F78E
       .byte $08 ; |    X   | $F78F
       .byte $08 ; |    X   | $F790
       .byte $80 ; |X       | $F791
       .byte $1C ; |   XXX  | $F792
       .byte $88 ; |X   X   | $F793
       .byte $CA ; |XX  X X | $F794
       .byte $44 ; | X   X  | $F795
       .byte $00 ; |        | $F796
       .byte $08 ; |    X   | $F797
       .byte $FF ; |XXXXXXXX| $F798
       
LF799: .byte $0F ; |    XXXX| $F799
       .byte $07 ; |     XXX| $F79A
       .byte $08 ; |    X   | $F79B
       .byte $05 ; |     X X| $F79C
       .byte $1F ; |   XXXXX| $F79D
       .byte $0F ; |    XXXX| $F79E
       .byte $08 ; |    X   | $F79F
       .byte $03 ; |      XX| $F7A0
       .byte $08 ; |    X   | $F7A1
       .byte $04 ; |     X  | $F7A2
       .byte $0A ; |    X X | $F7A3
       .byte $0F ; |    XXXX| $F7A4
       .byte $18 ; |   XX   | $F7A5
       .byte $0A ; |    X X | $F7A6
       .byte $08 ; |    X   | $F7A7
       .byte $03 ; |      XX| $F7A8
       
LF7A9: .byte $00 ; |        | $F7A9
       .byte $FF ; |XXXXXXXX| $F7AA
       .byte $01 ; |       X| $F7AB
       .byte $00 ; |        | $F7AC
       .byte $01 ; |       X| $F7AD
       .byte $00 ; |        | $F7AE
       .byte $00 ; |        | $F7AF
       .byte $FF ; |XXXXXXXX| $F7B0
       .byte $FF ; |XXXXXXXX| $F7B1
       .byte $00 ; |        | $F7B2
       .byte $00 ; |        | $F7B3
       .byte $01 ; |       X| $F7B4
       .byte $00 ; |        | $F7B5
       .byte $01 ; |       X| $F7B6
       .byte $FF ; |XXXXXXXX| $F7B7
       
       
;this is some kind of repeated array of color palettes
;that relates to the current game number.  I'm sure a lot of early games do it this way
COLOR_TABLE: 
       .byte $00; I don't think this byte gets used


P0_COLOR:
       .byte $DA
P1_COLOR:
       .byte $3A
PLAYFIELD_COLOR:
       .byte $27
BACKGROUND_COLOR:
       .byte $74
       
;repeat?
       .byte $5A ; | X XX X | $F7BD
       .byte $98 ; |X  XX   | $F7BE
       .byte $36 ; |  XX XX | $F7BF
       .byte $E4 ; |XXX  X  | $F7C0
       .byte $7A ; | XXXX X | $F7C1
       .byte $E8 ; |XXX X   | $F7C2
       .byte $2A ; |  X X X | $F7C3
       .byte $33 ; |  XX  XX| $F7C4
       .byte $EA ; |XXX X X | $F7C5
       .byte $9A ; |X  XX X | $F7C6
       .byte $46 ; | X   XX | $F7C7
       .byte $00 ; |        | $F7C8
       .byte $16 ; |   X XX | $F7C9
       .byte $66 ; | XX  XX | $F7CA
       .byte $98 ; |X  XX   | $F7CB
       .byte $09 ; |    X  X| $F7CC
       .byte $0F ; |    XXXX| $F7CD
       .byte $00 ; |        | $F7CE
       .byte $08 ; |    X   | $F7CF
       .byte $0A ; |    X X | $F7D0
       .byte $11 ; |   X   X| $F7D1
       .byte $77 ; | XXX XXX| $F7D2
       .byte $77 ; | XXX XXX| $F7D3
       .byte $05 ; |     X X| $F7D4
       .byte $22 ; |  X   X | $F7D5
       .byte $44 ; | X   X  | $F7D6
       .byte $11 ; |   X   X| $F7D7
       .byte $11 ; |   X   X| $F7D8
       .byte $11 ; |   X   X| $F7D9
       .byte $55 ; | X X X X| $F7DA
       .byte $11 ; |   X   X| $F7DB
       .byte $55 ; | X X X X| $F7DC
       .byte $11 ; |   X   X| $F7DD
       .byte $05 ; |     X X| $F7DE
       .byte $22 ; |  X   X | $F7DF
       .byte $77 ; | XXX XXX| $F7E0
       .byte $33 ; |  XX  XX| $F7E1
       .byte $77 ; | XXX XXX| $F7E2
       .byte $77 ; | XXX XXX| $F7E3
       .byte $77 ; | XXX XXX| $F7E4
       .byte $11 ; |   X   X| $F7E5
       .byte $77 ; | XXX XXX| $F7E6
       .byte $77 ; | XXX XXX| $F7E7
       .byte $05 ; |     X X| $F7E8
       .byte $22 ; |  X   X | $F7E9
       .byte $11 ; |   X   X| $F7EA
       .byte $11 ; |   X   X| $F7EB
       .byte $55 ; | X X X X| $F7EC
       .byte $44 ; | X   X  | $F7ED
       .byte $44 ; | X   X  | $F7EE
       .byte $11 ; |   X   X| $F7EF
       .byte $55 ; | X X X X| $F7F0
       .byte $55 ; | X X X X| $F7F1
       .byte $07 ; |     XXX| $F7F2
       .byte $22 ; |  X   X | $F7F3
       .byte $77 ; | XXX XXX| $F7F4
       .byte $77 ; | XXX XXX| $F7F5
       .byte $55 ; | X X X X| $F7F6
       .byte $77 ; | XXX XXX| $F7F7
       .byte $77 ; | XXX XXX| $F7F8
       .byte $77 ; | XXX XXX| $F7F9
       .byte $77 ; | XXX XXX| $F7FA
       .byte $77 ; | XXX XXX| $F7FB
   ;the tail end of the ROM might not be used
   
	.byte $00 ; |        | $F7FC
	.byte $F0 ; |XXXX    | $F7FD
	.byte $00 ; |        | $F7FE
	.byte $F0 ; |XXXX    | $F7FF


	;org $F7FC;4K ROM
	;.word	Start
	;.word	Start