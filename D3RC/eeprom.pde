//EEPRROM




static void
save_eeprom(){
	eeprom_write_word((uint16_t *)	EE_CH1_LOW,  	roll._adc_min);
	eeprom_write_word((uint16_t *)	EE_CH1_MID,  	roll._adc_trim);
	eeprom_write_word((uint16_t *)	EE_CH1_HIGH,  	roll._adc_max);

	eeprom_write_word((uint16_t *)	EE_CH2_LOW,  	pitch._adc_min);
	eeprom_write_word((uint16_t *)	EE_CH2_MID,  	pitch._adc_trim);
	eeprom_write_word((uint16_t *)	EE_CH2_HIGH,  	pitch._adc_max);

	eeprom_write_word((uint16_t *)	EE_CH3_LOW,  	throttle._adc_min);
	eeprom_write_word((uint16_t *)	EE_CH3_MID,  	throttle._adc_trim);
	eeprom_write_word((uint16_t *)	EE_CH3_HIGH,  	throttle._adc_max);

	eeprom_write_word((uint16_t *)	EE_CH4_LOW,  	yaw._adc_min);
	eeprom_write_word((uint16_t *)	EE_CH4_MID,  	yaw._adc_trim);
	eeprom_write_word((uint16_t *)	EE_CH4_HIGH,  	yaw._adc_max);

	eeprom_write_word((uint16_t *)	EE_CH1_EXPO,  	roll.get_expo());
	eeprom_write_word((uint16_t *)	EE_CH2_EXPO,  	pitch.get_expo());
	eeprom_write_word((uint16_t *)	EE_CH3_EXPO,  	throttle.get_expo());
	eeprom_write_word((uint16_t *)	EE_CH4_EXPO,  	yaw.get_expo());

	eeprom_write_word((uint16_t *)	EE_CH6_EXPO,  	gimbal.get_expo());
	eeprom_write_word((uint16_t *)	EE_CH6_LOW,  	gimbal._adc_min);
	//eeprom_write_word((uint16_t *)	EE_CH6_MID,  	gimbal._adc_trim);
	eeprom_write_word((uint16_t *)	EE_CH6_HIGH,  	gimbal._adc_max);

	//eeprom_write_byte((uint8_t *)	EE_CH1_REV,  	roll.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH2_REV,  	pitch.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH3_REV,  	throttle.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH4_REV,  	yaw.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH5_REV,  	gimbal_rate.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH6_REV,  	gimbal.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH7_REV,  	null.get_reverse());
	//eeprom_write_byte((uint8_t *)	EE_CH8_REV,  	null.get_reverse());
	
}
//	eeprom_write_byte((uint8_t *) mem, wp.p1);

//	wp.id = eeprom_read_byte((uint8_t *)mem);

static void
load_eeprom(){
	roll._adc_min	= eeprom_read_word((uint16_t *)	EE_CH1_LOW);
	roll._adc_trim	= eeprom_read_word((uint16_t *)	EE_CH1_MID);
	roll._adc_max	= eeprom_read_word((uint16_t *)	EE_CH1_HIGH);

	pitch._adc_min	= eeprom_read_word((uint16_t *)	EE_CH2_LOW);
	pitch._adc_trim	= eeprom_read_word((uint16_t *)	EE_CH2_MID);
	pitch._adc_max	= eeprom_read_word((uint16_t *)	EE_CH2_HIGH);

	throttle._adc_min	= eeprom_read_word((uint16_t *)	EE_CH3_LOW);
	throttle._adc_trim	= eeprom_read_word((uint16_t *)	EE_CH3_MID);
	throttle._adc_max	= eeprom_read_word((uint16_t *)	EE_CH3_HIGH);

	yaw._adc_min	= eeprom_read_word((uint16_t *)	EE_CH4_LOW);
	yaw._adc_trim	= eeprom_read_word((uint16_t *)	EE_CH4_MID);
	yaw._adc_max	= eeprom_read_word((uint16_t *)	EE_CH4_HIGH);

	roll.set_expo(eeprom_read_word((uint16_t *)		EE_CH1_EXPO));
	pitch.set_expo(eeprom_read_word((uint16_t *)	EE_CH2_EXPO));
	throttle.set_expo(eeprom_read_word((uint16_t *)	EE_CH3_EXPO));
	yaw.set_expo(eeprom_read_word((uint16_t *)		EE_CH4_EXPO));
	gimbal.set_expo(eeprom_read_word((uint16_t *)	EE_CH6_EXPO));

	gimbal._adc_min	    = eeprom_read_word((uint16_t *)	EE_CH6_LOW);
	//gimbal._adc_trim	= eeprom_read_word((uint16_t *)	EE_CH6_MID);
	gimbal._adc_max	    = eeprom_read_word((uint16_t *)	EE_CH6_HIGH);
	gimbal._adc_trim	= (gimbal._adc_min + gimbal._adc_max)/2;
	gimbal.set_reverse(eeprom_read_byte((uint8_t *)	EE_CH6_REV));
	
	roll.set_reverse(eeprom_read_byte((uint8_t *)	    EE_CH1_REV));
	pitch.set_reverse(eeprom_read_byte((uint8_t *)	    EE_CH2_REV));
	throttle.set_reverse(eeprom_read_byte((uint8_t *)	EE_CH3_REV));
	yaw.set_reverse(eeprom_read_byte((uint8_t *)	    EE_CH4_REV));
	//roll.set_reverse(eeprom_read_byte((uint8_t *)	EE_CH7_REV));
	//roll.set_reverse(eeprom_read_byte((uint8_t *)	EE_CH8_REV));
	preset_A_value = eeprom_read_dword((uint32_t *)	EE_PRESET_A);
	preset_B_value = eeprom_read_dword((uint32_t *)	EE_PRESET_B);
	swop_yaw = eeprom_read_byte((uint8_t *)	EE_SWOP_YAW);
	//eeprom_write_byte((uint8_t *)	EE_CH7_REV,  	null.get_reverse());
	
	
	cliSerial->printf_P(PSTR("preset_A_value %1.2f\n"), preset_A_value);
	cliSerial->printf_P(PSTR("preset_B_value %1.2f\n"), preset_B_value);
	
}





