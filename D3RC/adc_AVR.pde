

#if ADC_INPUT == ADC_AVR
// assume 

// called at 50hz
static void
read_adc()
{
	adc_roll 		= analogRead(0);
	adc_pitch 		= analogRead(1);
	adc_throttle 	= analogRead(3);
	adc_yaw 		= analogRead(2);
    adc_gimbal      = analogRead(4);
}


// called at 50hz
static void
update_sticks()
{
    //cliSerial->printf_P(PSTR(".\n"));
	roll.set_ADC(adc_roll);
	pitch.set_ADC(adc_pitch);
	throttle.set_ADC(adc_throttle);
	yaw.set_ADC(adc_yaw);
	gimbal.set_ADC(adc_gimbal);

	pwm_output[CH_1] = roll.get_PWM_angle(false);
	pwm_output[CH_2] = pitch.get_PWM_angle(false);
	pwm_output[CH_3] = throttle.get_PWM_linear();  /// XXX
	pwm_output[CH_4] = yaw.get_PWM_angle(false);
	pwm_output[CH_6] = gimbal.get_PWM_angle(false);
    input_rate = gimbal.get_PWM_angle(true);
}

#endif
