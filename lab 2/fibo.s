	        .text
			.global _start

_start:
		LDR R1, N 
		BL	FIB
		B DONE

FIB:	PUSH {LR} //remember return value

		CMP R1, #2 //if smaller than 2, then simply return 1
		BGE	REC //otherwise perform recursive step
		MOV R0, #1
		POP {LR}
		BX LR

REC:	PUSH {R1} //save current R1 on the stack
		SUB R1, R1, #1 //N-1
		BL FIB
		POP {R4} //get current N-1
		PUSH {R0} //push result of FIB(N-1)
		SUB R4, R4, #2 //compute N-2
		MOV R1, R4 //put N-2 in R1 because R1 is the argument register
		BL FIB 
		POP {R2} //pop the result
		ADD R0, R0, R2 //add them
		POP {LR} //remember the return value

		BX LR

DONE:	B DONE

N: 		.word 	8
