	        .text
			.global _start

_start:
		LDR R1, N 
		LDR R2, =NUMBERS

		BL MAX
		B DONE

MAX:	PUSH {R1}
		PUSH {R2}
		PUSH {R3}
		LDR R0, NUMBERS //initialize current max to first element of the list

LOOP:	SUBS R1, R1, #1 //if end of list reached, return
		CMP R1, #0
		BEQ RET
		ADD R2, R2, #4 //else, get next element
		LDR R3, [R2]
		CMP R0, R3 //check if current max is smaller than current element
		BGE LOOP
		MOV R0, R3 //if smaller, then update
		B LOOP //keep looping until end of list 

RET:	POP {R3}
		POP {R2}
		POP {R1}
		BX LR

DONE:	B DONE

N: 			.word 	7
NUMBERS:	.word 	4, 5, 3, 6, 1, 8, 2
