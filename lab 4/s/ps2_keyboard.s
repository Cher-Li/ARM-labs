	.text
	.global read_PS2_data_ASM

	.equ data_reg, 0xFF200100
	.equ control_reg, 0xFF200104

	//argument: char pointer holding the data
	//return: int that says if data read is valid or not
read_PS2_data_ASM:
	
	LDR R1, =data_reg 
	LDR R3, [R1] //load the register content
	MOV R2, #0x8000 //1 at the 15th bit 
	ANDS R3, R2 //check if RVALID is 1
	MOVEQ R0, #0 //if not, return 0
	BXEQ LR
	LDRB R2, [R1] //else load the first byte of the data register
	STR R2, [R0] //store that data at the address held by the pointer
	MOV R0, #1 //signal that it worked
	BX LR
	
	