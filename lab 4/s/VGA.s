.text
.equ pixel_base, 0xC8000000
.equ char_base, 0xC9000000
.global VGA_clear_charbuff_ASM
.global VGA_clear_pixelbuff_ASM

.global VGA_write_char_ASM    //(int x, int y, char c);
.global VGA_write_byte_ASM    //(int x, int y, char byte);

.global VGA_draw_point_ASM    //(int x, int y, short colour);



VGA_clear_charbuff_ASM:
     PUSH {R1-R8,LR}
     LDR  R1, =char_base
     MOV R2, #32     //space character 
     MOV R3, #0     //x counter
     MOV R4, #0     //y counter
clear_char_loop:
     CMP R4, #60    //check if we have finished 
     BEQ clear_char_done 
     CMP R3, #80    //check if at the end of a row
     MOVEQ R3, #0
     ADDEQ R4, R4, #1
     BEQ clear_char_loop
     MOV R6, R4     //copy y number 
     LSL R6, #7     //left shift y by 7 bits
     ORR R6, R6, R3 //get the increasing address 
     ORR R6, R6, R1 //add to base address to get current address

     STRB R2, [R6]

     ADD R3,R3,#1   //increment counter
     B clear_char_loop

clear_char_done:
     POP {R1-R8,LR}
     BX LR




VGA_clear_pixelbuff_ASM:
     PUSH {R1-R8,LR}
     LDR R1, =pixel_base
     MOV R2, #0
     MOV R3, #0     //x counter
     MOV R4, #0     //y counter
clear_pixelbuff_loop:
     
     CMP R3, #320    //check if at the end of a row
     MOVEQ R3, #0
     ADDEQ R4, R4, #1
     BEQ clear_pixelbuff_loop

     CMP R4, #240    //check if we have finished 
     BEQ clear_pixelbuff_done 

     MOV R6, R4     //copy y number 
     LSL R6, #10     //left shift y by 10 bits
     MOV R7, R3      //copy x number 
     LSL R7, #1     //left shift x by 1 bit

     ORR R7, R7, R6
     ORR R7, R7, R1
   
     STRH R2, [R7]

     ADD R3,R3,#1   //increment counter

     B clear_pixelbuff_loop

clear_pixelbuff_done:
     POP {R1-R8,LR}
     BX LR




VGA_write_char_ASM:
     PUSH {R4-R8,LR}
 write_char_check:
     //check x validation
     CMP R0, #0   
     BLE write_char_done
     CMP R0, #79 
     BGE write_char_done

     //check y validation
     CMP R1, #0
     BLE write_char_done
     CMP R1, #59
     BGE write_char_done

     //do store
     LDR R3, =char_base
     MOV R6, R1     //copy y number 
     LSL R6, #7     //left shift y by 7 bits
     ADD R6, R6, R0 //y+x
     ADD R6, R6, R3  //add to base address to get current address
    
     STRB R2, [R6]    
    
 write_char_done:
     POP {R4-R8,LR}
     BX LR






VGA_write_byte_ASM:
     PUSH {R4-R10,LR}
 write_byte_check:
     //check x validation
     CMP R0, #0   
     BLE write_byte_done
     CMP R0, #79 
     BGE write_byte_done

     //check y validation
     CMP R1, #0
     BLE write_byte_done
     CMP R1, #59
     BGE write_byte_done

     LDR R3, =char_base

    
     ADD R4, R0, #1   //the next coordinate (x+1,y)
     MOV R5, R1
     CMP R4, #80
     MOVEQ R4, #0      //if at the end of a line, change line 
     ADDEQ R5, R5, #1
     CMP R5, #60
     BEQ write_byte_done


    
     MOV R6, R1     //copy y number 
     LSL R6, #7     //left shift y by 7 bits
     ORR R6, R6, R0 //y+x
     ORR R6, R6, R3  //get first address

     MOV R7, R5     //copy y number 
     LSL R7, #7     //left shift y by 7 bits
     ORR R7, R7, R4 //y+x
     ORR R7, R7, R3  //get second address


      //do store 
     STR R2, [R8]
     LDRH R9, [R8]   //read 8 bits
     AND R10,R9,#0xF   //read second half to R10
     ASR R9,R9,#4    //read first half to R9

     MOV R8, R9   
     BL decide    
     MOV R9, R8

     MOV R8, R10
     BL decide 
     MOV R10, R8

     STRB R9, [R6]    
     STRB R10, [R7]
     
    
 write_byte_done:
     POP {R4-R10,LR}
     BX LR
 
 decide: 
    CMP R8, #0xA
    MOVEQ R8, #65
    BXEQ LR
    CMP R8, #0xB
    MOVEQ R8, #66
    BXEQ LR
    CMP R8, #0xC
    MOVEQ R8, #67
    BXEQ LR
    CMP R8, #0xD
    MOVEQ R8, #68
    BXEQ LR
    CMP R8, #0xE
    MOVEQ R8, #69
    BXEQ LR
    CMP R8, #0xF
    MOVEQ R8, #70
    BXEQ LR
    
    ADD R8, R8, #48
    BX LR
    
    

    



VGA_draw_point_ASM:
     PUSH {R4-R8,LR}
 draw_point_check:
     MOV R7, #255
     ADD R7, R7, #64
     //check x validation
     CMP R0, #0   
     BLE draw_point_done
     CMP R0, R7
     BGE draw_point_done

     //check y validation
     CMP R1, #0
     BLE draw_point_done
     CMP R1, #239
     BGE draw_point_done

     //do store
     LDR R3, =pixel_base
     MOV R6, R1     //copy y number 
     LSL R6, #10     //left shift y by 10 bits
     MOV R8, R0
     LSL R8, #1

     ORR R8, R6, R8
     ORR R8, R8, R3
     STRH R2, [R8]     
    
 draw_point_done:
     POP {R4-R8,LR}
     BX LR

