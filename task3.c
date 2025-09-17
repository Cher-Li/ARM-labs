// please use left and right arrow keys

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
    if (x < 0 || x >= 320 || y < 0 || y >= 240) {
        return; // revised this from task 0 to avoid out of bounds errors
    }
    short *value = 0xC8000000 | (y << 10) | (x << 1);
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

void VGA_fill() {
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			VGA_draw_point(x, y, 1234); 
		}
	}
}

int read_PS2_data(char *data) {
	int value = *((volatile int *)0xff200100); // keyboard input
	int RVALID = (value >> 15) & 0x1; 
	
	if (RVALID) {
		*data = (char)(value); 
		
		return 1; 
	}
	
	return 0; 
}

void draw_character(int x) {
	// x = center coord of the character, hard code color and size
	
	if (x == 160 || x == 96 || x == 32 || x == 224 || x == 288) {
		int start = x - 32; // columns are 64 so half of that
	
		for (int row = 0; row < 48; row++) {
			for (int col = 0; col < 64; col++) {
				VGA_draw_point(start + col, 192 + row, 0xFFFF); 
			}
		}	
	}
	
	return; 
	
}

void erase_character(int x) {
	int start = x - 32; 
	
	for (int row = 0; row < 48; row++) {
		for (int col = 0; col < 64; col++) {
			VGA_draw_point(start + col, 192 + row, 1234); 
		}
	}	
}

void draw_object(int x, int y) {
	int start_x = x - 32; 
	int start_y = y - 24; 
	
	for (int row = 0; row < 48; row++) {
		for (int col = 0; col < 64; col++) {
			VGA_draw_point(start_x + col, start_y + row, 0000); 
		}
	}
}

void erase_object(int x, int y) {
	int start_x = x - 32; 
	int start_y = y - 24; 
	
	for (int row = 0; row < 48; row++) {
		for (int col = 0; col < 64; col++) {
			VGA_draw_point(start_x + col, start_y + row, 1234); 
		}
	}
}

// ----------------------- //
// Psuedo Number Generator //
// ----------------------- //

unsigned int seed = 12345;  // You can set this to any starting value

// Function to generate a pseudo-random number
unsigned int pseudo_random() {
    // LCG parameters (from Numerical Recipes)
    seed = (1103515245 * seed + 12345) & 0x7fffffff;
    return seed;
}

// Function to get a pseudo-random number within a specific range [min, max]
unsigned int random_in_range(int min, int max) {
    return (pseudo_random() % (max - min + 1)) + min;
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

struct Player {
	int x_coord; 
}; 
struct Player character; 

int position; 
int score; 
void init_game() {
	VGA_fill(); 
	position = 160; 
	character.x_coord = 160; 
	draw_character(position); 
	score = 0; 
}

int min_speed = 1; 
int max_speed = 3; 

struct FallingObj { // idea based off Max Wu-Blouin on ed
	// int index; 
	int column; 
	int x, y; // middle of the obj
	int speed; 
	int counter; // inspired by Justin Jradi
	int active; 
}; 

// struct FallingObj all_objs[5] = { NULL, NULL, NULL, NULL, NULL }; 
struct FallingObj all_objs[5] = {0}; 

void spawn_object() {
	int column; 
	
	int all_active = 1; 
	for (int i = 0; i < 5; i++) {
		if (!all_objs[i].active) {
			all_active = 0; 
			break; 
		}
	}
	
	if (all_active) {
		return; 
	} else {
		while(1) {
			column = random_in_range(0, 4); 
			if (!(all_objs[column].active)) {
				break; 
			}
		}
	
		int speed = random_in_range(min_speed, max_speed); 
		int start_x = column * 64 + 32; 
		struct FallingObj obj = {column, start_x, 24, speed, 0, 1}; 
		all_objs[column] = obj; 

		draw_object(start_x, 24); 
	}
	
}

void update_character_position() {
	char data = 0; 
	if (read_PS2_data(&data)) {
		if (data == 0xe0) {
			read_PS2_data(&data); // get the extended code
		}
		
		// could test if x_coord match leftmost column and keyboard = left? 
		// might be too many nested ifs tho
		erase_character(character.x_coord); 
		
		if (data == 0x6b && character.x_coord != 32) {
            character.x_coord -= 32;
        } else if (data == 0x74 && character.x_coord != 288) {
            character.x_coord += 32;
        }
		
		draw_character(character.x_coord); 
	}
}

void update_objects() {
	for (int i = 0; i < 5; i++) {
		if (all_objs[i].active) {
			all_objs[i].counter += all_objs[i].speed; 
			if (all_objs[i].counter >= 100000) {
				all_objs[i].counter = 0;
				erase_object(all_objs[i].x, all_objs[i].y); 
				all_objs[i].y += 48; 
				if (all_objs[i].y == 216) {
					update_objects_bottom(i); 
				}
				
				draw_object(all_objs[i].x, all_objs[i].y); 
			}
		}
	}
	return; 
}

void update_objects_bottom(int index) {
    struct FallingObj *obj = &all_objs[index]; 

    if (check_collision(*obj)) {
        score++; 
        draw_character(character.x_coord); 
        obj -> active = 0; 
    } else {
        obj -> active = 0; 
        game_over(score); 
    }
}


int check_collision(struct FallingObj obj) {
	return (character.x_coord == obj.x); 
}

void game_over(int score) {
	VGA_clear_pixelbuff(); 
	VGA_write_char(2, 2, 'G'); 
	VGA_write_char(3, 2, 'A'); 
	VGA_write_char(4, 2, 'M'); 
	VGA_write_char(5, 2, 'E'); 
	VGA_write_char(6, 2, ' '); 
	VGA_write_char(7, 2, 'O'); 
	VGA_write_char(8, 2, 'V'); 
	VGA_write_char(9, 2, 'E'); 
	VGA_write_char(10, 2, 'R'); 
	
	VGA_write_char(2, 5, 'S'); 
	VGA_write_char(3, 5, 'C'); 
	VGA_write_char(4, 5, 'O'); 
	VGA_write_char(5, 5, 'R'); 
	VGA_write_char(6, 5, 'E'); 
	VGA_write_char(7, 5, ':'); 
	VGA_write_char(8, 5, ' '); 
	
	if (score < 10) { 
		VGA_write_char(9, 5, score + '0'); // rework this if score >= 10
	} else {
		score = score % 10; 
		VGA_write_char(9, 5, '1');
		VGA_write_char(10, 5, score + '0');
	}
	
	
	char data;
	while(1) {
		if (read_PS2_data(&data)) {
			memset(all_objs, 0, sizeof(all_objs));
			game_loop(); 
		}
	}
}

/*
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

*/

volatile int * timer = (int*) 0xFFFEC600; 
void timer_setup() {
	// based on code from DE1-SoC Computer manual
	int counter = 800000000;
	write_word(timer, counter); 
	write_word(timer + 2, 0b011); 

	//volatile int * MPcore_private_timer_ptr = (int *)MPCORE_PRIV_TIMER;
	//int counter = 200000000;
	//*(MPcore_private_timer_ptr) = counter; 
	//*(MPcore_private_timer_ptr + 2) = 0b011;
	return; 
}

int timer_expired() {
	int value = read_word(timer + 3); 
	return (value == 1); 
	
	//return (*(MPcore_private_timer_ptr + 3) == 0); 
}

int spawn_time; 
int spawn_count; 

void reset_spawn() {
	spawn_time = random_in_range(30000, 50000); 
	spawn_count = 0; 
}

void game_loop() {
	VGA_clear_charbuff(); 
	init_game(); 
	spawn_object(); 
	reset_spawn(); 
	
	while(1) {
		update_character_position(); 
		if (timer_expired()) {
			write_word(timer + 3, 0); 
			update_objects(); 
			spawn_count++; 
			if (spawn_count >= spawn_time) {
				reset_spawn(); 
				spawn_object(); 
			}
		}
	}
}

int main() {
	timer_setup();
	init_game(); 
	
	char start; 
	while(1) {
		if (read_PS2_data(&start)) {
				game_loop(); 
		}
	}
	
	
	/*
	spawn_object(); 
	while(1) {
		if (timer_expired()) {
				write_word(timer + 3, 0); 
				update_objects(); 
				spawn_count++; 
				
				// printf("spawn_count: %d, spawn_time: %d\n", spawn_count, spawn_time);
			
				if (spawn_count >= spawn_time) {
					reset_spawn(); 
					spawn_object(); 
				}
		}
	}
	*/
	
	/*
	spawn_object(); 
	while(1) {
		if (timer_expired()) {
			update_objects(); 
		}
	}
	*/
	
	/*
	int counter = 0; 
	while (counter < 5) {
		if (timer_expired()) {
			printf("%d", 3); 
			counter++; 
		}
	}
	*/
	
	
	// spawn_object(); 
	// while(1) {
		// update_objects(); 
	// }

	// draw_object(32, 24); 
	// draw_object(96, 24); 
	// draw_object(160, 24); 
	// draw_object(224, 24); 
	// draw_object(288, 24); 
	// draw_object(160, 168); 
	
	// game_over(9); 
	
	// update_character_position(); 
	
	/*
	for (int i = 0; i < 10; i++) {
        printf("Random number %d: %u\n", i + 1, random_in_range(1, 5));
    }
	*/
	
	// input_loop_fun();
	return 0;
}
