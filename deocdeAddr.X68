*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: Move the code that you are planing to decode to A1
* input: A1, 6bit digit
* output: print the digit
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
*TEST only , getting input
    MOVE.B  #4,D0
    TRAP    #15
* Assuming address is in D1
    
DeAddr  MOVE.L D7,D3
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
        CMP #3,D4
        BEQ DIRADDRP
        CMP #4,D4
        BEQ DIRADDRN
        CMP #7,D4
        BEQ TEMPADDR
        BRA EndDeAddr ;JUST INCASE
        
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
    JSR PRINTDIGI
    LEA     CloBra,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA EndDeAddr
    
*DIRECT ADDRESS (A#)+
DIRADDRP LEA     ABra,A1
        MOVE.B  #14,D0
        TRAP    #15
    JSR PRINTDIGI
    LEA     CloBra,A1
    MOVE.B  #14,D0
    TRAP    #15
    LEA     PlusSign,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA EndDeAddr
    
*DIRECT ADDRESS -(A#)
DIRADDRN LEA     NegSign,A1
        MOVE.B  #14,D0
        TRAP    #15
    LEA     ABra,A1
    MOVE.B  #14,D0
    TRAP    #15
    JSR PRINTDIGI
    LEA     CloBra,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA EndDeAddr
    
    
*TEMPADDR # OR L OR W
TEMPADDR    AND #7,D3
    CMP #0,D3
    BRA WORDADDR
    CMP #1,D3
    BRA LONGADDR
    CMP #4,D3
    BRA IMMEADDR
    BRA EndDeAddr
    
WORDADDR MOVE A1,D3
    ADD #$4,A1 
    *MOVE.B  #4,D0 ; assuming getting data from next line
    *TRAP    #15
    MOVE.W  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    BRA EndDeAddr
    
LONGADDR    MOVE A1,D3
    ADD #$4,A1 
*MOVE.B  #4,D0 ; assuming getting data from next line
*    TRAP    #15
    MOVE.W  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    BRA EndDeAddr
    
IMMEADDR    LEA     NumSign,A1
        MOVE.B  #14,D0
        TRAP    #15
    MOVE A1,D3
    ADD #$4,A1
    MOVE.W  D3,D1
    MOVE.B  #3,D0
    TRAP    #15
    BRA EndDeAddr




EndDeAddr   MOVE D7,D1 
    SIMHALT             ; halt simulator
   

* Put variables and constants here
CR      EQU     $0D
LF      EQU     $0A
D DC.B    'D',0
A DC.B    'A',0
Bra DC.B   '(',0
NumSign DC.B '#',0
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
