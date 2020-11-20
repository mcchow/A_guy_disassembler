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
    
*++++++++++++++++++++++++++++++++++AND+++++++++++++++++++
*--------------------------------------------
*BRANCH SUBROUTINE 
*CHECKING ADD VS ADDA
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_AND
*----I/O AND----
    LEA     MESSAGE_AND,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_OPMODE
    
*++++++++++++++++++++++++++++++++++OR+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR OR
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_OR
*----I/O OR----
    LEA     MESSAGE_OR,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_OPMODE
    
*++++++++++++++++++++++++++++++++++SUB+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR SUB
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_SUB
*----I/O SUB----
    LEA     MESSAGE_SUB,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_OPMODE
    
*++++++++++++++++++++++++++++++++++ADD,ADDA,ADDQ+++++++++++++++++++
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
    CMP.B   #$3,D6
    BEQ     PROCESS_ADDA    ;ADDA
    
    CMP.B   #$7,D6
    BEQ     PROCESS_ADDA
    
*----ALL OTHER ADD---
    BRA     PROCESS_ADD     ;ADD
 
*--------------------------------------------
*PROCESS PRINT FOR ADDA
*D7=ORIGINAL
PROCESS_ADDA   
*----I/O ADDA----
    LEA     MESSAGE_ADDA,A1
    MOVE.B  #14,D0
    TRAP #15
    
*----SETUP FOR SIZE COMPARE----
    MOVE.W  D7,D6
    LSR.W   #$6,D6
    
*----COMPARE FOR OPMODE----
    CMP.B   #$3,D6
    BEQ     PROCESS_ADDA_WORD
    
    CMP.B   #$7,D6
    BEQ     PROCESS_ADDA_LONG
    
*--------------------------------------------
*PROCESS ADDA FORMAT 'ADDA.W <EA>,An
*D7=ORIGINAL
PROCESS_ADDA_WORD
*----SIZE OUTPUT----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_ADDRESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PROCESS ADDA FORMAT 'ADDA.L <EA>,An
*D7=ORIGINAL
PROCESS_ADDA_LONG
*----SIZE OUTPUT----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PROCESS PRINT FOR ADD
*D7=ORIGINAL
PROCESS_ADD
*----I/O ADD----
    LEA     MESSAGE_ADD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_OPMODE
    
*++++++++++++++++++++++++++++++++++OUTPUT REGISTER, OPMODE, & EA+++++++++++++++++++
*OUTPUT PRINT FOR ADD, ADDA, SUB, AND, OR
*=D7 = ORIGINAL WORD
PRINT_OPMODE
*----SETUP FOR SIZE COMPARE----
    MOVE.W  D7,D6
    LSR.W   #$6,D6
    
*----COMPARE FOR OPMODE----
    CMP.B   #$0,D6
    BEQ     PROCESS_OPMODE_BYTEa
    
    CMP.B   #$1,D6
    BEQ     PROCESS_OPMODE_WORDa
    
    CMP.B   #$2,D6
    BEQ     PROCESS_OPMODE_LONGa
    
    CMP.B   #$4,D6
    BEQ     PROCESS_OPMODE_BYTEb
    
    CMP.B   #$5,D6
    BEQ     PROCESS_OPMODE_WORDb
    
    CMP.B   #$6,D6
    BEQ     PROCESS_OPMODE_LONGb
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.B <EA>,Dn
*D7=ORIGINAL
PROCESS_OPMODE_BYTEa
*----SIZE OUTPUT----
    LEA     MESSAGE_BYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRIMELOOP
  
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.W <EA>,Dn
*D7=ORIGINAL
PROCESS_OPMODE_WORDa
*----SIZE OUTPUT----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP

*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.L <EA>,Dn
*D7=ORIGINAL
PROCESS_OPMODE_LONGa
*----SIZE OUTPUT----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
 
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
   
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.B Dn,<EA>
*D7=ORIGINAL
PROCESS_OPMODE_BYTEb
*----SIZE OUTPUT----
    LEA     MESSAGE_BYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
   
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
 
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRIMELOOP
   
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.W Dn,<EA>
*D7=ORIGINAL
PROCESS_OPMODE_WORDb
*----SIZE OUTPUT----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
   
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
 
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15

    BRA     PRIMELOOP
 
 *--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.L Dn,<EA>
*D7=ORIGINAL
PROCESS_OPMODE_LONGb
*----SIZE OUTPUT----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W +(SP),D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.B  D6,D1
    TRAP    #15
   
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
 
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$001F,D6
    MOVEM.W D7/A5/A6,-(SP)
    BRA     DeAddr              ;PRINT EA
    
*----NEW LINE----
    LEA     newline,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRIMELOOP

*++++++++++++++++++++++++++++++++++Bcc+++++++++++++++++++
*--------------------------------------------
*PROCESS BCC'S SUBROUTINE FOR CONDITION
*D7=ORIGINAL   
PROCESS_BCC
*-----CONDITION----
    MOVE.W  D7,D6       ;SETUP
    AND.W   #$0F00,D6   ;CLEAR ALL BUT BITS 11-8
    LSR.W   #8,D6       ;MOVE BITS 11-8 TO 3-0
    
*----CHECK RA----
    CMP.B   #$0,D6
    BEQ     PRINT_BRA
*----CHECK HI----
    CMP.B   #$2,D6
    BEQ     PRINT_BHI
    
*----CHECK LS----
    CMP.B   #$3,D6
    BEQ     PRINT_BLS
*----CHECK CC----
    CMP.B   #$4,D6
    BEQ     PRINT_BCC
    
*----CHECK CS----
    CMP.B   #$5,D6
    BEQ     PRINT_BCS
    
*----CHECK NE----
    CMP.B   #$6,D6
    BEQ     PRINT_BNE
    
*----CHECK EQ----
    CMP.B   #$7,D6
    BEQ     PRINT_BEQ
    
*----CHECK VC----
    CMP.B   #$8,D6
    BEQ     PRINT_BVC
    
*----CHECK VS----
    CMP.B   #$9,D6
    BEQ     PRINT_BVS
    
*----CHECK PL----
    CMP.B   #$A,D6
    BEQ     PRINT_BPL
    
*----CHECK MI----
    CMP.B   #$B,D6
    BEQ     PRINT_BMI
    
*----CHECK GE----
    CMP.B   #$C,D6
    BEQ     PRINT_BGE
    
*----CHECK LT----
    CMP.B   #$D,D6
    BEQ     PRINT_BLT
    
*----CHECK GT----
    CMP.B   #$E,D6
    BEQ     PRINT_BGT
    
*----CHECK LE----
    CMP.B   #$F,D6
    BEQ     PRINT_BLE
    
    
*--------------------------------------------
*PRINT BRA THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BRA
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BHI THEN MOVE TO DISPLACEMENT_BCC
*D7=ORIGINAL 
PRINT_BHI
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLS
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
    
*--------------------------------------------
*PRINT BCC THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BCC
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BCS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BCS
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BNE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BNE
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BEQ THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BEQ
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BVC THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BVC
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BVS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BVS
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BPL THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BPL
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BMI THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BMI
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BGE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BGE
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLT THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLT
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BGT THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BGT
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLE
    *I/O CODE
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PROCESS SIZE OF DISPLACEMENT THEN MOVE TO PRINT FUNCTIONS
*D7=ORIGINAL
DISPLACEMENT_BCC
*----SETUP----
    MOVE.W  D7,D6
    AND.W   #$00FF,D6
    
*----CHECK FOR 16----
    CMP.B   #$00,D6
    BEQ     PRINT_16BIT
    
*----CHECK FOR 32----
    CMP.B   #FF,D6
    BEQ     PRINT_32BIT
    
*----ALL OTHERS----
    BRA     PRINT_8BIT
    
*--------------------------------------------
*PRINT 16 BIT DISPLACEMENT
*D7=ORIGINAL  
PRINT_16BIT
    *I/O CODE
    *DISPLACEMENT = NEXT WORD FROM A5
    BRA     PRIMELOOP
    
*--------------------------------------------
*PRINT 32 BIT DISPLACEMENT
*D7=ORIGINAL
PRINT_32BIT
    *I/O CODE
    *DISPLACEMENT = NEXT LONG FROM A5
    BRA     PRIMELOOP
    
*--------------------------------------------
*PRINT 8 BIT DISPLACEMENT
*D7=ORIGINAL
PRINT_8BIT
    *I/O CODE
    *DISPLACEMENT IN D6 OR LAST 8 BITS OF D7
    BRA     PRIMELOOP
    
    

    SIMHALT             ; halt simulator

CR                  EQU     $0D
LF                  EQU     $0A

MESSAGE_ADD         DC.B    'ADD',0
MESSAGE_ADDA        DC.B    'ADDA',0
MESSAGE_AND         DC.B    'AND',0
MESSAGE_OR          DC.B    'OR',0
MESSAGE_SUB         DC.B    'SUB',0

MESSAGE_BYTE        DC.B    '.B    ',0
MESSAGE_WORD        DC.B    '.W    ',0
MESSGAE_LONG        DC.B    '.L    ',0
MESSAGE_DIRECTORY   DC.B    'D'
MESSAGE_COMMA       DC.B    ',',0

SP                  EQU     $8000

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
