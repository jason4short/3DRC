
//////////////////////CONFIGURATION///////////////////////////////
#define MAX_CHANNELS 8			//set the number of chanels
//#define PPM_FRAME 22500		//set the PPM frame length in microseconds (1ms = 1000µs)	//http://www.mftech.de/ppm_en.htm
#define PPM_FRAME 20025
#define PPM_PULSE 400			//set the pulse length
#define POLARITY 0				//set polarity of the pulses: 1 is positive, 0 is negative
#define PPM_OUT_PIN 9			//set PPM signal output pin on the arduino
//////////////////////////////////////////////////////////////////


void init_arduRC()
{

	// PORTD
	//  				// PD0 - PCINT16	- RXD  		- Serial RX
	//  				// PD1 - PCINT17	- TXD  		- Serial TX
	pinMode(2,INPUT);	// PD2 - PCINT18	- INT0 		- Rudder in							- INPUT Rudder/Aileron
	pinMode(3,INPUT);	// PD3 - PCINT19 	- INT1 		- Elevator in 						- INPUT Elevator
	pinMode(4,INPUT);	// PD4 - PCINT20	- XCK/T0 	- MUX pin							- Connected to Pin 2 on ATtiny
	pinMode(5,INPUT);	// PD5 - PCINT21	- OC0B/T1	- Mode pin							- Connected to Pin 6 on ATtiny   - Select on MUX
	pinMode(6,INPUT);	// PD6 - PCINT22 	- AIN0		- Ground start signaling Pin
	pinMode(7,INPUT);	// PD7 - PCINT23	- AIN1		- GPS Mux pin

	// PORTB
	pinMode(8, OUTPUT); // PB0 - PCINT0		- ICP1 		- Servo throttle					- OUTPUT THROTTLE
	pinMode(9, OUTPUT);	// PB1 - PCINT1		- OC1A 		- Elevator PWM out					- Elevator PWM out
	pinMode(10,OUTPUT);	// PB2 - PCINT2		- OC1B		- Rudder PWM out					- Aileron PWM out
	pinMode(11,OUTPUT); // PB3 - PCINT3		- MOSI/OC2	-
	pinMode(12,OUTPUT); // PB4 - PCINT4		- MISO		- Blue LED pin  - GPS Lock			- GPS Lock
	pinMode(13,OUTPUT); // PB5 - PCINT5		- SCK		- Yellow LED pin   					- INPUT Throttle



	// turn on internal pullup resistors
	digitalWrite(2, HIGH);
	digitalWrite(3, HIGH);
	digitalWrite(4, HIGH);
	digitalWrite(5, HIGH);
	digitalWrite(6, HIGH);
	digitalWrite(7, HIGH);

	//pinMode(pin, INPUT);           // set pin to input
	//digitalWrite(pin, HIGH);       // turn on pullup resistors

	// setup PPM output:
	pinMode(PPM_OUT_PIN, OUTPUT);
	digitalWrite(PPM_OUT_PIN, !POLARITY);	// set the PPM signal pin to the default state (off)

 	// ATMEGA ADC
 	// PC0 - ADC0 	- PCINT8
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


	// setup expo
	//roll.set_expo(50);
	//pitch.set_expo(50);
	//yaw.set_expo(50);
	//throttle.set_expo(0);


	throttle._dead_zone = 90;
	throttle.set_reverse(true);
	roll.set_reverse(true);
	yaw.set_reverse(true);

    load_eeprom();

	// The ADC input range (or gain) can be changed via the following
	// functions, but be careful never to exceed VDD +0.3V max, or to
	// exceed the upper and lower limits if you adjust the input range!
	// Setting these values incorrectly may destroy your ADC!

	ads.begin();
	//                                                                ADS1015  ADS1115
	//                                                                -------  -------
	ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
	//ads.setGain(GAIN_ONE);        // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
	// ads.setGain(GAIN_TWO);        // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
	// ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
	// ads.setGain(GAIN_EIGHT);      // 8x gain   +/- 0.512V  1 bit = 0.25mV   0.015625mV
	// ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV


	pwm_output[CH_1] = 1500;
	pwm_output[CH_2] = 1500;
	pwm_output[CH_3] = 1000;
	pwm_output[CH_4] = 1500;
	pwm_output[CH_5] = 1500;
	pwm_output[CH_6] = 1500;
	pwm_output[CH_7] = 1500;
	pwm_output[CH_8] = 1500;

	// sets us to position 0 of 5 which is Stabilize on most setups
	current_mode = 0;
	update_control_mode();

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
}


static void
update_control_mode()
{
    // constrain to 0:5
	current_mode = min(current_mode, 5);

    // PWM is mapped to mode_pwm's preset values
	pwm_output[CH_5] = mode_pwm[current_mode];

	//cliSerial->printf_P(PSTR("PWM Out %d\n"), pwm_output[CH_5]);
}



static void
update_tether_options()
{
	float temp;

    // we are always in stabilize!
	pwm_output[CH_5] = mode_pwm[0];

	switch(current_mode){

		case 0: // stabilize
			tetherGo = false;
			//cliSerial->printf_P(PSTR("OFF\n"));
		break;

		case 1:
			//cliSerial->printf_P(PSTR("P-\n"));
			// decrease P
			temp = pid_roll.kP() - .005;
			temp = max(temp, 0);
	        pid_roll.kP(temp);
	        pid_pitch.kP(temp);
		break;

		case 2:
			//cliSerial->printf_P(PSTR("D-\n"));
			// decrease D
			temp = pid_roll.kD() - .001;
			temp = max(temp, 0);
	        pid_roll.kD(temp);
	        pid_pitch.kD(temp);
		break;

		case 3:
			tetherGo = true;
			//cliSerial->printf_P(PSTR("ON\n"));
		break;

		case 4:
			//cliSerial->printf_P(PSTR("P+ %1.4f\n"), pid_roll.kP().get());
			temp = pid_roll.kP() + .005;
			temp = max(temp, 0);
	        pid_roll.kP(temp);
	        pid_pitch.kP(temp);
		break;

		case 5:
			// increase D
			//cliSerial->printf_P(PSTR("D+\n"));
			temp = pid_roll.kD() + .001;
			temp = max(temp, 0);
	        pid_roll.kD(temp);
	        pid_pitch.kD(temp);
		break;

	}
}

// PPM Timer code

//  PPM Frame:
//     _____	 _____     _____	 _____     _____	 _____     _____	 _____     __________________
//  __| 1   |___|2    |___| 3   |___| 4   |___| 5   |___| 6   |___| 7   |___| 8   |___|                  |
//  400      400	   400	     400	   400	     400	   400	     400 	   400

volatile uint16_t _ppm_sent;

// called each ime we reach our compare value set by OCR1A
ISR(TIMER1_COMPA_vect)
{
	// volatile
	static boolean state = true;

	//end pulse and calculate when to start the next pulse
	static byte _chan_num;

	// reset counter
	TCNT1 = 0;

	if(state){
		state = false;

		//start pulse
		digitalWriteFast(PPM_OUT_PIN, POLARITY);

		// set 3-400ms gap between pulses
		OCR1A = PPM_PULSE * 2;

	}else{
		state = true;
		digitalWriteFast(PPM_OUT_PIN, !POLARITY);

		if(_chan_num >= MAX_CHANNELS){
			// we have output our 8th channel
			// we need to output a pause until we
			// reach the 22.5us
			_chan_num 		= 0;
			_ppm_sent 		+= PPM_PULSE;
			OCR1A 			= (PPM_FRAME - _ppm_sent) * 2;
			_ppm_sent 		= 0;
			RC_flag = true;

		}else{
			// we output the rc channel
			OCR1A 			= (pwm_output[_chan_num] - PPM_PULSE) * 2;
			_ppm_sent 		+= pwm_output[_chan_num];
			_chan_num++;
		}
	}
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



void
test_switches()
{
	if(true){
    	//cliSerial->printf_P(PSTR("press %d\n"), PIND);

		if(~PIND & SW2){
			cliSerial->printf_P(PSTR("press 2 \n"));
			   // ch 1 (pin 2) is high
		}

		if(~PIND & SW3){
			cliSerial->printf_P(PSTR("press 3 \n"));
			   // ch 1 (pin 2) is high
		}
		if(~PIND & SW4){
			cliSerial->printf_P(PSTR("press 4 \n"));
			   // ch 1 (pin 2) is high
		}
		if(~PIND & SW5){
			cliSerial->printf_P(PSTR("press 5 \n"));
			   // ch 1 (pin 2) is high
		}
		if(~PIND & SW6){
			cliSerial->printf_P(PSTR("press 6 \n"));
			   // ch 1 (pin 2) is high
		}
		if(~PIND & SW7){
			cliSerial->printf_P(PSTR("press 7 \n"));
			   // ch 1 (pin 2) is high
		}

	}
	delay(100);
}