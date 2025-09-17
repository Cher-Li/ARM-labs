			.text
			.global _start

_start:			

			LDR R4, =RESULT //R4 points to the result location
			LDR R2, [R4, #4] //R2 holds N

			ADD R6, R2, #0 //this is a copy of N, just in case we want to mutate R2

			MOV R5, #1 //flag to know if array is sorted **CONVENTION false = 1 and true = 0**

WHILE:		CMP R5, #0 //check if flag is false
			MOV R5, #0 //now set it to true
			MOV R1, #1 //this is the counter e.g. i (which we start at 1 and not 2)
			
			//reset the positions, everytime the loop starts again, we want to have the first 2 numbers in the array
			ADD R7, R4, #8 //i-1
			LDR R8, [R7] //A[i-1]
			ADD R9, R4, #12 //i
			LDR R10, [R9] //A[i]

			BNE INNER //if the flag was false, go in inner loop
			B DONE //otherwise we're done

INNER:		CMP R1, R6 //if i < N
			BEQ WHILE //if they are equal, start the while loop again

			CMP R8, R10 //otherwise check if we want to swap A[i-1] and A[i]
			BGT SWAP //if so, go do the swapping and come back here after (see SWAP)
SET_I:		ADD R1, R1, #1 //incrememnt the counter i

			//move forward in array, this correspond to A[i] and A[i-1] but with the new incremented i
			ADD R7, R7, #4
			LDR R8, [r7]
			ADD R9, R9, #4
			LDR R10, [R9]

			B INNER //keep doing the inner loop

SWAP:		MOV R11, R8 //swap, just like a typical C example
			STR R10, [R7]
			STR R11, [R9]
			MOV R5, #1 //set the flag to false
			B SET_I //come back to where we were

DONE:		STR R0, [R4] //store the result to the memory location		

END:		B END //infinite loop, for debugging

RESULT: 	.word	0 //memory assigned for result location
N: 			.word 	7 //size of list
NUMBERS:	.word 	-1, 6, 3, 9 //the list
			.word 	3, 2, 7
