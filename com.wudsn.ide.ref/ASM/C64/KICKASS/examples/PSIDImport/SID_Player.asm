
//---------------------------------------------------------
//---------------------------------------------------------
//			SID Player (Single speed)
//---------------------------------------------------------
//---------------------------------------------------------
.var music = LoadSid("Nightshift.sid")
:BasicUpstart2(start)
start:
			lda #$00
			sta $d020
			sta $d021
			ldx #0
			ldy #0
			lda #music.startSong-1
			jsr music.init	
			sei
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			asl $d019
			lda #$7b
			sta $dc0d
			lda #$81
			sta $d01a
			lda #$1b
			sta $d011
			lda #$80
			sta $d012
			cli
this:	jmp this
//---------------------------------------------------------
irq1:  	
			asl $d019
			inc $d020
			jsr music.play 
			dec $d020
			pla
			tay
			pla
			tax
			pla
			rti
//---------------------------------------------------------
.pc=music.location "Music"
.fill music.size, music.getData(i)

//----------------------------------------------------------
// Print the music info while assembling
.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright

.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength




