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

// From task 0 copy all functions

void VGA_draw_point(int x, int y, short c) {
	short *value = 0xc8000000 | (y << 10) | (x << 1); 
	*value = c; 
}

void VGA_write_char(int x, int y, char c) {
	// From task 1
	if (x < 0 | x >= 80 | y < 0 | y >= 60) {
		return; // validation
	}
	char *value = 0xc9000000 | (y << 7) | x; 
	*value = c; 
}

void VGA_clear_pixelbuff() {
	// From task 1
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			VGA_draw_point(x, y, 0); 
		}
	}
}

 void VGA_clear_charbuff() {
	// From task 1	
	 for (int x = 0; x < 80; x++) {
		for (int y = 0; y < 60; y++) {
			VGA_write_char(x, y, 0); 
		}
	}
}

int read_PS2_data(char *data) {
	int value = *((volatile int *)0xff200100); // keyboard input
	int RVALID = (value >> 15) & 0x1; 
	
	if (RVALID) {
		*data = (char)(value & 0xFF); 
		// "the low eight bits correspond to a byte of keyboard data" 
		
		return 1; 
	}
	
	return 0; 
}

void write_hex_digit(unsigned int x,unsigned int y, char c) {
    if (c > 9) {
        c += 55;
    } else {
        c += 48;
    }
    c &= 255;
    VGA_write_char(x,y,c);
}
void write_byte_kbrd(unsigned int x,unsigned int y, unsigned int c) {
   char lower=c>>4 &0x0F;
   write_hex_digit(x,y,lower);
   char upper=c&0x0F;
   write_hex_digit(x+1,y,upper);
   return;
}

void input_loop_fun() {
    unsigned int x = 0;
    unsigned int y = 0;
	VGA_clear_pixelbuff();
    VGA_clear_charbuff();

    while (y<=59) {
    
			char data;
            char r2 = read_PS2_data(&data);

            if (r2 != 0) {  // Check if data is available

				write_byte_kbrd(x,y,data); 
                x += 3;
                if (x > 79) {
                    y++;
                    x = 0;
                }

                if (y > 59) {  // Check if loop should exit
                    return;  // End of input loop
                }
            }
    }
}


int main() {
	input_loop_fun();
	return 0;
}
