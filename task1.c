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
void VGA_clear_pixelbuff() {
	// all valid mem locations: 0xC8000000 up to x = 319, y = 239
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			VGA_draw_point(x, y, 0); 
		}
	}
}

void VGA_draw_point(int x, int y, short c) {
	short *value = 0xc8000000 | (y << 10) | (x << 1); 
	*value = c; 
}

void VGA_write_char(int x, int y, char c) {
	if (x < 0 | x >= 80 | y < 0 | y >= 60) {
		return; // validation
	}
	char *value = 0xc9000000 | (y << 7) | x; 
	*value = c; 
}

void VGA_clear_charbuff() {
	// valid locations: width of 80 characters and a height of 60 characters
	for (int x = 0; x < 80; x++) {
		for (int y = 0; y < 60; y++) {
			VGA_write_char(x, y, 0); 
		}
	}
}

void draw_test_screen ()
{
    VGA_clear_pixelbuff();
    VGA_clear_charbuff();
	int SCREEN_HEIGHT=240;
	int SCREEN_WIDTH=320;
   for (int y = 0; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            // Calculate color components to create a smooth gradient
            unsigned int red = (x * 31 / SCREEN_WIDTH) << 11;      // Horizontal red gradient
            unsigned int green = (y * 63 / SCREEN_HEIGHT) << 5;    // Vertical green gradient
            unsigned int blue = ((x + y) * 31 / (SCREEN_WIDTH + SCREEN_HEIGHT));  // Diagonal blue gradient

            // Combine red, green, and blue into a 16-bit color
            unsigned int color = red | green | blue;

            // Draw the pixel at (x, y) with the calculated color
            VGA_draw_point(x, y, color);
        }
    }


    const char *message = "Hello World!";
    int x = 20;
    int y = 5;
    
    for (int i = 0; message[i] != '\0'; i++) {
        VGA_write_char(x++, y, message[i]);
    }
}

int main() {
	draw_test_screen();
	return 0;
}