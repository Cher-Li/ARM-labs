array:		.short 	9, 3, 1, 2 	// array
size: 		.word	4			// number of elements

.global _start

_start:
	// your code starts here
	MOV R0, #0 // step
	LDR R3, size
	MOV R8, #2 // short = 2 bytes
	LDR R2, =array

_loop1: 
	SUB R4, R3, #1 // size - 1
	CMP R0, R4
	BGE end
	
	MOV R1, #0 // *reset i for inner loop*

_loop2:
	SUB R4, R3, R0
	SUB R4, R4, #1 // size - step - 1
	CMP R1, R4
	BGE _incrementStep

_calculate: 
    MOV R9, R1
    MUL R9, R9, R8 // i * 2 b/c 2 bytes
    ADD R10, R2, R9 // R10 = address of array[i]

    LDRH R5, [R10] // R5 containing value of arr[i] 
    ADD R10, R10, #2 // arr[i+1]
    LDRH R6, [R10] // R6 = arr[i+1] 

    CMP R5, R6
    BGE _incrementI

    // swap array[i] and array[i+1]
	// no temp register b/c already have both values stored in R5 and R6
    STRH R6, [R10, #-2] // arr[i] = arr[i+1] 
    STRH R5, [R10]      // arr[i+1] = arr[i] 
	
_incrementI:
	ADD R1, R1, #1
	B _loop2

_incrementStep:
	ADD R0, R0, #1
	B _loop1

	// your code ends here
	
end:
    B 		end
	
