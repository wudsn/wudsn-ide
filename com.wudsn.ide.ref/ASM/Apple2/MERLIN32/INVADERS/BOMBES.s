********************************
********************************
*****                      *****
*****      ROUTINES        *****
*****       BOMBES         *****
*****                      *****
********************************
********************************
                         ;
                         ;
********************************
* DROP: PREPARE UNE NOUVELLE   *
*  ENTREE DANS LA TABLE DES    *
*  BOMBES.                     *
********************************
                         ;
DROP      LDA NBOMBES    ;NOMBRE DE BOMBES ACTIVES
          CMP NBOMAX     ;COMPARAISON AU MAX
          BNE DROP1      ;<>0, PAS ATTEINT
          RTS            ;ON NE FAIT RIEN
                         ;
                         ;
* ON TIRE OU ON TIRE PAS?      *
                         ;
DROP1     JSR HASARD
          LDA RND1
          BEQ DROP2      ;NUL ON TIRE
          RTS
                         ;
                         ;
* RECHERCHE D'UNE ENTREE LIBRE *
                         ;
DROP2     LDX NBOMAX     ;INDICE DS LA TABLE
DROP3     LDA YBOMBE,X   ;LIGNE DE LA BOMBE X
          BEQ DROP4      ;ESPACE LIBRE
          DEX            ;ENTREE SUIVANTE
          BPL DROP3
          BRK            ;IMPOSSIBLE D'ARRIVER ICI!
                         ;
DROP4     INC NBOMBES
          LDA YENV       ;LIGNE DU LANCEUR
          CLC
          ADC #$0C       ;BAS DE L'ENVAHISSEUR
          STA YBOMBE,X
                         ;
          JSR HASARD
          LDY RND2       ;NOMBRE COMPRIS ENTRE 0 ET 6

          LDA DPAL,Y     ;DEPLACEMENT DE LA BOMBE
          STA DPBOMBE,X
                         ;
                         ;
          LDA XENV       ;OCTET DE L'ENVAHISSEUR
          CLC
          ADC OSAL,Y     ;-1 OU 0 SELON Y
          STA OCTBOMBE,X ;OCTET DE LA BOMBE
          ASL
          ASL
          ASL            ;*8
          SEC
          SBC OCTBOMBE,X ;OCTET*7
          CLC
          ADC DPBOMBE,X  ;+ DEPLACEMENT
          STA XBOMBE,X   ;ABSCISSE  EN PIXELS
                         ;
                         ;
          STX NBO        ;# BOMBE COURANTE
          JSR PRBOMBE
          JSR XCIMAGE    ;TRACE AVEC VERIF. COLL.
          LDA COLLIS
          BMI DROP5      ;<0, PAS DE COLLISION
          JSR BOUM
                         ;
DROP5     RTS

********************************
* ALB                          *
* ARRET DE LA BOMBE #NBO       *
********************************
                         ;
ALB       LDX NBO        ;# DE LA BOMBE
          LDA #$00
          STA YBOMBE,X
          DEC NBOMBES
          RTS
                         ;
                         ;
********************************
*  MVTBOMBE                    *
*  MOVEMENT DES BOMBES         *
********************************
                         ;
                         ;
* VERIFICATION FREQUENCE       *
                         ;
MVTBOMBE  DEC CPTRBO
          BNE MVTBO4     ;<>0, ON NE FAIT RIEN
                         ;
          LDA FRBO       ;REMISE A NEUF DU COMPTEUR
          STA CPTRBO
                         ;
* MISE A JOUR DE CHAQUE BOMBE  *
* ACTIVE                       *
                         ;
          LDA NBOMAX     ; 1ER INDICE DS LES TABLEAUX
          STA NBO        ;# BOMBE COURANTE
MVTBO1    LDX NBO
          LDA YBOMBE,X   ;Y DE LA BOMBE
          BEQ MVTBO3     ;=0, INACTIVE
*EFFACEMENT                    *
                         ;
          JSR PRBOMBE
          JSR XIMAGE     ;XDRAW
                         ;
* CALCUL NOUVELLE POSITION     *
                         ;
                         ;
          LDX NBO
          LDA YBOMBE,X
          CLC
          ADC IBV        ;VITESSE VERTICALE
          STA YBOMBE,X
                         ;
* VERIFICATION FIN DE PARCOURS *
                         ;
          CMP YBOMAX
          BCC MVTBO2     ;PAS ATTEINTE
          JSR ALB        ;ARRET BOMBE
          BPL MVTBO3
                         ;

*REAFFICHAGE                   *
                         ;
MVTBO2    JSR PRBOMBE
          JSR XCIMAGE
                         ;
* VERIFICATION COLLISION       *
                         ;
          LDA COLLIS
          BMI MVTBO3     ;PAS DE COLL.
          JSR BOUM
                         ;
                         ;
* BOUCLAGE                     *
                         ;
MVTBO3    DEC NBO        ;BOMBE SUIVANTE
          BPL MVTBO1
MVTBO4    RTS
                         ;
                         ;
********************************
* BOUM                         *
* TRAITEMENT DES COLLISIONS DE *
* BOMBES.                      *
********************************
                         ;
                         ;
BOUM      LDX NBO        ;# DE LA BOMBE
                         ;
* A-T-ELLE HEURTE UNE BALLE?   *
                         ;
          LDA NBALLES    ;NOMBRE DE BALLES ACTIVES
          BEQ BOUM2      ;AUCUNE
                         ;
          LDA NBAMAX
          STA NBA        ;N0 DE BALLE COURANTE
BOUM1     JSR CMPBB      ;COMPARER COORDONEES
          LDA SEMBB      ;SEMAPHORE COLLISION BALLE-BOMBE
          BPL BOUM4      ;COORDONNEES EGALES
          DEC NBA
          BPL BOUM1      ;VOIR BALLE SUIVANTE
                         ;
                         ;
                         ;
* COLLISION DERRIERE ABRIS?    *
                         ;
BOUM2     LDX NBO        ;# BOMBE
          LDA YBOMBE,X   ;# DE SA LIGNE
          CMP #$A1       ;EST ELLE > ABRIS?
          BPL BOUM3      ;OUI, BASE EST FOUTUE!!!
                         ;
                         ;
* COLLISION AVEC ABRI          *
                         ;
                         ;
          JSR PRTROU
          JSR NIMAGE
          JSR PRBOMBE
          JSR NIMAGE     ;EFFACEMENT BOMBE
          JSR ALB        ;ARRET BOMBE
          RTS
                         ;
                         ;
* COLLISION AVEC BASE          *
                         ;
                         ;
BOUM3     JSR PRBOMBE
          JSR XIMAGE     ;EFFACER LA BOMBE
          JSR ALB        ;ARRET BOMBE
                         ;
          JSR EXPLB      ;EXPLOSION DE LA BASE
          LDA #$FF
          JSR DELAI      ;ON ATTEND UN CHOUYA
                         ;
          JSR NVBASE     ;ENGAGER NOUVELLE BASE
          RTS
                         ;
                         ;
                         ;
* COLLISION AVEC BALLE         *
                         ;
                         ;
BOUM4     JSR PRBALLE
          JSR NIMAGE     ;EFFACER LA BALLE
          JSR PRBOMBE
          JSR NIMAGE     ;EFFACEMENT BOMBE NBO
          JSR CLF        ;ARRETER LA BALLE
          JSR ALB        ;ARRETER LA BOMBE
          RTS            ;TERMINE
                         ;
                         ;
********************************
* PRBOMBE                      *
* PARAMETRES FORME BOMBE       *
********************************
                         ;
                         ;
PRBOMBE   LDA #$02
          STA NOCTETS
          LDA #$04
          STA NLIGNES
                         ;
                         ;
          LDX NBO        ;# DE LA BOMBE
          LDY DPBOMBE,X  ;# DU DEPLACEMENT
          LDA BOMBEBP,Y  ;ADRESSE FORME B.P.
          STA FORMEL
          LDA #>BOMBE0
          STA FORMEH
                         ;
          LDA YBOMBE,X   ;ORDONNEE
          TAY
          LDA OCTBOMBE,X ;# D'OCTET
          TAX
                         ;
          RTS
                         ;
                         ;
********************************
* PRTROU                       *
* PREPARATION PARAMETRES DE    *
* TROU                         *
********************************
                         ;
                         ;
PRTROU    LDA #$02
          STA NOCTETS
          LDA #$07
          STA NLIGNES
                         ;
          LDX NBO        ;# DE LA BOMBE
          LDY DPBOMBE,X  ;# DU DEPLACEMENT
          LDA TROUBP,Y
          STA FORMEL
          LDA #>TROU0
          STA FORMEH
                         ;
          LDY YBOMBE,X   ;LIGNE DE LA BOMBE
                         ;
          LDA OCTBOMBE,X
          TAX
          RTS
                         ;
                         ;
********************************
* CMPBB                        *
* COMPARAISON COORDONNEES      *
* BOMBE NBO ET BALLE NBA.      *
*                              *
********************************
                         ;
                         ;
CMPBB     LDA #$FF
          STA SEMBB      ;SEMAPHORE DESARME
                         ;
          LDY NBO        ;# DE LA BOMBE
          LDX NBA        ;# DE LA BALLE
          LDA YBALLE,X   ;COMPARAISON DES ORDONNEES
          CMP YBOMBE,Y
          BNE CMPBB2     ;ORDONNEES DIFFERENTES
                         ;
* COMPARAISON DES ABSCISSES    *
                         ;
          LDA XBALLE,X   ;ABSCISSE BALLE
          CLC
          ADC #$01       ;+1
          STA TEMP
          LDX #$04       ;COMPTEUR
CMPBB1    LDA TEMP
          CMP XBOMBE,Y
          BEQ CMPBB3     ;EGALITE-COLLISION
          DEC TEMP
          DEX            ;DECOMPTE
          BNE CMPBB1
                         ;
CMPBB2    RTS            ;PAS DE COLLISION
                         ;
CMPBB3    STX SEMBB
                         ;
          RTS
                         ;
                         ;
********************************
