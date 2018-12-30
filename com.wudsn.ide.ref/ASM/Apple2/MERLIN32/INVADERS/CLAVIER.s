********************************
********************************
****   CLAVIER             *****
********************************
********************************
                         ;
                         ;
********************************
* LIRECL: LECTURE DU CLAVIER   *
*                              *
* LIT LE CLAVIER ET MODIFIE    *
* EVENTUELLEMENT VBASE, FEU ET *
* DEBUG.                       *
********************************
                         ;
                         ;
LIRECL    LDA CLAVIER    ;LECTURE
          BPL RIEN
                         ;
                         ;
          CMP #$95       ;--->
          BNE LIRECL2    ;PAS CA
          LDA IBASE
          STA VBASE
          BPL RIEN       ;TERMINE
                         ;
LIRECL2   CMP #$88       ;<---
          BNE LIRECL3    ;TOUJOURS PAS BON
          LDA MIBASE     ;-IBASE
          STA VBASE
          BNE RIEN       ;TERMINE
                         ;
LIRECL3   CMP #$D3       ;"S"
          BNE LIRECL4    ;PAS BON
          LDA #$00
          STA VBASE
          BEQ RIEN
                         ;
LIRECL4   CMP #$A0       ;BARRE
          BNE RIEN
          JSR FEU
                         ;
RIEN      BIT CLACT      ;REACTIVATION
          JSR HASARD
          RTS            ;RETOUR
********************************
