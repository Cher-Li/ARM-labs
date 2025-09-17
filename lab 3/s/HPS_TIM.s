			.text
			.equ TIM_0, 0xFFC08000
			.equ TIM_1, 0xFFC09000
			.equ TIM_2, 0xFFD00000
			.equ TIM_3, 0xFFD01000
			.global HPS_TIM_config_ASM
			.global HPS_TIM_read_ASM
			.global HPS_TIM_clear_INT_ASM

//E -> Enable interrupt also fire up the timer
//S -> Are you executing an interrupt  0 --> in interrupt 1 --> not in interrupt
//F -> End of interrupt
//M -> Start with load value
//I -> Send interrupt when done

//Need to enable E before config
//M: Specify to start at specified value
//Set E = 1 -> start timer
//Timer counts down to 0
// S and F reset when reader E?
//If I is enabled, then interrupt request when timer reaches 0

//Counter -> current value of the timer
//Load value -> start value

HPS_TIM_config_ASM:
			PUSH {R1-R8}
			LDR R2, [R0]				//Load timers string
			AND R2, R2, #0xF			//clear leading bits
			MOV R1, #0					//initialize the counter
			
config_loop:
			CMP R1, #4					//if we covered all 4 timers then stop
			BGE config_done			
			AND R4, R2, #1              //check if bit is hot			
			ASR R2, R2, #1				//Shift input by 1 for next iteration

			CMP R4, #0 
			ADDEQ R1, R1, #1			//update counter
			BEQ config_loop	            //if the bit was low, go to next timer

			//Load the corresponding timer
			CMP R1, #0
			LDREQ R5, =TIM_0
			CMP R1, #1
			LDREQ R5, =TIM_1
			CMP R1, #2
			LDREQ R5, =TIM_2
			CMP R1, #3
			LDREQ R5, =TIM_3
		
			LDR R3, [R0, #0x8]			//need to disable the timer before doing any change
			AND R3, R3, #0x6			//Only change the E bit
			STR	R3, [R5, #0x8] 			//store result back
	
			//Now we can start configuring the proper timer

			LDR R3, [R0, #0x4]			//Load the timeout address
			STR R3, [R5] 				//Write the argument to it
			
			LDR R4, [R0, #0xC]			//Load INT_en param
			LSL R4, R4, #2				//shift by 2 bits to get the I bit

			LDR R3, [R0, #0x8]			//Load LD_en address param
			LSL R3, R3, #1				//shift by one bit to get the M bit

			ORR R7, R3, R4				//Mix M and I

			LDR R6, [R0, #0x10]			//Load the enable param

			ORR R7, R7, R6				//Mix M, I and E

			STR R7, [R5, #0x8]			//Store result

			ADD R1, R1, #1				//update counter
			B config_loop

config_done:
			POP {R1-R8}
			BX LR
	
	


HPS_TIM_read_ASM:
			PUSH {R1-R5}
			AND R0, R0, #0xF			//check one hot string
			MOV R1, #0					//initialize counter
			
read_loop:
			CMP R1, #4					//if we covered all 4 timers then we're done
			BGE read_done	

			AND R3, R0, #1              //check if this bit is hot
			ASR R0, R0, #1				//prepare for next iteration

			CMP R3, #0 
			ADDEQ R1, R1, #1			//update the counter
			BEQ read_loop	            //If the bit was low, go to next loop

			//Get the corresponding timer
			CMP R1, #0
			LDREQ R5, =TIM_0
			CMP R1, #1
			LDREQ R5, =TIM_1
			CMP R1, #2
			LDREQ R5, =TIM_2
			CMP R1, #3
			LDREQ R5, =TIM_3

			LDR R2, [R5, #0x10]			//Load the s bit
			AND R0, R2, #1				//just so we don't have garbage in front of our bit
			B read_done 

read_done:
			POP {R1-R5}
			BX LR


//This is the same thing as the read subroutine, except that the only thing we need to do is to read the F bit, which nicely clear everything for us
HPS_TIM_clear_INT_ASM:
			PUSH {R1-R5}
			AND R0, R0, #0xF			
			MOV R1, #0					
			
clear_loop:
			CMP R1, #4					
			BGE clear_done	
			
			AND R3, R0, #1
			ASR R0, R0, #1		

			CMP R3, #0					
			ADDEQ R1, R1, #1			
			BEQ clear_loop	

			CMP R1, #0
			LDREQ R5, =TIM_0
			CMP R1, #1
			LDREQ R5, =TIM_1
			CMP R1, #2
			LDREQ R5, =TIM_2
			CMP R1, #3
			LDREQ R5, =TIM_3

			LDR R3, [R5, #0xC]			

			ADD R1, R1, #1				
			B clear_loop

clear_done:
			POP {R1-R5}
			BX LR			

			.end
