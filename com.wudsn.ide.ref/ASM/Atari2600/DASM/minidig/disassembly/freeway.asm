; Freeway for the Atari 2600 VCS
;
; Copyright 1981 Activision Inc.
; By David Crane
;
; Reverse-Engineered by Bill Heineman
;
; 18.10.2K Made compilable with DASM 
; by Manuel Polik (101.36834@germanynet.de)

; Equates for all the WRITE only registers for the
; Atari 2600

VSYNC	=	$00	;Vertical sync set-clear
VBLANK	=	$01	;Vertical blank set-clear
WSYNC	=	$02	;Wait for leading edge of horizontal blank
RSYNC	=	$03	;Reset horizontal sync counter
NUSIZ0	=	$04	;Number size Player Missile 0
NUSIZ1	=	$05	;Number size Player Missile 1
COLUP0	=	$06	;Color-lum Player 0
COLUP1	=	$07	;Color-lum Player 1
COLUPF	=	$08	;Color-lum playfield
COLUBK	=	$09	;Color-lum background
CTRLPF	=	$0A	;Ctrol playfield ball size & collisions
REFP0	=	$0B	;Reflect player #0
REFP1	=	$0C	;Reflect player #1
PF0	=	$0D	;First 4 bits of playfield
PF1	=	$0E	;Middle 8 bits of playfield
PF2	=	$0F	;Last 8 bits of playfield
RESP0	=	$10	;Reset player #0 X coord
RESP1	=	$11	;Reset player #1 X coord
RESM0	=	$12	;Reset missile #0 X coord
RESM1	=	$13	;Reset missile #1 X coord
RESBL	=	$14	;Reset ball
AUDC0	=	$15	;Audio control 0
AUDC1	=	$16	;Audio control 1
AUDF0	=	$17	;Audio frequency 0
AUDF1	=	$18	;Audio frequency 1
AUDV0	=	$19	;Audio volume 0
AUDV1	=	$1A	;Audio volume 1
GRP0	=	$1B	;Pixel data player #0
GRP1	=	$1C	;Pixel data player #1
ENABL	=	$1F	;Ball enable register
HMP0	=	$20	;Horizontal motion Player #0
HMP1	=	$21	;Horizontal motion Player #1
HMBL	=	$24	;Horizontal motion Ball
HMOVE	=	$2A	;Add horizontal motion to registers
HMCLR	=	$2B	;Clear horizontal motion registers
CXCLR	=	$2C	;Clear collision registers

; Collision registers

CXM0P	=	$00	;Read collision M0-P1/M0-P0
CXM1P	=	$01	;Read collision M1-P0/M1-P1
CXP0FB	=	$02	;Read collision P0-PF/P0-BL
CXP1FB	=	$03	;Read collision P1-PF/P1-BL
CXM0FB	=	$04	;Read collision M0-PF/M0-BL
CXM1FB	=	$05	;Read collision M1-PF/M1-BL
CXBLPF	=	$06	;Read collision BL-PF/-----
CXPPMM	=	$07	;Read collision P0-P1/M0-M1
INPT0	=	$08	;Paddle #0
INPT1	=	$09	;Paddle #1
INPT2	=	$0A	;Paddle #2
INPT3	=	$0B	;Paddle #3
INPT4	=	$0C	;Misc input #0
INPT5	=	$0D	;Misc input #1

; 6532 equates

RIOTDATAA		=	$0280
RIOTDATAB		=	$0282
RIOTTIMER		=	$0284
RIOTSETTIMER1		=	$0294
RIOTSETTIMER8		=	$0295
RIOTSETTIMER64		=	$0296
RIOTSETTIMER1024	=	$0297

; Memory equates

GameNumber 			= $80	;Current game variation being played (0-7)
FrameCounter 			= $81	;Inc'd every video frame
Polynomial 			= $82	;Random number polynomial
SelectDelay			= $83	;Timer for select autorepeat
Player1Joy			= $84	;Player 1's joystick value
Player2Joy			= $85	;Player 2's joystick value
SaverColor			= $86	;$00 for normal, Random for screen saver
LumMask				= $87	;$FF for color, $0F for B&W and $07 for saver
ZColorScore			= $88	;Score color and Activision color
ZColorChicken			= $89	;Chicken color
ZColorLine			= $8A	;Street line color
ZColorPavement			= $8B	;Pavement color
ZColorBlack			= $8C	;Tire/black
ZColorSidewalk			= $8D	;Sidewalk color
ChickenYs			= $8E	;Y coords for Player 1 and 2's chickens / 2 Bytes

Chick0LaneCollide	= $90	;Lane where chicken #1 hit a car
Chick1LaneCollide	= $91	;Lane where chicken #2 hit a car
ChickP0Collide		= $92	;Collision flag from VCS
ChickP1Collide		= $93	;Collision flag from VCS
CurrentCarColor		= $94	;Current color of the car shape
LaneNumber		= $95	;Lane currently being drawn
CarXDirection		= $96	;1 or -1 for car X motion
ZCarPatterns		= $97	;Current size and multiples of cars / 10 Bytes

CarMotionTimers		= $A1	;Timer before car is moved	/ 10 Bytes
CarMotions		= $AB	;Motion values for each car / 10 Bytes

LChickPtrs16		= $B5	;Pointers for each chick per 16 scan lines / 12 Bytes

RChickPtrs16		= $C1	;Pointers for each chick per 16 scan lines / 12 Bytes
ZCarColors		= $CD	;Colors for all the cars / 10 Bytes

; I assume there are 7 pointers in a row here

CarShapePtr		= $D7	;Pointer to current car shape / 2 Bytes
ChickLeftShapePtr	= $D9	;Pointer to chicken shape #0 / 2 Bytes
ChickRightShapePtr	= $DB	;Pointer to chicken shape #1 / 2 Bytes

; The order of the 4 pointers below is important!

ScoreShape01Ptr		= $DD	;Pointer to left score first digit / 2 Bytes
ScoreShape11Ptr		= $DF	;Pointer to right score first digit / 2 Bytes

ScoreShape02Ptr		= $E1	;Pointer to left score second digit / 2 Bytes
ScoreShape12Ptr		= $E3	;Pointer to right score second digit / 2 Bytes

; All variables from here to $FF are zero'd out every new game

SaverTimer			= $E5	;If < 127 then in screen saver mode
GameTimer			= $E6	;If 0 then game is in progress
Scores				= $E7	;Player scores (BCD) / 2 Bytes
FrameCounterHi			= $E9	;Inc'd every 256 frames
ChickenSounds			= $EA	;True if a chicken was hit (Timer for clucking) / 2 Bytes
CarXCoords			= $EC	;Array of automobile X coords / 10 Bytes
TempX1				= $F6	;Temp X coord

; These temp variables cannot be used in a subroutine, they are in the stack

TempHonkDistance	= $F7	;Distance from a car to a chicken
TempCarSpeed		= $F8	;Speed of the car
TempCarX		= $F9	;X coord of the car
TempCarPattern		= $FA	;Car speed pattern
TempCarFacing		= $FB	;Facing of the car
TempCarXWrap		= $FC	;Wrapped X coord of a car
TempClosestDist		= $FD	;Closest car's distance
TempClosestFacing	= $FE	;Closest car's facing

	processor 6502
	ORG	$F000

	SEI			;Disable IRQ's
	CLD			;Binary mode

	LDX	#0		;Kill all of zero page
WarmStart	LDA	#0	;Zap memory
LOOPA	STA	$00,X
	TXS			;Place here to set stack to #$FF
	INX			;at end of loop
	BNE	LOOPA

	JSR	ResetGameVars	;Clear out the game variables

; Main game loop

MainLoop	LDX	#6-1
LOOPB	LDA	BaseColors,X	;Get the colors
	EOR	SaverColor	;Screen saver
	AND	LumMask	;B&W mask
						
	STA	ZColorScore,X	;Save the adjusted colors
	CPX	#4
	BCS	NoHardW
	STA	COLUP0,X	;Set the hardware default
NoHardW	DEX
	BPL	LOOPB

	STX	Chick0LaneCollide	;X = FF
	STX	Chick1LaneCollide	;Chicken's didn't hit a car
	STA	WSYNC	;Wait a line
	STA	RESBL	;Reset the ball
	LDA	#$22	;Set the horizontal ball motion (+2)
	STA	HMBL
	STA	ENABL	;Enable the ball (02)
	LDA	#40	;X position for score digit #1
	INX	;X = 00
	STX	COLUPF	;Black playfield (Ball)
	JSR	SetMotionRegsX	;Position digit #1
	LDA	#48	;X position for score digit #2
	STA	CTRLPF	;($30) No Reflect,No Score,Low Priority,8 pixel wide ball
	INX	;X = 01
	JSR	SetMotionRegsX	;Position digit #2

	LDA	#$04	;Two copies wide
	STA	NUSIZ0	;Two pairs of score digits
	STA	NUSIZ1

	LDA	ZColorScore	;Color of the score
	LDY	GameTimer	;Game in progress
	BNE	NormalScore
	LDY	FrameCounterHi	;Frames/256
	CPY	#32
	BCC	NoTimeInc	;Not time yet?
	INC	GameTimer	;Inc the game over timer
NoTimeInc	CPY	#30
	BCC	NormalScore
	LDA	FrameCounter	;Use the frame counter for a color
	AND	LumMask	;Fixed lum
NormalScore	STA	COLUP0	;Save the score color
	STA	COLUP1

;
; Now display the player's scores at the top of the screen
;

LOOPC	LDA	RIOTTIMER	;Wait for the proper scan line
	BNE	LOOPC

;
; 1 line of playfield
;

	STA	WSYNC	;Wait for sync
	STA	HMOVE	;Add horizontal motion to position sprites
	STA	VBLANK	;Enable video
	STA	CXCLR	;Clear collision registers

;
; Display the scores (8 scan lines)
; 61 cycle loop
;

	LDY	#7	;7 lines to display
LOOPD	STA	WSYNC	;3 Wait for sync
	STA	HMCLR	;3 Clear horizontal motion
	LDA	(ScoreShape01Ptr),Y	;5 Get the shape for player #0's score
	STA	GRP0	;3
	LDA	(ScoreShape02Ptr),Y	;5
	STA	GRP1	;3
	JSR	Waste18	;18 Wait for it to be displayed
	LDA	(ScoreShape11Ptr),Y	;5 Get the shape for player #1's score
	STA	GRP0	;3
	LDA	(ScoreShape12Ptr),Y	;5
	STA	GRP1	;3
	DEY	;2
	BPL	LOOPD	;3

;
; Waste 1 scan line to prepare to draw the sidewalk
;

	LDA	#$40	;Move the chickens 4 pixels to the left
	STA	HMP1
	STA	WSYNC	;Wait a line
	STA	HMOVE	;Add horizontal motion
	INY	;Y = 0
	STY	GRP0	;Clear the player shapes (Don't draw score)
	STY	GRP1
	LDA	#$08
	STA	REFP0	;Reverse player #0
	LDA	LChickPtrs16+11	;Get the topmost chicken shape
	STA	ChickLeftShapePtr
	LDA	RChickPtrs16+11
	STA	ChickRightShapePtr
	LDY	#8+1	;8 scan lines of sidewalk and 1 of border
	STA	HMCLR	;Clear horizontal motion registers

;
; Draw the first black line between the score and the sidewalk
;

	STA	WSYNC
	STA	HMOVE	;Add horizontal motion
	LDA	ZColorBlack	;Draw the black line
	STA	COLUBK
	LDA	ZColorChicken	;Set the chicken's color
	STA	COLUP1

;
; Just draw lines with the chicken on the sidewalk and 1 black line
;

LOOPE	STA	WSYNC
	LDA	ZColorSidewalk	;Assume sidewalk color
	CPY	#1	;Bottom line?
	BNE	NotLine
	LDA	ZColorBlack	;Draw a black line
NotLine	STA	COLUBK	;Set the background color
	LDA	(ChickLeftShapePtr),Y	;First chicken shape
	STA	GRP1
	JSR	Waste14
	LDA	(ChickRightShapePtr),Y
	STA	GRP1
	DEY
	BNE	LOOPE

;
; Now I need 3 scan lines to position the car
;

	STA	WSYNC	;Sync video
	STA	HMOVE	;Add horizontal motion (Draw black line)
	LDA	ZColorPavement	;Force pavement
	STA	COLUBK
	LDA	#10-1	;Init the lane count (10 lanes)
	STA	LaneNumber
	LDA	(ChickLeftShapePtr),Y	;First chicken (Y=0)
	STA	GRP1
	NOP	;10 cycles
	NOP
	NOP
	NOP
	NOP
	LDA	(ChickRightShapePtr),Y	;Second chicken
	STA	GRP1
	LDX	LaneNumber	;X = (10-1)
	LDA	LChickPtrs16+1,X	;Get the chick shape for the first lane
	STA	ChickLeftShapePtr
	LDA	RChickPtrs16+1,X
	STA	ChickRightShapePtr

;
; I will draw a lane of the highway
;

DrawALane	LDY	#15	;15 lines to draw
	LDA	#0	;A = 0
	STA	WSYNC

;
; Line 1 is just pavement and setup for car position
;

	STA	HMOVE	;(0) 3 Add horizontal motion
	STA	PF1	;(3) 3 Clear out the highway pattern (A=0)
	STA	PF2	;(6) 3
	STA	COLUPF	;(9) 3 Playfield is black
	LDA	(ChickLeftShapePtr),Y	;(12) 5 First shape byte
	STA	GRP1	;(17) 3
	LDA	ZCarColors,X	;(20) 4 Get the color of the car
	STA	CurrentCarColor	;(24) 3
	LDA	CarMotions,X	;(27) 4 Get the DEX count for car course position
	AND	#$0F	;(31) 2 Only use lower 4 bits
	STA	TempX1	;(33) 3
	LDA	(ChickRightShapePtr),Y	;(36) 5 Get player #2's shape
	DEY	;(41) 2 Y = 14
	STA	GRP1	;(43) 3 Draw it
	LDA	ZCarPatterns,X	;(46) 4 Get the width of the shape
	AND	#7	;(50) 2
	STA	NUSIZ0	;(52) 3
	CMP	#5	;(55) 2 Double wide?
	BNE	ItsACar	;(57) 2/3
	LDA	#<TruckFrame-4	;(59) 2 Draw a truck
	BNE	GotCarShp	;(61) 3

ItsACar	LDA	#<CarFrame-4	;(60) 2 Draw a car
	NOP	;(62) 2

GotCarShp	STA	CarShapePtr	;(64) 3 Save the car's shape
	LDA	(ChickLeftShapePtr),Y	;(67) 5
	STA	GRP1	;(72) 3

;
; Line 2 is pavement and actually setting the car position
;

	LDA	ZCarPatterns,X	;(75) 4
	BMI	CarOnRight	;(79) 2/3 (Car is on the right side)

;
; Set the car position for the left side
;

	LDX	TempX1	;(81) 3
	CPX	#3	;(84) 2
	LDA	(ChickRightShapePtr),Y	;(86) 5 Get the right chicken shape

;
; IMPORTANT!!!! This routine MUST start at cycle 91!!!
;

LOOPF	DEX	;(91) 2
	BPL	LOOPF	;2/3
	STA	RESP0	;3 Position the car on the left side
	BCS	DelayOk	;2/3 Too close to the left
	JSR	Waste12	;Waste 12 cycles
DelayOk	DEY	;2 Y = 13
	STA	GRP1	;3 Right chicken
	LDX	LaneNumber	;3
	LDA	CarMotions,X	;4 Fine horizonal position for car
	STA	HMP0	;3
	LDA	ZColorBlack	;3 Black color for tires
	JMP	BeginLaneLoop	;3

;
; Draw the right chicken first, then position the car on the right
; IMPORTANT!!!! This routine MUST start at cycle 82!!!
;

CarOnRight	NOP	;(82) 2 4 cycles
	NOP	;(84) 2
	STA	CXCLR	;(86) 3 Clear collisions
	LDX	LaneNumber	;(89) 3
	LDA	CarMotions,X	;(92) 4 Get the fine motion
	STA	HMP0	;(96) 3 Set now
	LDA	TempX1	;(99) 3 Get the course cycle count
	SEC	;(102) 2
	SBC	#30/5	;(104) 2 Remove 30 cycles (121-91)
	TAX	;(106) 2
	LDA	(ChickRightShapePtr),Y	;(108) 5 Get the right shape
	DEY	;(113) 2 Y = 13
	STA	GRP1	;(115) 3 Draw it
	LDA	ZColorBlack	;(118) 3 Start with black tires

;
; IMPORTANT!!!! This routine MUST start at cycle 121!!!
;

LOOPG	DEX	;(121) Course adjustment
	BPL	LOOPG
	STA	RESP0	;Set the car on the right side

;
; Draw the car in the lane, I enter with Black in A
; and then change to the proper color so I can draw the tires in black
; and the rest of the car in the proper color
;

BeginLaneLoop	STA	WSYNC	;Sync
LOOPH	STA	HMOVE	;Add horizontal motion
	STA	COLUP0	;Save the car color (Or black for the tires)
	LDA	(CarShapePtr),Y	;Get the car shape
	STA	GRP0	;Draw it
	LDA	ChickP1Collide	;Did player #2 get hit by a car? (Previous line)
	ORA	CXPPMM
	STA	ChickP1Collide
	STA	CXCLR	;Clear collisions
	LDA	(ChickLeftShapePtr),Y	;Get the chicken shape
	STA	GRP1
	CPY	#6	;At the bottom of the car?
	LDA	ChickP0Collide	;Check for car collision
	ORA	CXPPMM
	STA	ChickP0Collide
	STA	CXCLR	;Clear collisions again! (For player #2)
	LDA	(ChickRightShapePtr),Y	;Set player #2's chicken
	STA	GRP1
	BCC	FinishLane	;No more? (Fall through is only 2 cycles)
	DEY	;Count down
	.byte $8D, $2B, $00 ; This is STA HMCLR, absolute adressed!
						;4 Clear horizontal motion registers (4 cycles)
	LDA	CurrentCarColor	;Get the car color
	EOR	SaverColor	;Screen saver
	AND	LumMask
	JMP	LOOPH	;Loop

;
; Now, I finished drawing the car in the NORMAL color,
; let's draw the bottom tires
;

FinishLane	LDA	ZColorBlack	;Get black
	DEY	;Y = 4
	STA	WSYNC	;Sync
	STA	HMOVE	;Add horizontal motion
	STA	COLUP0
	LDA	(CarShapePtr),Y	;Draw the bottommost tires
	STA	GRP0
	LDA	ChickP1Collide	;Check for Player #2's chicken death
	ORA	CXPPMM
	STA	ChickP1Collide
	STA	CXCLR	;Clear collisions
	LDA	(ChickLeftShapePtr),Y	;Right player
	STA	GRP1
	NOP	;2
	LDA	ChickP0Collide	;Save player 1's collision value (Final for lane)
	ORA	CXPPMM
	STA	ChickP0Collide
	STA	CXCLR	;Clear collisions
	LDA	(ChickRightShapePtr),Y	;Draw the right chicken
	STA	GRP1
	DEY	;Y = 3

;
; Now, clear the car sprite and wrap up player 2's collision register
; Draw only pavement
;

	STA	WSYNC	;Sync
	STA	HMOVE	;Add horizontal motion
	LDA	#0	;Kill the car shape
	STA	GRP0
	LDA	(ChickLeftShapePtr),Y	;Draw the left chicken
	STA	GRP1
	LDX	LaneNumber	;Which lane am I in?
	BIT	ChickP0Collide	;Did I hit?
	BPL	NoHitP0
	STX	Chick0LaneCollide	;Save the lane number of the collision
NoHitP0	LDA	ChickP1Collide	;Get player #2
	ORA	CXPPMM	;Add the current hardware
	BPL	NoHitP1	;Did I hit?
	STX	Chick1LaneCollide	;Save the collision
NoHitP1	LDA	(ChickRightShapePtr),Y	;Get the chicken shape
	STA	GRP1	;Draw it
	STA	CXCLR	;Clear collisions
	DEY	;Y = 2
	LDA	LaneNumber	;Are we in the final lane?
	BEQ	WrapUp	;Finish and draw sidewalk if so...

;
; I need to draw the center divider or the single white line
; I will draw 3 lines, Either the lines will be drawn...
; Pavement,White,Pavement or
; Chicken,Pavement,Chicken
;

	LDX	ZColorPavement	;Get the pavement color
	CMP	#5	;Should I draw the center divider?
	BNE	DrawWhiteLane	;Draw the regular white lines
	LDX	ZColorChicken	;Use the chicken's color for the lines
DrawWhiteLane	STA	WSYNC
	STA	HMOVE	;Add horizontal motion
	LDA	#$AA	;Draw the line patter
	STA	PF0	;Write the highway line pattern
	STA	PF2
	LSR	;Reverse bits A = $55
	STA	PF1	;Middle bits
	STX	COLUPF	;Save the color (Pavement or chicken)
	LDA	(ChickLeftShapePtr),Y	;First chicken
	STA	GRP1
	DEC	LaneNumber	;Next lane
	LDA	(ChickRightShapePtr),Y
	STA	GRP1
	DEY	;Y = 1

;
; Center line (Pavement or white)
;

	STA	WSYNC
	STA	HMOVE	;Add horizontal motion
	CPX	ZColorChicken	;Am I drawing the center divider?
	BNE	NotCenter3
	LDA	#0	;I will also force the cars to face right
	STA	REFP0	;Don't reverse player #0
	LDA	ZColorPavement	;No center line
	JMP	Pavement

NotCenter3	LDA	ZColorLine	;White line color
Pavement	STA	COLUPF	;Change the line color
	LDA	(ChickLeftShapePtr),Y	;First chicken
	STA	GRP1
	JSR	Waste12	;Waste 12 cycles
	LDA	(ChickRightShapePtr),Y	;Second chicken
	STA	GRP1
	DEY	;Y = 0

;
; Final line (Chicken or pavement)
;

	STA	WSYNC
	STA	HMOVE	;Add horizontal motion
	STX	COLUPF
	LDA	(ChickLeftShapePtr),Y
	STA	GRP1
	LDX	LaneNumber	;Get the lane number
	LDA	LChickPtrs16+1,X	;Set the chick shape pointers for the next lane
	STA	ChickLeftShapePtr
	LDA	RChickPtrs16+1,X
	STA	TempX1	;Can't use yet...
	NOP
	LDA	(ChickRightShapePtr),Y	;Final right chicken shape
	STA	GRP1
	LDA	TempX1	;Grab from temp
	STA	ChickRightShapePtr	;Now I can use it
	LDA	#0	;Clear the collision masks
	STA	ChickP0Collide
	STA	ChickP1Collide
	STA	PF0	;Clear out the left most highway pattern
	JMP	DrawALane	;The other two are cleared at the beginning

;
; Now, draw the last lines of the chicken (Y == 2 on entry)
;

WrapUp	STA	WSYNC	;Sync
	STA	HMOVE	;Add horizontal motion
	LDA	(ChickLeftShapePtr),Y	;Get the left chicken
	STA	GRP1
	JSR	Waste14	;Waste 26 cycles
	JSR	Waste12
	LDA	(ChickRightShapePtr),Y	;Get the right chicken
	STA	GRP1
	DEY	;Looped 3 times?
	BPL	WrapUp	;All done?

;
; Now draw the sidewalk on the bottom of the screen
; I must loop with Y == 15 to compensate for the Chicken pointers
;

	LDY	#9+6	;9 scan lines to draw
LOOPI	LDA	ZColorSidewalk	;Assume sidewalk color
	STA	WSYNC	;Sync
	STA	HMOVE	;Border
	CPY	#9+6	;Topmost black line?
	BNE	NotBlk2
	LDA	ZColorBlack	;Draw black
NotBlk2	STA	COLUBK	;Save the color
	LDA	LChickPtrs16	;Bottommost chicken pointers
	STA	ChickLeftShapePtr
	LDA	RChickPtrs16
	STA	ChickRightShapePtr
	LDA	(ChickLeftShapePtr),Y	;Draw the left chicken
	STA	GRP1
	LDA	(ChickRightShapePtr),Y	;Draw the right chicken
	DEY
	STA	GRP1
	CPY	#6	;All done?
	BCS	LOOPI

;
; Draw the activision logo
; 1 line of black to prepare, then draw it
;

	STA	WSYNC	;Wait for video sync
	STA	HMOVE
	LDA	ZColorBlack	;Black line
	STA	COLUBK
	LDX	#0	;Clear the shape register
	STX	GRP1
	STX	HMCLR	;Clear horizontal motion registers
	INX	;X = 1
	STX	NUSIZ0	;3 shapes, close together
	STX	NUSIZ1
	STA	RESP0	;Set the x coord (16)
	STA	RESP1	;X coord (25) (16+9)
	LDA	#$10	;Move player #1 one pixel to the left
	STA	HMP1
	LDA	ZColorScore	;Score color
	STA	COLUP0
	STA	COLUP1

;
; Now draw the 8 lines
; Note : All the activision shapes end with a shape of zero,
; this way, I can assume the video display is pure black after the loop
; is finished.
;

	LDX	#8-1	;8 scan lines
LOOPJ	STA	WSYNC
	STA	HMOVE	;3 Move the players (Only first time)
	LDA	Activision1,X	;4 Draw the shape
	STA	GRP0	;3
	LDA	Activision2,X	;4 Draw in player #1
	STA	GRP1	;3
	NOP	;2 Waste 2 cycles
	LDA	Activision4,X	;4 Preload the final 2 bytes
	TAY	;2
	LDA	Activision3,X	;4
	STA	GRP0	;3 Store in shape (Cycle 32)
	STY	GRP1	;3
	STA	HMCLR	;3 Clear horizontal motion registers for future loops
	DEX	;2 All done?
	BPL	LOOPJ	;3 Loop

;
; The video display is now finished, let's time to the vertical blank
; (It's black anyways)
;

	LDA	#26	;Init the vertical blank timer
	STA	RIOTSETTIMER64

;
; Update a score value and process each player EVERY OTHER FRAME!
; I do this since I want the chickens to move 30 pixels a second instead
; of 60. Turbo chickens aren't much fun.
;

	LDA	FrameCounter	;Player 1 or 2 (Update 30 FPS)
	AND	#1
	TAX	;0/1
	ASL
	TAY	;0/2
	LDA	Scores,X	;Get the score (BCD)
	AND	#$F0	;Mask it
	LSR	;$00,$08,$10,$18,$20
	BNE	NotZero
	LDA	#<ChickFrameX	;Space character
NotZero	STA	ScoreShape01Ptr,Y	;Insert a space (Or digit)
	LDA	Scores,X	;Get the BCD number again
	AND	#$0F	;0-9
	ASL	;Mul by 8
	ASL
	ASL	;$00,$08,$10,$18,$20
	STA	ScoreShape02Ptr,Y	;Save the second digit

	LDY	#0	;Preload Y so the sound may be muted
	JSR	ReadConsoleSwitches	;Get the console switches (Affect's A)
	BPL	SetVol2	;Reset pressed?

;
; Process sound effects from the players
; $8F = Got a point
; $5C = Cluck!
;

	LDA	ChickenSounds,X	;Was the chicken moving down by impact?
	BEQ	CheckSelect	;No sound effect
	AND	#$40	;$40-$5C?
	BEQ	GotPoint
	LDA	#4	;Div 2 / Pure tone
	STA	AUDC0,X
	DEC	ChickenSounds,X	;Count down the sound timer
	LDA	ChickenSounds,X	;Get the value
	AND	#$1F	;0-27
	CMP	#16
	BCC	SetVol2	;Volume is zero (Y=0)
	PHA
	AND	#3	;0-3
	ADC	#3-1	;3-6
	STA	AUDF0,X	;Set the frequency
	PLA
	LDY	#4	;Medium volume
SetVol2	STY	AUDV0,X	;Save the volume

	CMP	#0	;No more?
	BNE	DontKillSnd1
	LDA	#0	;Shut off the sound
	STA	ChickenSounds,X	;No more clucking...

DontKillSnd1	LDA	RIOTDATAB	;Get the difficulty switches
	AND	DiffSwitchTbl,X	;Hard?
	BEQ	EndSound	;Nope
	LDA	#6	;Reset the chicken to the bottom on impact
	STA	ChickenYs,X
EndSound	JMP	SkipAmbientSnd

;
; I got a point!
;

GotPoint	LDA	ChickenSounds,X	;Get the clucking timer
	STA	AUDV0,X	;Set the volume using it
	LDA	#12	;Div 31 pure tone
	STA	AUDC0,X
	TXA	;0/1
	ADC	#6	;6/7
	STA	AUDF0,X
	DEC	ChickenSounds,X	;Count down the sound timer
	LDA	ChickenSounds,X	;Done?
	AND	#$0F
	BNE	JmpEndSnd
	LDA	#0	;Kill the sound
	STA	ChickenSounds,X
JmpEndSnd	JMP	SkipAmbientSnd	;End

;
; Check for game select and play a honking horn if so.
; Play amibent sounds (Motors, honking)
;

CheckSelect	LDA	SelectDelay	;Is the select switch held down?
	CMP	#8	;Check the time
	LDA	#2	;Choose a horn
	BCS	HonkHorn	;Honk!
	LDA	GameTimer	;Game in progress?
	BEQ	DoAmbient
	LDA	#0	;Don't play any sound if the game is over
	STA	AUDV0,X	;Clear the volume (Kill voice)
	BEQ	JmpEndSnd	;JMP

DoAmbient	LDA	ChickenSounds	;Any sound effect present?
	ORA	ChickenSounds+1
	BNE	TryMotor

	LDA	Polynomial	;Get the random number value
	EOR	#$40
	CMP	#$E0
	BCC	TryMotor	;No sound now
	LDA	Polynomial
	EOR	FrameCounter	;Real random
	AND	#$3F
	BEQ	TryMotor
	LDA	Polynomial	;Get the value

;
; Honk a horn
;

HonkHorn	AND	#3	;1 of 4 horns to play
	ORA	#4	;Pitch 4-7
	STA	AUDF0
	SEC
	SBC	#1	;Pitch 3-6
	STA	AUDF1
	LDA	#1	;4 bit polynomial
	STA	AUDC0
	STA	AUDC1
	STA	AUDV0	;Set volume to minimum
	STA	AUDV1	;for both voices
	BNE	JmpEndSnd	;JMP

;
; Play a car's motor if it's speed changes
;

TryMotor	LDA	ChickenYs,X	;Get the Y coord
	LSR	;Div by 16 for the lane
	LSR
	LSR
	LSR
	TAY
	CPY	#10
	BCC	LaneNumOk
	LDY	#9	;Force bottom lane
LaneNumOk	LDA	#0	;Going right?
	CPY	#5
	BCC	FacingRight
	LDA	#1	;Going left..
FacingRight	STA	TempCarFacing	;0-1

	LDA	ZCarPatterns,Y	;Get the car pattern for the lane
	STA	TempCarPattern	;Save the pattern
	LSR
	LSR
	LSR
	LSR
	AND	#7	;Isolate the speed
	STA	TempCarSpeed	;Save speed
	CMP	#2
	LDA	#32	;Can honk if 32 pixels away
	BCC	FastCar
	LDA	#$FF	;Set the facing for a slow car
	STA	TempCarFacing
	LDA	#16	;Honk if 16 pixels away
FastCar	STA	TempHonkDistance

	LDA	#3	;5 bit poly -< 4 bit poly
	STA	AUDC0,X
	LDA	CarXCoords,Y	;Get the X coord
	STA	TempCarX
	LDA	#127	;Maximum distance
	STA	TempClosestDist
	LDA	TempCarFacing	;0,1,-1
	STA	TempClosestFacing	;Assume this is the closest facing

	LDA	TempCarPattern	;Get width in pixels of car
	AND	#7
	ASL
	ASL
	ORA	#3	;Round up to end of table
	TAY	;Index

LOOPK	LDA	TempCarFacing	;Get the facing (0,1,-1)
	STA	TempX1
	CLC
	LDA	CarGroupXs,Y	;Get the base X
	ADC	TempCarX	;Add to true X
	CMP	#160
	BCC	NoXWrap
	SBC	#160	;Wrap around
NoXWrap	STA	TempCarXWrap	;Save the X

	LDA	TrueChickenXs,X	;Get the chicken
	SEC
	SBC	TempCarXWrap	;Get the difference
	BCS	DiffPositive
	EOR	#$FF	;Negate it
	INC	TempX1	;0,1,2
DiffPositive	CMP	TempClosestDist	;Closer?
	BCS	NotCloser
	STA	TempClosestDist	;Save the new distance
	LDA	TempX1	;Save the facing
	STA	TempClosestFacing
NotCloser	DEY
	TYA
	AND	#3	;All done?
	BNE	LOOPK

	LDA	TempClosestDist	;Will a car honk?
	CMP	TempHonkDistance
	BCC	IllHonk
	LDA	#15	;5 bit poly div 6
	STA	AUDC0,X
	LDA	#31	;Very low pitch (1 Khz)
	STA	AUDF0,X
	LDA	#1	;Minimum volume
	STA	AUDV0,X
	JMP	SkipAmbientSnd	;Done

;
; Honk the horn
;

IllHonk	DEC	TempHonkDistance	;Dec the distance to the car 15,31
	EOR	TempHonkDistance	;Reverse volume based on distance
	LSR	;Lower for the VCS
	LSR
	STA	AUDV0,X	;Set the volume
	LDY	TempClosestFacing	;-1,0,1,2
	INY	;0-3
	LDA	MotorPitchs,Y	;Get the pitch
	CLC
	ADC	TempCarSpeed	;Add the car's speed
	STA	AUDF0,X	;Set the frequency

;
; Blend the random number generator
;

SkipAmbientSnd	LDA	FrameCounter	;Only mix every 32 frames
	AND	#$1F
	BNE	NoRandom
	LDA	Polynomial	;Adjust the random number generator
	ASL
	ASL
	ASL
	EOR	Polynomial
	ASL
	ROL	Polynomial

;
; Move the cars in the upper 5 lanes
;

NoRandom	LDA	GameTimer	;Game in progress (if == 0)
	BNE	WaitHere
	LDX	#9
	LDA	#-1	;Make cars move to the left
	STA	CarXDirection
LOOPL	JSR	MoveACar
	DEX
	CPX	#5
	BCS	LOOPL

;
; Process VBlank here
;

WaitHere	LDA	RIOTTIMER	;Wait until the timer says ok!
	BNE	WaitHere

	LDY	#$82	;Enable video blank flags
	STY	WSYNC	;Sync to HBlank
	STY	VBLANK	;Enable vertical blank and dump I0-I3 to ground
	STY	VSYNC	;Enable vertical sync signal
	STY	WSYNC	;Wait 3 scan lines
	STY	WSYNC
	STY	WSYNC
	STA	VSYNC	;Disable vertical sync signal (A=0)

;
; Inc the frame counters and timers
;

	INC	FrameCounter	;Inc the frame counter
	BNE	NoRollSv	;255 frames?
	INC	FrameCounterHi	;High byte of the frame counter
	INC	SaverTimer	;Inc the screen saver timer
	BNE	NoRollSv	;Zero?
	SEC	;Keep the high byte set
	ROR	SaverTimer	;= $80

NoRollSv	LDY	#$FF	;Assume normal color
	LDA	RIOTDATAB	;B&W set?
	AND	#$08
	BNE	Color
	LDY	#$0F	;Force b&w
Color	TYA	;Place in A
	LDY	#0	;Assume screen saver not active
	BIT	SaverTimer	;Screen saver active?
	BPL	NoSaver8
	AND	#$F7	;Halve the brightness
	LDY	SaverTimer	;Get the timer value for the random colors
NoSaver8	STY	SaverColor	;Save the random saver scrambler
	ASL	SaverColor	;0,2,4 etc...
	STA	LumMask	;$FF,$0F,$07

	LDA	#44
	STA	WSYNC	;Wait for scan line
	STA	RIOTSETTIMER64	;Set the timer for start of screen

;
; Move the cars in the lower 5 lanes
;

	LDA	GameTimer	;Game in progress (if == 0)
	BNE	ReadJoysticks
	LDX	#4
	LDA	#1	;Make cars move to the right
	STA	CarXDirection
LOOPM	JSR	MoveACar
	DEX
	BPL	LOOPM

;
; Read the joysticks
;

ReadJoysticks	LDA	RIOTDATAA	;Read the joystick
	TAY
	AND	#$0F
	STA	Player2Joy	;Save player 2's joystick
	TYA
	LSR
	LSR
	LSR
	LSR
	STA	Player1Joy	;Save player 1's joystick
	INY
	BEQ	NoJoy	;No joystick pressed
	LDA	#0	;Joystick is pressed
	STA	SaverTimer

NoJoy	LDA	Polynomial	;Make sure the polynomial is non-zero!
	BNE	DoConsole
	INC	Polynomial
	BNE	NewSel

DoConsole	JSR	ReadConsoleSwitches	;Read the console
	BMI	ChkSelect	;Reset pressed?
	LDX	#SaverTimer	;Yep, reset the game
	JMP	WarmStart

ChkSelect	LDY	#0	;Was select pressed? (Init Y)
	BCS	SaveSelDelay	;Nope (Clear select delay)

	LDA	SelectDelay	;Select the next game
	BEQ	NotHeld
	DEC	SelectDelay
	BPL	NotSelTime
NotHeld	INC	GameNumber	;Inc the game selected
NewSel	JSR	ResetGameVars

	LDA	GameNumber	;Make sure the game number is 0-7
	AND	#7
	STA	GameNumber
	STA	SaverTimer
	ORA	#$A0	;Space / Digit
	TAY
	INY
	STY	Scores	;$A1-$A8 Space/1-8
	LDA	#$AA	;Space/space
	STA	Scores+1
	LDY	#30	;Game over!
	STY	GameTimer
SaveSelDelay	STY	SelectDelay	;30/60 delay (1/2 second or 0)

NotSelTime	LDA	GameTimer	;Game in progress? (if == 0)
	BEQ	MoveTheChickens
	JMP	MainLoop	;Loop

;
; Move both player's either up or down.
; Add score if you reached the top
;

MoveTheChickens	LDX	#2-1
LOOPN	LDA	ChickenSounds,X	;Override?
	BEQ	Normal1
	AND	#$10	;Force down...
	BNE	ForceDown
	BEQ	NotDown	;JMP

Normal1	LDA	Player1Joy,X	;Pressing up?
	LSR
	BCS	NotUp	;Nope
	INC	ChickenYs,X	;Move 1 pixel up
	LDY	ChickenYs,X	;At the top?
	CPY	#178
	BCC	NotUp	;Nope
	SED	;BCD
	LDA	Scores,X	;Add 1 to the score
	ADC	#1-1
	STA	Scores,X
	CLD	;HEX
	LDA	#$8F	;Start the sound effect for a point
	STA	ChickenSounds,X
	BNE	ForceBottom	;JMP

NotUp	LSR	;See if going down
	BCS	NotDown
ForceDown	DEC	ChickenYs,X	;Move down 1
	LDA	ChickenYs,X
	CMP	#6	;At the bottom
	BCS	NotDown
ForceBottom	LDA	#6	;Set to the bottom
	STA	ChickenYs,X

NotDown	LDA	ChickenSounds,X	;Am I playing a clucking sound?
	AND	#$1F
	CMP	#$17
	BCS	Next
	LDA	Chick0LaneCollide,X	;Am I hitting a car?
	BMI	Next
	LDA	#92	;Reset the sound
	STA	ChickenSounds,X
Next	DEX	;Next chicken...
	BPL	LOOPN

;
; Get the pointers to the chickens' shapes
;

	LDX	#0	;Player #1
	JSR	CalcChickShapePtr	;Get the pointer
	STA	LChickPtrs16,Y	;Save the pointer
	CPY	#11	;Topmost?
	BEQ	NoChick4
	CLC
	ADC	#16
	STA	LChickPtrs16+1,Y
NoChick4	INX
	JSR	CalcChickShapePtr
	STA	RChickPtrs16,Y
	CPY	#11
	BEQ	AlterCarSpeeds
	CLC
	ADC	#16
	STA	RChickPtrs16+1,Y

;
; Check if I need to speed up or slow down the cars
;

AlterCarSpeeds	LDA	FrameCounter	;Time?
	AND	#$70
	BNE	JmpMain
	LDA	GameNumber	;Easy game?
	AND	#4
	BEQ	JmpMain

	LDA	FrameCounter	;Get the frame count
	AND	#$0F	;Update 1 lane per frame
	TAX
	CPX	#10	;Only 10 lanes
	BCS	JmpMain
	LDA	ZCarPatterns,X	;Get the speed of this lane
	LSR
	LSR
	LSR
	LSR
	AND	#7	;Isolate the speed
	TAY	;Save in Y
	LDA	FrameCounter	;Get the random number
	EOR	Polynomial
	LSR	;Check low bit (1 = speed up)
	BCC	NotFaster
	DEY	;Speed up the car
	BPL	NotFaster
	LDY	#0	;No faster than zero
NotFaster	LSR	;Check bit #1 (1 = slow down)
	BCC	GotSpeed
	INY	;Slow down a bit
	CPY	#6
	BCC	GotSpeed
	LDY	#5	;Slowest speed
GotSpeed	TYA
	ASL	;Put back the speed value
	ASL
	ASL
	ASL
	STA	TempX1	;Save in temp
	LDA	ZCarPatterns,X	;Get the pattern
	AND	#$8F	;Mask speed
	ORA	TempX1	;Blend new speed
	STA	ZCarPatterns,X	;Save the pattern
JmpMain	JMP	MainLoop

; Reset the game variables

ResetGameVars	LDA	FrameCounter	;Reset the frame counter
	AND	#1			;But allow updating of the chickens
	STA	FrameCounter

	LDX	#2-1	;2 players
LOOPO	LDA	#6	;Move to the bottom
	STA	ChickenYs,X
	LDA	#0	;Reset the volume of the audio chip
	STA	AUDV0,X
	DEX
	BPL	LOOPO

	LDX	#14-1
	LDA	#>FontPage
LOOPP	STA	CarShapePtr,X	;Init the high byte for video pointers
	DEX
	DEX
	BPL	LOOPP

	LDX	#10-1	;10 lanes
LOOPQ	LDA	#1	;Allow motion in 2 frames
	STA	CarMotionTimers,X
	LDA	CarColors,X	;Copy the car colors
	STA	ZCarColors,X
	CLC
	LDA	GameNumber	;Get the traffic pattern
	AND	#3
	TAY
	TXA
	ADC	Mul10Tbl1,Y	;Mul 0-3 by 10
	TAY
	LDA	CarPatterns,Y	;Save the pattern
	STA	ZCarPatterns,X
	LDA	#$60	;Horizontal motion (+6 pixels)
	STA	CarMotions,X
	LDA	#<ChickFrameX	;No chickens are drawn
	STA	LChickPtrs16,X	;Zap all the tables
	STA	LChickPtrs16+4,X
	STA	RChickPtrs16+2,X
	DEX
	BPL	LOOPQ
	RTS

;
; Given a requested X coord in A,
; return in A and Y and Horizonal offset and the cycle delay
;

CalcXRegs	CLC
	ADC	#46
	TAY
	AND	#$F	;Mask the 4 bit offset
	STA	TempX1	;Save temp
	TYA	;Get value again
	LSR	;Isolate the upper 4 bits
	LSR
	LSR
	LSR
	TAY	;Save as a WSYNC Delay
	CLC
	ADC	TempX1	;Mod 15
	CMP	#15
	BCC	NoExcess
	SBC	#15	;Remove one step
	INY	;5 more cycles
NoExcess	EOR	#7	;Negate horizontal offset
	ASL	;Move to upper 4 bits (Hardware)
Waste18	ASL		;2 Call to waste 18 cycles
	ASL	;2
Waste14	ASL	;2 Call to waste 14 cycles
Waste12	RTS	;6 Call to waste 12 cycles

;
; Set the horizontal motion registers
;

SetMotionRegsX	JSR	CalcXRegs	;Calculate the values
	STA	HMP0,X	;Save the horizontal motion register
	STA	WSYNC	;Sync to video
LOOPR	DEY	;Wait for cycle delay (5 cycles per)
	BPL	LOOPR
	STA	RESP0,X	;Hit the register for course adjustment
	RTS	;Exit

;
; Move a car either left or right
; Note : I also will clear the chick shape values
;

MoveACar	DEC	CarMotionTimers,X	;Time to move it yet?
	BPL	NoMoveNow	;Nope
	LDA	ZCarPatterns,X	;Get the car's speed
	LSR
	LSR
	LSR
	LSR
	AND	#7	;0-7
	SEC
	SBC	#1	;-1-6
	BPL	NotFast	;2 pixels a frame?
	LDA	CarXCoords,X
	CLC
	ADC	CarXDirection	;Add the car direction now
	STA	CarXCoords,X
	LDA	#0	;Reset the timer
NotFast	STA	CarMotionTimers,X

	LDA	CarXCoords,X
	CLC
	ADC	CarXDirection	;Add the car direction
	CMP	#200	;Off the left side?
	BCC	NotHigh
	LDA	#159	;Wrap around
NotHigh	CMP	#160	;Off the right side?
	BCC	InRange
	LDA	#0	;Wrap around
InRange	STA	CarXCoords,X

NoMoveNow	LDA	CarXCoords,X	;Get the X coord of a car
	JSR	CalcXRegs
	STA	TempX1	;Save the horiz registers
	DEY	;-15 from the cycle count
	DEY
	DEY
	ASL	ZCarPatterns,X	;Save the carry
	CPY	#6	;Set carry if on the right side (Clear on left)
	ROR	ZCarPatterns,X	;Put the flag back
	TYA
	ORA	TempX1	;Get the horiz reg value
	STA	CarMotions,X	;Save the motion registers
	LDA	#<ChickFrameX	;Assume all chickens are blank
	STA	LChickPtrs16,X
	STA	RChickPtrs16+2,X
	STA	LChickPtrs16+4,X
	RTS

;
; Figure out which lane I shall draw the chicken
;

CalcChickShapePtr	LDA	ChickenYs,X	;Get the Y
	LSR	;/ by 16 to get the lane
	LSR
	LSR
	LSR
	TAY
	LDA	ChickenYs,X	;Get the Y again
	AND	#$F	;Mask
	STA	TempX1	;Save in a temp
	LDA	ChickenSounds,X	;Chicken in normal mode?
	BEQ	Normal2
	AND	#$40	;Not in pain...
	BEQ	Normal2
	LDA	ChickenYs,X	;Test bit #2
	LSR
	LSR
	LSR
	LDA	#<ChickFrame3	;If !(&4), use a sqwak frame
	BCC	GotFrame
Normal2	LDA	TempX1	;Get the scan line
	LSR
	LSR
	LSR
	LDA	#<ChickFrame1	;Use for lines !(&4)
	BCC	GotFrame
	LDA	#<ChickFrame2	;Use for lines &4
GotFrame	SEC
	SBC	TempX1	;Subtract from the scan line
	RTS

;
; Read the console switches from the 6532 RIOT chip
; Bits are...
; $01 Reset
; $02 Select
; $08 Color
; $40 Difficulty Left
; $80 Difficulty Right
; Carry = Select, Negative = Reset
;

ReadConsoleSwitches
	LDA	RIOTDATAB	;Read the switches
	LSR	;Shift the reset switch
	ROR	;Rotate reset to negative flag
	RTS	;and Carry has select

	HEX	250C250D	;Not used... (Filler)

;
; Activision logo bit map
;

Activision1	.byte	%00000000
			.byte	%10101101
			.byte	%10101001
			.byte	%11101001
			.byte	%10101001
			.byte	%11101101
			.byte	%01000001
			.byte	%00001111

Activision2	.byte	%00000000
			.byte	%01010000
			.byte	%01011000
			.byte	%01011100
			.byte	%01010110
			.byte	%01010011
			.byte	%00010001
			.byte	%11110000

Activision3	.byte	%00000000
			.byte	%10111010
			.byte	%10001010
			.byte	%10111010
			.byte	%10100010
			.byte	%00111010
			.byte	%10000000
			.byte	%11111110

Activision4	.byte	%00000000
			.byte	%11101001
			.byte	%10101011
			.byte	%10101111
			.byte	%10101101
			.byte	%11101001
			.byte	%00000000
			.byte	%00000000

;
; Size and shapes for each traffic pattern for the 8 games
;

CarPatterns	HEX	50403020101020304050	;Game #1,#5
	HEX	40312213041514233241	;Game #2,#6
	HEX	46362016050016203646	;Game #3,#7
	HEX	05152515050515251505	;Game #4,#8

;
; Base colors
;

BaseColors	HEX	4A	;Score and Activision color
	HEX	1E	;Chicken / Median color
	HEX	0C	;Line color
	HEX	06	;Pavement color
	HEX	00	;Tire color
	HEX	08	;Sidewalk color

CarColors	HEX	1AD8448824824A12DC42	;Colors for each lane of cars

;
; Must not cross page boundaries!!
; All shapes are upside down to allow decrementing by Y as both
; a counter and a shape index
;
	ORG $F700
;
; Numeric font
;

FontPage	.byte	%00111100
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%00111100

			.byte	%00111100
			.byte	%00011000
			.byte	%00011000
			.byte	%00011000
			.byte	%00011000
			.byte	%00011000
			.byte	%00111000
			.byte	%00011000

			.byte	%01111110
			.byte	%01100000
			.byte	%01100000
			.byte	%00111100
			.byte	%00000110
			.byte	%00000110
			.byte	%01000110
			.byte	%00111100

			.byte	%00111100
			.byte	%01000110
			.byte	%00000110
			.byte	%00001100
			.byte	%00001100
			.byte	%00000110
			.byte	%01000110
			.byte	%00111100

			.byte	%00001100
			.byte	%00001100
			.byte	%00001100
			.byte	%01111110
			.byte	%01001100
			.byte	%00101100
			.byte	%00011100
			.byte	%00001100

			.byte	%01111100
			.byte	%01000110
			.byte	%00000110
			.byte	%00000110
			.byte	%01111100
			.byte	%01100000
			.byte	%01100000
			.byte	%01111110

			.byte	%00111100
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%01111100
			.byte	%01100000
			.byte	%01100010
			.byte	%00111100

			.byte	%00011000
			.byte	%00011000
			.byte	%00011000
			.byte	%00011000
			.byte	%00001100
			.byte	%00000110
			.byte	%01000010
			.byte	%01111110

			.byte	%00111100
			.byte	%01100110
			.byte	%01100110
			.byte	%00111100
			.byte	%00111100
			.byte	%01100110
			.byte	%01100110
			.byte	%00111100

			.byte	%00111100
			.byte	%01000110
			.byte	%00000110
			.byte	%00111110
			.byte	%01100110
			.byte	%01100110
			.byte	%01100110
			.byte	%00111100

;
; Chicken frame with no shape
;

ChickFrameX	.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000

ChickFrame1	.byte	%00110000
			.byte	%01100000
			.byte	%01111000
			.byte	%11111000
			.byte	%10111000
			.byte	%00001100
			.byte	%00000110
			.byte	%00000100
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000

ChickFrame2	.byte	%00011000
			.byte	%00110000
			.byte	%01111000
			.byte	%11111000
			.byte	%10111000
			.byte	%00011000
			.byte	%00001100
			.byte	%00001000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000

ChickFrame3	.byte	%01100000
			.byte	%00110000
			.byte	%01111000
			.byte	%11111000
			.byte	%10111000
			.byte	%00111100
			.byte	%00101000
			.byte	%01000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000
			.byte	%00000000

CarFrame	.byte	%01100110
			.byte	%11111110
			.byte	%11001111
			.byte	%10110011
			.byte	%10110011
			.byte	%10110011
			.byte	%10110011
			.byte	%11001111
			.byte	%11111110
			.byte	%01100110
			.byte	%00000000

TruckFrame	.byte	%10000101
			.byte	%11111111
			.byte	%10000101
			.byte	%11111101
			.byte	%11111101
			.byte	%11111101
			.byte	%11111101
			.byte	%10000101
			.byte	%11111111
			.byte	%10000101

Mul10Tbl1	.byte	0,10,20,30
CarGroupXs	.byte	0,0,0,0	;X coord for each car group
			.byte	0,0,16,16
			.byte	0,0,0,32
			.byte	0,0,16,32
			.byte	0,0,0,64
			.byte	0,0,0,0
			.byte	0,0,32,64
TrueChickenXs	.byte	48,104	;Chicken Xs
MotorPitchs	.byte	16,16,17,16	;Base pitches for motors

	ORG $F7FC
			.word $f000 ;          Reset

DiffSwitchTbl	HEX	4080	;Left,Right difficulty flags