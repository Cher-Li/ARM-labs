#include "address_map_arm.h"

/* This program demonstrates the use of parallel ports in the DE1-SoC Computer
 * It performs the following: 
 * 	1. displays the SW switch values on the red lights LEDR
 * 	2. displays a rotating pattern on the HEX displays
 * 	3. if a KEY[3..0] is pressed, uses the SW switches as the pattern
*/

extern int max(int a, int b);
int max_1 ();
int max_2 ();

int main(void)
{
	int max1 = max_1 ();

	asm("MOV R6, R0");

	int max2 = max_2 ();

	if (max1 == max2) {
		return 0;
	} else {
		return 1;
	}
}

int max_1 () {

	int a[5]={1,20,3,4,5};
    int max_val;

	int length = sizeof(a) / sizeof(int);

	max_val = a[0];

	int i;
	for (i = 1; i < length; i++) {
		if (a[i] > max_val) {
			max_val = a[i];
		}
	}

    return max_val;
}

int max_2 () {

	int a[5]={1,20,3,4,5};
    int max_val;

	int length = sizeof(a) / sizeof(int);

	max_val = a[0];

	int i;
	for (i = 1; i < length; i++) {
		max_val = max(max_val,a[i]);
	}

    return max_val;
}
