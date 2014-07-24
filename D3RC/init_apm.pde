
#if BOARD_TYPE == APM_BOARD

#define PPM_OUT_PIN 12			//set PPM signal output pin on the arduino
#define CH_7_PIN 45			//set PPM signal output pin on the arduino
#define CH_8_PIN 44			//set PPM signal output pin on the arduino

void init_arduRC()
{
	// PORTD
	//  				// PD0 - PCINT16	- RXD  		- Serial RX
	//  				// PD1 - PCINT17	- TXD  		- Serial TX
	//pinMode(2,INPUT);	// PD2 - PCINT18	- INT0 		- 
	//pinMode(3,INPUT);	// PD3 - PCINT19 	- INT1 		- 
	//pinMode(4,INPUT);	// PD4 - PCINT20	- XCK/T0 	- 
	//pinMode(5,INPUT);	// PD5 - PCINT21	- OC0B/T1	- 
	//pinMode(6,INPUT);	// PD6 - PCINT22 	- AIN0		- 
	//pinMode(7,INPUT);	// PD7 - PCINT23	- AIN1		- 

	// PORTA
	/*
	pinMode(22,INPUT);  // PA0 - AD0                - 
	pinMode(23,OUTPUT);	// PA1 - AD1                -
	pinMode(24,OUTPUT);	// PA2 - AD2                -
	pinMode(25,OUTPUT); // PA3 - AD3                - HAL_GPIO_C_LED_PIN
	pinMode(26,OUTPUT); // PA4 - AD4                - HAL_GPIO_B_LED_PIN
	pinMode(27,OUTPUT); // PA5 - AD5                - HAL_GPIO_A_LED_PIN
	pinMode(28,OUTPUT); // PA6 - AD6                -
	pinMode(29,OUTPUT); // PA7 - AD7                -
	*/

	// PORTB
	/*
	pinMode(53, INPUT); // PB0 (SS/PCINT0)          - SPI_SS
	pinMode(52,OUTPUT); // PB1 (SCK/PCINT1) 		- SPI_SCK
	pinMode(51,OUTPUT);	// PB2 (MOSI/PCINT2)		- SPI_MOSI
	pinMode(50,OUTPUT); // PB3 (MISO/PCINT3)	    - SPI_MISO
	pinMode(10,OUTPUT); // PB4 (OC2A/PCINT4)		- PWM10
	pinMode(11,OUTPUT); // PB5 (OC1A/PCINT5)		- PWM11         CH_2
	pinMode(12,OUTPUT); // PB6 (OC1B/PCINT6)        - PWM12,        CH_1
	pinMode(13,OUTPUT); // PB7 (OC0A/OC1C/PCINT7)   - PWM13
	*/

	// PORTC
	/*
	pinMode(37,INPUT);  // PC0 - A8		- 
	pinMode(36,OUTPUT); // PC1 - A9		- 
	pinMode(35,OUTPUT);	// PC2 - A10	- 
	pinMode(34,OUTPUT); // PC3 - A11	
	pinMode(33,OUTPUT); // PC4 - A12	
	pinMode(32,OUTPUT); // PC5 - A13	
	pinMode(31,OUTPUT); // PC6 - A14	
	pinMode(30,OUTPUT); // PC7 - A15	
    */

	// PORTD
	/*
	pinMode(21,INPUT);  // PD0 (SCL/INT0) 		    - I2C_SCL
	pinMode(20,OUTPUT); // PD1 (SDA/INT1)		    - I2C_SDA
	pinMode(19,OUTPUT);	// PD2 (RXDI/INT2)	        - USART1_RX
	pinMode(18,OUTPUT); // PD3 (TXD1/INT3)          - USART1_TX
	pinMode(--,OUTPUT); // PD4 (ICP1)               - 
	pinMode(--,OUTPUT); // PD5 (XCK1)		        - 
	pinMode(--,OUTPUT); // PD6 (T1)		            - 
	pinMode(38,OUTPUT); // PD7 (T0)		            - 
    */

	// PORTE
	/*
	pinMode(0, INPUT);  // PE0 (RXD0/PCINT8)		- USART0_RX
	pinMode(1, OUTPUT);	// PE1 (TXD0)	            - USART0_TX
	pinMode(--,OUTPUT);	// PE2 (XCK0/AIN0)	        - 
	pinMode(5, OUTPUT); // PE3 (OC3A/AIN1)	        - PWM5          CH_8
	pinMode(2, OUTPUT); // PE4 (OC3B/INT4)	        - PWM2          CH_7
	pinMode(3, OUTPUT); // PE5 (OC3C/INT5)	        - PWM3          CH_6
	pinMode(--,OUTPUT); // PE6 (T3/INT6)	        - APM only
	pinMode(--,OUTPUT); // PE7 (CLKO/ICP3/INT7)		-
    */

	// PORTF
	/*
	pinMode(--,INPUT);  // PF0 (ADC0)               - Analog 0
	pinMode(--,OUTPUT);	// PF1 (ADC1)               - Analog 1
	pinMode(--,OUTPUT);	// PF2 (ADC2)               - Analog 2
	pinMode(--,OUTPUT); // PF3 (ADC3)               - Analog 3
	pinMode(--,OUTPUT); // PF4 (ADC4/TCK)           - Analog 4
	pinMode(--,OUTPUT); // PF5 (ADC5/TMS)           - Analog 5
	pinMode(--,OUTPUT); // PF6 (ADC6/TDO)           - Analog 6
	pinMode(--,OUTPUT); // PF7 (ADC7/TDI)           - Analog 7
    */

	// PORTG
	/*
	pinMode(41,INPUT);  // PG0 (WR)
	pinMode(40,OUTPUT); // PG1 (RD)
	pinMode(39,OUTPUT);	// PG2 (ALE)
	pinMode(--,OUTPUT); // PG3 (TOSC2)
	pinMode(--,OUTPUT); // PG4 (TOSC1)
	pinMode(4, OUTPUT); // PG5 (OC0B)               - PWM4
    */

	// PORTH
	/*
	pinMode(17,INPUT);  // PH0 (RXD2)               - USART2_RX
	pinMode(16,OUTPUT); // PH1 (TXD2)               - USART2_TX
	pinMode(--,OUTPUT);	// PH2 (XCK2)
	pinMode(6, OUTPUT); // PH3 (OC4A)               - PWM6          CH_5
	pinMode(7, OUTPUT); // PH4 (OC4B)               - PWM7          CH_4
	pinMode(8, OUTPUT); // PH5 (OC4C)               - PWM8          CH_3
	pinMode(9, OUTPUT); // PH6 (OC2B)               - PWM9          
	pinMode(--,OUTPUT); // PH7 (T4)                 - 
    */

	// PORTJ
	/*
	pinMode(15,INPUT);  // PJ0 (RXD3/PCINT9)        - USART3_RX
	pinMode(14,OUTPUT); // PJ1 (TXD3/PCINT10)       - USART3_TX
	pinMode(--,OUTPUT);	// PJ2 (XCK3/PCINT11)       - 
	pinMode(--,OUTPUT); // PJ3 (PCINT12)            - PWM6
	pinMode(--,OUTPUT); // PJ4 (PCINT13)            - PWM7
	pinMode(--,OUTPUT); // PJ5 (PCINT14)            - PWM8
	pinMode(--,OUTPUT); // PJ6 (PCINT15)            - PWM9
	pinMode(--,OUTPUT); // PJ7              - 
    */

	// PORTK
	/*
	pinMode(--,INPUT);  // PK0 (ADC8/PCINT16)       - Analog 8
	pinMode(--,OUTPUT); // PK1 (ADC9/PCINT17)       - Analog 9
	pinMode(--,OUTPUT);	// PK2 (ADC10/PCINT18)      - Analog 10
	pinMode(--,OUTPUT); // PK3 (ADC11/PCINT19)      - Analog 11
	pinMode(--,OUTPUT); // PK4 (ADC12/PCINT20)      - Analog 12
	pinMode(--,OUTPUT); // PK5 (ADC13/PCINT21)      - Analog 13
	pinMode(--,OUTPUT); // PK6 (ADC14/PCINT22)      - Analog 14
	pinMode(--,OUTPUT); // PK7 (ADC15/PCINT23)      - Analog 15
    */

	// PORTL
	/*
	pinMode(49,INPUT);  // PL0 (ICP4)               -
	pinMode(48,OUTPUT); // PL1 (ICP5)               -
	pinMode(47,OUTPUT);	// PL2 (T5)                 -
	pinMode(46,OUTPUT); // PL3 (OC5A)               -
	pinMode(45,OUTPUT); // PL4 (OC5B)               - CH_10 (on analog side)
	pinMode(44,OUTPUT); // PL5 (OC5C)               - CH_11 (on analog side)
	pinMode(43,OUTPUT); // PL6 
	pinMode(42,OUTPUT); // PL7 
    */

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


    //CH 7, Ch 8                                 // on APM
	pinMode(CH_7_PIN,INPUT); // PL4 (OC5B)       - CH_10 (on analog side)
	pinMode(CH_8_PIN,INPUT); // PL5 (OC5C)       - CH_11 (on analog side)
	// turn on internal pullup resistors
	digitalWrite(CH_7_PIN, HIGH);
	digitalWrite(CH_8_PIN, HIGH);
	
	//CH5
	pinMode(11,INPUT); // PB5 (OC1A/PCINT5)	        - PWM11         CH_2 - takeoff
	pinMode(8, INPUT); // PH5 (OC4C)                - PWM8          CH_3
	pinMode(7, INPUT); // PH4 (OC4B)                - PWM7          CH_4
	pinMode(6, INPUT); // PH3 (OC4A)               - PWM6           CH_5
	pinMode(3, INPUT); // PE5 (OC3C/INT5)	        - PWM3          CH_6
	pinMode(2, INPUT); // PE4 (OC3B/INT4)	        - PWM2          CH_7
	//pinMode(5, INPUT); // PE3 (OC3A/AIN1)	        - PWM5          CH_8
	//pinMode(13,INPUT); // PB7 (OC0A/OC1C/PCINT7)   - PWM13

	// turn on internal pullup resistors
	digitalWrite(11, HIGH);
	digitalWrite(8, HIGH);
	digitalWrite(7, HIGH);
	digitalWrite(6, HIGH);
	digitalWrite(3, HIGH);
	digitalWrite(2, HIGH);
	//digitalWrite(13, HIGH);

	// ---------------------------------------------------------
	// set Analog out 4 to output
	//DDRC |= B00010000;

	cli();
    // Timers
    // ========================

	// Configure timer 1 for CTC mode
	// Set Prescaler to 8
	TCCR1A = 0x0;
	TCCR1B = (1 << WGM12) | (1 << CS11);

	// Interrupts
	// look for an overflow interrupt every 22.5ms
	// Enable CTC interrupts whenever we match our CTC
	TIMSK1 |= _BV(OCIE1A);
    //cliSerial->printf_P(PSTR("$\n"));

	// Set initial compare value to trigger interrupt
	OCR1A = 100;


	sei();
    // ========================
}


// radio PWM input timers
static void
readCH_5()
{
    uint8_t temp_mode = current_mode;

	if(~PINB & SW5){
		temp_mode = 0;
		cliSerial->printf_P(PSTR("0\n"));
		
	}else if(~PINH & SW5){
		temp_mode = 2;
		cliSerial->printf_P(PSTR("2\n"));
		
	}else if(~PINH & SW4){
		temp_mode = 3;
		cliSerial->printf_P(PSTR("3\n"));
		
	}else if(~PINH & SW3){
		temp_mode = 1;
		cliSerial->printf_P(PSTR("1\n"));
	}
	
    if(temp_mode != current_mode){
        current_mode = temp_mode;
		mode_change_flag = 1;
	}
}

	
static void
readCH_7()
{
    // IS CH 7 high?
    //if(~PINB & 1){
	if(~PINE & SW5){
		//cliSerial->printf_P(PSTR("X\n"));
        pwm_output[CH_7] = 2000;
    }else{
        pwm_output[CH_7] = 1000;
    }
}

static void
readCH_8()
{
    // IS CH 8 high?
	if(~PINE & SW4){
		//cliSerial->printf_P(PSTR("Y\n"));
        pwm_output[CH_8] = 2000;
    }else{
        pwm_output[CH_8] = 1000;
    }
}

static bool preset_isPressed;
static bool preset_hold;
static uint8_t prev_preset_press;

static void
read_Presets()
{
    uint8_t temp = 0;

	if(~PINL & SW5){
		temp = PRESET_A_BUTTON;
		//cliSerial->printf_P(PSTR("in A %1.1f\n"), camera_angle);
		
	}else if(~PINL & SW4){
		temp = PRESET_B_BUTTON;
		//cliSerial->printf_P(PSTR("in B %1.1f\n"), camera_angle);
	}
	
	// release 
	// previous != 0
	// temo = 0;
    if(prev_preset_press != 0 && temp == 0){
    	//cliSerial->printf_P(PSTR("release! %d\n"), temp);

        // we have a release
        // was hold timer triggerd?
        if (preset_hold){
    		//cliSerial->printf_P(PSTR("trigger Hold %u\n"), prev_preset_press);
            save_preset(prev_preset_press);
        }else{ // press
    		//cliSerial->printf_P(PSTR("trigger press %u\n"), prev_preset_press);
            run_preset(prev_preset_press);
        }
        
        // we're no longer tracking the hold
        preset_hold = false;
    	//cliSerial->printf_P(PSTR("preset_hold false\n"));

        // remember no button is pressed
        prev_preset_press = 0;
        
        //bail
        return;
    }
    //

    // bail if no button is pressed
    if(temp == 0){
        preset_hold = 0;
        hold_timer = 0;
        return;
    }
    
    // new button is pressed
    if(prev_preset_press == 0 && temp != 0){
	    hold_timer = gimbal_timer;
    	//cliSerial->printf_P(PSTR("save hold timer %lu  %lu\n"), gimbal_timer, hold_timer);
    }
    
    // check delay length
    if((gimbal_timer - hold_timer) > 150){
    	//cliSerial->printf_P(PSTR("preset_hold true!  %lu   %lu\n"), gimbal_timer, hold_timer);
        preset_hold = true;
    }else{
        preset_hold = false;
    }
    prev_preset_press = temp;
    	
}

static void
save_preset(uint8_t button)
{
    //cliSerial->printf_P(PSTR("save preset %d\n"), button);
    
    if(button == PRESET_A_BUTTON){
        preset_A_value = camera_angle;
        eeprom_write_dword((uint32_t *)	EE_PRESET_A,  	preset_A_value);
        //cliSerial->printf_P(PSTR("Hold A %1.2f\n"), preset_A_value);

    }else if (button == PRESET_B_BUTTON){
        preset_B_value = camera_angle; 
        eeprom_write_dword((uint32_t *)	EE_PRESET_B,  	preset_B_value);
        //cliSerial->printf_P(PSTR("Hold B %1.2f\n"), preset_B_value);
    }

}
#endif