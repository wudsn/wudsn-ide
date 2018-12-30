********************************
********************************
*****                      *****
*****     ROUTINES         *****
*****      BALLES          *****
*****                      *****
********************************
********************************
                         ;
                         ;
********************************
*  FEU                         *
*  PREPARE UNE NOUVELLE ENTREE *
*  DANS LA TABLE DES BALLES    *
********************************
                         ;
FEU       LDA NBALLES    ;NOMBRE DE BALLES ACTIVES
          CMP NBAMAX     ;COMPARAISON AU MAX
          BNE FEU1       ;<>0, RESTE DE LA PLACE
          RTS            ;PLUS DE PLACE, ON NE FAIT RIEN
                         ;
FEU1      LDA DBALLE     ;COMPTEUR DELAI ENTRE BALLES
          BEQ FEU2       ;=0, TIR AUTORISE.
          RTS
                         ;
* RECHERCHE ENTREE LIBRE       *
                         ;
FEU2      LDX NBAMAX
FEU3      LDA YBALLE,X   ;ORDONNEE DE LA BALLE X
          BEQ FEU4       ;=0, L'ENTREE EST LIBRE
          DEX            ;BALLE SUIVANTE
          BPL FEU3
          BRK            ;IMPOSSIBLE D'ARRIVER ICI!
                         ;
* DEPART D'UNE NOUVELLE BALLE  *
                         ;
FEU4      INC NBALLES
          LDA YBMIN      ;ORDONNEE DE DEPART
          STA YBALLE,X
                         ;
          LDA XBASE      ;ABSCISSE BASE
          CLC
          ADC #$06       ;ABSCISSE CANON
          STA XBALLE,X
          TAY
          LDA NUMOCT,Y   ;# OCTET DE LA BALLE
          STA OCTBALLE,X
                         ;
          LDA DEPL,Y     ;# DEPLACEMENT AD-HOC
          STA DPBALLE,X
                         ;
                         ;
          STX NBA        ;# BALLE COURANTE
* AFFICHAGE BALLE              *
                         ;
          JSR PRBALLE    ;AFFICHAGE DE LA BALLE
          JSR XCIMAGE
                         ;
* VERIFICATION COLLISION       *
                         ;
          LDA COLLIS
          BMI FEU5       ;<0, PAS DE COLLISION
          JSR SPLASH     ;TRAITEMENT DES COLLISIONS
                         ;
FEU5      LDA FRBAL      ;REMISE A NEUF DU COMPTEUR D'ESPACEMENT
          STA DBALLE
          RTS

********************************
* CLF                          *
* ARRET DE LA BALLE #NBA       *
********************************
                         ;
CLF       LDX NBA        ;# DE LA BALLE
          LDA #$00
          STA YBALLE,X
          DEC NBALLES
          RTS
                         ;
                         ;
********************************
*  MVTBALLE                    *
*  MOUVEMENT DES BALLES ACTIVES*
********************************
                         ;
                         ;
* VERIFICATION COMPTEUR        *
                         ;
MVTBALLE  DEC CPTRBA     ;DECOMPTE FREQUENCE
          BNE MVTB4      ;<>0, PAS D'EXECUTION A CE CYCLE
          LDA FRBA       ;REMISE A NEUF COMPTEUR
          STA CPTRBA
                         ;
* MISE A JOUR BALLES ACTIVES   *
                         ;
          LDA NBAMAX
          STA NBA        ;# DE BALLE COURANTE
MVTB1     LDX NBA        ;INDICE DS LA TABLE DES BALLES
          LDA YBALLE,X   ;ORDONNEE DE LA BALLE X
          BEQ MVTB3      ;=0, BALLE INACTIVE
                         ;
*EFFACEMENT                    *
                         ;
          JSR PRBALLE
          JSR XIMAGE     ;XDRAW
                         ;
* CALCUL NOUVELLE POSITION     *
                         ;
                         ;
          LDX NBA        ;RESTAURATION DE X
          LDA YBALLE,X
          SEC
          SBC IBV        ;VITESSE VERTICALE
          STA YBALLE,X
                         ;
* VERIFICATION FIN DE PARCOURS *
                         ;
          CMP YBMAX
          BNE MVTB2      ;<>0, ENCORE DU CHEMIN A FAIRE
          JSR CLF        ;ARRET BALLE
          BPL MVTB3      ;=JMP
                         ;

*REAFFICHAGE                   *
                         ;
MVTB2     JSR PRBALLE
          JSR XCIMAGE
                         ;
* VERIFICATION COLLISION       *
                         ;
          LDA COLLIS
          BMI MVTB3      ;PAS DE COLL.
          JSR SPLASH
                         ;
                         ;
* BOUCLAGE                     *
                         ;
MVTB3     DEC NBA        ;BALLE SUIVANTE
          BPL MVTB1
                         ;
MVTB4     RTS
                         ;
                         ;
********************************
* SPLASH: COLLISION D'UNE BALLE*
********************************
                         ;
                         ;
                         ;
                         ;
SPLASH    JSR PRBALLE
          JSR NIMAGE     ;EFFACEMENT BALLE (PARFOIS NECESSAIRE...)
                         ;
                         ;
* COLLISION AVEC BOMBE?        *
                         ;
                         ;
          LDA NBOMBES    ;NOMBRE DE BOMBES
          BEQ SPLASH3    ;PAS DE BOMBES EN ROUTE
                         ;
          LDA NBOMAX
          STA NBO
SPLASH1   JSR CMPBB      ;COMPARER BALLE ET BOMBE
          LDA SEMBB      ;SEMAPHORE DE COLLISION
          BMI SPLASH2    ;COORDONNEES PAS EGALES
                         ;
                         ;
          JSR PRBOMBE
          JSR NIMAGE     ;EFFACEMENT BOMBE
          JSR CLF        ;ARRET BALLE
          JSR ALB        ;ARRET BOMBE
          RTS            ; TERMINE
                         ;
SPLASH2   DEC NBO        ;BOMBE SUIVANTE
          BPL SPLASH1    ;ON CONTINUE
                         ;
                         ;
* COLLISION AVEC ENVAHISSEUR?  *
                         ;
                         ;
SPLASH3   JSR LCMORT     ;CALCUL L ET C DE L'ENVAHISSEUR TOUCHE
                         ;
                         ;
          LDA L2         ;EST-CE BIEN UN ENVAHISSEUR???
          CMP LMORT      ;LMORT<=L2
          BMI SPLASH5    ;PAS UN ENV!
                         ;
          LDA C2
          CMP CMORT      ;CMORT<=C2
          BMI SPLASH5    ;PAS UN ENVAHISSEUR
                         ;
          LDX LMORT      ;VERIFICATION PRESENCE
          LDA ATLL,X     ;ADRESSE TABLE TL(LMORT)
          STA BDRL
          LDA ATLH,X
          STA BDRH
                         ;
          LDY CMORT      ;COLONNE
          LDA (BDRL),Y   ;INDICATEUR DE PRESENCE
          BEQ SPLASH5    ;PERSONNE!
                         ;
                         ;
* COLLISION AVEC UN ENVAHISSEUR*
                         ;
                         ;
          LDA #$00       ;MISE A JOUR SEMAPHORE DE PRESENCE
          STA (BDRL),Y
                         ;
          JSR CLF        ;ARRET BALLE
                         ;
          JSR PREXPL     ;AFFICHAGE EXPLOSION
          JSR IMAGE
          LDA #$15
          JSR DELAI      ;LAISSER VOIR
                         ;
          DEC NENV       ;DECREMENTER NOMBRE TOTAL D'ENV.
          BNE SPLASH4    ;<>0, IL EN RESTE
          JMP GAGNE      ;LE JOUEUR A GAGNE
                         ;
                         ;
                         ;
SPLASH4   JSR CALCSPL    ;MISE A JOUR C1,C2 ETC...
                         ;
          LDA #$07       ;MISE A JOUR SCORE
          SEC
          SBC LMORT
          LSR            ;INCREMENT SCORE /10
          JSR INCPTS     ;INCREMENTER SCORE
          JSR AFFPTS     ;AFFICHER
                         ;
          JSR PREXPL     ;EFFACER DEBRIS EXPLOSION
          JSR XIMAGE
                         ;
                         ;
          RTS            ;TERMINE
                         ;
                         ;
                         ;
* COLLISION AVEC ABRI          *
                         ;
                         ;
SPLASH5   JSR PRECLAT    ;PREPARATION PARAMETRES ECLAT
          JSR NIMAGE     ;AFFICHAGE EN NOIR
          JSR CLF        ;ARRET BALLE
          RTS

                         ;
********************************
* LCMORT                       *
* CALCUL DE LA LIGNE ET DE LA  *
* COLONNE DE L'ENVAHISSEUR     *
* POSSIBLEMENT TOUCHE.         *
********************************
                         ;
                         ;
LCMORT    LDX NBA
          LDA YBALLE,X
          SEC
          SBC YVERT
          LSR
          LSR
          LSR
          LSR            ;/16
          STA LMORT      ;LIGNE DU MALHEUREUX
          ASL
          ASL
          ASL
          ASL
          CLC
          ADC YVERT
          STA YENV       ;Y AFFICHAGE
                         ;
          LDA OCTBALLE,X ;OCTET ENVAHISSEUR
          SEC
          SBC XHORIZ
          CLC
          ADC COLLIS
          TAY
          LDA DIV3,Y     ;/3
          CLC
          STA TEMP       ;SA COLONNE PAR RAPPORT A C1
          ADC C1
          STA CMORT      ;SA COLONNE PAR RAPPORT A 0
          LDA TEMP
          ASL
          CLC
          ADC TEMP       ;*3
          CLC
          ADC XHORIZ
          STA XENV       ;SON NUMERO D'OCTET
          RTS
                         ;
********************************
* CALCSPL                      *
* RECLACUL DES SOMMES LIGNE    *
* ET COLONNE, DE L2,C1,C2,NDPLH*
* ET XHORIZ                    *
********************************
                         ;
* MISE A JOUR DES SOMMES L & C *
                         ;
CALCSPL   LDY LMORT      ;LIGNE DU MORT
          LDA SLIGNE,Y
          SEC
          SBC #$01
          STA SLIGNE,Y
                         ;
          LDY CMORT      ;COLONNE
          LDA SCOL,Y
          SEC
          SBC #$01
          STA SCOL,Y
                         ;
* MISE A JOUR DE L2,C1,C2      *
                         ;
          LDA #$FF       ;NOUVELLE VALEUR PROVISOIRE
          STA NL2
          STA NC1
          STA NC2
                         ;
          LDY L1         ;RECHERCHE DERNIERE LIGNE NON VIDE
          DEY            ;POUR COMPENSER LE INY QUI SUIT
CALCSPL1  INY
          LDA SLIGNE,Y   ;NBRE D'ENV. SUR LA LIGNE Y
          BEQ CALCSPL2
          STY NL2        ;DERNIERE LIGNE NON VIDE
                         ;
CALCSPL2  CPY L2
          BNE CALCSPL1
                         ;
          LDY C1         ;CALCUL DE NC1 ET NC2
          DEY            ;POUR COMPENSER LE INY QUI SUIT
CALCSPL3  INY            ;COLONNE SUIVANTE
          LDA SCOL,Y     ;NBRE D'ENV. SUR CETTE COLONNE
          BEQ CALCSPL4   ;=0, COLONNE EST VIDE
                         ;
          STY NC2        ;DERNIERE COLONNE NON VIDE
                         ;
          LDA NC1
          BPL CALCSPL4   ;>=0, ON A DEJA TROUVE LA 1ERE COLONNE NON VIDE
          STY NC1
CALCSPL4  CPY C2
          BNE CALCSPL3
                         ;
* RECALCUL DE XHORIZ           *
                         ;
          LDA NC1        ;CALCUL DE XHORIZ
          SEC
          SBC C1         ;NC1-C1
          STA TEMP
          ASL            ;*2
          CLC
          ADC TEMP       ;*3
          STA TEMP
          CLC
          ADC XHORIZ
          STA XHORIZ     ;XHORIZ:=XHORIZ+3*(NC1-C1)
                         ;
* RECALCUL DE NDPLH            *
          LDY PASH       ;V-A-T'ON A GAUCHE OU A DROITE?
          BPL CALCSPL5   ;>=0, A DROITE
          LDA TEMP       ;NDPLH:=NDPLH+3*(NC1-C1)

          CLC
          ADC NDPLH
          STA NDPLH
          BPL CALCSPL6
                         ;
CALCSPL5  LDA C2         ;NDPLH:=NDPLH +3*(C2-NC2)
          SEC
          SBC NC2
          STA TEMP
          ASL
          CLC
          ADC TEMP       ;*3
          CLC
          ADC NDPLH
          STA NDPLH
                         ;
* MISE A JOUR DE C1, C2 ET L1  *
                         ;
CALCSPL6  LDA NC1
          STA C1
          LDA NC2
          STA C2
          LDA NL2
          STA L2         ;NOUVELLE VALEUR DE L2
                         ;
          RTS
                         ;;
                         ;
********************************
* PRBALLE: PREPARATION DES PARA*
* METRES BALLE.                *
********************************
                         ;
                         ;
PRBALLE   LDA #$02
          STA NOCTETS
          LDA #$04
          STA NLIGNES
                         ;
          LDX NBA        ;# BALLE COURANTE
          LDY DPBALLE,X  ;# DU DEPLACEMENT
          LDA BALLEBP,Y  ;ADRESSE FORME B.P.
          STA FORMEL
          LDA #>BALLE0
          STA FORMEH
                         ;
          LDA YBALLE,X
          TAY
          LDA OCTBALLE,X
          TAX
                         ;
          RTS
                         ;
                         ;
********************************
* PREXPL                       *
* PREPARATION DES PARAMETRES   *
* POUR L'EXPLOSION D'UN ENV.  .*
********************************
                         ;
                         ;
PREXPL    LDA #$02
          STA NOCTETS
          LDA #$10
          STA NLIGNES
                         ;
          LDA #<EXPL     ;ADRESSE FORME
          STA FORMEL
          LDA #>EXPL
          STA FORMEH
                         ;
          LDY YENV       ;ORDONNEE DE L'ENVAHISSEUR
          DEY
          DEY
          DEY
          DEY            ;ORDONNEE DE L'EXPLOSION
          LDX XENV
                         ;
          RTS
                         ;
                         ;
                         ;
********************************
* PRECLAT                      *
* PREPARATION DES PARAMETRES   *
* D'ECLAT DANS UN ABRI.        *
********************************
                         ;
                         ;
PRECLAT   LDA #$02
          STA NOCTETS
          LDA #$08
          STA NLIGNES
                         ;
          LDX NBA        ;# BALLE
          LDY DPBALLE,X  ;# DU DEPLACEMENT
          LDA ECLATBP,Y  ;ADRESSE B.P. DE LA FORME
          STA FORMEL
          LDA #>ECLAT0
          STA FORMEH
                         ;
          LDY YBALLE,X
          DEY
          DEY
          DEY
          DEY
          LDA OCTBALLE,X
          TAX
                         ;
          RTS
                         ;
                         ;
