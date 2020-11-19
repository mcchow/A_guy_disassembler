

    ORG $1000

                lea       start_msg,a1  * Load welcome message
                move.b    #14,d0
                trap      #15
                lea       newline,a1
                move.b    #14,d0
                trap      #15
                lea       newline,a1      * instruct users that upper case syntax will be necessary ** write this ***
                move.b    #14,d0          
                trap      #15             

                addi.b    #$2,d5          * add two to io counter

main_process
                lea       get_address_msg,a1  * load start address prompt

                cmpi.b    #$1,d5               * check if we are at first stage of io
                beq       put_start_in_memory   * if we are, then process user input for start address
                
                cmpi.b    #$0,d5                * otherwise, process user input for end address
                beq       put_end_in_memory


input_to_hex        
                move.b    #14,d0
                trap      #15
                movea.w   init_addr,a1 * store at 6000, an arbitrary memory address ()can this go below?

                sub.b     #$1,d5 * remove one from io counter (can this go below)

                move.w    #2,d0 * trap 2 to read inout from keyboard
                trap      #15

                move.b    #0,d0 * display the input 
                trap      #15
                
                cmpi.l    #$8,d1 * ensure user input is an 8 byte address
                bne       invalid_input * if it isn't then show invalid message and repeat process

                clr.l     d6     * clear out D6 for input
                move.w    d1,d6  * make copy of the size to decrement loop in memory (might not need this)
                movea.l   a1,a2  * copy beginning of input at A1 to A2, A3, A4 for next steps
                movea.l   a1,a3  
                movea.l   a1,a4 

                bra       ensure_valid * check if user input is allowed

                bra       main_process * branch back to main process (can we remove this?) 

invalid_input
                add.b     #$1,d5          * increment io loop to go back a step
                lea       not_valid,a1    * load invalid address
                
                move.b    #14,d0          * 
                trap      #15             *
                bra       main_process    * branch back to main process to try again



ensure_valid
                cmpi.w    #$0,d6          * all elements of input have been processed (can this be plain old cmp?)
                beq       main_process    * if so, branch back to main

                clr.l     d2              *
                move.b    (a1),d2         * move byte A1 points to to D2
                cmp.b     smallest_letter,d2  * check if within bounds of smallest allowed letter
                bgt       validate_letter     * if so, branch to letter processing
                cmp.b     min_size,d2     * check if input is too small to be valid
                blt       invalid_input   * if so, it is invalid

                bra       process_number  * otherwise it's a number
                
* 30-39 means it's a number
process_number
                cmp.b    max_number,d2         * 
                bgt      invalid_input         * too big to be a number 
                sub.b    #$30,(a1)+      * Convert number to hex
                sub.b    #$1,d6          *
                bra      ensure_valid    *
                               

* 41-46  meaens it's a letter
validate_letter
                cmp.b     max_letter,d2  * Only allow capitols, it's a letter (move this to a const)
                blt       process_letter * It's within bounds of upper case letter

                cmp.b     max_letter,d2   * cehck if above max letter value
                bgt       invalid_input         * too big to be valid 


process_letter
                sub.b    #$37,(a1)+      * transform from ascii to hex
                sub.b    #$1,d6          * decrement one from size (do we need D^ for this?)
                bra      ensure_valid    * branch back to bounds



process_input
                clr.l     d7              * d7
                move.b    #$4,d7          * d7

process_input_loop
                cmp.b    #$0,d7 * d7
                beq      return_from_subroutine
                
                move.b   (a2)+,d4         *
                lsl.l    #4,d4            *
                add.b    (a2)+,d4         *
                move.b   d4,(a4)+         *
                sub.l    #$1,d7           * d7
                bra      process_input_loop

return_from_subroutine
                rts  * This is the only way to leave the


setup_storage
                jsr       process_input   * process input at A3
                move.l    (a3),d3         * move value at A3 to D3 and return 
                rts


put_start_in_memory
                jsr       setup_storage
                move.l    (a3),input_start * move content of A3 to input start variable
                bra       input_to_hex       * branch back to conversion loop

put_end_in_memory
                jsr       setup_storage  
                move.l   (a3),input_end  * move end address to input_end variable
                sub.b    #$1,d5          * remove one from io counter
                NOP * this is where we should jump to next stage
               


get_address_msg     dc.b      'Please enter an 8 byte hexadecimal start address: ',0
start_msg       dc.b      'Welcome to the program',CR,LF,0
min_size        dc.b      $30
smallest_letter dc.b      $40
max_letter      dc.b      $47
max_number      dc.b      $39
newline         dc.b      '',CR,LF,0
not_valid       dc.b      'This entry is not valid',CR,LF,0
init_addr       dc.w      $6000
input_start     ds.l      40
input_end       ds.l      40

CR              EQU     $0D
LF              EQU     $0A
