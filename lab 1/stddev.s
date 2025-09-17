			.text
			.global _start

_start:
			LDR R4, =RESULT //R4 points to the result location
			LDR R2, [R4, #4] //R2 holds the number of elements in the list 
			ADD R3, R4, #8 //R3 points to the first number 
			LDR R0, [R3] //R0 holds the first number in the list
			LDR R5, [R3] //R5 holds also the first number in the list, but will be the min


LOOP: 		SUBS R2, R2, #1 //decrement the loop counter 
			BEQ DONE //end counter if counter reached 0
			ADD R3, R3, #4 //R3 points to the next number in the list
			LDR R1, [R3] //R1 holds the next number in the list
			CMP R0, R1 //check if it is greater than max 
			BGE  MIN//if no, go check for min
			MOV R0, R1 //if yes, update current max
			B MIN //go check for min

MIN:		CMP R1, R5 //check if small than min
			BGE LOOP //if not, keep looping
			MOV R5, R1 //if yes, update
			B LOOP //keep looping

DONE:		ADD R3, R0, R5 //add the 2 results
			ASR R3, #2 //divide by 4

END:		B END //infinite loop, for debugging

RESULT: 	.word	0 //memory assigned for result location
N: 			.word 	7 //size of list
NUMBERS:	.word 	4, 0, 3, 6 //the list
			.word 	6, 8, 0

