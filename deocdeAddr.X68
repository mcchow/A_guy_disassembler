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
* Assuming address is in D1
    
DeAddr  MOVE.L D1,D3
        AND #63,D3
* decode MODE
        MOVE    D3,D4
        ASR #3,D4
        CMP #0,D4
        BEQ REGISTERD
        CMP #1,D4
        BEQ REGISTERA
        CMP #2,D4
        BEQ DIRADDR
*SECTION FOR D# AND A#
REGISTERD    LEA     D,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR PRINTDIGI
        BRA EndDeAddr
REGISTERA  LEA     A,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR PRINTDIGI
        BRA EndDeAddr         
*PRINT REGISTER#
PRINTDIGI   AND #7,D3
    MOVE.W  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    RTS
*DIRECT ADDRESS (A#)
DIRADDR LEA     ABra,A1
        MOVE.B  #14,D0
        TRAP    #15
    AND #7,D3
    MOVE.W  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    
    
    EndDeAddr   MOVE D1,D0 
    SIMHALT             ; halt simulator
   

* Put variables and constants here
CR      EQU     $0D
LF      EQU     $0A
D DC.B    'D',0
A DC.B    'A',0
ABra DC.B   '(A',0
CloBra DC.B ')',0
PlusSign DC.B '+',0
NegSign DC.B '-',0
NEXTLINE DC.B CR,LF,0


    END    START        ; last line of source
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
