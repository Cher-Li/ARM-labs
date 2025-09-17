.text
.equ fifospace, 0xFF203044
.equ leftdata, 0xFF203048
.equ rightdata, 0xFF20304C
.equ large, 0xFFFF0000

.global write_in_FIFO_ASM

write_in_FIFO_ASM:
	LDR R1, =fifospace
	LDR R2, =leftdata
	LDR R3, =rightdata
	LDR R4, [R1]
	LDR R1, =large
	LDR R1, [R1]
	ANDS R4, R1
	MOVEQ R0, #0
	BXEQ LR
	STR R0, [R2]
	STR R0, [R3]
	MOV R0, #1
	BX LR