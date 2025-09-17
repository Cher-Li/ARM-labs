n:	.word 4

.global _start

_start:
	// use R0 to pass N and store the return value
	LDR		R0, n	
	BL		padovan 
	
end:
	B		end
	
padovan:
	// your code starts here
	
	PUSH {R4, R5, LR}
	CMP R0, #2
	BNE _elseif
	MOV R0, #1
	POP {R4, R5, LR}
	BX LR // return

_elseif:
	CMP R0, #1
	BNE _else
	MOV R0, #1
	POP {R4, R5, LR}
	BX LR

_else:
	CMP R0, #0
	BNE _calc
	MOV R0, #1
	POP {R4, R5, LR}
	BX LR

_calc:
	// calc pad(n-2) + pad(n-3)
	MOV R4, R0 // n
	SUB R0, R0, #2 // n - 2

	// your code ends here
	BL		padovan
	
	// your code starts here
	// R0 now has pad(n-2)
	
	MOV R5, R0 // R5 = pad (n-2)
	MOV R0, R4 
	// STR R4, [R0] // restore R0 to n? 
	SUB R0, R0, #3 // n - 3	
	
	// your code ends here
	BL		padovan
	
	// your code starts here
	// R0 now has pad(n-3) 
	
	ADD R0, R5, R0 // pad (n-2) + pad (n-3)
	POP {R4, R5, LR}
	
	// your code ends here
	BX		LR