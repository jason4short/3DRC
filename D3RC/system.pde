static void
init_settings()
{
    #if ADC_INPUT == ADC_I2C

        ads.begin();
        //                                                                ADS1015  ADS1115
        //                                                                -------  -------
        ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
        //ads.setGain(GAIN_ONE);        // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
        // ads.setGain(GAIN_TWO);        // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
        // ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
        // ads.setGain(GAIN_EIGHT);      // 8x gain   +/- 0.512V  1 bit = 0.25mV   0.015625mV
        // ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV
    #endif

	pwm_output[CH_1] = 1500;
	pwm_output[CH_2] = 1500;
	pwm_output[CH_3] = 1000;
	pwm_output[CH_4] = 1500;
	pwm_output[CH_5] = 1500;
	pwm_output[CH_6] = 1500;
	pwm_output[CH_7] = 1500;
	pwm_output[CH_8] = 1500;

    // Setup Dead Zone
	roll.set_dead_zone(20);
	pitch.set_dead_zone(20);
	throttle.set_dead_zone(10);
	yaw.set_dead_zone(20);
	gimbal.set_dead_zone(100);
	
    
    load_eeprom();
	print_radio_cal();


    // Setup Channel directions
	throttle.set_reverse(false);
	roll.set_reverse(false);
	pitch.set_reverse(false);
	yaw.set_reverse(true);
	gimbal.set_reverse(false);



    
	// sets us to position 0 of 5 which is Stabilize on most setups
	current_mode = 0;
	update_control_mode();
}

static void
update_control_mode()
{
    // constrain to 0:5
	current_mode = min(current_mode, 5);

    // PWM is mapped to mode_pwm's preset values
	pwm_output[CH_5] = mode_pwm[current_mode];

	cliSerial->printf_P(PSTR("PWM Out %d\n"), pwm_output[CH_5]);
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