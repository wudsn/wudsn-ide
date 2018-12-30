********************************
* PERDU                        *
********************************
                         ;
PERDU     JSR CMPSR      ;SCORE/RECORD
          JSR AFFREC     ;REAFFICHER LE RECORD
                         ;
PERDU1    LDA CLAVIER    ;ATTENTE D'UNE CLE PRESSEE
          BPL PERDU1     ;AUCUNE CLE PRESSEE
          BIT CLACT
          JSR DEPART     ;REINITIALISATION
          JMP BOUCLE
                         ;
********************************
* GAGNE                        *
********************************
                         ;
                         ;
GAGNE     JSR CMPSR      ;COMPARAISON SCORE/RECORD
          JSR AFFREC     ;AFFICHAGE DU RECORD
          JSR PREXPL     ;EFFACEMENT DERNIERE VITIME
          JSR XIMAGE
          LDA #$FF       ;ATTENDRE UN CHOUYA
          JSR DELAI
          JSR DELAI
          JSR DEPART1    ;INITIALISATION PARTIELLE
          JMP BOUCLE
                         ;
                         ;
                         ;
********************************
* CMPSR                        *
* COMPARAISON SCORE/RECORD ET  *
* MISE A JOUR DU RECORD.       *
********************************
                         ;
                         ;
* COMPARAISON SCORE RECORD     *
                         ;
CMPSR     LDY #$00
          LDX #$04
CMPSR1    LDA POINTS,Y   ;CHIFFRE #Y
          CMP REC,Y
          BNE CMPSR2     ;DIFFERENTS, VOIR TESTS SUIVANTS
          INY            ;CHIFFRE SUIVANT
          CPY #$05       ;DERNIER ARRIVE?
          BNE CMPSR1     ;PAS ENCORE
          RTS            ;LES 2 NOMBRES SONT EGAUX
                         ;
CMPSR2    BPL CMPSR3     ;RECORD BATTU
          RTS            ;SCORE<RECORD
                         ;
CMPSR3    LDY #$04       ;MISE A JOUR RECORD
CMPSR4    LDA POINTS,Y
          STA REC,Y
          DEY
          BPL CMPSR4
                         ;
          RTS
                         ;
                         ;
********************************
* PRSCORE                      *
********************************
                         ;
                         ;
PRSCORE   LDA #$06
          STA NOCTETS
          LDA #$08
          STA NLIGNES
                         ;
          LDA #<SCORE
          STA FORMEL
          LDA #>SCORE
          STA FORMEH
                         ;
          LDY Y1
          LDX X1
          RTS
                         ;
                         ;
********************************
* PRREC                     *
********************************
                         ;
                         ;
PRREC     LDA #$08
          STA NOCTETS
          LDA #$08
          STA NLIGNES
                         ;
          LDA #<RECORD
          STA FORMEL
          LDA #>RECORD
          STA FORMEH
                         ;
          LDY Y2
          LDX X2
          RTS
                         ;
                         ;
********************************
* PRBASES                      *
********************************
                         ;
                         ;
PRBASES   LDA #$06
          STA NOCTETS
          LDA #$08
          STA NLIGNES
                         ;
          LDA #<BASES
          STA FORMEL
          LDA #>BASES
          STA FORMEH
                         ;
          LDY Y3
          LDX X3
          RTS
                         ;
********************************
* AFFPTS                       *
* AFFICHAGE DU SCORE           *
********************************
                         ;
                         ;
AFFPTS    LDA #$04
          STA TEMP       ;COMPTEUR
          LDA #>ZERO
          STA FORMEH
          LDA XSC
          STA XNBRE
          LDA YSC
          STA YNBRE
                         ;
                         ;
AFFPTS1   LDY TEMP
          LDA POINTS,Y   ;VALEUR DU CHIFFRE #Y
          TAY
          LDA CHIFFRE,Y  ;ADRESSE DE LA FORME CORRESPONDANTE
          STA FORMEL
          LDY YNBRE
          LDX XNBRE
          LDA #$01
          STA NOCTETS
          LDA #$07
          STA NLIGNES
          JSR IMAGE
                         ;
          DEC XNBRE
          DEC TEMP
          BPL AFFPTS1
                         ;
          RTS
                         ;
                         ;
                         ;
                         ;
********************************
* AFFREC                       *
* AFFICHAGE DU SCORE           *
********************************
                         ;
                         ;
AFFREC    LDA #$04
          STA TEMP       ;COMPTEUR
          LDA #>ZERO
          STA FORMEH
          LDA XREC
          STA XNBRE
          LDA YREC
          STA YNBRE
                         ;
                         ;
AFFREC1   LDY TEMP
          LDA REC,Y      ;VALEUR DU CHIFFRE #Y
          TAY
          LDA CHIFFRE,Y  ;ADRESSE DE LA FORME CORRESPONDANTE
          STA FORMEL
          LDY YNBRE
          LDX XNBRE
          LDA #$01
          STA NOCTETS
          LDA #$07
          STA NLIGNES
          JSR IMAGE
                         ;
          DEC XNBRE
          DEC TEMP
          BPL AFFREC1
                         ;
          RTS
                         ;
                         ;
                         ;
                         ;
********************************
* INCPTS                       *
* INCREMENTE DE 10*ACC LE      *
* NOMBRE DE POINTS.            *
********************************
                         ;
                         ;
INCPTS    CLC
          LDY #$03       ;CHIFFRE DES DIZAINES
INCPTS0   ADC POINTS,Y
          CMP #$0A
          BMI INCPTS1    ;LE CHIFFRE EST BIEN <10
          SEC
          SBC #$0A       ;ON RETIRE 10
          STA POINTS,Y
          SEC            ;REPORT AU CHIFFRE SUIVANT
          DEY            ;N0 CHIFFRE SUIVANT
          BPL INCPTS0
          LDA #$00
          STA POINTS
          STA POINTS+1
          STA POINTS+2
          STA POINTS+4
          STA POINTS+3
          RTS
                         ;
INCPTS1   STA POINTS,Y
          RTS
                         ;
