.global _start
.equ HEX0, 0x00000001
.equ HEX1, 0x00000002
.equ HEX2, 0x00000004
.equ HEX3, 0x00000008
.equ HEX4, 0x00000010
.equ HEX5, 0x00000020
.equ SSD_H3_0, 0xFF200020
.equ SSD_H5_4, 0xFF200030

// Slider Switches Driver
// returns the state of slider switches in A1
// post- A1: slide switch state
.equ SW_ADDR, 0xFF200040
read_slider_switches_ASM:
    LDR A2, =SW_ADDR     // load the address of slider switch state
    LDR A1, [A2]         // read slider switch state 
    BX  LR

// LEDs Driver
// writes the state of LEDs (On/Off) in A1 to the LEDs' control register
// pre-- A1: data to write to LED state
.equ LED_ADDR, 0xFF200000
write_LEDs_ASM:
    LDR A2, =LED_ADDR    // load the address of the LEDs' state
    STR A1, [A2]         // update LED state with the contents of A1
    BX  LR

HEX_clear_ASM:
	// one hot encoding so could loop through to AND each with A1
	LDR R1, =SSD_H3_0
	LDR R2, =SSD_H5_4
	//B Hex_0; 

//Clear_3_0: 
	//MOV R3, #0
	//STR R3, [R1]
	//BX LR

//Clear_5_4:
	//MOV R3, #0
	//STR R3, [R2]
	//BX LR

Hex_0:
	TST A1, #0x00000001
	BNE Clear_Hex_0 // NE means Z = 0, meaning asserted
	B Hex_1

Clear_Hex_0:
	//MOV R3, #0
	//STR R3, [R1] // currently clears the whole Hex 3-0 display? 
	LDR R3, [R1] // gets Hex 3-0
	AND R3, R3, #0xFFFFFF80
	//AND R3, R3,	11111111111111111111111110000000
	STR R3, [R1]

Hex_1: 
	TST A1, #0x00000002
	BNE Clear_Hex_1
	B Hex_2

Clear_Hex_1:
	LDR R3, [R1] 
	AND R3, R3, #0xFFFF80FF
	//AND R3, R3,	1111111111111111'1000'0000'1111'1111
	STR R3, [R1]

Hex_2:
	TST A1, #0x00000004
	BNE Clear_Hex_2
	B Hex_3

Clear_Hex_2:
	LDR R3, [R1] 
	AND R3, R3, #0xFF80FFFF
	STR R3, [R1]

Hex_3:
	TST A1, #0x00000008
	BNE Clear_Hex_3
	B Hex_4

Clear_Hex_3:
	LDR R3, [R1] 
	AND R3, R3, #0x80FFFFFF
	STR R3, [R1]

Hex_4:
	TST A1, #0x00000010
	BNE Clear_Hex_4
	B Hex_5

Clear_Hex_4:
	LDR R4, [R2] 
	AND R4, R4, #0xFFFFFF80
	STR R4, [R2]

Hex_5:
	TST A1, #0x00000020
	BNE Clear_Hex_5
	B Finished

Clear_Hex_5:
	LDR R4, [R2] 
	AND R4, R4, #0xFFFF80FF
	STR R4, [R2]

Finished:
	BX LR


HEX_flood_ASM:
	LDR R1, =SSD_H3_0
	LDR R2, =SSD_H5_4

Hex_checkF_0:
	TST	A1, #0x00000001 // similar to clear, asserted
	BNE Flood_Hex_0
	B Hex_checkF_1

Flood_Hex_0:
	ADD R3, R3,	#0x0000007F // Hex 5 -> 0 so write to least sig bits
	// also 7 segments, so 2^7 - 1 = 127 -> 7F
	STR R3, [R1]

Hex_checkF_1:
	TST A1, #0x00000002
	BNE Flood_Hex_1
	B Hex_checkF_2

Flood_Hex_1:
	ADD R3, R3, #0x00007F00 // second from the right, also 7F
	STR R3, [R1]
	
Hex_checkF_2:
	TST A1, #0x00000004
	BNE Flood_Hex_2
	B Hex_checkF_3
	
Flood_Hex_2:
	ADD R3, R3, #0x007F0000
	STR R3, [R1]
	
Hex_checkF_3:
	TST A1, #0x00000008
	BNE Flood_Hex_3
	B Hex_checkF_4

Flood_Hex_3:
	ADD R3, R3, #0x7F000000
	STR R3, [R1]

Hex_checkF_4:
	PUSH {R4} 
	TST A1, #0x00000010
	BNE Flood_Hex_4
	B Hex_checkF_5

Flood_Hex_4:
	ADD R4, R4, #0x0000007F // new register so starting from LSB
	STR R4, [R2]

Hex_checkF_5:
	TST A1, #0x00000020
	BNE Flood_Hex_5
	POP {R4} 
	BX LR

Flood_Hex_5:
	ADD R4, R4, #0x00007F00
	STR R4, [R2]
	POP {R4} 
	BX LR


HEX_write_ASM: 
	LDR R2, =SSD_H3_0 // since A1 is R0 and A2 is R1
	LDR R3, =SSD_H5_4
	// need register for updating
	MOV R4, #0 // 3-0
	MOV R5, #0 // 5-4

Hex_checkW_0:
	TST	A1, #0x00000001
	BNE Write_Hex_0
	B Hex_checkW_1

Write_Hex_0:
	// need to find out what value A2 is
	CMP A2, #0 // if want to write 0 to Hex 0 this should be equal
	PUSH {R4} 
	MOVEQ R4, #0x00003F
	CMP A2, #1
	MOVEQ R4, #0x000006
	CMP A2, #2
	MOVEQ R4, #0x00005B
	CMP A2, #3
	MOVEQ R4, #0x00004F	
	CMP A2, #4
	MOVEQ R4,#0x000066
	CMP A2, #5
	MOVEQ R4, #0x00006D
	CMP A2, #6
	MOVEQ R4, #0x00007D
	CMP A2, #7
	MOVEQ R4, #0x000007
	CMP A2, #8
	MOVEQ R4, #0x00007F
	CMP A2, #9
	MOVEQ R4, #0x0000EF
	CMP A2, #10
	MOVEQ R4, #0x000077
	CMP A2, #11
	MOVEQ R4, #0x00007C
	CMP A2, #12
	MOVEQ R4, #0x000039
	CMP A2, #13
	MOVEQ R4, #0x00005E
	CMP A2, #14
	MOVEQ R4, #0x000079
	CMP A2, #15
	MOVEQ R4, #0x000071
	
	STRB R4, [R2]
	POP {R4} 

Hex_checkW_1:
	TST	A1, #0x00000002
	BNE Write_Hex_1
	B Hex_checkW_2

Write_Hex_1:
	CMP A2, #0
	PUSH {R4} 
	MOVEQ R4, #0x00003F
	CMP A2, #1
	MOVEQ R4, #0x000006
	CMP A2, #2
	MOVEQ R4, #0x00005B
	CMP A2, #3
	MOVEQ R4, #0x00004F	
	CMP A2, #4
	MOVEQ R4,#0x000066
	CMP A2, #5
	MOVEQ R4, #0x00006D
	CMP A2, #6
	MOVEQ R4, #0x00007D
	CMP A2, #7
	MOVEQ R4, #0x000007
	CMP A2, #8
	MOVEQ R4, #0x00007F
	CMP A2, #9
	MOVEQ R4, #0x0000EF
	CMP A2, #10
	MOVEQ R4, #0x000077
	CMP A2, #11
	MOVEQ R4, #0x00007C
	CMP A2, #12
	MOVEQ R4, #0x000039
	CMP A2, #13
	MOVEQ R4, #0x00005E
	CMP A2, #14
	MOVEQ R4, #0x000079
	CMP A2, #15
	MOVEQ R4, #0x000071
	
	STRB R4, [R2, #1] // shift because R4 contains the full HEX 3-0
	POP {R4} 

Hex_checkW_2:
	TST A1, #0x00000004
	BNE Write_Hex_2
	B Hex_checkW_3

Write_Hex_2:
	CMP A2, #0
	PUSH {R4} 
	MOVEQ R4, #0x00003F
	CMP A2, #1
	MOVEQ R4, #0x000006
	CMP A2, #2
	MOVEQ R4, #0x00005B
	CMP A2, #3
	MOVEQ R4, #0x00004F	
	CMP A2, #4
	MOVEQ R4,#0x000066
	CMP A2, #5
	MOVEQ R4, #0x00006D
	CMP A2, #6
	MOVEQ R4, #0x00007D
	CMP A2, #7
	MOVEQ R4, #0x000007
	CMP A2, #8
	MOVEQ R4, #0x00007F
	CMP A2, #9
	MOVEQ R4, #0x0000EF
	CMP A2, #10
	MOVEQ R4, #0x000077
	CMP A2, #11
	MOVEQ R4, #0x00007C
	CMP A2, #12
	MOVEQ R4, #0x000039
	CMP A2, #13
	MOVEQ R4, #0x00005E
	CMP A2, #14
	MOVEQ R4, #0x000079
	CMP A2, #15
	MOVEQ R4, #0x000071
	
	STRB R4, [R2, #2]
	POP {R4} 

Hex_checkW_3:
	TST A1, #0x00000008
	BNE Write_Hex_3
	B Hex_checkW_4

Write_Hex_3:
	CMP A2, #0
	PUSH {R4} 
	MOVEQ R4, #0x00003F
	CMP A2, #1
	MOVEQ R4, #0x000006
	CMP A2, #2
	MOVEQ R4, #0x00005B
	CMP A2, #3
	MOVEQ R4, #0x00004F	
	CMP A2, #4
	MOVEQ R4,#0x000066
	CMP A2, #5
	MOVEQ R4, #0x00006D
	CMP A2, #6
	MOVEQ R4, #0x00007D
	CMP A2, #7
	MOVEQ R4, #0x000007
	CMP A2, #8
	MOVEQ R4, #0x00007F
	CMP A2, #9
	MOVEQ R4, #0x0000EF
	CMP A2, #10
	MOVEQ R4, #0x000077
	CMP A2, #11
	MOVEQ R4, #0x00007C
	CMP A2, #12
	MOVEQ R4, #0x000039
	CMP A2, #13
	MOVEQ R4, #0x00005E
	CMP A2, #14
	MOVEQ R4, #0x000079
	CMP A2, #15
	MOVEQ R4, #0x000071
	
	STRB R4, [R2, #3]
	POP {R4} 

Hex_checkW_4:
	TST A1, #0x00000010
	BNE Write_Hex_4
	B Hex_checkW_5

Write_Hex_4:
	CMP A2, #0
	PUSH {R5} 
	MOVEQ R5, #0x00003F // R4 -> R5 to keep 3-0 and 5-4 separate
	CMP A2, #1
	MOVEQ R5, #0x000006
	CMP A2, #2
	MOVEQ R5, #0x00005B
	CMP A2, #3
	MOVEQ R5, #0x00004F	
	CMP A2, #4
	MOVEQ R5,#0x000066
	CMP A2, #5
	MOVEQ R5, #0x00006D
	CMP A2, #6
	MOVEQ R5, #0x00007D
	CMP A2, #7
	MOVEQ R5, #0x000007
	CMP A2, #8
	MOVEQ R5, #0x00007F
	CMP A2, #9
	MOVEQ R5, #0x0000EF
	CMP A2, #10
	MOVEQ R5, #0x000077
	CMP A2, #11
	MOVEQ R5, #0x00007C
	CMP A2, #12
	MOVEQ R5, #0x000039
	CMP A2, #13
	MOVEQ R5, #0x00005E
	CMP A2, #14
	MOVEQ R5, #0x000079
	CMP A2, #15
	MOVEQ R5, #0x000071
	
	STRB R5, [R3]
	POP {R5} 

Hex_checkW_5:
	TST A1, #0x00000020
	BNE Write_Hex_5
	BX LR

Write_Hex_5:
	CMP A2, #0
	PUSH {R5} 
	MOVEQ R5, #0x00003F
	CMP A2, #1
	MOVEQ R5, #0x000006
	CMP A2, #2
	MOVEQ R5, #0x00005B
	CMP A2, #3
	MOVEQ R5, #0x00004F	
	CMP A2, #4
	MOVEQ R5,#0x000066
	CMP A2, #5
	MOVEQ R5, #0x00006D
	CMP A2, #6
	MOVEQ R5, #0x00007D
	CMP A2, #7
	MOVEQ R5, #0x000007
	CMP A2, #8
	MOVEQ R5, #0x00007F
	CMP A2, #9
	MOVEQ R5, #0x0000EF
	CMP A2, #10
	MOVEQ R5, #0x000077
	CMP A2, #11
	MOVEQ R5, #0x00007C
	CMP A2, #12
	MOVEQ R5, #0x000039
	CMP A2, #13
	MOVEQ R5, #0x00005E
	CMP A2, #14
	MOVEQ R5, #0x000079
	CMP A2, #15
	MOVEQ R5, #0x000071
	
	STRB R5, [R3, #1]
	POP {R5} 
	
	BX LR

// A1 = HEX displays, A2 = int value between 0-15
// 0 -> 00111111 -> 3F
// 1 -> 00000110 -> 06
// 2 -> 01011011 -> 5B
// 3 = 4F, 4 = 66, 5 = 6D, 6 = 7D, 8 = 7F, 9 = EF
// A = 77, B = 7C, C = 39, D = 5E, E = 79, F = 71
	

.equ PB, 0xFF200050
read_PB_data_ASM: 
    LDR R1, =PB
    LDR R0, [R1] 
    BX  LR


PB_data_is_pressed_ASM: 
	LDR R2, =PB // receives pushbutton index address
	LDR R1, [R2] // gets actual value in memory
	
	// pass in the corresponding pushbutton in R0
	TST R0, R1 // NE, Z = 0, asserted
	MOVNE R0, #1 // return this if corresponding button is pressed
	BXNE LR
	
	MOV R0, #0
	BX LR


.equ PB_edgecp, 0xFF20005C
read_PB_edgecp_ASM: 
	LDR R1, =PB_edgecp
	LDR R0, [R1]
	BX LR


PB_edgecp_is_pressed_ASM: 
	LDR R2, =PB_edgecp
	LDR R1, [R2]
	
	TST R3, R1
	MOVNE R0, #1 // return if pushbutton pressed and released
	BXNE LR
	
	MOV R0, #0
	BX LR
	

PB_clear_edgecp_ASM: 
	LDR R1, =PB_edgecp
	PUSH {LR} 
	BL read_PB_edgecp_ASM
	POP {LR} 
	// register value stored in R0
	STR R0, [R1] 
	BX LR


.equ PB_interrupt, 0xFF200058
enable_PB_INT_ASM: 
	// R0 having pushbutton indices
	LDR R1, =PB_interrupt
	LDR R2, [R1]
    ORR R2, R2, R0 // turn on any that corresponds to R0
    STR R2, [R1] 
    BX LR


disable_PB_INT_ASM: 
	LDR R1, =PB_interrupt
	LDR R2, [R1]
    BIC R2, R2, R0 // anything in R0, invert to be 0, AND to be 0
    STR R2, [R1] 
    BX LR
	
	
display_start: 
	// needs 0000 from the right, but also clear the first two
	MOV A1, #0x30 // first two displays
	PUSH {LR}
	BL HEX_clear_ASM
	POP {LR}
	MOV A1, #0x0000000F
	MOV A2, #0 
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR} 
	BX LR
	

overflow:
	// loop through each display and write the appropriate letter
	LDR R0, =SSD_H3_0
	LDR R1, =SSD_H5_4
	// 3-0 is rFlo part, 5-4 is ou part
	// o = 5C, L = 38, and so on

	LDR R2, =#0x5071385C
	STR R2, [R0] 
	LDR R2, =#0x5C1C
	STR R2, [R1] 
	
	PUSH {LR} 
	BL read_slider_switches_ASM
	BL write_LEDs_ASM
	POP {LR} 
	
	PUSH {LR} 
	BL read_PB_edgecp_ASM
	POP {LR} 
	CMP R0, #0
	BEQ overflow
	
	MOV R3, #0x00000001
	PUSH {LR} 
	BL PB_edgecp_is_pressed_ASM
	POP {LR} 
	CMP R0, #1 // clear
	BEQ _start
	
	B overflow
	
	BX LR

_start:
	//LDR R1, =SSD_H3_0
	//PUSH {R5}
	//ADD R5, R5,	#0x0000007F
	//STR R5, [R1]
	//POP {R5}
	
	//mov A1, #0x0000000C
	//BL  HEX_clear_ASM 
	
	
	//MOV A1, #0xFFFFFFFF
	//MOV A1, #0x00000001
	//BL HEX_flood_ASM
	//BL HEX_clear_ASM
	
	//MOV A1, #0x00000001
	//MOV A2, #9
	//BL HEX_write_ASM
	
	// BL PB_clear_edgecp_ASM
	

	// based on result of indices, do the operations
	// remember the + / - signs if the result isn't 0
	// if out of bounds, say overflow and keep it at overflow until clear
	// otherwise continue to loop the operations, display r op n
	// if cleared, go back to start
	
	// BL overflow
	
	BL display_start
	MOV R6, #0 // R6 will be uniquely r
	MOV R9, #0 // 0 if in first iteration to do n operation m
	BL PB_clear_edgecp_ASM
	
waiting:
	PUSH {LR}
	BL read_slider_switches_ASM
	POP {LR} 
	AND R7, A1, #0x0F // only gets the LSBs
	LSR R8, A1, #4 // R8 = A1 >> 4, so the next 4 LSBs
	AND R8, R8, #0x0F // ignore anything in other SWs
	
	PUSH {LR}
	BL write_LEDs_ASM
	
	BL read_PB_edgecp_ASM
	POP {LR} 
	CMP R0, #0 // if a pushbutton has been released it wouldn't be 0
	BEQ waiting

	// pushbutton has been released
	// should reset the edgecapture register here? 
	MOV R3, #0x00000001
	PUSH {LR} 
	BL PB_edgecp_is_pressed_ASM
	POP {LR} 
	CMP R0, #1 // clear
	BEQ _start
	
	MOV R3, #0x00000002
	PUSH {LR}
	BL PB_edgecp_is_pressed_ASM
	POP {LR} 
	CMP R0, #1 // subtraction
	BEQ sub
	
	MOV R3, #0x00000004
	PUSH {LR}
	BL PB_edgecp_is_pressed_ASM
	POP {LR} 
	CMP R0, #1 // addition
	BEQ add

sub: 
	CMP R9, #0
	BEQ sub_1
	B sub_2

add: 
	CMP R9, #0
	BEQ add_1
	B add_2

sub_1:
	// n - m
	MOV R9, #1
	SUB R6, R7, R8
	B display_r

add_1: 
	MOV R9, #1
	ADD R6, R7, R8
	B display_r

sub_2:
	// r - n instead
	SUB R6, R6, R7
	B display_r

add_2: 
	ADD R6, R6, R7
	B display_r

display_r:
	// also done with calculations so prob do this
	PUSH {LR} 
	BL PB_clear_edgecp_ASM
	POP {LR} 
	// R6 contains r
	CMP R6, #0x00000063
	BGT overflow
	CMP R6, #0xFFFFFF9D
	BLT overflow

	CMP R6, #0 
	PUSH {LR} 
	// does this even work since it's not a BL
	BLT neg_sign
	BGT pos_sign
	//BEQ display_start // takes care of signs and if = 0000
	B display_zeros
	// POP {LR} 

neg_sign: 
	// takes the current display and add the neg sign to the front
	
	LDR R0, =SSD_H5_4
	LDR R1, =0x4040
	STR R1, [R0]
	
	MVN R10, R6
	ADD R10, R10, #1 // R10 will be absolute value of the r value
	
	POP {LR}
	
	B binary_to_decimal
	

pos_sign:	
	LDR R0, =SSD_H5_4
	LDR R1, =0x4670
	STR R1, [R0]
	
	MOV R10, R6
	
	POP {LR} 
	
	B binary_to_decimal

display_zeros: 
	MOV A1, #0x30
	PUSH {LR}
	BL HEX_clear_ASM
	POP {LR}
	MOV A1, #0x0000000F
	MOV A2, #0 
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR} 
	
	B waiting
	
	POP {LR} 

binary_to_decimal:
	// R10 is absolute value in binary to be displayed
	// since absolute value range from 0 to 99, always at least 2 zeroes in a 4 digit display
	
	// Hex 3 = 0x00000008, Hex 2 = 0x00000004
	// A1 = hex indices, A2 = digit to be written
	MOV A1, #0x00000008
	MOV A2, #0
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	MOV A1, #0x00000004
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR} 
	
	// now to get tens and ones place
	// AND R10, R10, #0x3 // similar to AND #0x0F, 2 LSBs? 
	// maybe don't need it at all if made sure it's in the right range
	
	MOV A1, #0x00000002
	MOV A2, #0 
	// maybe decrement R10 by 10 until reach the 1's place
	// that's how many "10s" there are

tens_place: 
	CMP R10, #10
	BLT writing_ten
	SUB R10, R10, #10
	ADD A2, A2, #1
	B tens_place

writing_ten:
	// A1 should still have 0x2, A2 has how many loops down to one's place
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}

ones_place: 
	MOV A1, #0x00000001 
	// oh wait after subtracting 10s, it should just be 1 digit
	MOV A2, R10
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR} 
	
	// 6 -> +/- 06
	// 10 -> +/- 10 

	B waiting
	
	
	//B _end
	
//_end:
	//B _end