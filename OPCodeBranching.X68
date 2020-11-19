*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

OPSETUP
    MOVEA.L input_start,A5
    MOVEA.L input_end,A6
    
PRIMELOOP
*----CHECK IF AT END OF MEMORY TO DECODE----
    CMPA.L  A5,A6
    BGT     ENDPROGRAM      ;WILL WRITE LATER
    
    MOVE.W  (A5)+,D7        ;MOVE NEXT WORD TO D7
    
    MOVE.W  D7,D6           ;MOVE COPY OF D7 TO D6 TO MANIP
    AND.W   $C000,D6          ;CLEAR ALL BUT FIRST TWO BITS
    ROL.W   #2,D6           ;MOVE FIRST TWO BITS TO END
    
*----CHECK FIRST BITS FOR SUBROUTINES----
    CMP.B   #%00,D6         ;IF FIRST BITS 00
    BEQ     ZEROZERO
    
    CMP.B   #%01,D6         ;IF FIRST BITS 01
    BEQ     ZEROONE     
    
    CMP.B   #%10,D6         ;IF FIRST BITS 10
    BEQ     ONEZERO 
    
    CMP.B   #%11,D6         ;IF FIRST BITS 11
    BEQ     ONEONE
    

*--------------------------------------------
*MOVE & MOVEA
*D7 = ORIGINAL WORD OF MEMORY
ZEROZERO
    *Martin's MOVE and MOVEA code
    
*--------------------------------------------
*NOP, MOVEQ, MOVEM, ADDQ, LEA, NOT, BCC, JSR, & RTS
*D7 = ORIGINAL WORD OF MEMORY
ZEROONE
*---------NOP------------
    CMP.W   #$4E71,D7
    BEQ     PRINT_NOP       ;OUTPUT NOP
    
*--------RTS------------
    CMP.W   #$4E75,D7
    BEQ     PRINT_RTS       ;OUTPUT RTS
    
*-----SETUP BITS 13-12-----
    MOVE.W  D7,D6           ;COPY ORIGINAL TO D6
    AND.W   #$3000,D6       ;CLEAR ALL BUT BITS 13-12
    ROL.W   #4,D6
    
*CHECK FOR SECONDARY SUBROUTINES OR PROCESS SUB
    CMP.B   #%00,D6
    BEQ     ZEROONE_SECONDARY_BRANCH    ;FOR MOVEM, LEA, NOT, JSR
    
    CMP.B   #%01,D6
    BEQ     PROCESS_ADDQ    ;ADDQ
    
    CMP.B   #%10,D6
    BEQ     PROCESS_BCC     ;BCC & BRA
    
    CMP.B   #%11,D6
    BEQ     PROCESS_MOVEQ   ;MOVEQ

*--------------------------------------------
*SECONDARY BRANCH SUBROUTINE FOR ZEROONE
*MOVEM, LEA, NOT, & JSR
*D7 = ORIGINAL WORD OF MEMORY
ZEROONE_SECONDARY_BRANCH
*---CHECK FOR JSR----
    MOVE.W  D7,D6
    AND.W   #$FC0,D6    ;CLEAR ALL BUT BITS 11-6
    LSR.W   #6,D6       ;MOVE BITS 11-6 TO 5-0
    CMP.B   #$3A,D6
    BEQ     PROCESS_JSR ;JSR
    
*---CHECK FOR NOT-----
    MOVE.W  D7,D6
    AND.W   #$F00,D6    ;CLEAR ALL BUT BITS 11-8
    LSR.W   #8,D6       ;MOVE BITS 11-8 TO 3-0
    CMP.B   #$6,D6
    BEQ     PROCESS_NOT ;NOT
    
*---CHECK FOR LEA----
    MOVE.W  D7,D6
    AND.W   #$1C0,D6    ;CLEAR ALL BUT BITS 8-6
    LSR.W   #6,D6       ;MOVE BITS 8-6 TO 2-0
    CMP.B   #$7,D6
    BEQ     PROCESS_LEA ;LEA
    
*---CHECK FOR MOVEM---
    MOVE.W  D7,D6
    AND.W   #$380,D6    ;CLEAR ALL BUT BITS 9-7
    LSR.W   #7,D6       ;MOVE BITS 9-7 TO 2-0
    CMP.B   #$1,D6
    BEQ     PROCESS_MOVEM   ;MOVEM
    
*--------------------------------------------
*SUB, & OR
*D7 = ORIGINAL WORD OF MEMORY
ONEZERO
*---SETUP----------
    MOVE.W  D7,D6
    AND.W   #$3000,D6
    ROL.W   #4,D6
    
*---CHECK FOR OR---
    CMP.B   #0,D6
    BEQ     PROCESS_OR
    
*---CHECK FOR SUB--
    CMP.B   #1,D6
    BEQ     PROCESS_SUB
    
*--------------------------------------------
*ADD, ADDA, AND, LSL/LSR, ASL/ASR, & ROL/ROR
*D7 = ORIGINAL WORD OF MEMORY
ONEONE
*---SETUP----------
    MOVE.W  D7,D6
    AND.W   #$3000,D6
    ROL.W   #4,D6
    
*CHECK FOR ADD & ADDA--
    CMP.B   #$1,D6
    BEQ     ADD_BRANCH_SUBTROUTINE  ;ADD & ADDA
    
*---CHECK FOR AND-----
    CMP.B   #$0,D6
    BEQ     PROCESS_AND             ;AND
    
*CHECK FOR LSd, ASd, & ROd
    CMP.B   #$2,D6
    BEQ     ONEONE_SHIFT_SUBROUTINE ;MARTIN'S WORKING ON THIS
    
*--------------------------------------------
*BRANCH SUBROUTINE 
*CHECKING ADD VS ADDA
*D7 = ORIGINAL WORD OF MEMORY 
ADD_BRANCH_SUBROUTINE
*---SETUP----------
    MOVE.W  D7,D6
    AND.W   #$1C0,D6
    LSR.W   #6,D6
    
*----CHECK FOR ADDA---
    CMP.B   #$1,D6
    BEQ     PROCESS_ADDA    ;ADDA
    
*----ALL OTHER ADD---
    BRA     PROCESS_ADD     ;ADD


    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
