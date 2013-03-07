 
/********************** ADC Live Plotting & Logging Code ****************************
	Sends ADC value from pin F0 in hex from the M2 microcontroller [http://medesign.seas.upenn.edu/index.php/Guides/MaEvArM].

	By Nick McGill [nmcgill.com]
************************************************************************************/

// header files
#include "m_general.h"
#include "m_usb.h"

// subroutines
void set_ADC(void);
void update_ADC(void);

// global variables
#define DEBUG 1
#define CLOCK 0
int f0val = 0;

int main(void){

	m_red(ON);
	m_green(ON);

	if (DEBUG){
		m_usb_init(); // connect usb
		while(!m_usb_isconnected()){};  //wait for connection
	}

	m_red(OFF);
	m_green(OFF);

	char rx_buffer; //computer interactions

	set_ADC();
  
	while(1){
	
		update_ADC();

		while(!m_usb_rx_available());  	//wait for an indication from the computer
		rx_buffer = m_usb_rx_char();  	//grab the computer packet

		m_usb_rx_flush();  				//clear buffer		

		if(rx_buffer == 1) {  			//computer wants ir data

			//write ir data as concatenated hex:  i.e. f0f1f4f5
			m_usb_tx_hex(f0val);
			m_usb_tx_char('\n');  //MATLAB serial command reads 1 line at a time

		}
		if (ADC > 512){
			m_green(ON);
			m_red(OFF);
		}	
		else{
			m_red(ON);
			m_green(OFF);
		}
	}
}


//_______________________________________ Subroutine for setting ADCs
void set_ADC(void){
	//****************** set ADC values
	clear(ADMUX, REFS1); // voltage Reference - set to VCC
	set(ADMUX, REFS0);   // ^
	
	//clear(ADMUX, REFS1); // voltage Reference - set to Vref, the Aref pin, 3.4V
	//clear(ADMUX, REFS0); // ^

	set(ADCSRA, ADPS2); // set the ADC clock prescaler, divide 16 MHz by 128 (set, set, set)
	set(ADCSRA, ADPS1); // ^
	set(ADCSRA, ADPS0); // ^
	
	set(DIDR0, ADC0D); // disable the f0 digital input
}



//_______________________________________ Subroutine for updating ADCs
void update_ADC(){ 		//update to current ADC values, set to ADC_F0, B4

	//-------------------> set pin F0 to read ADC values
	clear(ADCSRB, MUX5); // single-ended channel selection
	clear(ADMUX, MUX2); // ^
	clear(ADMUX, MUX1); // ^
	clear(ADMUX, MUX0); // ^
	
	set(ADCSRA, ADEN); // start conversion process
	set(ADCSRA, ADSC); // ^
	while(!check(ADCSRA,ADIF));


	f0val = ADC;
	set(ADCSRA, ADIF); // sets flag after conversion
}

