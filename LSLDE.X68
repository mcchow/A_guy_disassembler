*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    lsR.b     #$02,d0
    lsl.w     #$04,d2
    lsl.w     $00FF0000
*TEST only , getting input
    MOVE.B  #4,D0
    TRAP    #15
    MOVE D1,D7
*REAL CODE======================================
* memory shift
startLS    MOVE D7,D6
    AND #192,D6
    LSR #6,D6
    CMP #3,D6
    BEQ MSLS
    BRA NormalLS
*memory shift section
MSLS    * LS, AS, RO
    LSR #8,D6
    LSR #1,D6
    AND #3,D6
    CMP #1,D6
    BEQ PRINTLSM
    CMP #0,D6
    BEQ PRINTASM
    CMP #2,D6
    BEQ PRINTROM

MSLR    MOVE D7,D6
    AND #256,D6
    CMP #0,D6
    BEQ PRINTRM
    BRA PRINTLM
MSEA    MOVE D7,D6
*print effective address.... need to copy
    BRA ENDOFLR


PRINTLSM LEA     LS,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA MSLR
PRINTASM LEA     AS,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA MSLR
PRINTROM LEA     RO,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA MSLR
PRINTLM LEA     L,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DefineSIZE
PRINTRM LEA     R,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DefineSIZE



NormalLS    MOVE D7,D6
* LS, AS, RO
    AND #24,D6
    LSR #3,D6
    CMP #1,D6
    BEQ PRINTLS
    CMP #0,D6
    BEQ PRINTAS
    CMP #2,D6
    BEQ PRINTRO
    
* left or right
LRDefine MOVE D7,D6
    AND #256,D6
    CMP #0,D6
    BEQ PRINTR
    BRA PRINTL

* size
DefineSIZE    MOVE D7,D6
    AND #192,D6
    LSR #6,D6
    CMP #0,D6
    BEQ PRINTSIZEB
    CMP #1,D6
    BEQ PRINTSIZEW

*D# OR # IE: LSL.R (d# / #)
DEFINENUM MOVE D7,D6
    AND #16,D6
    CMP #0,D6
    BEQ PRINTNUM
    MOVE D7,D6
    AND #1792,D6
    LSR #8,D6
    MOVE D6,D1
    JSR PRINTDADDR
    
*DISTINATION D#
DEFINEDIS MOVE D7,D6
    LEA     COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    AND #7,D6
    MOVE    D6,D1
    JSR PRINTDADDR
    BRA ENDOFLR
    
PRINTLS LEA     LS,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA LRDefine
PRINTAS LEA     AS,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA LRDefine
PRINTRO LEA     RO,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA LRDefine
PRINTL LEA     L,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DefineSIZE
PRINTR LEA     R,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DefineSIZE
PRINTSIZEB LEA     SizeB,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DEFINENUM
PRINTSIZEW LEA     SizeW,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA DEFINENUM
PRINTDADDR LEA D,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #3,D0
    TRAP    #15
    RTS
PRINTNUM LEA NUM,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE D7,D6
    LSR #8,D6
    LSR #1,D6
    AND #7,D6
    MOVE    D6,D1
    MOVE.B  #3,D0
    TRAP    #15
    BRA     DEFINEDIS

ENDOFLR MOVE D6,D5
    SIMHALT             ; halt simulator

* Put variables and constants here
LS DC.B    'LS',0
AS DC.B    'AS',0
RO DC.B    'RO',0
L DC.B    'L',0
R DC.B    'R',0
D DC.B    'D',0
SizeB DC.B    '.B ',0
SizeW DC.B  '.W ',0
NUM DC.B '#',0
COMMA DC.B ' , ',0

    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
