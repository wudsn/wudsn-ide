********************************
********************************
*****                      *****
*****     ROUTINES         *****
*****       BASE           *****
*****                      *****
********************************
********************************
                         ;
                         ;
********************************
* MVTBASE                      *
* MOUVEMENT DE LA BASE         *
********************************
                         ;
                         ;
* VERIFICATION SI CYCLE OK     *
                         ;
MVTBASE   DEC CPTRBASE
          BNE MVTBASE3   ;<>0, PAS D'EXECUTION A CE CYCLE
          LDA FRBASE     ;REMISE A NEUF COMPTEUR
          STA CPTRBASE
                         ;
                         ;
* VERIFICATION VITESSE=0       *
                         ;
          LDA VBASE      ;VITESSE BASE
          BEQ MVTBASE3   ;NUL, ON NE FAIT RIEN
                         ;
* VERIFICATION DES LIMITES     *
                         ;
          BMI MVTBASE1   ;VBASE<0, VERIFIER LIMITE INFERIEURE
                         ;
*VERIFICATION LIMITE SUPERIEURE*
                         ;
          LDA XBASE
          CMP XBMAX
          BNE MVTBASE2   ;PAS ATTEINTE
                         ;
          LDA #$00
          STA VBASE      ;ARRET FORCE
          RTS            ;PAS DE MISE A JOUR POSITION
                         ;
                         ;
*VERIFICATION LIMITE INFERIEURE*
                         ;
MVTBASE1  LDA XBASE
          CMP XBMIN
          BNE MVTBASE2   ;PAS ATTEINTE
          LDA #$00
          STA VBASE      ;ARRET
          RTS
                         ;
                         ;
*MISE A JOUR DE LA BASE        *
                         ;
MVTBASE2  JSR PRBASE
          JSR XIMAGE     ;EFFACEMENT
          LDA XBASE
          CLC
          ADC VBASE      ;NOUVELLE POSITION
          STA XBASE
          JSR PRBASE
          JSR XIMAGE     ;AFFICHAGE
                         ;
MVTBASE3  RTS
                         ;
                         ;
                         ;
********************************
* PRBASE                       *
* PREPARATION DES PARAMETRES   *
* D'AFFICHAGE                  *
********************************
                         ;
PRBASE    LDA #$03
          STA NOCTETS
          LDA #$08
          STA NLIGNES
                         ;
* CALCUL ADRESSE FORME         *
                         ;
          LDY XBASE      ;ABSCISSE EN PIXELS
          LDX DEPL,Y     ;# DU DEPLACEMENT
          LDA BASEBP,X   ;ADRESSE FORME B.P.
          STA FORMEL
          LDA #>BASE0
          STA FORMEH
                         ;
          LDX NUMOCT,Y   ;# OCTET D'AFFICHAGE
          LDY YBASE      ;# LIGNE
                         ;
          RTS
                         ;
                         ;
********************************
* EXPLB                        *
* EXPLOSION DE LA BASE         *
********************************
EXPLB     JSR PRBASE
          JSR XIMAGE     ;EFFACEMENT
                         ;
          LDY NDMAX      ;NOMBRE DE DEBRIS MAX
          INY            ;CAR ON COMPTE A PARTIR DE 0
          STY NDEBRIS    ;NMBRE DE DEBRIS ACTIFS
                         ;
* INITIALISATION TABLE EXPLOS. *
                         ;
EXPLB1    LDA XD0,Y
          CLC
          ADC XBASE
          STA XD,Y
          LDA YD0,Y
          STA YD,Y
          LDA VX0,Y
          STA VX,Y
          LDA VY0,Y
          STA VY,Y
          DEY
          BPL EXPLB1
                         ;
                         ;
* AFFICHAGE SEQUENCES          *
                         ;
EXPL2     JSR MVTD
          LDA #$20
          JSR DELAI
          LDA NDEBRIS
          BNE EXPL2
                         ;
          RTS
                         ;
                         ;
********************************
* MVTD                         *
* MOUVEMENT DES DEBRIS D'UNE   *
* EXPLOSION.                   *
********************************
                         ;
MVTD      LDA NDMAX
          STA ND         ;COMPTEUR DE DEBRIS
MVTD1     LDY ND
          LDA YD,Y       ;ORDONNEE DEBRI Y
          BEQ MVTD6      ;DEBRI INACTIF
* EFFACEMENT DEBRI COURANT     *
                         ;
          JSR PRDEBRI
          JSR NIMAGE     ;EFFACEMENT
* MISE A JOUR VITESSE VERT.     *
                         ;
          LDY ND
          LDA VY,Y
          CLC
          ADC G          ;GRAVITATION
          STA VY,Y
                         ;
* MISE A JOUR ABSCISSE         *
                         ;
          LDA XD,Y
          CLC
          ADC VX,Y
          STA XD,Y
                         ;
* VERIFICATION LIMITE          *
                         ;
          LDA VX,Y
          BMI MVTD3
          LDA XD,Y       ;VX>0, VERIFIER LIMITE SUP.
          CMP XMAX
          BCC MVTD4      ;PAS DE DEPASSEMENT
MVTD2     DEC NDEBRIS
          BEQ MVTD7      ;IL N'Y A PLUS RIEN
          LDA #$00
          STA YD,Y       ;DESACTIVATION

          BEQ MVTD6
                         ;
MVTD3     LDA XD,Y       ;VX<0, COMPARAISON LIMITE INF.
          BMI MVTD2
                         ;
* MISE A JOUR ORDONNEE         *
                         ;
MVTD4     LDA YD,Y
          CLC
          ADC VY,Y
          STA YD,Y
                         ;
                         ;
* VERIFICATION LIMITE          *
          CMP YMAX
          BCC MVTD5
                         ;
          DEC NDEBRIS
          LDA #$00
          STA YD,Y
          BEQ MVTD6
                         ;
* REAFFICHAGE                  *
                         ;
MVTD5     JSR PRDEBRI
          JSR XIMAGE
                         ;
                         ;
* BOUCLAGE                     *
                         ;
MVTD6     DEC ND
          BPL MVTD1
                         ;
MVTD7     RTS
                         ;
                         ;
                         ;
********************************
* PRDEBRI                      *
********************************
                         ;
                         ;
PRDEBRI   LDA #$02
          STA NOCTETS
          LDA #$02
          STA NLIGNES
                         ;
          LDX XD,Y       ;ABSCISSE
          LDA DEPL,X     ;DEPLACEMENT
          TAX
          LDA DEBRIBP,X
          STA FORMEL
          LDA #>DEBRI0
          STA FORMEH
                         ;
          LDX XD,Y
          LDA NUMOCT,X
          TAX
          LDA YD,Y
          TAY
                         ;
          RTS
                         ;
                         ;
                         ;
                         ;
                         ;
********************************
* NVBASE                       *
* REDEMARRAGE D'UNE NOUVELLE   *
* BASE.                        *
********************************
                         ;
                         ;
NVBASE    DEC NBASES
          BNE NVBASE1    ;<>0, ON CONTINUE
          JMP PERDU      ;PARTIE TERMINEE
                         ;
NVBASE1   LDA #$00       ;REDEMARRAGE
          STA VBASE      ;A L'ARRET
          LDA XBMIN      ; A GAUCHE
          STA XBASE
* ARRET DES BOMBES             *
                         ;
          LDA NBOMBES
          BEQ NVBASE4    ;AUCUNE
          LDX NBOMAX     ;INDICE DS TABLE DES BOMBES
          STX NBO
NVBASE2   LDX NBO
          LDA YBOMBE,X   ;POSITION VERTICALE
          BEQ NVBASE3    ;PAS ACTIVE
          JSR PRBOMBE
          JSR NIMAGE     ;EFFACEMENT
          JSR ALB        ;DESACTIVATION
NVBASE3   DEC NBO        ;BOMBE SUIVANTE
          BPL NVBASE2
                         ;

* ARRET DES BALLES             *
                         ;
NVBASE4   LDA NBALLES
          BEQ NVBASE7    ;AUCUNE
          LDX NBAMAX
          STX NBA
NVBASE6   LDX NBA
          LDA YBALLE,X
          BEQ NVBASE5    ;PAS ACTIVE
          JSR PRBALLE
          JSR NIMAGE     ;EFFACEMENT
          JSR CLF
NVBASE5   DEC NBA
          BPL NVBASE6
                         ;
          LDA #$FF
NVBASE7   JSR DELAI      ;ON ATTEND UN CHOUYA
          JSR DELAI
                         ;
                         ;
* EFFACEMENT D'UNE BASE        *
* DANS LA RESERVE              *
                         ;
                         ;
          JSR PRBASE     ;PREPARATION DES PARAMETRES
                         ;
          LDA NBASES
          ASL
          ASL
          ASL
          ASL            ;*10
          CLC
          ADC Y3         ;ORDONNEE DE LA BASE A EFFACER
          TAY
          LDX X3         ;SON ABSCISSE
          JSR XIMAGE
                         ;
* ET REAFFICHAGE BASE          *
                         ;
          JSR PRBASE
          JSR IMAGE
          LDA #$FF
          JSR DELAI      ;ATTENDRE UN PEU
          JMP BOUCLE
          RTS
                         ;
