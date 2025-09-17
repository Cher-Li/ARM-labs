			.text
			.equ HEX0_3, 0xFF200020
			.equ HEX4_5, 0xFF200030
			.global HEX_clear_ASM
			.global HEX_flood_ASM
			.global HEX_write_ASM

//clear
HEX_clear_ASM:
				PUSH {R4-R9,LR}
				LDR R2, =HEX0_3			//#Load the first display
				MOV R4, #0              //initiate counter 
				MOV R3, #0xFFFFFF00     //11111111 11111111 11111111 00000000
				MOV R9, R3              //#constant of above value

clear_loop:
				CMP R4, #5				//check if we've done all one hot encode detection
				BGT clear_done	        //#branch to done

                CMP R4, #4              //check if HEX0,HEX1,HEX2,HEX3 have all been checked
				LDREQ R2, =HEX4_5		//#Load the second display
				MOVEQ R3, R9            //#restore R3 for change  

				AND R6, R0, #1         //check the value of the least significant bit of one hot encoder
				ASR R0, R0, #1			//Shift R0, move to the next bit
				CMP R6, #0              //check if we should perform clear on this HEX				
				BEQ clear_update
						          

				//#do clear 				
				LDR R6, [R2]
				AND R6, R6, R3			//#Set new value, perform ADD on 0 and random number, the result is 0
				STR R6, [R2]		    //#Store it into the display
				

clear_update:
                ADD R4, R4, #1		    //  Increment counter		
				LSL R3, #8			    //  Shift R3 by 8 bits
				ADD R3, R3, #0xFF       //   make the byte of current HEX 0, e.g:R3 = 11111111 11111111 00000000 11111111 when HEX1
				B clear_loop            //  #return to loop

clear_done:
				POP {R4-R9,LR}
				BX LR

//flood				
HEX_flood_ASM:
				PUSH {R4-R9,LR}
				LDR R2, =HEX0_3			// Load the first display
				MOV R4, #0				//initialize counter
				MOV R3, #0xFF           //00000000 00000000 00000000 11111111
				MOV R9, R3

flood_loop:
				CMP R4, #5				//If all the one hot encoder are checked
				BGT flood_done	        //#we are done

                CMP R4, #4
				LDREQ R2, =HEX4_5		// Load the second display
				MOVEQ R3, R9
				
				AND R6, R0, #1          //check LSB
				ASR R0, R0, #1          //right shift R0 for 1 bit				
				CMP R6, #0
				BEQ flood_update        //#If bit is 0, jump to update
				
				//#do flood
				LDR R7, [R2]
				ORR R7, R7, R3			//Set new value
				STR R7, [R2]			//Store it into the display
			

flood_update:
                ADD R4, R4, #1			//Increment counter
				LSL R3, #8				//Shift R3 by 8 bits
				B flood_loop
flood_done:
				POP {R4-R9,LR}
				BX LR


//write			
HEX_write_ASM:
				MOV R3, R0              //store input string in R3
				PUSH {R1-R9, LR}
				BL HEX_clear_ASM		//clear displays to write 
				POP {R1-R9, LR}
				MOV R0, R3              //recover R0 
				PUSH {R4-R9, LR}
				LDR R2, =HEX0_3		//Load the first display
				MOV R4, #0 //counter
				
			

L0:
				CMP R1, #0               
				MOVEQ R3, #0x3F            //0111111
				MOVEQ R9, R3
				BEQ write_loop

L1:	
				CMP R1, #1              
				MOVEQ R3, #0x06            //0000110
				MOVEQ R9, R3
				BEQ write_loop

L2:	
				CMP R1, #2 
				MOVEQ R3, #0x5B            //1011011
				MOVEQ R9, R3
				BEQ write_loop

L3:	
				CMP R1, #3
				MOVEQ R3, #0x4F            //1001111
				MOVEQ R9, R3
				BEQ write_loop

L4:	
				CMP R1, #4
				MOVEQ R3, #0x66            //1100110
				MOVEQ R9, R3
				BEQ write_loop

L5:	
				CMP R1, #5
				MOVEQ R3, #0x6D            //1101101
				MOVEQ R9, R3
				BEQ write_loop

L6:	
				CMP R1, #6
				MOVEQ R3, #0x7D            //1111101
				MOVEQ R9, R3
				BEQ write_loop

L7:	
				CMP R1, #7
				MOVEQ R3, #0x07            //0000111
				MOVEQ R9, R3
				BEQ write_loop

L8:	
				CMP R1, #8
				MOVEQ R3, #0x7F             //1111111
				MOVEQ R9, R3
				BEQ write_loop

L9:	
				CMP R1, #9
				MOVEQ R3, #0x6F             //1101111
				MOVEQ R9, R3
				BEQ write_loop

L10:	
				CMP R1, #10
				MOVEQ R3, #0x77             //1110111
				MOVEQ R9, R3
				BEQ write_loop

L11:	
				CMP R1, #11
				MOVEQ R3, #0x7C             //1111100
				MOVEQ R9, R3
				BEQ write_loop

L12:	
				CMP R1, #12
				MOVEQ R3, #0x39             //0111001
				MOVEQ R9, R3
				BEQ write_loop

L13:	
				CMP R1, #13
				MOVEQ R3, #0x5E             //1011110
				MOVEQ R9, R3
				BEQ write_loop

L14:	
				CMP R1, #14
				MOVEQ R3, #0x79             //1111001
				MOVEQ R9, R3
				BEQ write_loop

				MOV R3, #0x71             //1110001
				MOV R9, R3
				B write_loop

write_loop:
				CMP R4, #5				//if all the one hot encoder is checked
				BGT write_done	//#we are done
				AND R6, R0, #1          //check if LSB is 0 or 1
				ASR R0, R0, #1			//right shift R0 for 1 bit

				CMP R4, #4
				LDREQ R2, =HEX4_5		// Load the second display
				MOVEQ R3, R9

				CMP R6, #0				
				BEQ write_update //#If bit is 0, jump to update

				//#do write 
				LDR R6, [R2]
				ORR R6, R6, R3			//Set new value
				STR R6, [R2]		    //Store it into the display				
				
write_update:
                ADD R4, R4, #1		// Increment				
				LSL R3, #8			//left shift R3 by 8 bits							
				B write_loop	   //#return to the start of the loop


write_done:
				POP {R4-R9,LR}
				BX LR

				.end


