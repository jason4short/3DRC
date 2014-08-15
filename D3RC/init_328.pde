
#if BOARD_TYPE == PRO_MINI_BOARD



#define PPM_OUT_PIN 9			//set PPM signal output pin on the arduino

void init_arduRC()
{

	// PORTD
	//  				// PD0 - PCINT16	- RXD  		- Serial RX
	//  				// PD1 - PCINT17	- TXD  		- Serial TX
	pinMode(2,INPUT);	// PD2 - PCINT18	- INT0 		- 
	pinMode(3,INPUT);	// PD3 - PCINT19 	- INT1 		-
	pinMode(4,INPUT);	// PD4 - PCINT20	- XCK/T0 	- 
	pinMode(5,INPUT);	// PD5 - PCINT21	- OC0B/T1	- 
	pinMode(6,INPUT);	// PD6 - PCINT22 	- AIN0		- 
	pinMode(7,INPUT);	// PD7 - PCINT23	- AIN1		- 

	// PORTB
	pinMode(8, OUTPUT); // PB0 - PCINT0		- ICP1 		- 
	pinMode(9, OUTPUT);	// PB1 - PCINT1		- OC1A 		- 
	pinMode(10,OUTPUT);	// PB2 - PCINT2		- OC1B		- 
	pinMode(11,OUTPUT); // PB3 - PCINT3		- MOSI/OC2	-
	pinMode(12,OUTPUT); // PB4 - PCINT4		- MISO		- 
	pinMode(13,OUTPUT); // PB5 - PCINT5		- SCK		- 



	// turn on internal pullup resistors
	digitalWrite(2, HIGH);
	digitalWrite(3, HIGH);
	digitalWrite(4, HIGH);
	digitalWrite(5, HIGH);
	digitalWrite(6, HIGH);
	digitalWrite(7, HIGH);
	digitalWrite(8, HIGH);

	//pinMode(pin, INPUT);           // set pin to input
	//digitalWrite(pin, HIGH);       // turn on pullup resistors

	// setup PPM output:
	pinMode(PPM_OUT_PIN, OUTPUT);
	digitalWrite(PPM_OUT_PIN, !POLARITY);	// set the PPM signal pin to the default state (off)

 	// ATMEGA ADC
 	// PC0 - ADC0 	- PCINT8            - CH6 input Gimbal
 	// PC1 - ADC1 	- PCINT9
 	// PC2 - ADC2 	- PCINT10
 	// PC3 - ADC3 	- PCINT11
 	// PC4 - ADC4 	- PCINT12	- SDA
 	// PC5 - ADC5 	- PCINT13	- SCL
 	// PC6 - ADC5 	- PCINT14 - reset

	// PCIE0 : PCINT  7..0
	// PCIE1 : PCINT 14..8
	// PCIE2 : PCINT 23..16

	// ---------------------------------------------------------
	// enable pin change interrupts
	PCICR = _BV(PCIE2); // | _BV(PCIE2);

	// enable in change interrupt on PB5 (digital pin 13)
	//PCMSK0 = _BV(PCINT3) | _BV(PCINT5);

	// enable pin change interrupt on
	PCMSK2 = _BV(PCINT18) | _BV(PCINT19) | _BV(PCINT20) | _BV(PCINT21) | _BV(PCINT22) | _BV(PCINT23);

	// ---------------------------------------------------------

    // load parameters from EEPROM
	//load_parameters();
	print_radio_cal();


	// set Analog out 4 to output
	//DDRC |= B00010000;



    // INIT Timers
    // ========================
	cli();

	// Configure timer 1 for CTC mode
	// Set Prescaler to 8
	TCCR1A = 0x0;
	TCCR1B = (1 << WGM12) | (1 << CS11);

	// Interrupts
	// look for an overflow interrupt every 22.5ms
	// Enable CTC interrupts whenever we match our CTC
	TIMSK1 |= _BV(OCIE1A);

	// Set initial compare value to trigger interrupt
	OCR1A = 100;
	sei();
    // ========================

}

// radio PWM input timers
ISR(PCINT2_vect) {

	if(~PIND & SW3){
		current_mode = 0;
		mode_change_flag = 1;
		//cliSerial->printf_P(PSTR("3\n"));
	}
	if(~PIND & SW2){
		current_mode = 1;
		mode_change_flag = 1;
		//cliSerial->printf_P(PSTR("2\n"));
	}
	if(~PIND & SW4){
		current_mode = 2;
		mode_change_flag = 1;
		//cliSerial->printf_P(PSTR("4\n"));
	}
	if(~PIND & SW6){
		current_mode = 3;
		mode_change_flag = 1;
	    //cliSerial->printf_P(PSTR("6\n"));
	}
	if(~PIND & SW5){
		current_mode = 4;
		mode_change_flag = 1;
		//cliSerial->printf_P(PSTR("5\n"));
	}
	if(~PIND & SW7){
		current_mode = 5;
		mode_change_flag = 1;
		//cliSerial->printf_P(PSTR("7\n"));
	}
}

ISR(PCINT0_vect)
{
	//if(PINB & 8)   // pin 11
	//if(PINB & 32)  // pin 13
}



// radio PWM input timers
static void
readCH_5()
{
}



static void
readCH_7()
{
    // IS CH 7 high?
    if(~PINB & 1){
        pwm_output[CH_7] = 1000;
    }else{
        pwm_output[CH_7] = 2000;
    }
}

static void
readCH_8()
{
    // IS CH 7 high?
    if(~PINB & SW2){
        pwm_output[CH_8] = 1000;
    }else{
        pwm_output[CH_8] = 2000;
    }
}


#endif