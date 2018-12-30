          DSK INVADERS
          LST OFF
          ORG $4000
********************************
* LES ENVAHISSEURS DE L'ESPACE *
* VERSION 1.80 DU 23/12/84     *
********************************
                         ;
          JMP ENTREE
                         ;
                         ;
* ADRESSES PARTICULIERES       *
CENV      DS 1
                         ;
                         ;
                         ;
                         ;
* FONCTIONS GRAPHIQUES         *
                         ;
                         ;
HGR       EQU $F3E2
BCKGND    EQU $F3F4
                         ;
* FONCTIONS CLAVIER            *
                         ;
CLAVIER   EQU $C000
CLACT     EQU $C010
                         ;
                         ;
* FONCTIONS DIVERSES           *
                         ;
                         ;
                         ;
                         ;
********************************
*       CONSTANTES             *
********************************
                         ;
                         ;
PASV      DFB $08        ;INCREMENT LIGNE ENV.
PASH      DFB $01        ;INCREMENT COLONNE ENV.
DISTH     DFB $03        ;DISTANCE ENTRE ENV.
DISTV     DFB $10
MAXENV    DFB $08
X0        DFB $01
Y0        DFB $08
NPOS      DFB 30         ;NOMBRE DE POSITIONS SUR L'ECRAN
FRENV0    DFB $80
FRBASE    DFB $02
FRBA      DFB 04
FRBO      DFB 03
XBMIN     DFB 8
XBMAX     DFB $D2
NBAMAX    DFB 03
NBOMAX    DFB 04
YBMIN     DFB 180
YBMAX     DFB 08
YBOMAX    DFB $BF
IBV       DFB 4
IBASE     DFB 2
MIBASE    DFB -2
YBASE     DFB 184
NLMAX     DFB 05
NBASEM    DFB 3
DIFFT     DFB $10
FRBAL     DFB $25
CST1      DFB 3
X1        DFB 33
X2        DFB 33
X3        DFB 33
Y1        DFB 08
Y2        DFB 60
Y3        DFB 110
XSC       DFB 37
YSC       DFB 18
XREC      DFB 37
SEMBB     DS 1
YREC      DFB 70
ATT1      DFB #$05
NENVMAX   DFB 54
G         DFB $02
YMAX      DFB $BE
XMAX      DFB $F0
NDMAX     DFB $2C
                         ;
                         ;
                         ;
********************************
* VARIABLES                    *
********************************
                         ;
                         ;
*  EN  PAGE  ZERO              *
                         ;
ADRL      EQU $02
ADRH      EQU $03
BDRL      EQU $04
BDRH      EQU $05
FORMEL    EQU $06
FORMEH    EQU $07
                         ;
                         ;
                         ;
*  AUTRES VARIABLES            *
                         ;
NLIGNES   DS 1
NOCTETS   DS 1
XENV      DS 1
YENV      DS 1
TYPENV    DS 1
LENV      DS 1
C1        DS 1
C2        DS 1
L1        DS 1
L2        DS 1
I         DS 1
J         DS 1
YVERT     DS 1
XHORIZ    DS 1
NDPLH     DS 1
D1        DS 1
D2        DS 1
XBASE     DS 1
CPTRENV   DS 1
CPTRBASE  DS 1
VBASE     DS 1
YBALLE    DS 20
XBALLE    DS 20
OCTBALLE  DS 20
DPBALLE   DS 20
YBOMBE    DS 20
XBOMBE    DS 20
OCTBOMBE  DS 20
DPBOMBE   DS 20
NBOMBES   DS 1
NBALLES   DS 1
NBO       DS 1
NBA       DS 1
COLLIS    DS 1
CMORT     DS 1
LMORT     DS 1
TEMP      DS 1
SLIGNE    DS 10
SCOL      DS 10
NL2       DS 1
NC1       DS 1
NC2       DS 1
NBASES    DS 1
DBALLE    DS 1
NABRIS    DS 1
RND1      DS 1
RND2      DS 1
SC        DS 9
CPTRBO    DS 1
CPTRBA    DS 1
PLUSVITE  DS 1
XNBRE     DS 1
YNBRE     DS 1
POINTS    HEX 0000000000
REC       HEX 0000000000
FRENV     DS 1
NENV      DS 1
ND        DS 1
XD        DS 50
YD        DS 50
VX        DS 50
VY        DS 50
NDEBRIS   DS 1
                         ;
                         ;
********************************
********************************
********************************
                         ;
                         ;
ENTREE    JSR HGR
          BIT $C052
          JSR DEPART     ;INITIALISATIONS
                         ;
********************************
* BOUCLE PRINCIPALE            *
********************************
                         ;
                         ;
BOUCLE    JSR LIRECL     ;LECTURE CLAVIER
                         ;
          JSR DEPLENV    ;DEPLACEMENT ENVAHISSEURS
          JSR MVTBOMBE
          JSR MVTBASE    ;MOUVEMENT BASE
          JSR MVTBALLE
                         ;
* ACCELERATION ENVAHISSEURS    *
                         ;
          LDA PLUSVITE
          BNE BOUCLE1    ;PAS MAINTENANT
          LDA CST1
          STA PLUSVITE   ;REINITIALISATION COMPTEUR
          LDA FRENV
          LSR
          ADC #$01
          STA FRENV
                         ;
                         ;
* DECOMPTE ESPACEMENT BALLES   *
                         ;
BOUCLE1   LDA DBALLE     ;DECREMENTER DBALLE
          BEQ BOUCLE     ;JUSQU'A 0
          DEC DBALLE
                         ;
                         ;
          JMP BOUCLE
                         ;
                         ;
********************************
          PUT CLAVIER.s
          PUT ENVAHISSEURS.s
          PUT BASE.s
          PUT BALLES.s
          PUT BOMBES.s
          PUT PARTIE.s
          PUT ROUTINES.s
          PUT TABLES.s
