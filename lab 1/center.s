			.text
			.global _start

_start:
			LDR R4, =RESULT //R4 points to the result location
			LDR R2, [R4, #4] //R2 holds the number of elements in the list 
			ADD R3, R4, #8 //R3 points to the first number 
			LDR R0, [R3] //R0 holds the first number in the list

			ADD R6, R2, #0 //size of the list but constant

			//after this loop, R0 will hold the total
LOOP: 		SUBS R2, R2, #1 //decrement the loop counter 
			BEQ DONE //end counter if counter reached 0
			ADD R3, R3, #4 //R3 points to the next number in the list
			LDR R1, [R3] //R1 holds the next number in the list
			ADD R0, R0, R1 //add the number to the total result
			B LOOP 
	
DONE:

			MOV R8, R6 //copy the size of the list to avoid side-effect
			MOV R7, #0 //counter to find the log

LOG:		CMP R8, #0 //if we reached 0, go to SHIFT to divide R0 by log base 2 of R8
			BEQ SHIFT
			ASR R8,#1 //divide the size of the list by 2
			ADD R7, R7, #1 //increment the counter
			B LOG

SHIFT:		ASR R0, R7 
			ADD R6, R6, #1 //add 1 to the size otherwise we get an off-by-one error in the loop below

			//now we go backward, starting from the end of the list, we go toward the begining of the list
AVG:		SUBS R6, R6, #1 //substract the counter 
			BEQ END 
			LDR R1, [R3] //store the value at that address in R1
			SUBS R1, R1, R0 //subs the average from the value in R1
			STR R1, [R3] //store the value back
			SUBS R3, R3, #4 //decrement the address
			B AVG //keep looping

END:		B END //infinite loop, for debugging

RESULT: 	.word	0 //memory assigned for result location
N: 			.word 	4 //size of list
NUMBERS:	.word 	3, 3, 3, 3 //the list
			//.word 	-14, 9, 10, 15
