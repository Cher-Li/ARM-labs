#include <stdint.h>
	
// Reads a byte from a specific memory address
uint8_t read_byte(uint32_t address) {
	uint8_t result; 
	__asm__ __volatile__(
        "ldrb %0, [%1]"
        :"=r"(result) // %0, output
        :"r"(address) // input, %1
    );
	return result; 
}

// Writes a byte to a specific memory address
void write_byte(uint32_t address, uint8_t value) {
	__asm__ __volatile__(
        "strb %0, [%1]"
		: // error of lacking '=' otherwise
        :"r"(value), "r" (address) // no output value in this one
		// I'm guessing value then address b/c %0 then %1
    );
}

// Reads a halfword (2 bytes) from a specific memory address
uint16_t read_halfword(uint32_t address) {
	uint16_t result; 
	__asm__ __volatile__(
        "ldrh %0, [%1]"
        :"=r"(result) 
        :"r"(address) 
    );
	return result; // same format as read_byte just halfword
}

// Writes a halfword (2 bytes) to a specific memory address
void write_halfword(uint32_t address, uint16_t value) {
	__asm__ __volatile__(
        "strh %0, [%1]"
		: 
        :"r"(value), "r" (address)
    );
}

// Reads a word (4 bytes) from a specific memory address
uint32_t read_word(uint32_t address) {
	uint32_t result; 
	__asm__ __volatile__(
        "ldr %0, [%1]"
        :"=r"(result) 
        :"r"(address) 
    );
	return result; 
}

// Writes a word (4 bytes) to a specific memory address
void write_word(uint32_t address, uint32_t value) {
	__asm__ __volatile__(
        "str %0, [%1]"
		: 
        :"r"(value), "r" (address)
    );
}

int foo(int x){
    int y = 0;
    __asm__ __volatile__(
        "add %0, %1, %2"     // %0, %1, and %2 are linked to output and input operands. y = x + 10.
        :"=r"(y)             // Output operands: %0
        :"r"(x), "r"(10)     // Input operands: %1, %2
        :"r1"                // Clobbers
    );
    return y;
}

int main() {
    int x = 0;  
    printf("Before inline assembly: x = %d\n", x);
    __asm__ __volatile__(
        "mov r0, %0\n\t"    // \n\t is newline in assembly and required for each line.
        "bl foo\n\t"        // Call function foo. Note that it automatically uses r0 as the argument registers.
        "mov %0, r0"        // r0 is used as the result registers.
        :"+r"(x)            // output operands: %0 ('+' instead of '=' here means it can be also used as input.)
    );
    printf("Final result: x = %d\n", x);
    return x;
}   