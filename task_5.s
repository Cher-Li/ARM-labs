
.data
input_image:    // don't refer to this label directly
.byte 230, 172, 36, 60, 99, 64, 212, 100, 69, 98, 146, 76
.byte 12, 51, 7, 70, 132, 101, 200, 223, 51, 35, 191, 12
.byte 9, 66, 112, 69, 83, 181, 88, 127, 120, 139, 199, 82 
.byte 232, 60, 24, 250, 193, 125, 59, 126, 110, 206, 194, 62

output_image:   // don't refer to this label directly
.space 16

image_size:
.word 16


.text
.global _start
_start:
	LDR R0, =input_image
    LDR R1, =output_image
    LDR R2, =image_size
	LDR	R2, [R2]
    BL 	rgb2gray
	
end:
	B 	end
	
rgb2gray:
	// your code starts here
	PUSH {R4-R10}
	
	MOV R7, #77
	MOV R8, #150
	MOV R9, #29
	MOV R3, #0 

loop:
	CMP R3, R2
	BGE finished
	
	MOV R10, #0 // final grey pixel value

	LDRB R4, [R0], #1
	LDRB R5, [R0], #1
	LDRB R6, [R0], #1
	
	MLA R10, R7, R4, R10
	MLA R10, R8, R5, R10
	MLA R10, R9, R6, R10
	
	LSR R10, R10, #8
	STRB R10, [R1], #1
	
	ADD R3, R3, #1
	B loop

finished:
	POP {R4-R10}

    // your code ends here
    BX  LR