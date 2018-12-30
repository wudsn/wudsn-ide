                         ;
                         ;
********************************
********************************
*****                     ******
*****      ROUTINES       ******
*****    ENVAHISSEURS     ******
*****                     ******
********************************
********************************
                         ;
                         ;
********************************
* DEPLENV: DEPLACEMENT DES     *
* ENVAHISSEURS.                *
*                              *
********************************
                         ;
                         ;
*VERIFICATION SI DEPLACEMENT   *
                         ;
DEPLENV   DEC CPTRENV    ;DECOMPTE
          BNE DEPLENV2   ;<>0, PAS AU COURS DE CE CYCLE
          LDA FRENV      ;REMISE A NEUF COMPTEUR
          STA CPTRENV
                         ;
* DEPLACEMENT EFFECTIF         *
                         ;
          JSR AFFENV     ;EFFACEMENT DES ENVAHISSEURS
                         ;
          DEC NDPLH      ;DECOMPTE DES DEPLACEMENTS HORIZONTAUX
          BNE DEPLENV1   ;<>0, IL EN RESTE A EFFECTUER
                         ;
          JSR DEPLV      ;DEPLACEMENT VERTICAL
          JSR AFFENV     ;REAFFICHAGE
          RTS
                         ;
                         ;
DEPLENV1  JSR DEPLH      ;DEPLACEMENT HORIZONTAL DES ENVAHISSEURS
          JSR AFFENV     ;REAFFICHAGE
          RTS
                         ;
* LACHE D'UNE BOMBE            *
DEPLENV2  JSR LACHER
          LDA ATT1
          JSR DELAI
          RTS
                         ;
                         ;
                         ;

                         ;
********************************
* DEPLH: DEPLACEMENT HORIZONTAL*
* DES ENVAHISSEURS.            *
********************************
                         ;
DEPLH     LDA XHORIZ     ;MISE A JOUR XHORIZ
          CLC
          ADC PASH
          STA XHORIZ
                         ;
* COMMUTATION DU TYPE D'ENV.   *
                         ;
          LDX L1         ;X COMPTEUR DE LIGNE
          DEX            ;POUR COMPENSER INX QUI SUIT
          LDY #$0A       ;INDICE DU TYPE DANS LA TABLE
DEPLH1    INX            ;LIGNE SUIVNTE
          LDA ATLL,X     ;ADRESSE TABLE TL
          STA BDRL       ;PREPARATION ADRESSAGE INDIRECT
          LDA ATLH,X
          STA BDRH
                         ;
          LDA DIFFT      ;DIFFERENCE D'ADRESSE TYPE 2-TYPE 1
          SEC
          SBC (BDRL),Y   ;COMMUTATION
          STA (BDRL),Y
                         ;
          CPX L2         ;COMPARAISON DERNIERE LIGNE
          BNE DEPLH1
          RTS
                         ;
                         ;
********************************
* DEPLV: DEPLACEMENT VERTICAL  *
* DES ENVAHISSEURS.            *
********************************
                         ;
                         ;
DEPLV     LDA #$00       ;INVERSION DU SENS HORIZONTAL
          SEC
          SBC PASH
          STA PASH       ;PASH:=-PASH
* REMISE A JOUR DE NDPLH       *
                         ;
          LDA C1
          SEC
          SBC C2
          STA TEMP       ;(C1-C2)
          ASL            ;(C1-C2)*2
          CLC
          ADC TEMP       ;(C1-C2)*3
          CLC
          ADC NPOS
          STA NDPLH      ;NPOS-(C2-C1)*3
                         ;
                         ;
*CHANGEMENT DE LIGNE           *
                         ;
          LDA YVERT
          CLC
          ADC PASV
          STA YVERT
          DEC PLUSVITE   ;DECOMPTE SEMAPHORE ACCELERATION
                         ;
          RTS
                         ;
                         ;
********************************
* AFFENV: AFFICHAGE DES ENVA-  *
* HISSEURS.                    *
********************************
                         ;
AFFENV    LDA L1
          STA LENV       ;COMPTEUR DE LIGNES
          LDA YVERT
          STA YENV
                         ;
AFFENV1   JSR AFFL       ;AFFICHAGE LIGNE
          LDA LENV
          CMP L2         ;DERNIERE LIGNE?
          BEQ AFFENV2    ;=0, OUI
                         ;
          INC LENV       ;LIGNE SUIVANTE
          LDA YENV       ;ORDONNEE SUIVANTE
          CLC
          ADC DISTV
          STA YENV
          BNE AFFENV1    ;=JMP
                         ;
AFFENV2   RTS            ;FIN D'AFFICHAGE
                         ;
                         ;
********************************
* AFFL: AFFICHE LA LIGNE L     *
* DES ENVAHISSEURS.            *
********************************
                         ;
                         ;
                         ;
* RECHERCHE TABLE LIGNE        *
                         ;
AFFL      LDX LENV       ; # LIGNE ENVAHISSEURS
          LDA ATLL,X     ;ADRESSE TL
          STA BDRL
          LDA ATLH,X
          STA BDRH       ;PREPARATION ADRESSAGE INDIRECT
                         ;
          LDY #$0A
          LDA (BDRL),Y   ;TYPE DE FORME
          STA TYPENV
                         ;
          LDA XHORIZ     ;ABSCISSE 1ERE COLONNE
          STA XENV
                         ;
* BOUCLE SUR LES COLONNES      *
                         ;
          LDA C1
          STA CENV       ;INITIALISATION COLONNE COURANTE
                         ;
AFFL1     LDY CENV       ;INDICE DS TL
          LDA (BDRL),Y
          BEQ AFFL2      ;PAS D'ENVAHISSEUR
          JSR PRENV
          JSR XIMAGE     ;AFFICHAGE
                         ;
AFFL2     LDA CENV       ;COLONNE COURANTE
          CMP C2         ;COMPARAISON
          BEQ AFFL3      ;=0, DERNIERE COLONNE TRAITEE
                         ;
          LDA DISTH      ;MISE A JOUR XENV
          CLC
          ADC XENV
          STA XENV       ;ABSCISSE PROCHAIN ENV.
                         ;
          INC CENV       ;NUMERO PROCHAINE COLONNE
          BNE AFFL1      ;RETOUR BOUCLE
                         ;
                         ;
* BASE ATTEINTE PAR LA HORDE?  *
                         ;
AFFL3     LDA YENV       ;ORDONNEE LIGNE COURANTE
          CMP YBASE
          BNE AFFL4      ;<>0,  NON PAS CETTE FOIS...
          JSR EXPLB      ;EXPLOSION BASE
          JMP PERDU      ;PAS DE CHANCE!
                         ;
AFFL4     RTS            ;LIGNE TERMINEE
                         ;
                         ;
                         ;
********************************
* PRENV: PREPARATION DES PARA- *
* POUR LE TRACE D'UN ENVAHISS. *
********************************
                         ;
                         ;
PRENV     LDA #$02       ;2 OCTETS/LIGNE
          STA NOCTETS
          LDA #$08       ;HAUTEUR EN LIGNES
          STA NLIGNES
                         ;
          LDY LENV       ;# DE LIGNE ENVAHISSEUR
          LDA FENVL,Y    ;ADRESSE FORME
          CLC
          ADC TYPENV     ;+ DIFFERENCE ADRESSE DUE AU TYPE
          STA FORMEL
          LDA FENVH,Y
          ADC #$00       ;ADDITION SUR 2 OCTETS
          STA FORMEH
                         ;
          LDY YENV       ;ORDONNEE
          LDX XENV       ;ABSCISSE
                         ;
          RTS
                         ;
                         ;
                         ;
********************************
* LACHER                       *
* LACHE UNE BOMBE              *
********************************
                         ;
                         ;
                         ;
* RECHERCHE DES CANDIDATS      *
                         ;
LACHER    LDA L1         ;LIGNE COURANTE
          STA LENV       ;DEPART LIGNE L1
          LDA YVERT      ;ORDONNEE DE LA LIGNE COURANTE
          STA YENV
                         ;
          LDY C2         ;MISE A ZERO DE SC(I)
          LDA #$00
LACHER0   STA SC,Y
          DEY
          BPL LACHER0
                         ;
                         ;
LACHER1   LDX LENV       ;# DE LIGNE COURANTE
          LDA ATLL,X
          STA BDRL
          LDA ATLH,X
          STA BDRH       ;ADRESSE TABLE ENVAHISSEURS EN LENV
                         ;
          LDY C1         ;COLONNE COURANTE, ON DEMARRE PAR C1.
          LDA XHORIZ     ;ABSCISSE COURANTE
          STA XENV
LACHER2   LDA (BDRL),Y   ;SEMAPHORE DE PRESENCE
          BEQ LACHER3    ;=0, PERSONNE
          CLC
          ADC SC,Y       ;INCREMENTER SOMME POUR CETTE COLONNE
          STA SC,Y
* CET ENVAHISSEURS EST IL LE   *
* DERNIER DE LA COLONNE?       *
                         ;
          CMP SCOL,Y     ;COMPARER A LA SOMME ENTIERE
          BNE LACHER3    ;SOMMES DIFFERENTES, CE N'EST PAS LE DERNIER.
                         ;
* ON POSSEDE UN CANDIDAT       *
                         ;
          STY NBO        ;SAUVEGARDER Y
          JSR DROP       ;LARGUER LA BOMBE
          LDY NBO        ;RECUPERER Y
LACHER3   CPY C2         ;DERNIERE COLONNE?
          BEQ LACHER4    ;=0, TERMINE POUR CETTE LIGNE.
          INY            ;COLONNE SUIVANTE
                         ;
          LDA XENV       ;MISE A JOUR ABSCISSE COLONNE
          CLC
          ADC DISTH
          STA XENV
                         ;
          BNE LACHER2    ;BOUCLAGE
                         ;
LACHER4   LDA LENV
          CMP L2         ;DERNIERE LIGNE?
          BEQ LACHER5    ;=0, OUI.
          INC LENV       ;LIGNE SUIVANTE

          LDA YENV       ;MISE A JOUR ORDONEE LIGNE
          CLC
          ADC DISTV
          STA YENV
          BNE LACHER1    ;BOUCLAGE
                         ;
LACHER5   RTS
                         ;
                         ;
