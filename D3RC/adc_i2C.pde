
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

	pwm_output[CH_1] = roll.get_PWM_angle(false);
	pwm_output[CH_2] = pitch.get_PWM_angle(false);
	pwm_output[CH_3] = throttle.get_PWM_linear();  /// XXX
	pwm_output[CH_4] = yaw.get_PWM_angle(false);
	//pwm_output[CH_6] = gimbal.get_PWM_angle(false);
    input_rate = gimbal.get_PWM_angle(true);
}


#endif

