#include "./drivers/inc/vga.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/audio.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/wavetable.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/slider_switches.h"

//note mapping
float key_a=130.813;
float key_s=146.832;
float key_d=164.814;
float key_f=174.614;
float key_j=195.998;
float key_k=220.000;
float key_l=246.942;
float key_semi=261.626;

//trace if a key is pressed
int flagA=0;
int flagS=0;
int flagD=0;
int flagF=0;
int flagJ=0;
int flagK=0;
int flagL=0;
int flagSEMI=0;

//preprocessed arrays
int noteC[366];
int noteD[326];
int noteE[291];
int noteF[274];
int noteG[244];
int noteA[218];
int noteB[194];
int noteC2[183];

//sample number t for each key
int l1=366;
int l2=326;
int l3=291;	
int l4=274;
int l5=244;
int l6=218;
int l7=194;
int l8=183;

//different counter for each key to avoid disconnection of voice
int counterA=0;
int counterS=0;
int counterD=0;
int counterF=0;
int counterJ=0;
int counterK=0;
int counterL=0;
int counterSEMI=0;

//signal at current moment
int signal = 0;

//volume number
int volume = 30;


//display locals
int buffer[320];
int delete_buffer[320];

//store keyboard code 
char* c="";
char in=0;

//function to compute signal according to period number and frequency
int compute_signal(int t, float f){
	int index = ((int)(f * t)) %48000;
	float decimal = f * t - (int)f * t;
	float linear = (1-decimal)*sine[index] + decimal*sine[index + 1];
	return (int)linear;
}

//method to preprocess signals of completed notes in order to save processing time
void preprocess(float frequency, int* ques, int n){
	int j;
	for (j = 0; j < n; j++) {
		ques[j] = compute_signal(j, frequency);
	}
}

//update flags 
void detectKeyboard(){
				/detect keyboard scan code
				if (read_ps2_data_ASM(c)) {
					in = *c;
					//detect make code
				  	if(in !=0xF0){
				    	switch(*c){
                		case 0x1C:          				
                    		flagA=1;
							break;                     
               			case 0x1B:
                			flagS=1;
							break;
						case 0x23:
                			flagD=1;
							break;
						case 0x2B:
                			flagF=1;
							break;
						case 0x3B:
                			flagJ=1;
							break;
						case 0x42:
                			flagK=1;
							break;
						case 0x4B:
                			flagL=1;
							break;
						case 0x4C:
               		 		flagSEMI=1;
							break;
				    	}
				 	 }	
					//detect break code
				    else{				
												
						//read second half of the break code to decide which key is released
						while(!read_ps2_data_ASM(c));
						in = *c;
						switch(in){
						case 0x1C:          				
                    		flagA=0; 
							break;                  
               			case 0x1B:
                			flagS=0;
							break;
						case 0x23:
                			flagD=0;
							break;
						case 0x2B:
                			flagF=0;
							break;
						case 0x3B:
                			flagJ=0;
							break;
						case 0x42:
                			flagK=0;
							break;
						case 0x4B:
                			flagL=0; 
							break;
						case 0x4C:
               		 		flagSEMI=0; 
							break;
						case 0x1A:
							if (volume>10) volume -= 10;
							break;
						case 0x22:
							if (volume<100) volume += 10;
							break;
						}
					}			
		
				}
}

//compute current signal by detecting flags
void synchronize(){
	if(counterA>l1){
				counterA=0;
			}
			if(counterS>l2){
				counterS=0;
			}
			if(counterD>l3){
				counterD=0;
			}
			if(counterF>l4){
				counterF=0;
			}
			if(counterJ>l5){
				counterJ=0;
			}
			if(counterK>l6){
				counterK=0;
			}
			if(counterL>l7){
				counterL=0;
			}
			if(counterSEMI>l8){
				counterSEMI=0;
			}
		
			//write signal into audio
			signal = 0;
			if (flagA == 1) {
				signal += noteC[counterA];
				counterA++;
			}
			if (flagS == 1) {
				signal += noteD[counterS];
				counterS++;
			}
			if (flagD == 1) {
				signal += noteE[counterD];
				counterD++;
			}
			if (flagF == 1) {
				signal += noteF[counterF];
				counterF++;
			}
			if (flagJ == 1) {
				signal += noteG[counterJ];
				counterJ++;
			}
			if (flagK == 1) {
				signal += noteA[counterK];
				counterK++;
			}
			if (flagL == 1) {
				signal += noteB[counterL];
				counterL++;
			}
			if (flagSEMI == 1) {
				signal += noteC2[counterSEMI];
				counterSEMI++;
			}
			//audio_write_data_ASM(signal*volume,signal*volume);
			//buffer[ylocation]=signal;
}

//draw signal accrording to flags
int draw(int i){
	//depending on what flag is on we add the sine wave together
	float yvalue = 0;
	int temp;
	if(flagA){
		temp=i;
		while(temp>l1){
			temp=temp-l1;
		}
		yvalue +=noteC[temp];
	}if(flagS){
		temp=i;
		while(temp>l2){
			temp=temp-l2;
		}
		yvalue +=noteD[temp];
	}if(flagD){
		temp=i;
		while(temp>l3){
			temp=temp-l3;
		}
		yvalue +=noteE[temp];
	}if(flagF){
		temp=i;
		while(temp>l4){
			temp=temp-l4;
		}
		yvalue +=noteF[temp];
	}if(flagJ){
		temp=i;
		while(temp>l5){
			temp=temp-l5;
		}
		yvalue +=noteG[temp];
	}if(flagK){
		temp=i;
		while(temp>l6){
			temp=temp-l6;
		}
		yvalue +=noteA[temp];
	}if(flagL){
		temp=i;
		while(temp>l7){
			temp=temp-l7;
		}
		yvalue +=noteB[temp];
	}if(flagSEMI){
		temp=i;
		while(temp>l8){
			temp=temp-l8;
		}
		yvalue +=noteC2[temp];
	}
	return (int)yvalue;
}


int main() {
	//Timer for audio
	HPS_TIM_config_t hps_tim0;
	hps_tim0.tim = TIM0;
	hps_tim0.timeout = 20;  
	hps_tim0.LD_en = 1;         
	hps_tim0.INT_en = 0;        
	hps_tim0.enable = 1;       
	HPS_TIM_config_ASM(&hps_tim0); 

	//Timer for keyboard
	HPS_TIM_config_t hps_tim1;
	hps_tim1.tim = TIM1;
	hps_tim1.timeout = 32000; 
	hps_tim1.LD_en = 1;        
	hps_tim1.INT_en = 0;        
	hps_tim1.enable = 1;        
	HPS_TIM_config_ASM(&hps_tim1); 

	//Timer for display
	HPS_TIM_config_t hps_tim2;
	hps_tim2.tim = TIM2;
	hps_tim2.timeout = 20000; //> 16K
	hps_tim2.LD_en = 1;         
	hps_tim2.INT_en = 0;      
	hps_tim2.enable = 1;     
	HPS_TIM_config_ASM(&hps_tim2);

	//initialize 2 display-related buffer
	int i;
	for (i = 0; i < 320; i++) {
		buffer[i] = 0;
		delete_buffer[i] = 0;
	}

	//clear display
	VGA_clear_pixelbuff_ASM();
	
	//do preprocessing
    preprocess(key_a,noteC,l1);
    preprocess(key_s,noteD,l2);		
    preprocess(key_d,noteE,l3);		
    preprocess(key_f,noteF,l4);		
    preprocess(key_j,noteG,l5);	
    preprocess(key_k,noteA,l6);	
    preprocess(key_l,noteB,l7);		
    preprocess(key_semi,noteC2,l8);


	int audio_flag = 1;
	int keyboard_flag = 1;

	//display counter
	int x=0;
	//flag to decide whether update display
	int updatedisplay=1;
	//every time audio updates, increment this
	int pixelwritten=0;

	//start infinite loop
	while(1) {

		if (HPS_TIM_read_ASM(TIM0) && audio_flag) { 
			HPS_TIM_clear_INT_ASM(TIM0);			

			if (HPS_TIM_read_ASM(TIM1) && keyboard_flag) {
				HPS_TIM_clear_INT_ASM(TIM1); 
				//detect keyboard scan code
				detectKeyboard();			
			}//keyboard timer action done

			//write audio
			synchronize();
			if(audio_write_data_ASM(signal*volume,signal*volume)){

				//store signal into display buffer
				pixelwritten++;
				if(pixelwritten>319){
					updatedisplay=1;
					pixelwritten=0;
				}				
					buffer[pixelwritten] = draw(pixelwritten);
			}//write buffer done

		}//write audio done 
				
		
		//if a whole screen display is computed, we are allowed to draw
		if (HPS_TIM_read_ASM(TIM2) && updatedisplay) {
			HPS_TIM_clear_INT_ASM(TIM2);
			//unable display again
			updatedisplay=0;
			pixelwritten=0;
			//redraw a whole screen
			for (x = 0; x < 320; x++) {
				//clear the point before
				VGA_draw_point_ASM(x,120 + delete_buffer[x] / 300000,0);
				//draw new point
		    	VGA_draw_point_ASM(x,120 + buffer[x] / 300000 ,0xFFFFFF);
				//store current value in order to delete next time
				delete_buffer[x]=buffer[x];
			}
			
		}




	}//while1 end(actually never end)
	return 0;
}
