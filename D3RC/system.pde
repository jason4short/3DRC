

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