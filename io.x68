

    ORG $1000

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
