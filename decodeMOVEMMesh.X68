*-----------------------------------------------------------
* Title      : Move M mesh decode
* Written by :Martin Chow Sheung Him
* Date       :
* Description: decode the move M address mesh
* mesh is a 16 bit data that indicate the D# and A# need to store
* there are two way , read and store is decode
* this function is taking D6 as input mesh and print the D# and A# as output
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
*TEST only , getting input
    MOVE.B  #4,D0
    TRAP    #15
* D6 is the data, D1 is the count
    MOVE D1,D6
    MOVE #0,D1
    
* PRINT FIRST D#
FirstD  CMP #8,D1
    BEQ FirstAST
    MOVE D6,D5

* DETERMINE DIRECTION(READ OR WRITE TO M)
    CMP #0,D4
    BEQ FDIN
    BRA FDRE
FDIN    AND #1,D5
    LSR #1,D6
    BRA ENDFDIN
FDRE    AND #32768,D5
    LSL #1,D6
    
ENDFDIN    CMP #0,D5
    BEQ FirstDADDONE
    JSR PRINTDMM
    JSR PRINTDIGIMM
    BRA NextDST
FirstDADDONE    ADD #1,D1
    BRA FirstD
    
* PRINT NEXT D# START WITH /
NextDST ADD #1,D1
NextD   CMP #8,D1
    BEQ FirstASTSL
    MOVE D6,D5
* DETERMINE DIRECTION(READ OR WRITE TO M)
    CMP #0,D4
    BEQ FNIN
    BRA FNRE
NDIN    AND #1,D5
    LSR #1,D6
    BRA ENDFNIN
NDRE    AND #32768,D5
    LSL #1,D6
    
ENDFDIN BEQ NEXTDADDONE
    JSR PRINTSLASHMM
    JSR PRINTDMM
    JSR PRINTDIGIMM
NEXTDADDONE    ADD #1,D1    
    BRA NEXTD


*PRINT SLASH AS THERE IS D#
FirstASTSL JSR PRINTSLASHMM
* PRINT FIRST A#
FirstAST MOVE #0,D1

FirstA  CMP #8,D3
    BEQ MESHEND
    MOVE D6,D5
    
* DETERMINE DIRECTION(READ OR WRITE TO M)
    CMP #0,D4
    BEQ FAIN
    BRA FARE
FAIN    AND #1,D5
    LSR #1,D6
    BRA ENDFAIN
FARE    AND #32768,D5
    LSL #1,D6
    
ENDFAIN   BEQ FirstAADDONE
    JSR PRINTAMM
    JSR PRINTDIGIMM
    BRA NextAST
FirstAADDONE    ADD #1,D1
    BRA FirstA

NextAST ADD #1,D1
NextA   CMP #8,D1
    BEQ FirstASTSL
    MOVE D6,D5* DETERMINE DIRECTION(READ OR WRITE TO M)
    CMP #0,D4
    BEQ FDIN
    BRA FDRE
FDIN    AND #1,D5
    LSR #1,D6
    BRA ENDFDIN
FDRE    AND #32768,D5
    LSL #1,D6
    
ENDFDIN BEQ NEXTDADDONE
    JSR PRINTSLASHMM
    JSR PRINTDMM
    JSR PRINTDIGIMM
NEXTDADDONE    ADD #1,D1    
    BRA NEXTD

MESHEND MOVE D0,D0
    
    
    
    
    
    
    SIMHALT             ; halt simulator
*====================================================================
*FUNCTION LIST
*====================================================================

*PRINT D FOR MOVEM
PRINTDMM    LEA     D,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
        
*PRINT A FOR MOVEM        
PRINTAMM    LEA     A,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
*PRINT DIGI MOVE M
PRINTDIGIMM   MOVE.B  #3,D0
    TRAP    #15
    RTS

*PRINT /
PRINTSLASHMM    LEA     SLASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS


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
SLASH DC.B '/',0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
