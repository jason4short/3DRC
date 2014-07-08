
// this is to support the Adafruit 12bit I2C encoder
// Call this at 200hz

#if ADC_INPUT == ADC_I2C

static void
read_adc()
{
	pointer++;

	if(pointer > 3)
		pointer = 0;

	filter1[pointer] = ads.readADC_SingleEnded(0);
	filter2[pointer] = ads.readADC_SingleEnded(1);
	filter3[pointer] = ads.readADC_SingleEnded(2);
	filter4[pointer] = ads.readADC_SingleEnded(3);
}


// called at 50hz
static void
update_sticks()
{
    //cliSerial->printf_P(PSTR(".\n"));

	adc_roll 		= (filter1[0] + filter1[1] + filter1[2] + filter1[3]) / 4;
	adc_pitch 		= (filter2[0] + filter2[1] + filter2[2] + filter2[3]) / 4;
	adc_throttle 	= (filter3[0] + filter3[1] + filter3[2] + filter3[3]) / 4;
	adc_yaw 		= (filter4[0] + filter4[1] + filter4[2] + filter4[3]) / 4;

    adc_gimbal = analogRead(CH6_GIMBAL);

	roll.set_ADC(adc_roll);
	pitch.set_ADC(adc_pitch);
	throttle.set_ADC(adc_throttle);
	yaw.set_ADC(adc_yaw);
	gimbal.set_ADC(adc_gimbal);

	pwm_output[CH_1] = roll.get_PWM(true);
	pwm_output[CH_2] = pitch.get_PWM(true);
	pwm_output[CH_3] = throttle.get_PWM(true);  /// XXX
	pwm_output[CH_4] = yaw.get_PWM(true);
	pwm_output[CH_6] = gimbal.get_PWM(false);
}

static void
update_tether()
{
    /*
	adc_roll 		= (filter1[0] + filter1[1] + filter1[2] + filter1[3]) / 4;
	adc_pitch 		= (filter2[0] + filter2[1] + filter2[2] + filter2[3]) / 4;
	adc_throttle 	= (filter3[0] + filter3[1] + filter3[2] + filter3[3]) / 4;
	adc_yaw 		= (filter4[0] + filter4[1] + filter4[2] + filter4[3]) / 4;

	roll.set_ADC(adc_roll);
	pitch.set_ADC(adc_pitch);
	throttle.set_ADC(adc_throttle);
	yaw.set_ADC(adc_yaw);

	int16_t _roll = (roll.get_PWM(true) - 1500) * 9;
	//int16_t _pitch = (pitch.get_PWM(true) - 1500) * 9;

	int32_t roll_error 	= constrain((_roll - tether_gimbal.roll), -1500, 1500);
	//int32_t pitch_error = constrain((_pitch - tether_gimbal.pitch), -1500, 1500);

    int16_t roll_out  	= pid_roll.get_pid(roll_error, .02);
    //int16_t pitch_out  	= pid_pitch.get_pid(pitch_error, .02);

	pwm_output[CH_1] 	= 1500 + constrain(roll_out, -500, 500);
	//pwm_output[CH_2] 	= 1500 + constrain(pitch_out, -500, 500);


	pwm_output[CH_2] 	= pitch.get_PWM(true);
	pwm_output[CH_3] 	= throttle.get_PWM(false);
	pwm_output[CH_4] 	= 1500;
	*/
}

#endif

