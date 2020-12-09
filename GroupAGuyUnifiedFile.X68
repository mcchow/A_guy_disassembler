*-----------------------------------------------------------
* Title      :Group A Guy Deconstructor
* Written by :Daniel Lorentz, Martin Chow, Dale Berg
* Date       :12/5/20
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
*----------------------Dale Code--------------------------------

                lea       starting_prompt,a1
                move.b    #14,d0
                trap      #15
                lea       new_line,a1
                move.b    #14,d0
                trap      #15
                lea       new_line,a1      * instruct users that upper case syntax will be necessary ** write this ***
                move.b    #14,d0
                trap      #15

                addi.b    #$2,d3          * add two to io counter

main_process
                lea       start_address_msg,a1  * load start address prompt

                cmpi.b    #$2,d3
                beq       input_to_hex

                cmpi.b    #$1,d3               * check if we are at first stage of io
                beq       put_start_in_memory   * if we are, then process user input for start address

                cmpi.b    #$0,d3                * otherwise, process user input for end address
                beq       put_end_in_memory


input_to_hex
                cmpi.b    #$0,d3
                jsr       load_end_addr * load end address message


                move.b    #14,d0
                trap      #15
                movea.w   init_addr,a1 * store at 6000, an arbitrary memory address ()can this go below?


                sub.b     #$1,d3 * remove one from io counter (can this go below)

                move.w    #2,d0 * trap 2 to read inout from keyboard
                trap      #15

                move.b    #0,d0 * display the input
                trap      #15

                clr.l     d6     * clear out D6 for input
                move.w    d1,d6  * make copy of the size to decrement loop in memory (might not need this)
                movea.l   a1,a2  * copy the value at A1 to A2

                cmpi.l    #$8,d1 * ensure user input is an 8 byte address
                bne       invalid * if it isn't then show invalid message and repeat process

                jmp       ensure_valid * check if user input is allowed

invalid
                add.b     #$1,d3          * increment io loop to go back a step
                lea       not_valid,a1    * load invalid address
                move.b    #14,d0          *
                trap      #15             *
                jmp       main_process    * branch back to main process to try again



ensure_valid
                cmpi.w    #$0,d6          * all elements of input have been processed (can this be plain old cmp?)
                beq       main_process    * if so, branch back to main

                clr.l     d2              * clear out D2
                move.b    (a1),d2         * move byte A1 points to to D2

                cmp.b     smallest_letter,d2  * check if within bounds of smallest allowed letter
                bgt       verify_letter   * if so, branch to letter processing
                cmp.b     min_size,d2     * check if input is too small to be valid
                blt       invalid         * if so, it is invalid

                jmp       number          * otherwise it's a number

verify_letter
                cmp.b     #$66,d2
                bgt       invalid

                cmp.b     #$60,d2
                bgt       verified_letter_lowercase   

                cmp.b     max_letter_size_uppercase,d2        * Only allow capitols, it's a letter (move this to a const)
                blt       verified_letter_uppercase         * It's within bounds of upper case letter

                cmp.b     max_letter_size_uppercase,d2         * (move this to a const)
                bgt       invalid         * too big to be valid

verified_letter_uppercase
                sub.b    #$37,(a1)+      * transform from ascii to hex
                sub.b    #$1,d6          * decrement one from size (do we need D^ for this?)
                jmp      ensure_valid         * branch back to bounds

verified_letter_lowercase
                subi.b   #$57,(a1)+      * transform from ascii to hex
                sub.b    #$1,d6          * decrement one from size (do we need D^ for this?)
                jmp      ensure_valid         * branch back to bounds

number
                cmp.b    max_number_value,d2         
                bgt      invalid         
                sub.b    #$30,(a1)+     
                sub.b    #$1,d6          
                jmp      ensure_valid          

                
put_start_in_memory
               jsr       setup_storage
               move.l    (a3),input_start * move content of A3 to input start variable
               jmp       input_to_hex       * branch back to conversion loop

put_end_in_memory
               jsr      setup_storage
               move.l   (a3),input_end  * move end address to input_end variable
               sub.b    #$1,d3          *
               *JMP      OPSETUP * this is where we should jump to next stage

process_input
                clr.l     d7              
                move.b    #$4,d7          

process_input_loop
                cmp.b    #$0,d7 
                beq      return_from_process
                move.b   (a2)+,d4         
                lsl.l    #4,d4            
                add.b    (a2)+,d4         
                move.b   d4,(a4)+         
                sub.l    #$1,d7          
                jmp      process_input_loop

return_from_process
                rts  * This is the only way to leave the process loop

setup_storage
                movea.l   a2,a4           *
                movea.l   a2,a3           *
                jsr       process_input
                move.l    (a3),d5         *
                rts

load_end_addr
            lea       end_address_msg,a1 * load the leaving message
            rts
*----------------------Daniel Code--------------------------------
OPSETUP
    MOVEA.L input_start,A5
    MOVEA.L input_end,A6
    
    JMP     PRIMELOOP
    
PRIMELOOP
*----CHECK IF AT END OF MEMORY TO DECODE----
    CMPA.L  A6,A5
    BGT     ENDPROGRAM      ;WILL WRITE LATER
    
    MOVE.W  (A5)+,D7        ;MOVE NEXT WORD TO D7
    
    MOVE.W  D7,D6           ;MOVE COPY OF D7 TO D6 TO MANIP
    AND.W   #$C000,D6          ;CLEAR ALL BUT FIRST TWO BITS
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
*----SETUP----
    MOVE.W  D7,D6
    AND.W   #$01C0,D6       ;CLEAR ALL BUT BITS 8-6
    LSL.W   #6,D6           ;MOVE BITS 8-6 TO 2-0
    
*----MOVEA----
    CMP.B   #01,D6
    BEQ     PROCESS_MOVEA
    
*----MOVE----
    BRA     PROCESS_MOVE    ;ALL OTHERS ARE MOVE

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
    ROL.W   #4,D6           ;MOVE BITS 13-12 TO 1-0
    
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
    AND.W   #$0FC0,D6    ;CLEAR ALL BUT BITS 11-6
    LSR.W   #6,D6       ;MOVE BITS 11-6 TO 5-0
    CMP.B   #$3A,D6
    BEQ     PROCESS_JSR ;JSR
    
*---CHECK FOR NOT-----
    MOVE.W  D7,D6
    AND.W   #$0F00,D6    ;CLEAR ALL BUT BITS 11-8
    LSR.W   #8,D6       ;MOVE BITS 11-8 TO 3-0
    CMP.B   #$6,D6
    BEQ     PROCESS_NOT ;NOT
    
*---CHECK FOR LEA----
    MOVE.W  D7,D6
    AND.W   #$01C0,D6    ;CLEAR ALL BUT BITS 8-6
    LSR.W   #6,D6       ;MOVE BITS 8-6 TO 2-0
    CMP.B   #$7,D6
    BEQ     PROCESS_LEA ;LEA
    
*---CHECK FOR MOVEM---
    MOVE.W  D7,D6
    AND.W   #$0380,D6    ;CLEAR ALL BUT BITS 9-7
    LSR.W   #7,D6       ;MOVE BITS 9-7 TO 2-0
    CMP.B   #$1,D6
    BEQ     MOVEMfunc   ;MOVEM
    
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
    BEQ     ADD_BRANCH_SUBROUTINE  ;ADD & ADDA
    
*---CHECK FOR AND-----
    CMP.B   #$0,D6
    BEQ     PROCESS_AND             ;AND
    
*CHECK FOR LSd, ASd, & ROd
    CMP.B   #$2,D6
    BEQ     startLS ;MARTIN'S WORKING ON THIS

*++++++++++++++++++++++++++++++++++NOP & RTS+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR NOP
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_NOP
*----I/O NOP----
    LEA     MESSAGE_NOP,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JMP     PRIMELOOP 
    
*--------------------------------------------
*PROCESS OUTPUT FOR NOP
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_RTS
*----I/O RTS----
    LEA     MESSAGE_RTS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JMP     PRIMELOOP 
    
*++++++++++++++++++++++++++++++++++MOVE, MOVEA, MOVEQ, MOVEM+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR MOVEA
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_MOVEA
*----I/O MOVEA----
    LEA     MESSAGE_MOVEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----COMPARE SIZE----
    MOVE.W  D7,D6
    AND.W   #$3000,D6
    ROL.W   #4,D6
    
    CMP.B   #3,D6
    BEQ     PRINT_MOVE_WORD
    
    CMP.B   #2,D6
    BEQ     PRINT_MOVE_LONG
    
*--------------------------------------------
*PROCESS OUTPUT FOR MOVE
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_MOVE
*----I/O MOVE----
    LEA     MESSAGE_MOVE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----COMPARE SIZE----
    MOVE.W  D7,D6
    AND.W   #$3000,D6
    ROL.W   #4,D6
    
    CMP.B   #1,D6
    BEQ     PRINT_MOVE_BYTE
    
    CMP.B   #3,D6
    BEQ     PRINT_MOVE_WORD
    
    CMP.B   #2,D6
    BEQ     PRINT_MOVE_LONG
    
*--------------------------------------------
*PROCESS OUTPUT FOR MOVEQ
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_MOVEQ
    *JMP     CHECK_AND_OR_MOVEQ_EA       ;CHECK IF EA IS VALID
*----I/O MOVEQ----
    LEA     MESSAGE_MOVEQ,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----I/O LONG----   ;ONLY CAN BE LONG
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----I/O HEX---
    LEA     MESSAGE_HEX,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----I/O DATA(HEX FORMAT)----
    MOVE.W  D7,D6
    AND.W   #$00FF,D6
    MOVE.B  D6,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2      ;PRINT AS HEX
    TRAP    #15
    
*----COMMA----
    LEA     MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----I/O REGISTER---- 
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER I/O----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #7,D6
    MOVE.B  D6,D1
    MOVE.B  #10,D2
    MOVE.B  #15,D0
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP 
    

*--------------------------------------------
*PROCESS OUTPUT FOR MOVE & MOVEA BYTE
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_MOVE_BYTE
*----I/O----
    LEA     MESSAGE_BYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_MOVE_EA
    
*--------------------------------------------
*PROCESS OUTPUT FOR MOVE & MOVEA WORD
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_MOVE_WORD
*----I/O----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_MOVE_EA
    
*--------------------------------------------
*PROCESS OUTPUT FOR MOVE & MOVEA LONG
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_MOVE_LONG
*----I/O----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_MOVE_EA
    
*--------------------------------------------
*PROCESS OUTPUT FOR MOVE & MOVEA EA
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_MOVE_EA
*----PRINT SOURCE EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6
    
*----COMMA----
    LEA     MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----PRINT DESTINATION EA----
    MOVE.W  D7,D6
    AND.W   #$0FC0,D6  
    LSR.W   #6,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP 
    

*++++++++++++++++++++++++++++++++++LEA+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR LEA
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_LEA
    JMP     CHECK_LEA_JSR_EA
    
*----I/O LEA----
    LEA     MESSAGE_LEA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JMP     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6

*----COMMA----
    LEA     MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----An----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    
    LEA     MESSAGE_ADDRESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  D6,D1
    MOVE.B  #3,D0
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP

*--------------------------------------------
*CHECK IF LEA & JSR ea IS VALID
*D7 = ORIGINAL WORD OF MEMORY
CHECK_LEA_JSR_EA
*----CHECK INVALID EA----
    MOVE.W  D7,D6
    AND.W   #$0038,D6
    LSR.B   #$3,D6
    
    CMP.B   #$2,D6          ;IF Dn OR An
    BLT     PRINT_DATA
    
    CMP.B   #$3,D6          ;IF (An)+
    BEQ     PRINT_DATA
    
    CMP.B   #$4,D6          ;IF -(An)
    BEQ     PRINT_DATA
    
    CMP.B   #$7,D6          ;IF EA MODE == #7
    BEQ     CHECK_LEA_EA  
*--------------------------------------------
*CHECK IF LEA ea IS VALID WHEN MODE == %111
*D7 = ORIGINAL WORD OF MEMORY 
CHECK_LEA_EA
    MOVE.W  D7,D6
    AND.W   #$0007,D6
    
    CMP.B   #$4,D6
    BEQ     PRINT_DATA
    
    RTS
*++++++++++++++++++++++++++++++++++JSR+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR JSR
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_JSR
    JMP     CHECK_LEA_JSR_EA        ;CHECK THAT EA IS VALID
*----I/O JSR----
    LEA     MESSAGE_JSR,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JMP     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6

*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
   
*++++++++++++++++++++++++++++++++++NOT+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR NOT
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_NOT
*----CHECK THAT ea IS VALID ----
    MOVE.W  D7,D6
    AND.W   #$0038,D6
    LSR.B   #$3,D6
    
    CMP.B   #$1,D6
    BEQ     PRINT_DATA
    
    CMP.B   #$7,D6
    BEQ     CHECK_NOT_EA
    
*----I/O NOT----
    LEA     MESSAGE_NOT,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP FOR COMPARE----
    MOVE.W  D7,D6
    AND.W   #$00C0,D6
    LSR.B   #6,D6
    
*----CHECK FOR BYTE----
    CMP.B   #$0,D6
    BEQ     PRINT_NOT_BYTE

*----CHECK FOR WORD----
    CMP.B   #$1,D6
    BEQ     PRINT_NOT_WORD

*----CHECK FOR LONG----
    CMP.B   #$2,D6
    BEQ     PRINT_NOT_LONG
    
*--------------------------------------------
*CHECK REGISTER IS VALID WHEN EA MODE == %111
*D7 = ORIGINAL WORD OF MEMORY 
CHECK_NOT_EA
    MOVE.W  D7,D6
    AND.W   #$0007,D6
    
    CMP.B   #$1,D6
    BEQ     PRINT_DATA
    
    CMP.B   #$2,D6
    BGE     CHECK_ADD_ERROR_EA_REGISTER
    
    RTS
    
*--------------------------------------------
*PROCESS OUTPUT FOR NOT BYTE & EA
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_NOT_BYTE
*----I/O BYTE----
    LEA     MESSAGE_BYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JMP     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6

*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP

*--------------------------------------------
*PROCESS OUTPUT FOR NOT WORD & EA
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_NOT_WORD
*----I/O WORD----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JMP     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP

*--------------------------------------------
*PROCESS OUTPUT FOR NOT LONG & EA
*D7 = ORIGINAL WORD OF MEMORY 
PRINT_NOT_LONG
*----I/O BYTE----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----SETUP EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JMP     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7/A5/A6
    
    *----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP 
    
*++++++++++++++++++++++++++++++++++AND+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR AND
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_AND
    JMP     CHECK_AND_OR_MOVEQ_EA     ;FUNCTION CHECKS IF EA IS VALID
    
*----I/O AND----
    LEA     MESSAGE_AND,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_OPMODE
    
*--------------------------------------------
*CHECK AND, OR, & MOVEQ ea TO ENSURE IT IS VALID
*D7 = ORIGINAL WORD OF MEMORY
CHECK_AND_OR_MOVEQ_EA
*----CHECK ea VALID----
    MOVE.W  D7,D6
    AND.W   #$0038,D6
    LSR.W   #$3,D6
    
    CMP.B   #$1,D6          ;IF EA MODE == An
    BEQ     PRINT_DATA
    RTS
    
*++++++++++++++++++++++++++++++++++OR+++++++++++++++++++
*--------------------------------------------
*PROCESS OUTPUT FOR OR
*D7 = ORIGINAL WORD OF MEMORY 
PROCESS_OR
    JMP     CHECK_AND_OR_MOVEQ_EA     ;FUNCITON CHECKS IF EA IS VALID
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
    AND.W   #$01C0,D6
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
    AND.W   #$01C0,D6
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
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W (SP)+,D7,A5,A6
    LEA     MESSAGE_ADDRESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.W  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
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
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W (SP)+,D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.W  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PROCESS PRINT FOR ADD
*D7=ORIGINAL
PROCESS_ADD
    JMP     CHECK_ADD_ERROR
    
PROCESS_ADD_CLEAR
*----I/O ADD----
    LEA     MESSAGE_ADD,A1
    MOVE.B  #14,D0
    TRAP    #15
    

    
    BRA     PRINT_OPMODE

*--------------------------------------------
*CHECK IF EA IS CORRECT FOR ADD
*D7=ORIGINAL
CHECK_ADD_ERROR
    MOVE.W  D7,D6
    AND.W   #$01C0,D6
    LSR.W   #6,D6

*----CHECK IF OPMODE = 4, 5, OR 6----
    CMP.B   #$4,D6
    BGE     CHECK_ADD_EA    
    
    RTS                         ;RETURN TO PROCESS_ADD
    
*--------------------------------------------
*IF OPMODE SHOWS ADD, LSs Dn,<ea>, CHECK DESTINATION IS VALID 
*D7=ORIGINAL
CHECK_ADD_EA
    MOVE.W  D7,D6
    AND.W   #$0038,D6
    LSR.W   #$3,D6

*----CHECK FOR Dn & An----
    CMP.B   #$1,D6
    BLE     PRINT_DATA
    
*----CHECK FOR MODE 111----
    CMP.B   #$7,D6
    BEQ     CHECK_ADD_ERROR_EA_REGISTER
    
    RTS    

*--------------------------------------------
*CHECK IF ea OPMODE OF 111 IS VALID
*D7=ORIGINAL
CHECK_ADD_ERROR_EA_REGISTER
    MOVE.W  D7,D6
    AND.W   #$0007,D6
    
    CMP.B   #$1,D6
    BGT     PRINT_DATA
    
    RTS
*--------------------------------------------
*PROCESS PRINT FOR ADDQ 
*D7=ORIGINAL
PROCESS_ADDQ
*----CHECK FOR OPMODE ERROR----
    MOVE.W  D7,D6
    AND.W   #$0038,D6
    LSR.B   #$3,D6
    
    CMP.B   #$7,D6
    BEQ     CHECK_ADD_ERROR_EA_REGISTER

*----I/O ADDQ----
    LEA     MESSAGE_ADDQ,A1
    MOVE.B  #14,D0
    TRAP    #15
    

*----COMPARE FOR SIZE----
    MOVE.W  D7,D6
    AND.W   #$00C0,D6
    LSR.W   #6,D6
    
    CMP.B   #$0,D6
    BEQ     PRINT_ADDQ_BYTE
    
    CMP.B   #$1,D6
    BEQ     PRINT_ADDQ_WORD
    
    CMP.B   #$2,D6
    BEQ     PRINT_ADDQ_LONG
    
*--------------------------------------------
*PROCESS PRINT FOR ADDQ 
*D7=ORIGINAL
PRINT_ADDQ_BYTE
*----I/O BYTE----
    LEA     MESSAGE_BYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_ADDQ_DATA
    
*--------------------------------------------
*PROCESS PRINT FOR ADDQ 
*D7=ORIGINAL
PRINT_ADDQ_WORD
*----I/O BYTE----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_ADDQ_DATA
    
*--------------------------------------------
*PROCESS PRINT FOR ADDQ 
*D7=ORIGINAL
PRINT_ADDQ_LONG
*----I/O BYTE----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_ADDQ_DATA
    
*--------------------------------------------
*PROCESS DATA PRINT FOR ADDQ 
*D7=ORIGINAL
PRINT_ADDQ_DATA    
*----I/O DATA----
    LEA     MESSAGE_HEX,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    
*----register----
    MOVEM.W (SP)+,D7,A5,A6
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  D6,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    
*----COMMA----
    LEA     MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
   
*----EA----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA

    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRIMELOOP
    
*++++++++++++++++++++++++++++++++++OUTPUT REGISTER, OPMODE, & EA+++++++++++++++++++
*OUTPUT PRINT FOR ADD, ADDA, SUB, AND, OR
*=D7 = ORIGINAL WORD
PRINT_OPMODE
*----SETUP FOR SIZE COMPARE----
    MOVE.W  D7,D6
    AND.W   #$01C0,D6
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
    
    BRA     PRINT_EA_Dn
    

  
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.W <EA>,Dn
*D7=ORIGINAL
PROCESS_OPMODE_WORDa
*----SIZE OUTPUT----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_EA_Dn

*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.L <EA>,Dn
*D7=ORIGINAL
PROCESS_OPMODE_LONGa
*----SIZE OUTPUT----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_EA_Dn
    
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.B <EA>,Dn
*D7=ORIGINAL
PRINT_EA_Dn
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY OUTPUT----
    MOVEM.W (SP)+,D7,A5,A6
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.W  D6,D1
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
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
    
    BRA     PRINT_Dn_EA
   
*--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.W Dn,<EA>
*D7=ORIGINAL
PROCESS_OPMODE_WORDb
*----SIZE OUTPUT----
    LEA     MESSAGE_WORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA PRINT_Dn_EA
 
 *--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.L Dn,<EA>
*D7=ORIGINAL
PROCESS_OPMODE_LONGb
*----SIZE OUTPUT----
    LEA     MESSAGE_LONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     PRINT_Dn_EA
    
 *--------------------------------------------
*PROCESS & OUTPUT FOR ADD, AND, OR, SUB FORMAT 'ADD.L Dn,<EA>
*D7=ORIGINAL
PRINT_Dn_EA
*----DIRECTORY OUTPUT----
    
    LEA     MESSAGE_DIRECTORY,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----DIRECTORY NUMBER----
    MOVE.W  D7,D6
    AND.W   #$0E00,D6
    ROL.W   #$7,D6
    MOVE.B  #3,D0
    MOVE.W  D6,D1
    TRAP    #15
   
*----PRINT COMMA----
    LEA MESSAGE_COMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
 
*----EA OUTPUT----
    MOVE.W  D7,D6
    AND.W   #$003F,D6
    MOVEM.W D7/A5/A6,-(SP)
    JSR     DeAddr              ;PRINT EA
    
    MOVEM.W (SP)+,D7,A5,A6
*----NEW LINE----
    LEA     new_line,A1
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
    LEA     MESSAGE_BRA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BHI THEN MOVE TO DISPLACEMENT_BCC
*D7=ORIGINAL 
PRINT_BHI
    LEA     MESSAGE_BHI,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLS
    LEA     MESSAGE_BLS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
    
*--------------------------------------------
*PRINT BCC THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BCC
   LEA     MESSAGE_BCC,A1
   MOVE.B  #14,D0
   TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BCS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BCS
    LEA     MESSAGE_BCS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BNE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BNE
    LEA     MESSAGE_BNE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BEQ THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BEQ
    LEA     MESSAGE_BEQ,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BVC THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BVC
    LEA     MESSAGE_BVC,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BVS THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BVS
    LEA     MESSAGE_BVS,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BPL THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BPL
    LEA     MESSAGE_BPL,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BMI THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BMI
    LEA     MESSAGE_BMI,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BGE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BGE
    LEA     MESSAGE_BGE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLT THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLT
    LEA     MESSAGE_BLT,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BGT THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BGT
    LEA     MESSAGE_BGT,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA DISPLACEMENT_BCC
    
*--------------------------------------------
*PRINT BLE THEN MOVE TO DISPLACEMENT_BCC 
*D7=ORIGINAL
PRINT_BLE
    LEA     MESSAGE_BLE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
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
    CMP.B   #$FF,D6
    BEQ     PRINT_32BIT
    
*----ALL OTHERS----
    BRA     PRINT_8BIT
    
*--------------------------------------------
*PRINT 16 BIT DISPLACEMENT
*D7=ORIGINAL  
PRINT_16BIT
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PRINT 32 BIT DISPLACEMENT
*D7=ORIGINAL
PRINT_32BIT
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
*--------------------------------------------
*PRINT 8 BIT DISPLACEMENT
*D7=ORIGINAL
PRINT_8BIT
    MOVE.B  D7,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
  
*--------------------------------------------
*PRINT WORD OF DATA THAT DOES NOT MATCH DECODING OPTIONS
*D7=ORIGINAL  
PRINT_DATA
*----I/O DATA----
    LEA     MESSAGE_DATA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
*----PRINT DATA AS HEX----
    MOVE.B  #15,D0
    MOVE.W  D7,D1
    MOVE.B  #16,D2
    TRAP    #15
    
*----NEW LINE----
    LEA     new_line,A1
    MOVE.B  #14,D0
    TRAP    #15  
    
    BRA     PRIMELOOP
    
    
ENDPROGRAM
    


*----------------------Martin Code--------------------------------
*----------------------MOVEM--------------------------------

*Start of the move M function
MOVEMfunc    JSR printMOVEM
*print size
    MOVE D7,D6
    AND #64,D6
    LSR #6,D6
    CMP #0,D6
    BEQ PRINTSIZEDW
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
        
PRINTSIZEDW  LEA     dotw,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS  
  
        
FirstD  
    MOVE.L  #$0,D1
    CMP #8,D1
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
    BEQ NDIN
    BRA NDRE
NDIN    AND #1,D5
    LSR #1,D6
    BRA ENDNDIN
NDRE    AND #32768,D5
    LSL #1,D6
    
ENDNDIN CMP #0,D5
    BEQ NEXTDADDONE
    JSR PRINTSLASHMM
    JSR PRINTDMM
    JSR PRINTDIGIMM
NEXTDADDONE    ADD #1,D1    
    BRA NEXTD

*======================================================================

*SET PRINT SLASH FLAG TO 1 AS THERE IS D#
FirstASTSL MOVE #1,D2
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
    
ENDFAIN   CMP #0,D5
    BEQ FirstAADDONE

    CMP #0,D2
    BEQ noslash
    JSR PRINTSLASHMM
noslash    JSR PRINTAMM
    JSR PRINTDIGIMM
    BRA NextAST
FirstAADDONE    ADD #1,D1
    BRA FirstA

NextAST ADD #1,D1
NextA   CMP #8,D1
    BEQ MESHEND
    MOVE D6,D5
* DETERMINE DIRECTION(READ OR WRITE TO M)
    CMP #0,D4
    BEQ NAIN
    BRA NARE
NAIN    AND #1,D5
    LSR #1,D6
    BRA ENDNAIN
NARE    AND #32768,D5
    LSL #1,D6
    
ENDNAIN    CMP #0,D5
    BEQ NEXTAADDONE
    JSR PRINTSLASHMM
    JSR PRINTAMM
    JSR PRINTDIGIMM
NEXTAADDONE    ADD #1,D1    
    BRA NEXTA

MESHEND MOVE D0,D0

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
        
*----------------------LSd,ASd,ROd--------------------------------
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
    RTS
*----------------------EA--------------------------------
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
    RTS
*----------------------Dale Variables--------------------------------
start_address_msg     dc.b      'Please enter an 8 byte hexadecimal start address: ',0
end_address_msg       dc.b      'Please enter an 8 byte hexadecimal end address: ',0
starting_prompt       dc.b      'Welcome to the program',CR,LF,0

min_size        dc.b      $30
smallest_letter dc.b      $40
max_letter_size_uppercase dc.b      $47
max_number_value dc.b     $39



new_line         dc.b      '',CR,LF,0
not_valid       dc.b      'This entry is not valid',CR,LF,0
init_addr       dc.w      $6000
input_start     ds.l      40
input_end       ds.l      40

CR              EQU     $0D
LF              EQU     $0A

*----------------------Daniel Variables--------------------------------
MESSAGE_ADD         DC.B    'ADD',0
MESSAGE_ADDA        DC.B    'ADDA',0
MESSAGE_AND         DC.B    'AND',0
MESSAGE_OR          DC.B    'OR',0
MESSAGE_SUB         DC.B    'SUB',0
MESSAGE_NOT         DC.B    'NOT',0
MESSAGE_JSR         DC.B    'JSR    ',0
MESSAGE_LEA         DC.B    'LEA    ',0
MESSAGE_ADDQ        DC.B    'ADDQ',0
MESSAGE_MOVE        DC.B    'MOVE',0
MESSAGE_MOVEQ       DC.B    'MOVEQ',0
MESSAGE_MOVEA       DC.B    'MOVEA',0
MESSAGE_MOVEM       DC.B    'MOVEM',0
MESSAGE_NOP         DC.B    'NOP',CR,LF,0
MESSAGE_RTS         DC.B    'RTS',CR,LF,0

MESSAGE_BRA       DC.B    'BRA',0
MESSAGE_BHI       DC.B    'BHI',0
MESSAGE_BLS       DC.B    'BLS',0
MESSAGE_BCC       DC.B    'BCC',0
MESSAGE_BCS       DC.B    'BCS',0
MESSAGE_BNE       DC.B    'BNE',0
MESSAGE_BEQ       DC.B    'BEQ',0
MESSAGE_BVC       DC.B    'BVC',0
MESSAGE_BVS       DC.B    'BVS',0
MESSAGE_BPL       DC.B    'BPL',0
MESSAGE_BMI       DC.B    'BMI',0
MESSAGE_BGE       DC.B    'BGE',0
MESSAGE_BLT       DC.B    'BLT',0
MESSAGE_BGT       DC.B    'BGT',0
MESSAGE_BLE       DC.B    'BLE',0

MESSAGE_HEX         DC.B    '#$',0
MESSAGE_BYTE        DC.B    '.B    ',0
MESSAGE_WORD        DC.B    '.W    ',0
MESSAGE_LONG        DC.B    '.L    ',0
MESSAGE_DIRECTORY   DC.B    'D',0
MESSAGE_ADDRESS     DC.B    'A',0
MESSAGE_COMMA       DC.B    ',',0
MESSAGE_DATA        DC.B    'DATA:     ',0

*----------------------Martin Variables--------------------------------
D DC.B    'D',0
A DC.B    'A',0
Bra DC.B   '(',0
NumSign DC.B '#',0
ABra DC.B   '(A',0
CloBra DC.B ')',0
PlusSign DC.B '+',0
NegSign DC.B '-',0
NEXTLINE DC.B CR,LF,0

LS DC.B    'LS',0
AS DC.B    'AS',0
RO DC.B    'RO',0
L DC.B    'L',0
R DC.B    'R',0
SizeB DC.B    '.B ',0
SizeW DC.B  '.W ',0
NUM DC.B '#',0
COMMA DC.B ' , ',0

SLASH DC.B '/',0

EA  DC.B    '<EA>',0
MOVEM   DC.B  'MOVEM',0
TAP DC.B    '   ',0

dotw    DC.B    '.W',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
