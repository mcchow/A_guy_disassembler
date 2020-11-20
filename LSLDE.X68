*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE D7,D6
* LS, AS, RO
    AND 24,D6
    CMP 1,D6
    BEQ PRINTLS
    CMP 0,D6
    BEQ PRINTAS
    CMP 2,D6
    BEQ PRINTRO
    
    MOVE D7,D6
* left or right
    AND 100,D6
    CMP 0,D6
    BEQ PRINTL
    CMP 0,D6
    BEQ PRINTR
    
    MOVE D7,D6
* Number
    AND 488,D6
    LSR 8,D6
    MOVE D6,D1
    JMP PRINTNUM
    
    
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
