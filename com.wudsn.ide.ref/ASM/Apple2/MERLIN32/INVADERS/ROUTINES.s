********************************
********************************
****       DIVERS          *****
****                       *****
********************************
********************************
                         ;
********************************
* DEPART                       *
* INITIALISATIONS DE DEMARRAGE *
********************************
                         ;
                         ;
DEPART    LDA NBASEM
          STA NBASES     ;NOMBRE DE BASES
          LDA #$00       ;MISE A 0 DU SCORE
          STA POINTS
          STA POINTS+1
          STA POINTS+2
          STA POINTS+3
          STA POINTS+4
                         ;
* EFFACEMENT ECRAN             *
                         ;
DEPART1   LDA #$00
          JSR BCKGND
                         ;
********************************
* INITIALISATION ENVAHISSEURS  *
********************************
                         ;
          LDA #$00       ;# 1ERE LIGNE D'ENV.
          STA L1
          LDA NLMAX      ;# DERNIERE LIGNE
          STA L2
          LDA #$00       ;# 1ERE COLONNE
          STA C1
          LDA MAXENV     ;NBRE PAR LIGNE
          STA C2         ;= # DERNIERE COLONNE
          LDA NENVMAX    ;NOMBRE TOTAL
          STA NENV
                         ;
          LDA Y0         ;LIGNE DE DEPART POUR LA 1ERE LIGNE
          STA YVERT
          LDA X0         ;X DE DEPART POUR LA 1ERE COL.
          STA XHORIZ
          LDA C1
          SEC
          SBC C2
          STA TEMP
          ASL
          CLC
          ADC TEMP
          CLC
          ADC NPOS       ;NPOS-3*(C2-C1)
          STA NDPLH      ;DECOMPTEUR DE DEPLACEMENTS
                         ;
          LDA #01
          STA PASH
                         ;
          LDA FRENV0
          STA FRENV
          STA CPTRENV    ;FREQUENCE DE DEPLACEMENT DES ENVAHISSEURS.
                         ;
                         ;
* TABLE DES LIGNES             *
                         ;
          LDA DIFFT      ;DIFFERENCE D'ADRESSE DES FORMES TYPE2-TYPE1
          STA TEMP
                         ;
          LDX NLMAX      ;CALCUL ADRESSE TL(X)
DEPART2   LDA ATLL,X
          STA BDRL
          LDA ATLH,X
          STA BDRH
                         ;
          LDY MAXENV
          LDA #$01
DEPART3   STA (BDRL),Y   ;MISE A 1 DES SEMAPHORES DE PRESENCE
          DEY
          BPL DEPART3
          LDA TEMP       ;DEPLACEMENT ADRESSE
          LDY #$0A
          STA (BDRL),Y
          EOR DIFFT      ;COMMUTATION
          STA TEMP
          DEX
          BPL DEPART2
                         ;
* TABLE  DES SOMMES DE LIGNE   *
                         ;
          LDX NLMAX
          LDA MAXENV
          CLC
          ADC #$01
DEPART4   STA SLIGNE,X
          DEX
          BPL DEPART4
                         ;
* TABLE DES SOMMES COLONNE     *
                         ;
          LDX MAXENV
          LDA NLMAX
          CLC
          ADC #$01
DEPART5   STA SCOL,X
          DEX
          BPL DEPART5
          LDA CST1
          STA PLUSVITE
                         ;
* PASSAGE EN MODE GRAPHIQUE    *
                         ;
                         ;
********************************
* AFFICHAGE DES ABRIS          *
********************************
                         ;
          LDA #$05
          STA NABRIS     ;NOMBRE D'ABRIS
          LDA #$1B       ;ABSCISSE DERNIER ABRI
          STA TEMP
                         ;
DEPART6   JSR PRABRI
          JSR IMAGE
          LDA TEMP
          SEC
          SBC #$06
          STA TEMP
          DEC NABRIS
          BNE DEPART6
                         ;
                         ;
                         ;
********************************
* AFFICHAGE DES ENVAHISSEURS   *
********************************
                         ;
                         ;
          JSR AFFENV     ;AFFICHAGE
                         ;
                         ;
********************************
* INITIALISATION DE LA BASE    *
********************************
                         ;
          LDA XBMIN
          STA XBASE      ;ABSCISSE
          LDA #$00
          STA VBASE      ;DEPART ARRETE
                         ;
          LDA FRBASE     ;FREQUENCE D'APPEL
          STA CPTRBASE
          JSR PRBASE     ;PREPARATION PARAMETRES
          JSR IMAGE      ;AFFICHAGE
                         ;
********************************
* TABLE DES BALLES             *
********************************
                         ;
          LDA FRBA
          STA CPTRBA
          LDA #$00
          STA NBALLES
          STA DBALLE
          LDX NBAMAX
DEPART7   STA YBALLE,X
          DEX
          BPL DEPART7
                         ;
********************************
* TABLE DES BOMBES             *
********************************
                         ;
          LDA FRBO
          STA CPTRBO
          LDA #$00
          STA NBOMBES
          LDX NBOMAX
DEPART8   STA YBOMBE,X
          DEX
          BPL DEPART8
                         ;
                         ;
********************************
* AFFICHAGE DU SCORE           *
********************************
                         ;
                         ;
          JSR PRSCORE
          JSR IMAGE      ;AFFICHAGE "SCORE"
          JSR AFFPTS     ;AFFICHAGE VALEUR SCORE
                         ;
          JSR PRREC
          JSR IMAGE      ;AFFICHAGE "RECORD"
          JSR AFFREC     ;AFFICHAGE VALEUR
                         ;
          JSR PRBASES
          JSR IMAGE      ;AFFICHAGE "BASES"
          LDA NBASES
          SEC
          SBC #$01
          BEQ DEPART10   ;IL N'EN RESTE PLUS EN RESERVE
          STA TEMP
DEPART9   JSR PRBASE     ;PREPARATION PARAMETRES D'AFFICHAGE
          LDA TEMP       ;#BASE COURANTE DS RESERVE
          ASL
          ASL
          ASL
          ASL            ;*10
          CLC
          ADC Y3         ;ORDONNEE D'AFFICHAGE
          TAY
          LDX X3

          JSR IMAGE      ;AFFICHAGE
          DEC TEMP
          BNE DEPART9
                         ;

DEPART10  RTS
                         ;
                         ;
                         ;
********************************
* PRABR: PREPARATION DES       *
* PARAMETRES D'ABRI.           *
********************************
                         ;
                         ;
PRABRI    LDA #$03
          STA NOCTETS
          LDA #$10
          STA NLIGNES
          LDY #$90
          LDX TEMP
          LDA #<ABRI
          STA FORMEL
          LDA #>ABRI
          STA FORMEH
          RTS
                         ;
                         ;
********************************
*        IMAGE                 *
* AFFICHAGE DE LA FORME (FORMEL*
* FORMEH) EN (X,Y)             *
********************************
                         ;
                         ;
* DEPARTIALISATIONS              *
                         ;
IMAGE     STY I          ;N0 PREMIERE LIGNE
          STX J          ;N0 PREMIER OCTET
                         ;
          LDX #$00       ;TJRS 0 PR ADRESSAGE INDIRECT INDEXE
                         ;
* CALCUL ADRESSE PREMIER OCTET *
* A L'ECRAN                    *
                         ;
IMAGE1    LDY I
          LDA YBP,Y      ;ADRESSE DE BASE I (B.P.)
          CLC
          ADC J          ;DEPLACEMENT PREMIER OCTET
          STA ADRL
                         ;
          LDA YHP,Y
          STA ADRH
                         ;
* AFFICHAGE LIGNE I            *
                         ;
          LDY #$00       ;INDICE PREMIER OCTET A L'ECRAN
IMAGE2    LDA (FORMEL,X) ;OCTET COURANT DE LA FORME
          STA (ADRL),Y   ;AFFICHAGE A L'ECRAN
                         ;
* MISE A JOUR DES # D'OCTETS   *
                         ;
          INY            ;PROCHAINOCTET A L'ECRAN
          INC FORMEL     ;PROCHAIN OCTET DS TABLE DE FORME
          CPY NOCTETS    ;COMPARER AU NBRE D'O/L
          BNE IMAGE2     ;<>0? OUI, I INACHEVEE
                         ;
          INC I          ;LIGNE SUIVANTE
          DEC NLIGNES    ;DECOMPTE DES LIGNES
          BNE IMAGE1     ;<>0? OUI, RESTE DES IS
                         ;
          RTS
                         ;
********************************
*       XIMAGE                 *
* AFFICHAGE AVEC OU EXCLUSIF   *
* DE LA FORME (FORMEL,FORMEH)  *
* EN (X,Y).                    *
********************************
                         ;
                         ;
* INITIALISATIONS                *
                         ;
XIMAGE    STY I          ;N0 PREMIERE LIGNE
          STX J          ;N0 PREMIER OCTET
                         ;
          LDX #$00       ;TJRS 0 PR ADRESSAGE INDIRECT INDEXE
                         ;
* CALCUL ADRESSE PREMIER OCTET *
* A L'ECRAN                    *
                         ;
XIMAGE1   LDY I
          LDA YBP,Y      ;ADRESSE DE BASE I (B.P.)
          CLC
          ADC J          ;DEPLACEMENT PREMIER OCTET
          STA ADRL
                         ;
          LDA YHP,Y
          STA ADRH
                         ;
* AFFICHAGE LIGNE I            *
                         ;
          LDY #$00       ;INDICE PREMIER OCTET A L'ECRAN
XIMAGE2   LDA (FORMEL,X) ;OCTET COURANT DE LA FORME
          EOR (ADRL),Y
          STA (ADRL),Y   ;AFFICHAGE A L'ECRAN
                         ;
* MISE A JOUR DES # D'OCTETS   *
                         ;
          INY            ;PROCHAINOCTET A L'ECRAN
          INC FORMEL     ;PROCHAIN OCTET DS TABLE DE FORME
          CPY NOCTETS    ;COMPARER AU NBRE D'O/L
          BNE XIMAGE2    ;<>0? OUI, I INACHEVEE
                         ;
          INC I          ;LIGNE SUIVANTE
          DEC NLIGNES    ;DECOMPTE DES LIGNES
          BNE XIMAGE1    ;<>0? OUI, RESTE DES IS
                         ;
          RTS
                         ;
********************************
*       XCIMAGE                *
* AFFICHAGE AVEC OU EXCLUSIF   *
* ET TEST COLLISION.           *
********************************
                         ;
                         ;
* INITALISATIONS                 *
                         ;
XCIMAGE   STY I          ;N0 PREMIERE LIGNE
          STX J          ;N0 PREMIER OCTET
                         ;
          LDX #$00       ;TJRS 0 PR ADRESSAGE INDIRECT INDEXE
                         ;
          LDA #$FF
          STA COLLIS     ;SEMAPHORE DESARME
                         ;
* CALCUL ADRESSE PREMIER OCTET *
* A L'ECRAN                    *
                         ;
XCIMAGE1  LDY I
          LDA YBP,Y      ;ADRESSE DE BASE I (B.P.)
          CLC
          ADC J          ;DEPLACEMENT PREMIER OCTET
          STA ADRL
                         ;
          LDA YHP,Y
          STA ADRH
                         ;
* AFFICHAGE LIGNE I            *
                         ;
          LDY #$00       ;INDICE PREMIER OCTET A L'ECRAN
XCIMAGE2  LDA (FORMEL,X) ;OCTET COURANT DE LA FORME
          PHA            ;SAUVEGARDE
          AND (ADRL),Y   ;TEST COLLISION
          BEQ XCIMAGE3   ;PAS DE  PROBLEME
          STY COLLIS     ;SEMAPHORE <>0
                         ;
XCIMAGE3  PLA            ;RESTAURATION OCTET FORME
          EOR (ADRL),Y
          STA (ADRL),Y   ;AFFICHAGE A L'ECRAN
                         ;
* MISE A JOUR DES # D'OCTETS   *
                         ;
          INY            ;PROCHAINOCTET A L'ECRAN
          INC FORMEL     ;PROCHAIN OCTET DS TABLE DE FORME
          CPY NOCTETS    ;COMPARER AU NBRE D'O/L
          BNE XCIMAGE2   ;<>0? OUI, I INACHEVEE
                         ;
          INC I          ;LIGNE SUIVANTE
          DEC NLIGNES    ;DECOMPTE DES LIGNES
          BNE XCIMAGE1   ;<>0? OUI, RESTE DES IS
                         ;
          RTS
                         ;
********************************
*       NIMAGE                 *
* AFFICHAGE EN NOIR D'UNE      *
* FORME.                       *
********************************
                         ;
                         ;
* INITIALISATIONS              *
                         ;
NIMAGE    STY I          ;N0 PREMIERE LIGNE
          STX J          ;N0 PREMIER OCTET
                         ;
          LDX #$00       ;TJRS 0 PR ADRESSAGE INDIRECT INDEXE
                         ;
* CALCUL ADRESSE PREMIER OCTET *
* A L'ECRAN                    *
                         ;
NIMAGE1   LDY I
          LDA YBP,Y      ;ADRESSE DE BASE I (B.P.)
          CLC
          ADC J          ;DEPLACEMENT PREMIER OCTET
          STA ADRL
                         ;
          LDA YHP,Y
          STA ADRH
                         ;
* AFFICHAGE LIGNE I            *
                         ;
          LDY #$00       ;INDICE PREMIER OCTET A L'ECRAN
NIMAGE2   LDA (FORMEL,X) ;OCTET COURANT DE LA FORME
          EOR #$FF       ;COMPLEMENT
          AND (ADRL),Y   ;OCTET PAGE GRAPHIQUE
          STA (ADRL),Y   ;AFFICHAGE A L'ECRAN
                         ;
* MISE A JOUR DES # D'OCTETS   *
                         ;
          INY            ;PROCHAINOCTET A L'ECRAN
          INC FORMEL     ;PROCHAIN OCTET DS TABLE DE FORME
          CPY NOCTETS    ;COMPARER AU NBRE D'O/L
          BNE NIMAGE2    ;<>0? OUI, I INACHEVEE
                         ;
          INC I          ;LIGNE SUIVANTE
          DEC NLIGNES    ;DECOMPTE DES LIGNES
          BNE NIMAGE1    ;<>0? OUI, RESTE DES IS
                         ;
          RTS
                         ;
********************************
* DELAI: ROUTINE DE PAUSE      *
********************************
                         ;
                         ;
DELAI     STA D2
          LDA #$00
          STA D1
DELAI1    DEC D1
          BNE DELAI1
          DEC D2
          BNE DELAI1
          RTS
                         ;
                         ;
********************************
* GENERE DEUX NOMBRES RND1 & 2 *
* HASARD                       *
********************************
                         ;
HASARD    LDA RND2
          CLC
          ADC #$01
          CMP #$07
          BNE HASARD1
          LDA #$00
HASARD1   STA RND2
          LDA RND1
          CLC
          ADC #$01
          CMP #$89
          BNE HASARD2
          LDA #$00
HASARD2   STA RND1
          RTS
