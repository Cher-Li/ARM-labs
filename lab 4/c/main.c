#include <stdio.h>
#include "./drivers/inc/VGA.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/slider_switches.h"


void test_char() {
	int x, y;
	char c = 0;

	for (y = 0; y < 59; y++)
		for (x = 0; x <= 79; x++)
			VGA_write_char_ASM(x, y, c++);
	
}

void test_byte() {
	int x, y;
	char c = 0;

	for (y = 0; y < 59; y++)
		for (x = 0; x <= 79; x+=3)
			VGA_write_byte_ASM(x, y, c++);

}

void test_pixel() {
	int x, y;
	unsigned short colour = 0;

	for (y = 0; y < 239; y++)
		for (x = 0; x <= 319; x++)
			VGA_draw_point_ASM(x,y,colour++);

}

int main() {

    //test_pixel();
    //VGA_clear_pixelbuff_ASM();
    //test_char();
    //VGA_clear_charbuff_ASM();
    //test_byte();
    /* while(1){
       // PB0 is pressed
       if (0x1 & read_PB_data_ASM()){  
          if(0x3FF & read_slider_switches_ASM()){
              test_byte();
          }
          else{
              test_char();
          }
       }
       //PB1 is pressed
       if (0x2 & read_PB_data_ASM()){
           test_pixel();
       }
       //PB2 is pressed 
       if (0x4 & read_PB_data_ASM()){
           VGA_clear_charbuff_ASM();
       }
       //PB3 is pressed
       if (0x8 & read_PB_data_ASM()){
           VGA_clear_pixelbuff_ASM();
       }
    } */
	
	/*
	char* c;
	int x = 1;		
	int y = 1;
	VGA_clear_charbuff_ASM();
	while(1) {
		if (read_PS2_data_ASM(c)) {
			VGA_write_byte_ASM(x, y, *c);
			if (x >= 79) {
				x = 1;
				y++;
			}
			else {
				x = x + 3;
			}
		}
	}  
	*/

	
	int counter = 0;
	int signal = 0x00FFFFFF;
	while (1) {
		if (write_in_FIFO_ASM(signal)) {
			counter++;
		}
		if (counter >= 240) {
			counter = 0;
			if (signal == 0x00FFFFFF) 
				signal = 0x00000000;
			else 
				signal = 0x00FFFFFF;
		}
	}	
	
	
	return 0;
}
