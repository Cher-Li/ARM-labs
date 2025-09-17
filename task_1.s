dividend:
    .word 10
divisor:
    .word 2

    .global _start
_start:
    // R0: stores the quotient
    MOV R0, #0
    
	// your code starts here
	
	LDR R1, dividend
	LDR R2, divisor
	MOV R3, #0 // sign
	MOV R7, #1 // LSL takes only registers
	MOV R8, #-1 // For MUL because also take only registers
	
	// sign switching: 
	CMP R1, #0 
	BGE _checkDivisor // if dividend >= 0, skip this loop
	
	EOR R3, R3, #1
	MUL R1, R1, R8
	
_checkDivisor: 
	CMP R2, #0
	BGE _calc
	
	EOR R3, R3, #1
	MUL R2, R2, R8
	
_calc: 
	MOV R4, #0 // remainder
	MOV R5, #31 // i = 32 - 1
	
_loop: 
	CMP R5, #0
	BLT _afterLoop // if i < 0 skip this loop
	
	LSL R4, R4, #1
	LSR R6, R1, R5 // dividend >> i, temporary value for calculations
	AND R6, R6, #1
	ORR R4, R4, R6

_innerLoop: 
	CMP R4, R2
	BLT _decrement // remainder < divisor
	SUB R4, R4, R2
	LSL R6, R7, R5
	ORR R0, R0, R6

_decrement: 
	SUB R5, R5, #1
	B _loop

_afterLoop: 
	CMP R3, #0
	BEQ end // if sign = 0, branch to end	
	MUL R0, R0, R8
	
	// your code ends here
end:
    B end