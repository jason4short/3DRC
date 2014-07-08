
#if BOARD_TYPE == PRO_MINI_BOARD



#define PPM_OUT_PIN 9			//set PPM signal output pin on the arduino

void init_arduRC()
{
	pinMode(12,OUTPUT); // PB5 - PCINT5		- SCK		- Yellow LED pin   					- INPUT Throttle

	// PORTD
	//  				// PD0 - PCINT16	- RXD  		- Serial RX
	//  				// PD1 - PCINT17	- TXD  		- Serial TX
	//pinMode(2,INPUT);	// PD2 - PCINT18	- INT0 		- Rudder in							- INPUT Rudder/Aileron
	//pinMode(3,INPUT);	// PD3 - PCINT19 	- INT1 		- Elevator in 						- INPUT Elevator
	//pinMode(4,INPUT);	// PD4 - PCINT20	- XCK/T0 	- MUX pin							- Connected to Pin 2 on ATtiny
	//pinMode(5,INPUT);	// PD5 - PCINT21	- OC0B/T1	- Mode pin							- Connected to Pin 6 on ATtiny   - Select on MUX
	//pinMode(6,INPUT);	// PD6 - PCINT22 	- AIN0		- Ground start signaling Pin
	//pinMode(7,INPUT);	// PD7 - PCINT23	- AIN1		- GPS Mux pin

	// PORTB
	pinMode(8, INPUT); // PB0 - PCINT0		- ICP1 		- Servo throttle					- OUTPUT THROTTLE
	pinMode(9, OUTPUT);	// PB1 - PCINT1		- OC1A 		- Elevator PWM out					- Elevator PWM out
	pinMode(10,OUTPUT);	// PB2 - PCINT2		- OC1B		- Rudder PWM out					- Aileron PWM out
	pinMode(11,OUTPUT); // PB3 - PCINT3		- MOSI/OC2	-
	pinMode(12,OUTPUT); // PB4 - PCINT4		- MISO		- Blue LED pin  - GPS Lock			- GPS Lock
	pinMode(13,OUTPUT); // PB5 - PCINT5		- SCK		- Yellow LED pin   					- INPUT Throttle

	// PORTC
	pinMode(8, INPUT); // PB0 - PCINT0		- ICP1 		- Servo throttle					- OUTPUT THROTTLE
	pinMode(9, OUTPUT);	// PB1 - PCINT1		- OC1A 		- Elevator PWM out					- Elevator PWM out
	pinMode(10,OUTPUT);	// PB2 - PCINT2		- OC1B		- Rudder PWM out					- Aileron PWM out
	pinMode(11,OUTPUT); // PB3 - PCINT3		- MOSI/OC2	-
	pinMode(12,OUTPUT); // PB4 - PCINT4		- MISO		- Blue LED pin  - GPS Lock			- GPS Lock
	pinMode(13,OUTPUT); // PB5 - PCINT5		- SCK		- Yellow LED pin   					- INPUT Throttle


	// turn on internal pullup resistors
	//digitalWrite(2, HIGH);
	//digitalWrite(3, HIGH);
	//digitalWrite(4, HIGH);
	//digitalWrite(5, HIGH);
	//digitalWrite(6, HIGH);
	//digitalWrite(7, HIGH);
	//digitalWrite(8, HIGH);

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


	// ---------------------------------------------------------




	// set Analog out 4 to output
	//DDRC |= B00010000;


	// setup expo
	//roll.set_expo(50);
	//pitch.set_expo(50);
	//yaw.set_expo(50);
	//throttle.set_expo(0);


	// The ADC input range (or gain) can be changed via the following
	// functions, but be careful never to exceed VDD +0.3V max, or to
	// exceed the upper and lower limits if you adjust the input range!
	// Setting these values incorrectly may destroy your ADC!

	//ads.begin();
	//                                                                ADS1015  ADS1115
	//                                                                -------  -------
	//ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
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


    ///*
	//cli();

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

	// Configure timer 1 for CTC mode
	// Set Prescaler to 8
	TCCR1A = 0x0;
	TCCR1B = (1 << WGM12) | (1 << CS11);

	// Interrupts
	// look for an overflow interrupt every 22.5ms
	// Enable CTC interrupts whenever we match our CTC
	TIMSK1 |= _BV(OCIE1A);
    cliSerial->printf_P(PSTR("$\n"));

	// Set initial compare value to trigger interrupt
	OCR1A = 100;
	sei();

    // Setup Dead Zone
	gimbal._dead_zone = 0;
	throttle._dead_zone = 90;
	
    // Setup Channel directions
	throttle.set_reverse(true);
	roll.set_reverse(false);
	yaw.set_reverse(false);
    
    load_eeprom();
	print_radio_cal();


	// sets us to position 0 of 5 which is Stabilize on most setups
	current_mode = 0;
	update_control_mode();
}

#endif