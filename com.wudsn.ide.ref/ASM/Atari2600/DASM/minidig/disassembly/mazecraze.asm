; Disassembly of maze.bin
; Disassembled Fri Feb 08 23:31:38 2002
; Using DiStella v2.0
;
; Command Line: D:\MYDOCU~1\DESKTOP\ATARI2~1\_EMULA~1\DISTELLA\DISTELLA.EXE -a maze.bin 
;

VSYNC   =  $00
VBLANK  =  $01
WSYNC   =  $02
RSYNC   =  $03
NUSIZ0  =  $04
NUSIZ1  =  $05
COLUPF  =  $08
COLUBK  =  $09
CTRLPF  =  $0A
REFP0   =  $0B
REFP1   =  $0C
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESP0   =  $10
AUDC0   =  $15
AUDF0   =  $17
AUDV0   =  $19
AUDV1   =  $1A
GRP0    =  $1B
GRP1    =  $1C
ENAM0   =  $1D
ENAM1   =  $1E
ENABL   =  $1F
HMP0    =  $20
HMBL    =  $24
VDELP0  =  $25
VDELBL  =  $27
HMOVE   =  $2A
SWCHA   =  $0280
SWCHB   =  $0282
INTIM   =  $0284
TIM8T   =  $0295
TIM64T  =  $0296
LFEAD   =   $FEAD
LFEEB   =   $FEEB
LFEF8   =   $FEF8
LFF19   =   $FF19

       ORG $F000
LF000: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$F0,$60,$90
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$77,$22,$22,$33
       .byte $22,$77,$11,$77,$44,$77,$77,$44,$66,$44,$77,$44,$44,$77,$55,$55
       .byte $77,$44,$77,$11,$77,$77,$55,$77,$11,$77,$44,$44,$44,$44,$77,$77
       .byte $55,$77,$55,$77,$77,$44,$77,$55,$77,$77,$55,$55,$55,$77
LF0EE: .byte $BC,$C1,$C6,$CB,$D0,$D5,$DA,$DF,$E4,$E9,$BC,$C1,$C6,$CB,$D0,$D5
       .byte $EA,$EA


	;Start of Screen?

	;F0 seems to be used as indirect pointers for Playfield data.  This initializes it.
LF100: LDA    #$F0    
       LDX    #$07    
LF104: STA    $F0,X   
       DEX            
       BNE    LF104   

       LDX    $BD     
       TXA            
       AND    #$03    
       TAY            
       LDA    LF0EE,Y 
       STA    $F6     
       TXA            
       ROL            
       ROL            
       ROL            
       AND    #$03    
       TAY            
       LDA    LF0EE,Y 
       STA    $F0     
       TXA            
       LSR            
       LSR            
       AND    #$0F    
       TAY            
       LDA    LF0EE,Y 
       STA    $F4     
       LDA    #$B4    
       CPY    #$09    
       BCC    LF133   
       LDA    #$BC    
LF133: STA    $F2     

		; draw the numbers (game select info)
       LDY    #$04    
LF137: LDX    #$02    
LF139: STA    WSYNC   
       LDA    #$00    
       STA    PF1     
       LDA    ($F0),Y 
       STA    PF0     
       LDA    ($F2),Y 
       AND    #$F0    
       STA    PF2     
       LDA    ($F4),Y 
       STA    PF0     
       JSR    LF931   
       LDA    ($F6),Y 
       AND    #$0F    
       STA    PF2     
       DEX            
       BNE    LF139   
       DEY            
       BPL    LF137   

		; clear the playfield
       INY            
       STY    PF0     
       STY    PF1     
       STY    PF2     
       STA    WSYNC   

       STX    $F4     
       STX    $F5     
       LDA    $DF     
       AND    #$03    
       BEQ    LF17E   
       LDX    #$01    
LF171: LDA    $EA,X   
       AND    #$07    
       TAY            
       LDA    LFEFD,Y 
       STA    $F4,X   
       DEX            
       BPL    LF171   

		; Loop here.  Hmmm.
LF17E: LDA    #$05    
       STA    $F0     


LF182: STA    WSYNC   
       LDA    $C0     
       STA    COLUPF  
       LDA    $F4     
       STA    PF1     
       JSR    LF931   
       LDX    $C1     
       LDY    $C2     
       STX    COLUPF  
       STY    COLUPF  
       LDA    $F5     
       STA    PF1     
       LDA    $C0     
       STA    COLUPF  
       NOP            
       NOP            
       NOP            
       NOP            
       STX    COLUPF  
       STY    COLUPF  
       DEC    $F0     
       BPL    LF182   

		; probably setup for drawing the maze
       LDA    #$00    
       STA    PF1     
       LDA    #$F0    
       STA    $F9     ; setting the high bytes of the GRP indirect addressing
       STA    $FB     ;
       LDA    $C7     
       ASL            
       CLC            
       ADC    #$00    
       STA    $F8     
       LDA    $C8     
       ASL            
       CLC            
       ADC    #$00    
       STA    $FA     
       LDX    #$02    

LF1C7: LDA    $C9,X   
       SEC            
       SBC    #$2E    
       STA    $C9,X   
       DEX            
       BPL    LF1C7   

		; Set the background color.  Must be about to draw the maze.
       LDA    $C4     
       STA    COLUBK  
       BIT    $B0     
       BMI    LF1DB   
       LDA    $C2     

LF1DB: STA    WSYNC   
       STA    COLUPF  
       STX    $F2     
       STX    $F3     
       LDY    #$07    
LF1E5: DEY            
       BNE    LF1E5   

       LDX    #$1E    	; Here's the key to the PHP trick.  Set the top of the stack to
       TXS  			; ENAM1.

       LDX    #$0B    ; 11
       LDA    $F0     


		; DRAW THE MAZE.  Here's the good stuff.
		;
		; X is used as the main counter.
		; Y indexes the player graphics
		;
		; The playfield is not reflected.
		;
		; Ball/Missiles drawn using PHP trick
		;
		; No WSyncs used in here.
		;
		; I think the loop starts a bit before the edge of the first line.
		;
		; Playfield temp variables:
		; $F2 = PF0
		; $F3 = PF0
		; $F4 = PF1
		; $F5 = PF1
		; $F6 = PF2
		; $F7 = PF2
		; 
		; $C9 = M0
		; $CA = M1
		; $CB = BL
		;
		; $F8 = indirect GRP0
		; $FA = indirect GRP1
		; 
		;
		; ******************************************************************************************
LF1EF: LDA    $8C,X   
       ORA    #$AA 		; 10101010  This explains how the maze is so big.
       STA    $F4   	; He's only using every other byte for the PF data.  
       STA    PF1     

       LDA    $CA     
       AND    #$FE    	; 11111110
       PHP            	; Enable M1

       LDA    $C9     
       AND    #$FE    	; 11111110
       PHP            	; Enable M0

       LDA    $F2     	; The first line probably starts about here.
       STA    PF0  

       LDA    ($FA),Y
       STA    GRP1    

       LDA    $98,X   
       ORA    #$55    	; 01010101 Here's another instance of his trick of
       STA    $F6     	; using every other byte for PF data.
       STA    PF2     

       LDA    $F3     	; pf0
       STA    PF0     

       LDA    $A4,X   	; pf1
       ORA    #$AA    	; 10101010
       STA    $F5     
       STA    PF1     

       LDA    $B0,X   	; pf2
       ORA    #$55    	; 01010101
       AND    #$7F    	; 01111111
       STA    PF2     
       STA    $F7     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F2     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $F3     
       STA    PF0     

       PLA            
       PLA            
       PLA            	; Roll the stack back to ENABL

       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     

       INC    $CB     	; What's this part?
       LDA    $B0,X   	; Something to do with changing the color
       BMI    LF255   	; of the playfield...
       LDA    $C2     
       BNE    LF258   

LF255: NOP            
       LDA    $C4     

LF258: STA    COLUPF  

       LDA    $F2     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       INC    $CA     	; M0
       INC    $C9     	; M1

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    $F3     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     
       LDA    $CB     
       AND    #$FE    
       PHP            
       LDA    $F2     
       STA    PF0     
       LDA    $CA     
       AND    #$FE    
       PHP            
       LDA    $C9     
       AND    #$FE    
       PHP            
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    $F3     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     
       LDA    $80,X   
       AND    #$55    
       STA    $F0     
       ASL            
       ASL            
       ASL            
       ASL            
       STA    $F1     
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F2     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $F3     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       PLA            
       PLA            
       PLA            
       LDA    $F7     
       STA    PF2     
       INC    $CB     
       INC    $CA     
       INC    $C9     
       LDA    $F2     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    $CB     
       AND    #$FE    
       PHP            
       LDA    $F3     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     
       NOP            
       LDA    $F0     
       LDA    $8C,X   
       AND    #$AA    
       STA    $F4     
       STA    PF1     
       LDA    $CA     
       AND    #$FE    
       PHP            
       LDA    $C9     
       AND    #$FE    
       PHP            
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F0     
       STA    PF0     
       LDA    $98,X   
       AND    #$55    
       STA    $F6     
       STA    PF2     
       LDA    $F1     
       STA    PF0     
       LDA    $A4,X   
       AND    #$AA    
       STA    $F5     
       STA    PF1     
       LDA    $B0,X   
       AND    #$55    
       STA    PF2     
       STA    $F7     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F0     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $F1     
       STA    PF0     
       PLA            
       PLA            
       PLA            
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     
       LDA    $7F,X   
       ORA    #$55    
       STA    $F2     
       ASL            
       ASL            
       ASL            
       ASL            
       STA    $F3     
       LDA    $F0     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       INC    $CB     
       INC    $CA     
       INC    $C9     
       LDA    $F1     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    $CB     
       AND    #$FE    
       PHP            
       LDA    $F0     
       STA    PF0     
       LDA    $CA     
       AND    #$FE    
       PHP            
       LDA    $C9     
       AND    #$FE    
       PHP            
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $F1     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       INC    $CB     
       INC    $CA     
       INC    $C9     
       LDA    ($FA),Y 
       STA    GRP1    
       LDA    $F0     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $F1     
       STA    PF0     
       PLA            
       PLA            
       PLA            
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       STA    PF2     

       INY            
       LDA    ($F8),Y 
       STA    GRP0    
       LDA    $F0     
       STA    PF0     
       LDA    $F4     
       STA    PF1     
       LDA    $F6     
       STA    PF2     
       LDA    $CB     
       AND    #$FE    
       PHP            
       DEC    $F4     
       DEC    $F4     
       DEC    $F4     
       LDA    $F1     
       STA    PF0     
       LDA    $F5     
       STA    PF1     
       LDA    $F7     
       DEX            
       BMI    LF40D   
       STA    PF2     
       JMP    LF1EF   

		; done drawing maze
LF40D: LDX    #$06    
       STA    PF2     

LF411: LDA    #$00    
       STA    WSYNC   
       STA    ENAM0   
       STA    ENAM1   
       STA    ENABL   
       STA    GRP0    
       STA    GRP1    
       LDA    #$FF    
       STA    PF0     
       STA    PF1     
       STA    PF2     
       LDY    #$04    

LF429: DEY            
       BPL    LF429   
       LSR            
       STA    PF2     
       DEX            
       BNE    LF411   
       LDA    $C3     
       STA    COLUBK  
       STX    PF0     
       STX    PF1     
       STX    PF2     
       LDX    #$02    
LF43E: DEC    $C9,X   
       DEC    $C9,X   
       DEX            
       BPL    LF43E   
       TXS            
       LDA    #$26    
       STA    TIM64T  
       JSR    LF945   
LF44E: LDA    $E1     
       LSR            
       BCS    LF492   
       LDA    $BC     
       AND    #$01    
       BEQ    LF460   
       LDA    SWCHB   
       AND    #$01    
       BNE    LF48F   
LF460: LDA    SWCHB   
       AND    #$03    
       CMP    #$02    
       BNE    LF476   
       LDA    $BC     
       ORA    #$01    
       STA    $BC     
       LDA    #$00    
       STA    $DC     
       JMP    LF4BE   
LF476: LDA    SWCHB   
       AND    #$02    
       BEQ    LF495   
       LDA    #$50    
       STA    $E2     
       LDA    $BC     
       AND    #$60    
       CMP    #$40    
       BNE    LF492   
       LDA    REFP1   
       AND    PF0     
       BMI    LF492   
LF48F: JMP    LFA7E   
LF492: JMP    LF4BE   
LF495: LDA    $BC     
       ORA    #$50    
       AND    #$FE    
       STA    $BC     
       INC    $E2     
       LDA    $E2     
       CMP    #$0D    
       BCC    LF4BE   
       LDA    SWCHB   
       LSR            
       LDA    #$0C    
       BCC    LF4AF   
       LDA    #$02    
LF4AF: STA    $E2     
       INC    $BD     
       JSR    LF967   
       LDA    #$0A    
       JSR    LFB89   
       JMP    LF764   
LF4BE: LDA    REFP1   
       AND    PF0     
       ORA    #$7F    
       AND    SWCHA   
       CMP    #$FF    
       BEQ    LF4CF   
       LDA    #$00    
       STA    $DC     
LF4CF: LDX    #$01    
LF4D1: LDA    REFP1,X 
       BPL    LF4DB   
       LDA    $EA,X   
       ORA    #$10    
       STA    $EA,X   
LF4DB: DEX            
       BPL    LF4D1   
       LDA    $BD     
       ROL            
       ROL            
       ROL            
       AND    #$03    
       TAY            
       LDA    $E3     
       AND    #$07    
       BNE    LF504   
       BIT    $E3     
       LDA    $E3     
       BMI    LF4F8   
       BVS    LF4F8   
       LDA    #$40    
       ORA    $E3     
LF4F8: CLC            
       ADC    LFEE7,Y 
       STA    $E3     
       LDA    $BC     
       AND    #$60    
       BEQ    LF507   
LF504: JMP    LF6C7   
LF507: LDX    #$01    
       LDA    SWCHA   
       ASL            
       ASL            
       ASL            
       ASL            
LF510: EOR    #$F0    
       STA    $F3     
       LDA    $E0     
       AND    #$04    
       BEQ    LF535   
       LDA    $DD,X   
       BEQ    LF523   
       DEC    $DD,X   
       JMP    LF535   
LF523: LDA    REFP1,X 
       BMI    LF535   
       LDA    #$7D    
       STA    $DD,X   
       LDA    #$14    
       STA    $E1     
       LDA    $BC     
       ORA    #$02    
       STA    $BC     
LF535: LDA    SWCHB   
       AND    LFED3,X 
       BEQ    LF546   
       LDA    $E3     
       AND    #$C0    
       BNE    LF546   
       JMP    LF638   
LF546: LDA    $EA,X   
       AND    #$40    
       BNE    LF55A   
       LDA    $E4,X   
       BEQ    LF581   
       LDA    $EA,X   
       EOR    #$20    
       STA    $EA,X   
       AND    #$20    
       BEQ    LF55D   
LF55A: JMP    LF632   
LF55D: DEC    $E4,X   
       LDA    #$0F    
       STA    $F0     
       LDA    $E4,X   
       CMP    #$C8    
       BCS    LF55A   
       CMP    #$96    
       BCS    LF57B   
       LSR    $F0     
       CMP    #$64    
       BCS    LF57B   
       LSR    $F0     
       CMP    #$32    
       BCS    LF57B   
       LSR    $F0     
LF57B: AND    $F0     
       CMP    $F0     
       BNE    LF55A   
LF581: LDA    $D5,X   
       AND    #$07    
       BEQ    LF5DA   
       CMP    #$02    
       BNE    LF5D7   
       LDA    $E0     
       AND    #$80    
       BEQ    LF5D7   
       LDA    $EA,X   
       AND    #$10    
       BEQ    LF5D7   
       LDA    REFP1,X 
       BMI    LF5D7   
       LDA    $EA,X   
       AND    #$EF    
       STA    $EA,X   
       LDA    $E6,X   
       CMP    #$19    
       BEQ    LF5BA   
       LDA    $E6,X   
       STA    $C2     
       LDA    $E8,X   
       STA    $C3     
       JSR    LF9F1   
       LDA    $C4     
       EOR    #$FF    
       AND    ($C5),Y 
       STA    ($C5),Y 
LF5BA: LDA    $CE,X   
       LSR            
       LSR            
       STA    $E8,X   
       STA    $C3     
       LDA    $C7,X   
       LSR            
       STA    $E6,X   
       STA    $C2     
       JSR    LF9F1   
       LDA    $C4     
       ORA    ($C5),Y 
       STA    ($C5),Y 
       LDA    #$05    
       JSR    LFEA3   
LF5D7: JMP    LF62F   
LF5DA: LDA    $F3     
       BEQ    LF632   
       LDY    #$FF    
       STY    $F1     
       LDY    #$03    
LF5E4: STY    $F2     
       ASL    $F3     
       BCC    LF5FF   
       LDA    LFEE3,Y 
       JSR    LF990   
       BNE    LF5FF   
       LDY    $F2     
       LDA    LFEE3,Y 
       EOR    $D5,X   
       AND    #$C0    
       BNE    LF620   
       STY    $F1     
LF5FF: LDY    $F2     
       DEY            
       BPL    LF5E4   
       LDY    $F1     
       BPL    LF620   
       LDA    $EC,X   
       BNE    LF61D   
       LDA    #$1F    
       CPX    #$00    
       BEQ    LF613   
       LSR            
LF613: STA    AUDF0,X 
       LDA    #$0C    
       STA    AUDC0,X 
       LDA    #$05    
       STA    AUDV0,X 
LF61D: JMP    LF638   
LF620: LDA    $EC,X   
       BNE    LF628   
       LDA    #$01    
       STA    $EC,X   
LF628: LDA    LFEE3,Y 
       ORA    #$04    
       STA    $D5,X   
LF62F: JSR    LFD91   
LF632: LDA    $EC,X   
       BNE    LF638   
       STA    AUDV0,X 
LF638: DEX            
       BMI    LF643   
       LDA    SWCHA   
       AND    #$F0    
       JMP    LF510   
LF643: LDA    $DF     
       AND    #$03    
       BEQ    LF686   
       LDX    #$01    
LF64B: LDA    #$02    
       STA    $F5     
LF64F: LDY    $F5     
       JSR    LFCFB   
       BCC    LF66D   
       LDA    LFECD,Y 
       AND    $EA,X   
       BNE    LF66D   
       LDA    LFECD,Y 
       ORA    $EA,X   
       STA    $EA,X   
       AND    #$07    
       TAY            
       LDA    LFF21,Y 
       JSR    LFEA3   
LF66D: DEC    $F5     
       BPL    LF64F   
       DEX            
       BPL    LF64B   
       LDX    #$02    
LF676: LDA    LFECD,X 
       AND    $EA     
       AND    $EB     
       BEQ    LF683   
       LDA    #$AA    
       STA    $C9,X   
LF683: DEX            
       BPL    LF676   
LF686: LDA    $DF     
       AND    #$94    
       BEQ    LF6C7   
       LDX    #$01    
LF68E: LDY    #$04    
LF690: JSR    LFCFB   
       BCC    LF6C1   
       LDA    $E0     
       AND    #$20    
       BEQ    LF6A1   
       JSR    LFDFD   
       JMP    LF6C4   
LF6A1: LDA    $EA,X   
       AND    #$40    
       BNE    LF6C4   
       LDA    $EA,X   
       ORA    #$40    
       STA    $EA,X   
       LDA    $EA     
       AND    $EB     
       AND    #$40    
       BEQ    LF6BB   
       LDA    $BC     
       ORA    #$40    
       STA    $BC     
LF6BB: JSR    LFDDB   
       JMP    LF6C4   
LF6C1: DEY            
       BPL    LF690   
LF6C4: DEX            
       BPL    LF68E   
LF6C7: LDA    $E0     
       AND    #$40    
       BEQ    LF6ED   
       DEC    $DE     
       BNE    LF6ED   
       LDA    $BC     
       AND    #$60    
       BNE    LF6ED   
       LDA    $DD     
       CMP    #$1E    
       BCC    LF6E1   
       SBC    #$04    
       STA    $DD     
LF6E1: STA    $DE     
       LDA    #$1E    
       STA    $E1     
       LDA    $BC     
       ORA    #$02    
       STA    $BC     
LF6ED: JSR    LF8D5   
       DEC    $E3     
       LDA    $E0     
       AND    #$10    
       BEQ    LF73B   
       LDX    #$03    
LF6FA: LDA    $BC     
       AND    #$10    
       BNE    LF711   
       LDA    CTRLPF,X
       BPL    LF711   
       LDA    #$AA    
       STA    $C7,X   
       LDA    $E8,X   
       AND    #$F7    
       STA    $E8,X   
       JMP    LF734   
LF711: LDA    $E8,X   
       AND    #$08    
       BEQ    LF71F   
       LDA    $E1     
       AND    #$1F    
       CMP    #$1F    
       BNE    LF731   
LF71F: LDA    $D3,X   
       STA    $D5,X   
       LDA    $CC,X   
       STA    $CE,X   
       LDA    $C5,X   
       STA    $C7,X   
       LDA    $E8,X   
       ORA    #$08    
       STA    $E8,X   
LF731: JSR    LFD50   
LF734: DEX            
       CPX    #$02    
       BPL    LF6FA   
       BMI    LF764   
LF73B: LDA    $BC     
       AND    #$20    
       BNE    LF764   
       LDA    $E3     
       AND    #$07    
       BNE    LF764   
       LDA    $E3     
       AND    #$C0    
       BEQ    LF764   
       LDX    #$06    
       JSR    LFD50   
       DEX            
       LDA    #$40    
       JSR    LFD3D   
       DEX            
       JSR    LFD50   
       DEX            
       JSR    LFD50   
       DEX            
       JSR    LFD3B   
LF764: LDA    $E3     
       EOR    #$20    
       STA    $E3     
       JSR    LF945   
       LDX    #$01    
LF76F: LDA    $EC,X   
       CMP    #$01    
       BNE    LF77D   
       LDA    #$00    
       STA    AUDC0,X 
       LDA    #$08    
       STA    AUDV0,X 
LF77D: DEX            
       BPL    LF76F   
       LDX    #$04    
LF782: LDA    $CE,X   
       CPX    #$02    
       ADC    #$18    
       PHA            
       LSR            
       LSR            
       LSR            
       LSR            
       TAY            
       STY    $F0     
       PLA            
       AND    #$0F    
       CLC            
       ADC    $F0     
       CMP    #$0F    
       BCC    LF79D   
       SBC    #$0F    
       INY            
LF79D: CMP    #$08    
       EOR    #$0F    
       BCS    LF7A6   
       ADC    #$01    
       DEY            
LF7A6: ASL            
       STA    WSYNC   
       ASL            
       ASL            
       ASL            
       STA    HMP0,X  
LF7AE: DEY            
       BPL    LF7AE   
       STA    RESP0,X 
       DEX            
       BPL    LF782   
       LDX    #$01    
LF7B8: LDA    $EC,X   
       CMP    #$01    
       BNE    LF7C6   
       LDA    #$00    
       STA    $EC,X   
       STA    AUDV0,X 
       STA    $EE,X   
LF7C6: DEX            
       BPL    LF7B8   
       LDA    $BD     
       AND    #$03    
       STA    $F1     
       DEC    $E1     
       BNE    LF7E7   
       LDA    $BC     
       AND    #$DD    
       STA    $BC     
       LDA    #$00    
       STA    AUDV0   
       STA    AUDV1   
       INC    $DC     
       INC    $DC     
       BNE    LF7E7   
       INC    $DC     
LF7E7: LDA    $BC     
       AND    #$02    
       BEQ    LF7F1   
       LDA    #$00    
       STA    $F1     
LF7F1: LDY    #$02    
       STY    $F2     
       LDA    $BC     
       AND    #$01    
       BNE    LF82B   
       LDA    $BC     
       AND    #$10    
       BNE    LF831   
       LDA    $BC     
       AND    #$60    
       BEQ    LF831   
       CMP    #$20    
       BNE    LF822   
       LDA    $DF     
       AND    #$94    
       BEQ    LF822   
       LDA    $E1     
       AND    #$04    
       BNE    LF82B   
       LDY    #$01    
       LDA    $E3     
       AND    #$10    
       BEQ    LF82B   
       DEY            
       BPL    LF82B   
LF822: LDY    #$01    
       LDA    $CE     
       CMP    #$9C    
       BCC    LF82B   
       DEY            
LF82B: LDA    #$00    
       STA    $F1     
       STY    $F2     
LF831: LDY    $F1     
       LDX    #$0B    
LF835: TXA            
       CMP    LFF19,Y 
       BCS    LF846   
       CMP    LFF1D,Y 
       BCC    LF846   
       LDA    $B0,X   
       ORA    #$80    
       BNE    LF84A   
LF846: LDA    $B0,X   
       AND    #$7F    
LF84A: STA    $B0,X   
       DEX            
       BPL    LF835   
       LDA    $BC     
       AND    #$51    
       BEQ    LF87D   
       LDX    #$01    
LF857: LDA    $E6,X   
       STA    $C2     
       CMP    #$19    
       BEQ    LF87A   
       LDA    $E8,X   
       STA    $C3     
       JSR    LF9F1   
       LDA    $E1     
       AND    #$20    
       BEQ    LF872   
       LDA    $C4     
       ORA    ($C5),Y 
       BNE    LF878   
LF872: LDA    $C4     
       EOR    #$FF    
       AND    ($C5),Y 
LF878: STA    ($C5),Y 
LF87A: DEX            
       BPL    LF857   
LF87D: LDA    SWCHB   
       AND    #$08    
       TAY            
       BEQ    LF887   
       LDA    #$F7    
LF887: ORA    #$07    
       STA    $F3     
       LDA    $DC     
       STA    $F4     
       LSR            
       BCS    LF89F   
       LDX    #$FF    
       LDA    $BC     
       AND    #$10    
       BNE    LF89C   
       STX    $F3     
LF89C: INX            
       STX    $F4     
LF89F: LDX    #$FB    
LF8A1: LDA    LFEEB,Y 
       EOR    $F4     
       AND    $F3     
       STA    REFP0,X 
       STA    $C5,X   
       INY            
       INX            
       BMI    LF8A1   
       JSR    LFE2C   
       INX            
       JSR    LFE2C   
       LDA    #$20    
       STA    CTRLPF  
       STA    NUSIZ0  
       STA    NUSIZ1  
       LDX    $F2     
       LDA    $C0,X   
       STA    $C2     
       STA    WSYNC   
       STA    HMOVE   

LF8C9: LDA    INTIM   
       BNE    LF8C9   
       STA    WSYNC   
       STA    VBLANK  
       JMP    LF100   

LF8D5: STA    WSYNC   
LF8D7: LDA    INTIM   
       BNE    LF8D7   
       STA    WSYNC   
       LDA    #$02    
       STA    VBLANK  
       STA    WSYNC   
       STA    WSYNC   
       STA    WSYNC   
       STA    VSYNC   
       JSR    LF8FD   
       STA    WSYNC   
       LDA    #$00    
       STA    WSYNC   
       STA    VSYNC   
       LDA    #$3C    
       STA    WSYNC   
       STA    TIM64T  
       RTS            

LF8FD: LDA    $BF     
       STA    $C0     
       LDA    $BE     
       STA    $C1     
       ASL    $C1     
       ROL    $C0     
       ASL    $C1     
       ROL    $C0     
       LDA    $BE     
       ROR            
       ROR            
       AND    #$80    
       EOR    $C0     
       STA    $C0     
       LDA    $BE     
       CLC            
       ADC    $C1     
       BCC    LF921   
       INC    $BF     
       CLC            
LF921: ADC    #$19    
       STA    $BE     
       LDA    $BF     
       ADC    $C0     
       CLC            
       ADC    #$36    
       STA    $BF     
       CLC            
       ADC    $BD     
LF931: RTS            

LF932: STY    $F1     
       JSR    LF8FD   
       LDY    #$00    
       TYA            
LF93A: CLC            
       ADC    $BF     
       BCC    LF940   
       INY            
LF940: DEC    $F1     
       BPL    LF93A   
       RTS            

LF945: LDA    $E3     
       AND    #$20    
       BEQ    LF966   
       LDA    $DF     
       AND    #$10    
       BEQ    LF966   
       LDX    #$01    
LF953: LDY    $C9,X   
       LDA    $CC,X   
       STA    $C9,X   
       STY    $CC,X   
       LDY    $D0,X   
       LDA    $D3,X   
       STA    $D0,X   
       STY    $D3,X   
       DEX            
       BPL    LF953   
LF966: RTS            

LF967: LDA    $BD     
       LSR            
       LSR            
       AND    #$0F    
       TAY            
       LDA    LFF29,Y 
       STA    $DF     
       LDA    LFF39,Y 
       STA    $E0     
       LDA    $BD     
       AND    #$3F    
       TAY            
       LDA    #$94    
       CPY    #$14    
       BEQ    LF989   
       LDA    #$D4    
       CPY    #$18    
       BNE    LF98F   
LF989: STA    $DF     
       LDA    #$00    
       STA    $E0     
LF98F: RTS            

LF990: STA    $C4     
       LDA    $CE,X   
       LSR            
       LSR            
       STA    $C3     
       LDA    $C7,X   
       LSR            
       STA    $C2     
       LDA    $C4     
       JSR    LFA1F   
       LDY    #$01    
LF9A4: LDA    $00E6,Y 
       CMP    $C2     
       BNE    LF9B6   
       LDA    $00E8,Y 
       CMP    $C3     
       BNE    LF9B6   
       LDA    #$00    
       CLC            
       RTS            

LF9B6: DEY            
       BPL    LF9A4   
       LDA    $C2     
       CMP    #$17    
       BCS    LF9DF   
       LDA    $C3     
       BEQ    LF9DF   
       CMP    #$26    
       BCC    LF9F1   
       CPX    #$02    
       BCS    LF9DF   
       LDA    $DF     
       AND    #$40    
       BNE    LF9DF   
       LDA    $DF     
       AND    #$03    
       BEQ    LF9F1   
       LDA    $EA,X   
       AND    #$07    
       CMP    #$07    
       BEQ    LF9F1   
LF9DF: SEC            
       LDA    #$FF    
       RTS            

LF9E3: LDA    $C2     
       CMP    #$17    
       BCS    LF9DF   
       LDA    $C3     
       BEQ    LF9DF   
       CMP    $CB     
       BCS    LF9DF   
LF9F1: LDY    $C3     
       LDA    LFEC1,Y 
       CPY    #$18    
       BCC    LF9FD   
       LDA    LFEAD,Y 
LF9FD: STA    $C4     
       TYA            
       LSR            
       LSR            
       TAY            
       LDA    LFED9,Y 
       STA    $C5     
       LDA    $C2     
       LSR            
       TAY            
       LDA    #$00    
       STA    $C6     
       CLC            
       LDA    $C4     
       AND    ($C5),Y 
       RTS            

LFA16: LDA    $C9     
LFA18: EOR    #$80    
       JMP    LFA1F   
LFA1D: LDA    $C9     
LFA1F: ASL            
       BCS    LFA2A   
       BMI    LFA27   
       INC    $C3     
       RTS            

LFA27: DEC    $C2     
       RTS            

LFA2A: BPL    LFA2F   
       INC    $C2     
       RTS            

LFA2F: DEC    $C3     
       RTS            

LFA32: JSR    LF9E3   
       BCS    LFA43   
       BNE    LFA3D   
       LDA    #$3F    
       BNE    LFA3F   
LFA3D: LDA    #$7F    
LFA3F: AND    $BC     
       STA    $BC     
LFA43: RTS            

LFA44: LDA    $BC     
       ORA    #$C0    
       STA    $BC     
       INC    $C2     
       JSR    LFA32   
       DEC    $C2     
       DEC    $C2     
       JSR    LFA32   
       INC    $C2     
       INC    $C3     
       JSR    LFA32   
       DEC    $C3     
       DEC    $C3     
       JSR    LFA32   
       INC    $C3     
       RTS            

LFA67: JSR    LF8FD   
       AND    #$0F    
       CMP    #$0C    
       BCS    LFA67   
       ASL            
       RTS            

LFA72: .byte $20,$FD,$F8,$29,$1F,$C9,$13,$B0,$F7,$38,$2A,$60
LFA7E: LDY    #$00    
       STY    AUDV0   
       STY    AUDV1   
       LDX    #$3B    
       DEY            
LFA87: STY    $80,X   
       DEX            
       BPL    LFA87   
       LDA    $BF     
       AND    #$0F    
       STA    $CE     
       JSR    LFA67   
       STA    $C2     
       ASL            
       STA    $C7     
       STA    $C8     
       LDA    #$01    
       STA    $C3     
       STA    $D0     
       STA    $CD     
       LDA    #$06    
       STA    $CF     
       LDA    #$28    
       STA    $CB     
       LDA    #$0A    
       STA    $D3     
       LDX    #$10    
       STX    $D4     
LFAB4: LDA    $C2     
       STA    $D6,X   
       LDA    $C3     
       STA    $E7,X   
       DEX            
       BPL    LFAB4   
       JSR    LFC68   
       LDA    #$26    
       STA    $CB     
       LDA    $C2     
       STA    $D2     
       LDA    $C7     
       LSR            
       STA    $C2     
       LDA    #$01    
       STA    $C3     
       LDA    #$50    
       STA    $CD     
       JSR    LFC68   
       LDX    #$10    
       STX    $D5     
LFADE: LDX    $D5     
       LDA    $D6,X   
       STA    $C2     
       LDA    $E7,X   
       STA    $C3     
       LDA    #$18    
       STA    $CD     
       JSR    LFC68   
       DEC    $D5     
       BPL    LFADE   
       LDA    #$FF    
       STA    $D4     
       LDA    #$16    
       STA    $D7     
       LDA    #$25    
       STA    $D6     
LFAFF: LDA    $D7     
       STA    $C2     
       LDA    $D6     
       STA    $C3     
       JSR    LFA44   
       LDA    $BC     
       AND    #$40    
       BEQ    LFB56   
       JSR    LF8FD   
       STA    $C9     
       LSR            
       LDA    #$40    
       BCS    LFB1C   
       LDA    #$C0    
LFB1C: STA    $D8     
LFB1E: LDA    $C9     
       CLC            
       ADC    $D8     
       STA    $C9     
       LDA    $D7     
       STA    $C2     
       LDA    $D6     
       STA    $C3     
LFB2D: JSR    LFA1D   
       JSR    LFA1D   
       JSR    LFA44   
       LDA    $BC     
       AND    #$80    
       BNE    LFB1E   
       LDA    $BC     
       AND    #$40    
       BNE    LFB2D   
       LDA    #$05    
       STA    $CD     
       LDA    $C9     
       EOR    #$80    
       AND    #$C0    
       ORA    #$01    
       STA    $C9     
       JSR    LFC77   
       JMP    LFAFF   
LFB56: DEC    $D6     
       DEC    $D6     
       BPL    LFAFF   
       LDA    #$25    
       STA    $D6     
       DEC    $D7     
       DEC    $D7     
       BPL    LFAFF   
       LDA    #$00    
       STA    $BC     
       JSR    LF967   
       LDA    $DF     
       AND    #$03    
       TAY            
       LDA    LFF05,Y 
       STA    $EA     
       STA    $EB     
       LDA    $D2     
       JSR    LFB89   
       LDA    #$00    
       STA    $EC     
       STA    $ED     
       STA    $DC     
       JMP    LF44E   
LFB89: STA    $C4     
       LDX    #$04    
       TXA            
LFB8E: STA    $CE,X   
       DEX            
       BPL    LFB8E   
       LDA    #$AA    
       LDX    #$04    
LFB97: STA    $C9,X   
       DEX            
       BPL    LFB97   
       LDX    #$04    
LFB9E: LDA    $DF     
       AND    LFEF8,X 
       BEQ    LFBAE   
       LDA    #$94    
       STA    $D0,X   
       LDA    $C4     
       ASL            
       STA    $C9,X   
LFBAE: DEX            
       BPL    LFB9E   
       LDA    $DF     
       AND    #$01    
       BEQ    LFBD7   
       LDX    #$01    
       LDA    #$54    
LFBBB: STA    $D0,X   
       JSR    LFA67   
       ASL            
       STA    $C9,X   
       LDA    #$64    
       DEX            
       BPL    LFBBB   
       LDA    $DF     
       AND    #$02    
       BEQ    LFBD7   
       LDA    $C4     
       ASL            
       STA    $CB     
       LDA    #$94    
       STA    $D2     
LFBD7: LDA    #$80    
       LDX    #$06    
LFBDB: STA    $D5,X   
       DEX            
       BPL    LFBDB   
       LDX    #$04    
       JSR    LFD50   
       JSR    LFD50   
       JSR    LFD50   
       JSR    LF8D5   
       DEX            
       JSR    LFD50   
       DEX            
       JSR    LFD3B   
       JSR    LFD3B   
       LDX    #$00    
       STX    $E4     
       STX    $E5     
       STX    $DD     
       STX    $DE     
       INX            
       STX    $E3     
       STX    VDELP0  
       STX    VDELBL  
       LDA    $E0     
       AND    #$40    
       BEQ    LFC16   
       LDA    #$FA    
       STA    $DD     
       STA    $DE     
LFC16: LDA    #$19    
       STA    $E6     
       STA    $E7     
       RTS            

LFC1D: JSR    LFA16   
       JSR    LF9F1   
       EOR    ($C5),Y 
       STA    ($C5),Y 
       LDA    $BF     
       ORA    #$02    
       STA    COLUBK  
       JSR    LFA1D   
       LDA    $C3     
       CMP    $D0     
       BCC    LFC44   
       STA    $D0     
       LDA    $C2     
       STA    $D1     
       LDA    #$40    
       CMP    $CD     
       BCC    LFC44   
       STA    $CD     
LFC44: LDA    $C3     
       CMP    #$27    
       BCS    LFC81   
       DEC    $D3     
       BNE    LFC60   
       LDA    #$0A    
       STA    $D3     
       LDX    $D4     
       BMI    LFC60   
       LDA    $C2     
       STA    $D6,X   
       LDA    $C3     
       STA    $E7,X   
       DEC    $D4     
LFC60: DEC    $C9     
       LDA    $C9     
       AND    #$03    
       BNE    LFC77   
LFC68: LDA    $BF     
       AND    $CE     
       TAY            
       JSR    LF8FD   
       AND    #$C0    
       ORA    LFF09,Y 
       STA    $C9     
LFC77: DEC    $CD     
       BNE    LFC96   
       LDA    $CB     
       CMP    #$28    
       BCS    LFC82   
LFC81: RTS            

LFC82: DEC    $CF     
       BNE    LFC96   
       LDA    $D1     
       STA    $C2     
       LDA    $D0     
       STA    $C3     
       INC    $CF     
       LDA    #$40    
       STA    $CD     
       BNE    LFC68   
LFC96: LDA    $C9     
       STA    $CA     
       LDA    #$40    
       BIT    $BE     
       BPL    LFCA2   
       LDA    #$C0    
LFCA2: STA    $CC     
LFCA4: JSR    LFA1D   
       JSR    LFA1D   
       JSR    LFA44   
       LDA    $BC     
       AND    #$80    
       BNE    LFCBC   
       LDA    $BC     
       AND    #$40    
       BEQ    LFCBC   
       JMP    LFC1D   
LFCBC: JSR    LFA16   
       JSR    LFA16   
       LDA    $C9     
       CLC            
       ADC    $CC     
       STA    $C9     
       CMP    $CA     
       BNE    LFCA4   
       JSR    LF8FD   
       STA    $CA     
LFCD2: JSR    LFA1F   
       JSR    LF9E3   
       BCS    LFCDC   
       BEQ    LFCF3   
LFCDC: LDA    $CA     
       JSR    LFA18   
       LDA    $BF     
       ASL            
       ASL            
       ASL            
       LDA    #$40    
       BCC    LFCEC   
       LDA    #$BF    
LFCEC: ADC    $CA     
       STA    $CA     
       JMP    LFCD2   
LFCF3: LDA    $CA     
       JSR    LFA1F   
       JMP    LFC68   
LFCFB: LDA    $00C9,Y 
       CLC            
       ADC    #$01    
       CMP    $C7,X   
       BCC    LFD1D   
       LDA    $C7,X   
       ADC    #$00    
       CMP    $00C9,Y 
       BCC    LFD1D   
       LDA    $00D0,Y 
       SBC    #$03    
       CMP    $CE,X   
       BCS    LFD1C   
       ADC    #$05    
       CMP    $CE,X   
       RTS            

LFD1C: CLC            
LFD1D: RTS            


START:
       SEI            
       CLD            
       LDX    #$00    
       TXA            
LFD23: STA    VSYNC,X 
       INX            
       BNE    LFD23   
       DEX            
       TXS            
       LDA    INTIM   
       AND    #$0F    
       TAY            
       LDA    LFFE5,Y 
       STA    $BF     
       STA    TIM8T   
       JMP    LFA7E   

LFD3B: LDA    #$C0    
LFD3D: STA    $F1     
       JSR    LFDBE   

LFD42: LDA    $D5,X   
       CLC            
       ADC    $F1     
       STA    $D5,X   
       JSR    LF990   
       BNE    LFD42   
       BEQ    LFD8B   

LFD50: JSR    LFDBE   
       STA    $F1     
       LDA    #$FF    
       STA    $F2     

LFD59: LDA    $D5,X   
       CLC            
       ADC    #$40    
       STA    $D5,X   
       CMP    $F1     
       BEQ    LFD76   
       JSR    LF990   
       BNE    LFD59   
       INC    $F2     
       LDA    $F3     
       LSR            
       LSR            
       ORA    $D5,X   
       STA    $F3     
       JMP    LFD59   
LFD76: LDY    $F2     
       BMI    LFD87   
       JSR    LF932   
       LDA    $F3     
LFD7F: DEY            
       BMI    LFD87   
       ASL            
       ASL            
       JMP    LFD7F   
LFD87: AND    #$C0    
       STA    $D5,X   
LFD8B: LDA    $D5,X   
       ORA    #$04    
       STA    $D5,X   
LFD91: DEC    $D5,X   
       LDA    $D5,X   
       ASL            
       BCS    LFDB4   
       BMI    LFDB1   
       INC    $CE,X   
       INC    $CE,X   
       LDA    $CE,X   
       CMP    #$9C    
       BCC    LFDBD   
       LDA    #$FF    
       STA    $EC,X   
       LDA    #$00    
       STA    $EE,X   
       LDA    #$60    
       JMP    LFDF4   
LFDB1: DEC    $C7,X   
       RTS            

LFDB4: BPL    LFDB9   
       INC    $C7,X   
       RTS            

LFDB9: DEC    $CE,X   
       DEC    $CE,X   
LFDBD: RTS            

LFDBE: LDA    $C7,X   
       CMP    #$2D    
       BCC    LFDC7   
       PLA            
       PLA            
       RTS            

LFDC7: LDA    $D5,X   
       AND    #$07    
       BEQ    LFDD2   
       PLA            
       PLA            
       JMP    LFD91   
LFDD2: LDA    $D5,X   
       EOR    #$80    
       AND    #$C0    
       STA    $D5,X   
       RTS            

LFDDB: LDA    $DF     
       AND    #$BF    
       STA    $DF     
       LDA    #$03    
LFDE3: JSR    LFEA3   
       LDA    $E3     
       AND    #$EF    
       CPX    #$00    
       BNE    LFDF0   
       ORA    #$10    
LFDF0: STA    $E3     
       LDA    #$20    
LFDF4: ORA    $BC     
       STA    $BC     
       LDA    #$40    
       STA    $E1     
LFDFC: RTS            

LFDFD: LDA    $E4,X   
       CMP    #$D2    
       BCS    LFDFC   
       LDA    #$FA    
       STA    $E4,X   
       LDA    #$02    
       BNE    LFDE3   
LFE0B: LDA    #$15    
       CPX    #$00    
       BEQ    LFE12   
       LSR            
LFE12: STA    AUDF0,X 
       LDA    $EE,X   
       LSR            
       LSR            
       STA    $F0     
       LDA    #$0C    
       STA    AUDC0,X 
       SEC            
       SBC    $F0     
       STA    AUDV0,X 
       INC    $EE,X   
       LDA    $EE,X   
       CMP    #$28    
       BCS    LFEA1   
       RTS            

LFE2C: LDA    $DC     
       LSR            
       BCS    LFEA1   
       LDA    $BC     
       AND    #$10    
       BNE    LFEA1   
       LDA    $EC,X   
       BEQ    LFE90   
       CMP    #$FF    
       BEQ    LFEAC   
       CMP    #$05    
       BEQ    LFE0B   
       ROL            
       ROL            
       ROL            
       ROL            
       AND    #$07    
       TAY            
       LDA    LFF49,Y 
       STA    $F6     
       LDA    $EC,X   
       AND    #$0F    
       TAY            
       LDA    $EE,X   
       CPY    #$03    
       BNE    LFE5B   
       LSR            
LFE5B: CLC            
       ADC    LFFE0,Y 
       TAY            
       LDA    LFF4C,Y 
       BMI    LFE91   
       CLC            
       ADC    $F6     
       CPX    #$00    
       BEQ    LFE6D   
       LSR            
LFE6D: STA    AUDF0,X 
       LDA    $EC,X   
       CMP    #$03    
       BNE    LFE7B   
       LDA    LFF6C,Y 
       JMP    LFE7D   
LFE7B: LDA    #$08    
LFE7D: STA    AUDV0,X 
       LDA    $EC,X   
       CMP    #$03    
       BEQ    LFE89   
       LDA    #$0C    
       BNE    LFE8C   
LFE89: LDA    LFFA7,Y 
LFE8C: STA    AUDC0,X 
       INC    $EE,X   
LFE90: RTS            

LFE91: LDA    $EC,X   
       AND    #$F0    
       BEQ    LFEA1   
       LDA    $EC,X   
       SEC            
       SBC    #$20    
       STA    $EC,X   
       JMP    LFEA5   
LFEA1: LDA    #$00    
LFEA3: STA    $EC,X   
LFEA5: LDA    #$00    
       STA    $EE,X   
       STA    AUDV0,X 
       RTS            

LFEAC: LDA    $EE,X   
       CMP    #$40    
       BCS    LFEA1   
       JSR    LF8FD   
       CPX    #$00    
       BEQ    LFEBB   
       AND    #$07    
LFEBB: STA    AUDF0,X 
       LDA    #$0F    
       BNE    LFE7D   
LFEC1: BPL    LFEE3   
       RTI            

LFEC4: .byte $80,$80,$40,$20,$10,$08,$04,$02,$01
LFECD: .byte $01,$02,$04,$08,$10,$20
LFED3: .byte $40,$80,$01,$02,$04,$08
LFED9: .byte $80,$8C,$8C,$98,$98,$80,$A4,$A4,$B0,$B0
LFEE3: CPY    #$40    
       .byte $80 ;.NOOP
       BRK            
LFEE7: .byte $42 ;.JAM
       EOR    ($43,X) 
       EOR    PF2     
       ORA    ($02,X) 
       .byte $0C ;.NOOP
       ASL    VSYNC   
       BRK            
       BRK            
       .byte $42 ;.JAM
       .byte $92 ;.JAM
       CPY    VSYNC   
       ROL    $80     
       .byte $80 ;.NOOP
       .byte $04 ;.NOOP
       BPL    LFF0D   
LFEFD: EOR    #$09    
       EOR    ($01,X) 
       PHA            
       PHP            
       RTI            

LFF04: .byte $00
LFF05: .byte $00,$04,$00,$00
LFF09: .byte $01,$01,$02,$03
LFF0D: .byte $02 ;.JAM
       .byte $02 ;.JAM
       .byte $03 ;.SLO
       .byte $03 ;.SLO
       ORA    ($03,X) 
       .byte $02 ;.JAM
       ORA    ($03,X) 
       ORA    ($01,X) 
       ORA    ($00,X) 
       PHP            
       ASL            
       .byte $0F ;.SLO
LFF1D: ORA    ($04,X) 
       .byte $02 ;.JAM
       BRK            
LFF21: BRK            
       .byte $04 ;.NOOP
       .byte $04 ;.NOOP
	 BIT    NUSIZ0  
       BIT    HMBL    
       .byte $44 ;.NOOP
LFF29: BRK            
       .byte $80 ;.NOOP
       CPY    #$C4    
       .byte $03 ;.SLO
       .byte $80 ;.NOOP
