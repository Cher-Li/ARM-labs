.section .vectors, "ax"
B _start            // reset vector
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0             // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

PB_int_flag:
.word 0x0

tim_int_flag:
    .word 0x0
	
// from the user manual shift LED example
//PATTERN:
//.byte       0x79396D79004F5B660079396D79004F5B6D00395C5E790039777179
// the full message with SW0-3 in hex, 00 being spaces
// have a pointer pointing to the specific starting letter based on switches
// shift forward or back
// maybe a separate constant for length of message so can reset? 
KEY_DIR:
.word       1 // default is right to left

TEST_PATTERN:
.byte 0x5C, 0x71, 0x71, 0x06, 0x39, 0x79, 0x00, 0x00

PAUSE: 
.word 0 // default is off
SPEED: 
.word 60000000
//.word 100000000
//.word 200000000
// 0.3 / 0.5 / 1, default is 0.3, multiply by freq	

.text
.global _start

_start:
	MOV R0, #0xF // 1111 aka all 4 pushbuttons
	BL enable_PB_INT_ASM // R0 should have pushbutton indices
	
	// A1 is load value, A2 is config
	LDR A1, =SPEED
	LDR A1, [A1] 
	MOV A2, #0x7 // ...111
	BL ARM_TIM_config_ASM // writes 1 if interrupt received
	
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR CPSR_c, R1           // change to IRQ mode
    LDR SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 on-chip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR CPSR, R1             // change to supervisor mode
    LDR SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL  CONFIG_GIC           // configure the ARM GIC
    // NOTE: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, 
    // use ARM_TIM_config_ASM subroutine
    LDR R0, =0xFF200050      // pushbutton KEY base address
    MOV R1, #0xF             // set interrupt mask bits
    STR R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR CPSR_c, R0
IDLE:	
	LDR R8, =TEST_PATTERN // OFF1CE, pointer to the specific character
	// changed to R8 so wouldn't overwrite this
	LDR R7, =KEY_DIR
	LDR R7, [R7] 
	ADD R5, R8, #6 // know where to loop back
	
displaying: 
	MOV A1, #0x7
    BL write_LEDs_ASM
	
	LDR R3, =SSD_H3_0
	LDR R4, =SSD_H5_4
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN // reset if reached end, otherwise continue
	LDRB R2, [R8], #1
	STRB R2, [R4, #1] // leftmost hex display
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	LDRB R2, [R8], #1
	STRB R2, [R4] 
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	LDRB R2, [R8], #1
	STRB R2, [R3, #3] 
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	LDRB R2, [R8], #1
	STRB R2, [R3, #2] 
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	LDRB R2, [R8], #1
	STRB R2, [R3, #1] 
	
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	LDRB R2, [R8], #1
	STRB R2, [R3] // rightmost hex display
	
wait_for_int:
	LDR R0, =PB_int_flag
	LDR R9, [R0] // actual value of the flags
	MOV R1, #0
	STR R1, [R0] // reset flag
	
	LDR R11, =SPEED
	LDR R11, [R11] // actual load value
	MOV R0, #0x1 // PB0 
	TST R0, R9
	BNE decrease_speed
	
	MOV R0, #0x2 // PB1
	TST R0, R9
	BNE increase_speed
	
continuing: 
	// read speed and reset LEDs? 
	LDR R1, =60000000 // 0.3, 3 leds
	CMP R11, R1
	MOVEQ A1, #0x7
	LDR R1, =100000000 // 0.5, 5 leds
	CMP R11, R1
	MOVEQ A1, #0x1F
	LDR R1, =200000000 // 1, 10 leds
	CMP R11, R1
	LDREQ A1, =0x3FF
	BL write_LEDs_ASM

	MOV R0, #0x4 // PB2
	TST R0, R9
	EORNE R7, R7, #1 // R7 is direction
	
	MOV R0, #0x8 // PB3
	TST R0, R9
	EORNE R10, R10, #1
	CMP R10, #1 // pause off = 0, pause on = 1
	BEQ paused
	
	LDR R6, =tim_int_flag
	LDR R6, [R6]
	CMP R6, #1
	
	BNE wait_for_int
	
	LDR R6, =tim_int_flag
	MOV R0, #0
	STR R0, [R6] 
	
	BL ARM_TIM_clear_INT_ASM
	
	CMP R7, #1
	
	// 1 is default, right to left
	BEQ shift_left
	B shift_right

increase_speed:
	LDR R0, =60000000
	CMP R11, R0
	BEQ continuing

	LDR R0, =100000000 
	CMP R11, R0 // 0.5, so go to 0.3
	LDREQ R11, =SPEED
	LDREQ R0, =60000000
	STREQ R0, [R11] 
	BEQ redo_speed
	
	LDR R0, =200000000
	CMP R11, R0 // 1, go to 0.5
	LDREQ R11, =SPEED
	LDREQ R0, =100000000
	STREQ R0, [R11] 
	BEQ redo_speed
	
decrease_speed: 
	LDR R0, =200000000
	CMP R11, R0
	BEQ continuing
	
	LDR R0, =60000000
	CMP R11, R0 // 0.3, go up to 0.5
	LDREQ R11, =SPEED
	LDREQ R0, =100000000
	STREQ R0, [R11] 
	BEQ redo_speed
	
	LDR R0, =100000000
	CMP R11, R0 // 0.5, go up to 1
	LDREQ R11, =SPEED
	LDREQ R0, =200000000
	STREQ R0, [R11] 
	BEQ redo_speed

redo_speed: 
// R11 has the new speed, also possibly LED stuff here
	LDR A1, =SPEED
	LDR A1, [A1] 
	MOV A2, #0x7 // ...111
	BL ARM_TIM_config_ASM
	
	B continuing

paused: 
	MOV A1, #0
	BL write_LEDs_ASM

	LDR R0, =PB_int_flag
	LDR R9, [R0] // actual value of the flags
	MOV R1, #0
	STR R1, [R0] // reset flag
	
	// won't change the actual display but PB0-2 still active
	MOV R0, #0x1 // PB0 
	TST R0, R9
	BLNE paused_decrease
	// BNE decrease_speed
	
	MOV R0, #0x2 // PB1
	TST R0, R9
	BLNE paused_increase
	// BNE increase_speed
	
	MOV R0, #0x4 // PB2
	TST R0, R9
	EORNE R7, R7, #1 // R7 is direction
	// code logic that the effects will take place after unpaused
	
	
	MOV R1, #0x8 // PB3
	TST R1, R9
	EORNE R10, R10, #1
	CMP R10, #0
	BEQ wait_for_int // unpaused
	B paused
	// also still need to update changes in PB0-2

paused_decrease:
	LDR R0, =200000000
	CMP R11, R0
	BXEQ LR 
	
	LDR R0, =60000000
	CMP R11, R0 // 0.3, go up to 0.5
	LDREQ R11, =SPEED
	LDREQ R0, =100000000
	STREQ R0, [R11] 
	PUSH {LR} 
	//BEQ redo_speed
	BLEQ paused_redo
	POP {LR} 
	
	LDR R0, =100000000
	CMP R11, R0 // 0.5, go up to 1
	LDREQ R11, =SPEED
	LDREQ R0, =200000000
	STREQ R0, [R11] 
	//BEQ redo_speed
	PUSH {LR} 
	BLEQ paused_redo
	POP {LR} 

	BX LR

paused_increase:
	LDR R0, =60000000
	CMP R11, R0
	BXEQ LR

	LDR R0, =100000000 
	CMP R11, R0 // 0.5, so go to 0.3
	LDREQ R11, =SPEED
	LDREQ R0, =60000000
	STREQ R0, [R11] 
	PUSH {LR} 
	BLEQ paused_redo
	POP {LR} 
	
	LDR R0, =200000000
	CMP R11, R0 // 1, go to 0.5
	LDREQ R11, =SPEED
	LDREQ R0, =100000000
	STREQ R0, [R11] 
	PUSH {LR} 
	BLEQ paused_redo
	POP {LR} 
	
	BX LR

paused_redo: 
// R11 has the new speed, also possibly LED stuff here
	LDR A1, =SPEED
	LDR A1, [A1] 
	MOV A2, #0x7 // ...111
	PUSH {LR} 
	BL ARM_TIM_config_ASM
	POP {LR}
	
	BX LR

shift_left: 
	// *need the following two lines*
	CMP R8, R5
	LDREQ R8, =TEST_PATTERN
	ADD R8, R8, #1
	B displaying

shift_right:
	LDR R0, =TEST_PATTERN
	CMP R8, R0 // at the start, so move to the end
	ADDEQ R8, R8, #6
	
	SUB R8, R8, #1
	B displaying

	// start w/ initial speed and pattern being 0.3 sec and OFF1CE
	// direction is right to left
	// use tim_int_flag to check timer for when it needs to shift
	
	// make sure it wraps around
	
	// use PB_int_flag for pushbuttons
	// check which one it is
	
	// PB3: flips the "pause" bit, if paused it doesn't shift
	
	// PB2: flips "direction" bit
	
	// PB1 increases speed, PB0 decreases speed, rates of 1/0.5/0.3
	// Base LED on the specific rate
	
	// need polling for switches
	// ECSE 324, ECSE 325, CODE, CAFE corresponding to SW 0-3
	
	// figure out concat w/ spaces after

    B IDLE // This is where you write your main program task(s)

CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* NOTE: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	
	// repeating the previous 3 lines
	MOV R0, #29
	MOV R1, #1
	BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}



/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
/*--- Undefined instructions --------------------------------------*/
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ----------------------------------------*/
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------*/
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------*/
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------*/
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR
/* NOTE: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the DE1-SoC Computer Manual
   on page 46 */
Checking:
	CMP R5, #73
	BEQ Pushbutton_check
	
	CMP R5, #29 // ID for timer is 29
	BEQ Timer_check
	// basically need to check which one, unexpected otherwise, ISR then exit
UNEXPECTED:
    B UNEXPECTED      // if not recognized, stop here
Pushbutton_check:
    BL KEY_ISR
	B EXIT_IRQ
Timer_check:
	BL ARM_TIM_ISR
	B EXIT_IRQ
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------*/
SERVICE_FIQ:
    B SERVICE_FIQ
	
KEY_ISR:
	LDR R0, =0xFF20005C
	LDR R1, [R0] // value of the edgecap
	LDR R2, =PB_int_flag
	STR R1, [R2]
	
	MOV R3, #0xFFFFFFFF
	STR R3, [R0] 
	
	BX LR

/*
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
    LDR R0, =0xFF200020    // base address of HEX display
CHECK_KEY0:
    MOV R3, #0x1
    ANDS R3, R3, R1        // check for KEY0
    BEQ CHECK_KEY1
    MOV R2, #0b00111111
    STR R2, [R0]           // display "0"
    B END_KEY_ISR
CHECK_KEY1:
    MOV R3, #0x2
    ANDS R3, R3, R1        // check for KEY1
    BEQ CHECK_KEY2
    MOV R2, #0b00000110
    STR R2, [R0]           // display "1"
    B END_KEY_ISR
CHECK_KEY2:
    MOV R3, #0x4
    ANDS R3, R3, R1        // check for KEY2
    BEQ IS_KEY3
    MOV R2, #0b01011011
    STR R2, [R0]           // display "2"
    B END_KEY_ISR
IS_KEY3:
    MOV R2, #0b01001111
    STR R2, [R0]           // display "3"
END_KEY_ISR:
    BX LR
*/

ARM_TIM_ISR: 	
	LDR R0, =tim_int_flag
	// assuming calling this func when interrupt is received
	
	MOV R1, #1
	STR R1, [R0] 

	// The F bit can be cleared to 0 by 
	// writing writing a 1 into the Interrupt status register
	
	LDR R0, =0xFFFEC60C
	STR R1, [R0] 
	
	BX LR 

.equ LOAD_REG, 0xFFFEC600
.equ CONTROL_REG, 0xFFFEC608
.equ INT_STAT, 0xFFFEC60C
.equ COUNTER, 0xFFFEC604

.equ PB_interrupt, 0xFF200058
enable_PB_INT_ASM: 
	// R0 having pushbutton indices
	LDR R1, =PB_interrupt
	LDR R2, [R1]
    ORR R2, R2, R0 // turn on any that corresponds to R0
    STR R2, [R1] 
    BX LR
	

ARM_TIM_config_ASM: 
	LDR A3, =LOAD_REG
	STR A1, [A3]
	
	LDR A3, =CONTROL_REG
	STR A2, [A3] 
	
	BX LR 


ARM_TIM_read_INT_ASM: 
	LDR R1, =INT_STAT
	LDR R0, [R1] 
	
	BX LR

ARM_TIM_clear_INT_ASM: 
	LDR R1, =INT_STAT
	MOV R0, #1
	STR R0, [R1] 

	BX LR

// from task 1, use for displaying speed rate
// 1: all LEDS on
// 0.5: 5 LEDS on
// 0.3: 3 LEDS on
.equ LED_ADDR, 0xFF200000
write_LEDs_ASM:
    LDR A2, =LED_ADDR    // load the address of the LEDs' state
    STR A1, [A2]         // update LED state with the contents of A1
    BX  LR


.equ SSD_H3_0, 0xFF200020
.equ SSD_H5_4, 0xFF200030

/*
HEX_write_ASM: 
	LDR R0, =SSD_H3_0 // A3 will be digit
	MOV R4, #0 // 3-0
	// always writing to HEX0
	
Write_Hex_0:
	// need to find out what value A3 is
	CMP A3, #0 // if want to write 0 to Hex 0 this should be equal
	PUSH {R4} 
	MOVEQ R4, #0x00003F
	CMP A3, #1
	MOVEQ R4, #0x000006
	CMP A3, #2
	MOVEQ R4, #0x00005B
	CMP A3, #3
	MOVEQ R4, #0x00004F	
	CMP A3, #4
	MOVEQ R4,#0x000066
	CMP A3, #5
	MOVEQ R4, #0x00006D
	CMP A3, #6
	MOVEQ R4, #0x00007D
	CMP A3, #7
	MOVEQ R4, #0x000007
	CMP A3, #8
	MOVEQ R4, #0x00007F
	CMP A3, #9
	MOVEQ R4, #0x0000EF
	CMP A3, #10
	MOVEQ R4, #0x000077
	CMP A3, #11
	MOVEQ R4, #0x00007C
	CMP A3, #12
	MOVEQ R4, #0x000039
	CMP A3, #13
	MOVEQ R4, #0x00005E
	CMP A3, #14
	MOVEQ R4, #0x000079
	CMP A3, #15
	MOVEQ R4, #0x000071
	
	STRB R4, [R0]
	POP {R4} 
	
	BX LR
*/

/*
_start:
	// increment every 0.25 seconds, so that should be inital value given freq
	// 50000000
	
	LDR A1, =0x2FAF080
	//LDR A1, =0x1
	// config: E = 1 to turn timer on, A = 1 to continue the loop
	// I = 0 since testing read_INT_ASM subroutine
	MOV A2, #0x3 // 0000...0011

	BL ARM_TIM_config_ASM
	MOV A3, #0

loop: 
	BL ARM_TIM_read_INT_ASM // F asserted when timer reaches 0
	CMP R0, #1
	BNE loop
	
	BL ARM_TIM_clear_INT_ASM
	
	ADD A3, A3, #1
	CMP A3, #16
	BNE display
	
	MOV A3, #0 // reached 16 so need to reset

display: 
	// A3 still the counter so just call hex write when F = 1
	BL HEX_write_ASM
	
	B loop
*/