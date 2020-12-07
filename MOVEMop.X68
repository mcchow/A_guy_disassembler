*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*TEST only , getting input
    MOVE.B  #4,D0
    TRAP    #15

*Start of the move M function
MOVEMfunc    JSR printMOVEM
*print size
DefineSIZE    MOVE D7,D6
    AND #64,D6
    LSR #6,D6
    CMP #0,D6
    BEQ PRINTSIZEW
    JSR printTAP
* define read or write
    MOVE D7,D6
    AND #1024,D6
    LSR #6,D6
    CMP #0,D6
    BEQ MOVEMwrite
    BRA MOVEMread
*Register to memory
MOVEMwrite  MOVE A5,D6
    ADD #16,A5
    JSR FirstD
    JSR printcomma
    JSR DeAddr
    BRA ENDMOVEMfunc
MOVEMread      JSR DeAddr
    JSR printcomma
    MOVE A5,D6
    ADD #16,A5
    JSR FirstD
    

ENDMOVEMfunc    RTS    
SIMHALT             ; halt simulator

printMOVEM  LEA     MOVEM,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS

printTAP  LEA     MOVEM,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS

printcomma  LEA     comma,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
        
PRINTSIZEW  LEA     dotw,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS        
* Put variables and constants here
*this EA just test only , need to replace by real effective address code
EA  DC.B    '<EA>',0
MOVEM   DC.B  'MOVEM',0
TAP DC.B    '   ',0
comma DC.B  ',',0
dotw    DC.B    '.W',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
