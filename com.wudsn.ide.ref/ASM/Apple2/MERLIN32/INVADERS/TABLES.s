          DS $5000-*
********************************
* TABLES DIVERSES              *
********************************
                         ;
                         ;

                         ;
********************************
* ADRESSES DE BASE DES LIGNES  *
*  YBP,Y=BITS DE BAS POIDS     *
*  YHP,Y=BITS DE HAUTS POIDS   *
*  DE LA LIGNE Y.              *
*                              *
* NON LISTEE                   *
********************************
          LST OFF
********************************
                         ;
YBP       HEX 0000000000000000
          HEX 8080808080808080
          HEX 0000000000000000
          HEX 8080808080808080
          HEX 0000000000000000
          HEX 8080808080808080
          HEX 0000000000000000
          HEX 8080808080808080
          HEX 2828282828282828
          HEX A8A8A8A8A8A8A8A8
          HEX 2828282828282828
          HEX A8A8A8A8A8A8A8A8
          HEX 2828282828282828
          HEX A8A8A8A8A8A8A8A8
          HEX 2828282828282828
          HEX A8A8A8A8A8A8A8A8
          HEX 5050505050505050
          HEX D0D0D0D0D0D0D0D0
          HEX 5050505050505050
          HEX D0D0D0D0D0D0D0D0
          HEX 5050505050505050
          HEX D0D0D0D0D0D0D0D0
          HEX 5050505050505050
          HEX D0D0D0D0D0D0D0D0
*
YHP       HEX 2024282C3034383C
          HEX 2024282C3034383C
          HEX 2125292D3135393D
          HEX 2125292D3135393D
          HEX 22262A2E32363A3E
          HEX 22262A2E32363A3E
          HEX 23272B2F33373B3F
          HEX 23272B2F33373B3F
          HEX 2024282C3034383C
          HEX 2024282C3034383C
          HEX 2125292D3135393D
          HEX 2125292D3135393D
          HEX 22262A2E32363A3E
          HEX 22262A2E32363A3E
          HEX 23272B2F33373B3F
          HEX 23272B2F33373B3F
          HEX 2024282C3034383C
          HEX 2024282C3034383C
          HEX 2125292D3135393D
          HEX 2125292D3135393D
          HEX 22262A2E32363A3E
          HEX 22262A2E32363A3E
          HEX 23272B2F33373B3F
          HEX 23272B2F33373B3F
                         ;
          LST ON
                         ;
********************************
********************************
*  ENVAHISSEURS                *
********************************
********************************
                         ;
          DS $5200-*
                         ;
*
* TABLE DEPLACEMENT 0
*
ENV11     HEX 6143
          HEX 7A2F
          HEX 5C1D
          HEX 5C1D
          HEX 7E3F
          HEX 7E3F
          HEX 180C
          HEX 0F78
*
*
ENV12     HEX 6223
          HEX 7A2F
          HEX 5C1D
          HEX 5C1D
          HEX 7E3F
          HEX 7E3F
          HEX 180C
          HEX 1C1C
*
*
ENV21     HEX 2412
          HEX 3C1E
          HEX 7C1F
          HEX 4C19
          HEX 780F
          HEX 780F
          HEX 680B
          HEX 4631
*
*
ENV22     HEX 2632
          HEX 3C1E
          HEX 7C1F
          HEX 5C1D
          HEX 580D
          HEX 780F
          HEX 680B
          HEX 4809
*
*
ENV31     HEX 780F
          HEX 7C1F
          HEX 4E39
          HEX 4631
          HEX 7E3F
          HEX 580D
          HEX 180C
          HEX 1004
*
ENV32     HEX 780F
          HEX 7C1F
          HEX 4E39
          HEX 4631
          HEX 7E3F
          HEX 580D
          HEX 180C
          HEX 0C18
*
********************************
* TABLE DES ADRESSE DE FORMES  *
********************************
                         ;
FENVL     DFB #<ENV11,#<ENV11,#<ENV21,#<ENV21,#<ENV31,#<ENV31
FENVH     DFB #>ENV11,#>ENV11,#>ENV21,#>ENV21,#>ENV31,#>ENV31
                         ;
                         ;
********************************
* TABLE DES LIGNES D'ENVAHIS.  *
********************************
                         ;
TL1       DS 12
TL2       DS 12
TL3       DS 12
TL4       DS 12
TL5       DS 12
TL6       DS 12
TL7       DS 12
TL8       DS 12
                         ;
* ADRESSE DES TABLES TL        *
                         ;
ATLL      DFB #<TL1,#<TL2,#<TL3,#<TL4,#<TL5,#<TL6,#<TL7,#<TL8
ATLH      DFB #>TL1,#>TL2,#>TL3,#>TL4,#>TL5,#>TL6,#>TL7,#>TL8
                         ;
          DS $5300-*
*
* TABLE DE FORME DE LA BASE
*


*
* TABLE DEPLACEMENT 0
*
BASE0     HEX 400100
          HEX 400100
          HEX 400100
          HEX 780F00
          HEX 780F00
          HEX 780F00
          HEX 7F7F00
          HEX 7F7F00
*
* TABLE DEPLACEMENT 1
*
BASE1     HEX 000300
          HEX 000300
          HEX 000300
          HEX 701F00
          HEX 701F00
          HEX 701F00
          HEX 7E7F01
          HEX 7E7F01
*
* TABLE DEPLACEMENT 2
*
BASE2     HEX 000600
          HEX 000600
          HEX 000600
          HEX 603F00
          HEX 603F00
          HEX 603F00
          HEX 7C7F03
          HEX 7C7F03
*
* TABLE DEPLACEMENT 3
*
BASE3     HEX 000C00
          HEX 000C00
          HEX 000C00
          HEX 407F00
          HEX 407F00
          HEX 407F00
          HEX 787F07
          HEX 787F07
*
* TABLE DEPLACEMENT 4
*
BASE4     HEX 001800
          HEX 001800
          HEX 001800
          HEX 007F01
          HEX 007F01
          HEX 007F01
          HEX 707F0F
          HEX 707F0F
*
* TABLE DEPLACEMENT 5
*
BASE5     HEX 003000
          HEX 003000
          HEX 003000
          HEX 007E03
          HEX 007E03
          HEX 007E03
          HEX 607F1F
          HEX 607F1F
*
* TABLE DEPLACEMENT 6
*
BASE6     HEX 006000
          HEX 006000
          HEX 006000
          HEX 007C07
          HEX 007C07
          HEX 007C07
          HEX 407F3F
          HEX 407F3F
                         ;
* ADRESSES DES DEPLACEMENTS EN *
* FONCTION DE X                *
                         ;
BASEBP    DFB <BASE0,<BASE1,<BASE2,<BASE3,<BASE4,<BASE5,<BASE6
                         ;
********************************
* BALLES TIREES PAR LA BASE    *
********************************
                         ;
                         ;
          DS $5400-*
BALLE0    HEX 0300
          HEX 0300
          HEX 0300
          HEX 0300
*
* TABLE DEPLACEMENT 1
*
BALLE1    HEX 0600
          HEX 0600
          HEX 0600
          HEX 0600
*
* TABLE DEPLACEMENT 2
*
BALLE2    HEX 0C00
          HEX 0C00
          HEX 0C00
          HEX 0C00
*
* TABLE DEPLACEMENT 3
*
BALLE3    HEX 1800
          HEX 1800
          HEX 1800
          HEX 1800
*
* TABLE DEPLACEMENT 4
*
BALLE4    HEX 3000
          HEX 3000
          HEX 3000
          HEX 3000
*
* TABLE DEPLACEMENT 5
*
BALLE5    HEX 6000
          HEX 6000
          HEX 6000
          HEX 6000
*
* TABLE DEPLACEMENT 6
*
BALLE6    HEX 4001
          HEX 4001
          HEX 4001
          HEX 4001
                         ;
                         ;
BALLEBP   DFB <BALLE0,<BALLE1,<BALLE2,<BALLE3,<BALLE4,<BALLE5,<BALLE6
                         ;
                         ;
                         ;
********************************
*  EXPLOSIONS ENVAHISSEURS     *
********************************
                         ;
          DS $5500-*
                         ;
*
EXPL      HEX 8080
          HEX 5082
          HEX 8080
          HEX 888A
          HEX A081
          HEX 9492
          HEX 82A4
          HEX D491
          HEX C195
          HEX 94C0
          HEX 810A
          HEX AAD1
          HEX 8084
          HEX AA95
          HEX 80A0
          HEX D48A
                         ;
                         ;
********************************
* FORME ABRI                   *
********************************
                         ;
                         ;
ABRI      HEX 401F00
          HEX 707F00
          HEX 787F01
          HEX 7C7F03
          HEX 7E7F07
          HEX 7E7F07
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
          HEX 7F7F0F
                         ;
                         ;
********************************
* ECLAT DE BALLE DANS ABRI     *
********************************
                         ;
*
* TABLE DEPLACEMENT 0
*
ECLAT0    HEX 1000
          HEX 1B00
          HEX 0F00
          HEX 1E00
          HEX 0F00
          HEX 1F00
          HEX 0F00
          HEX 0700
ECLAT1    HEX 0000
          HEX 0300
          HEX 0700
          HEX 1C00
          HEX 0E00
          HEX 0E00
          HEX 0F00
          HEX 0700
ECLAT2    HEX 0000
          HEX 0600
          HEX 0E00
          HEX 3800
          HEX 1C00
          HEX 1C00
          HEX 1E00
          HEX 0E00
ECLAT3    HEX 0000
          HEX 0000
          HEX 0000
          HEX 7300
          HEX 3F00
          HEX 3E00
          HEX 3C00
          HEX 1C00
ECLAT4    HEX 0703
          HEX 0603
          HEX 4601
          HEX 6601
          HEX 7E00
          HEX 7C00
          HEX 7800
          HEX 3800
ECLAT5    HEX 0000
          HEX 0000
          HEX 0000
          HEX 0000
          HEX 7000
          HEX 7801
          HEX 7001
          HEX 7000
ECLAT6    HEX 0000
          HEX 0000
          HEX 0007
          HEX 200F
          HEX 6003
          HEX 6007
          HEX 7007
          HEX 6003
                         ;
                         ;
                         ;
ECLATBP   DFB <ECLAT0,<ECLAT1,<ECLAT2,<ECLAT3,<ECLAT4,<ECLAT5,<ECLAT6
                         ;
                         ;
********************************
* FORME BOMBE                  *
********************************
                         ;
                         ;

          DS $5600-*


*
* TABLE DEPLACEMENT 0
*
BOMBE0    HEX 0500
          HEX 0700
          HEX 0700
          HEX 0200
*
* TABLE DEPLACEMENT 1
*
BOMBE1    HEX 0A00
          HEX 0E00
          HEX 0E00
          HEX 0400
*
* TABLE DEPLACEMENT 2
*
BOMBE2    HEX 1400
          HEX 1C00
          HEX 1C00
          HEX 0800
*
* TABLE DEPLACEMENT 3
*
BOMBE3    HEX 2800
          HEX 3800
          HEX 3800
          HEX 1000
*
* TABLE DEPLACEMENT 4
*
BOMBE4    HEX 5000
          HEX 7000
          HEX 7000
          HEX 2000
*
* TABLE DEPLACEMENT 5
*
BOMBE5    HEX 2001
          HEX 6001
          HEX 6001
          HEX 4000
*
* TABLE DEPLACEMENT 6
*
BOMBE6    HEX 4002
          HEX 4003
          HEX 4003
          HEX 0001
BOMBEBP   DFB #<BOMBE0,#<BOMBE1,#<BOMBE2,#<BOMBE3,#<BOMBE4,#<BOMBE5,#<BOMBE6
                         ;
                         ;
********************************
* TROU PROVOQUE PAR UNE BOMBE  *
* DANS UN ABRI.                *
********************************
                         ;

          DS $5700-*


*
* TABLE DEPLACEMENT 0
*
TROU0     HEX 3F00
          HEX 3F00
          HEX 3E00
          HEX 7E00
          HEX 3E01
          HEX 1C00
          HEX 0800
*
* TABLE DEPLACEMENT 1
*
TROU1     HEX 7E00
          HEX 7E00
          HEX 7C00
          HEX 7C01
          HEX 7C02
          HEX 3800
          HEX 1000
*
* TABLE DEPLACEMENT 2
*
TROU2     HEX 7C01
          HEX 7C01
          HEX 7801
          HEX 7803
          HEX 7805
          HEX 7000
          HEX 2000
*
* TABLE DEPLACEMENT 3
*
TROU3     HEX 7803
          HEX 7803
          HEX 7003
          HEX 7007
          HEX 700B
          HEX 6001
          HEX 4000
*
* TABLE DEPLACEMENT 4
*
TROU4     HEX 7007
          HEX 7007
          HEX 6007
          HEX 600F
          HEX 6017
          HEX 4003
          HEX 0001
*
* TABLE DEPLACEMENT 5
*
TROU5     HEX 600F
          HEX 600F
          HEX 400F
          HEX 401F
          HEX 402F
          HEX 0007
          HEX 0002
*
* TABLE DEPLACEMENT 6
*
TROU6     HEX 401F
          HEX 401F
          HEX 001F
          HEX 003F
          HEX 005F
          HEX 000E
          HEX 0004
TROUBP    DFB #<TROU0,#<TROU1,#<TROU2,#<TROU3,#<TROU4,#<TROU5,#<TROU6
                         ;
                         ;
********************************
* EXPLOSION DE LA BASE         *
********************************
                         ;
                         ;
          DS $5800-*
                         ;
*
* TABLE DEPLACEMENT 0
*
DEBRI0    HEX 0300
          HEX 0300
*
* TABLE DEPLACEMENT 1
*
DEBRI1    HEX 0600
          HEX 0600
*
* TABLE DEPLACEMENT 2
*
DEBRI2    HEX 0C00
          HEX 0C00
*
* TABLE DEPLACEMENT 3
*
DEBRI3    HEX 1800
          HEX 1800
*
* TABLE DEPLACEMENT 4
*
DEBRI4    HEX 3000
          HEX 3000
*
* TABLE DEPLACEMENT 5
*
DEBRI5    HEX 6000
          HEX 6000
*
* TABLE DEPLACEMENT 6
*
DEBRI6    HEX 4001
          HEX 4001
DEBRIBP   DFB #<DEBRI0,#<DEBRI1,#<DEBRI2,#<DEBRI3,#<DEBRI4,#<DEBRI5,#<DEBRI6
                         ;
                         ;
********************************
* TABLE D'EXPLOSION            *
********************************
                         ;
                         ;
YD0       HEX BEBEBEBEBEBEBE
          HEX BEBEBEBEBEBEBE
          HEX BEBEBEBEBEBEBEBE
          HEX BDBDBDBDBDBDBDBD
          HEX BCBCBCBCBCBCBCBC
          HEX BBBBBBBBBBBBBBBB
          HEX BABABABAB9B900
XD0       HEX 00020406080A0C
          HEX 0001030507090B
          HEX 0305070903050709
          HEX 0406080904060809
          HEX 0305070903050709
          HEX 0305070903050709
          HEX 0606060606060000
VX0       HEX FFFEFEFD010203
          HEX FFFEFEFD010203
          HEX FE01FF020201FFFE
          HEX FFFF0101FEFB0102
          HEX FEFF0201FDFE0203
          HEX FCFA0402FFFE0302
          HEX FFFE0102FF030000
VY0       HEX F0F6F5FEFDF6F5
          HEX F4F3FFFEF2F4EF
          HEX F1F2F3F4F5F0F1F3
          HEX F3F4F0FFF2F3F4F5
          HEX F7F8F9FAFBFCFDFE
          HEX FFFEFDFCFBFAF9F8
          HEX F7F9FAFBF9FE0000
                         ;
                         ;
                         ;
********************************
*  TEXTES                      *
********************************
                         ;
                         ;
          DS $5A00-*
* SCORE:                       *
                         ;



SCORE     HEX 000000000000
          HEX 1E3C78787103
          HEX 214204091200
          HEX 010204091200
          HEX 1E0204797100
          HEX 200204491000
          HEX 214204091100
          HEX 1E3C78087203
                         ;

* RECORD:                      *
                         ;
RECORD    HEX 0000000000000000
          HEX 1F7E787071630300
          HEX 2102040912240400
          HEX 2102040812240800
          HEX 1F1E040872230800
          HEX 0902040812210800
          HEX 1102040912220400
          HEX 217E787011640300
                         ;
                         ;


* BASES:                       *
                         ;
                         ;
BASES     HEX 000000000000
          HEX 0F3C78786303
          HEX 114204091004
          HEX 114204081000
          HEX 1F7E78786003
          HEX 214200090004
          HEX 214204091004
          HEX 1F4278786303
                         ;
                         ;
* CHIFFRES DE 0 A 9            *



          DS $5B00-*
*
*
ZERO      HEX 0E
          HEX 11
          HEX 11
          HEX 11
          HEX 11
          HEX 11
          HEX 0E


*
*


*
* TABLE DEPLACEMENT 0
*
UN        HEX 04
          HEX 06
          HEX 04
          HEX 04
          HEX 04
          HEX 04
          HEX 0E
*
DEUX      HEX 0E
          HEX 11
          HEX 10
          HEX 0C
          HEX 02
          HEX 01
          HEX 1F


*
*
TROIS     HEX 0E
          HEX 11
          HEX 10
          HEX 0C
          HEX 10
          HEX 11
          HEX 0E


*
*
QUATRE    HEX 08
          HEX 0C
          HEX 0A
          HEX 09
          HEX 1F
          HEX 08
          HEX 08


*
*
CINQ      HEX 0F
          HEX 01
          HEX 01
          HEX 0F
          HEX 10
          HEX 10
          HEX 0F


*
*
SIX       HEX 0E
          HEX 11
          HEX 01
          HEX 0F
          HEX 11
          HEX 11
          HEX 0E


*
*
SEPT      HEX 1F
          HEX 10
          HEX 08
          HEX 04
          HEX 02
          HEX 02
          HEX 02


*
*
HUIT      HEX 0E
          HEX 11
          HEX 11
          HEX 0E
          HEX 11
          HEX 11
          HEX 0E


*
*
NEUF      HEX 0E
          HEX 11
          HEX 11
          HEX 1E
          HEX 10
          HEX 11
          HEX 0E
                         ;
CHIFFRE   DFB #<ZERO,#<UN,#<DEUX,#<TROIS,#<QUATRE,#<CINQ
          DFB #<SIX,#<SEPT,#<HUIT,#<NEUF
                         ;
                         ;
          DS $5C00-*
                         ;
* NUMERO DES DEPLACEMENTS EN   *
* FONCTION DE X.               *
* NON LISTEE                   *
          LST OFF
                         ;
                         ;
DEPL      LUP 37
          HEX 00010203040506
          --^
                         ;
          DS $5E00-*
                         ;
          LST ON
* TABLE DE NUMEROS D'OCTET EN  *
* PAGE GRAPHIQUE EN FONCTION DE*
* L'ABSCISSE                   *
* NON LISTEE                   *
          LST OFF
                         ;
NUMOCT
]A        = 0
          LUP 37
          DFB ]A,]A,]A,]A,]A,]A,]A
]A        = ]A+1
          --^
                         ;
                         ;
          LST ON
                         ;
********************************
* TABLE DE DIVISION PAR 3      *
********************************
                         ;
          DS $6100-*
                         ;
DIV3      HEX 000000010101
          HEX 020202030303
          HEX 040404050505
          HEX 060606070707
          HEX 080808090909
          HEX 0A0A0A0B0B0B
          HEX 0C0C0C0D0D0D
          HEX 0E0E0E0F0F0F
                         ;
                         ;
                         ;
********************************
* TABLES DE DEPLACEMENTS ET    *
* SUPPLEMENTS OCTET ALEATOIRES *
********************************
                         ;
                         ;
DPAL      HEX 04050601020305
OSAL      HEX 00000001010100
                         ;
                         ;
