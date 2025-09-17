
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
	PUSH {R4-R9}
	
	MOV R7, #77
	MOV R8, #150
	MOV R9, #29
	MOV R3, #0 // stop when = image size

loop:
	CMP R3, R2
	BGE finished // if R3 < image size continue the loop

	LDRB R4, [R0] // R4 = red
	ADD R0, R0, #1
	LDRB R5, [R0] // R5 = green
	ADD R0, R0, #1
	LDRB R6, [R0] // R6 = blue
	ADD R0, R0, #1
	
	// calculations
	MUL R4, R4, R7
	MUL R5, R5, R8
	MUL R6, R6, R9
	ADD R4, R4, R5
	ADD R4, R4, R6
	
	// R4 = R4 / 256 means right shift by 8
	LSR R4, R4, #8
	MOV R5, R4
	STRB R5, [R1]
	ADD R1, R1, #1 // output image onto next pixel
	
	ADD R3, R3, #1 // also increment pixel count
	B loop

finished:
	POP {R4-R9}

    // your code ends here
    BX  LR