// This is the help function
// PSTR is an AVR macro to read strings from flash memory
// printf_P is a version of print_f that reads from flash memory
static int8_t   main_menu_help(uint8_t argc, const Menu::arg *argv)
{
	cliSerial->printf_P(PSTR("Commands:\n"
						 "  ppm\n"
						 "  cal\n"
						 "  adc\n"
						 "  swop\n"
						 "  expo\n"
						 "  show\n"
						 "  proto\n"
						 "  eedump\n"
						 "  erase\n"
						 "  reset\n"
						 "  ch7\n"
						 "\n"));
	return(0);
}
static int8_t   test_ppm		    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_adc		    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_expo		    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_swop		    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_show		    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_cal_sticks	    (uint8_t argc, const Menu::arg *argv);		 // in test.cpp
static int8_t   test_eedump		    (uint8_t argc, const Menu::arg *argv);
static int8_t   setup_erase		    (uint8_t argc, const Menu::arg *argv);
static int8_t   test_ch7		    (uint8_t argc, const Menu::arg *argv);
static int8_t   test_speed		    (uint8_t argc, const Menu::arg *argv);
static int8_t   setup_reverse		(uint8_t argc, const Menu::arg *argv);


// Command/function table for the top-level menu.
const struct Menu::command main_menu_commands[] PROGMEM = {
//   command		function called
//   =======		===============
	{"erase",	    setup_erase},
	{"ppm",		    test_ppm},
	{"cal",		    test_cal_sticks},
	{"adc",		    test_adc},
	{"expo",	    test_expo},
	{"swop",	    test_swop},
	{"show",	    test_show},
	{"help",	    main_menu_help},
	{"eedump",	    test_eedump},
	{"ch7",		    test_ch7},
	{"rev",	    	setup_reverse},
	{"speed",	    test_speed},

};

// Create the top-level menu object.
MENU(main_menu, THISFIRMWARE, main_menu_commands);




// Print the current configuration.
// Called by the setup menu 'show' command.
static int8_t
test_show(uint8_t argc, const Menu::arg *argv)
{
	// clear the area
	//print_blanks(8);

	//AP_Param::show_all();

	return(0);
}

static void
trim_sticks()
{
	roll.detect_trim();
	pitch.detect_trim();
	throttle.detect_trim();
	yaw.detect_trim();
	gimbal.detect_trim();
}

static int8_t
test_ch7(uint8_t argc, const Menu::arg *argv)
{
	cliSerial->printf_P(PSTR("Test CH 7\n"));

	while(1) {
		delay(20);
		readCH_7();
		if(pwm_output[CH_7] == 2000){
			cliSerial->printf_P(PSTR("CH 7 high\n"));
		}else{
			cliSerial->printf_P(PSTR("CH 7 low\n"));
		}
		readCH_8();
		if(pwm_output[CH_8] == 2000){
			cliSerial->printf_P(PSTR("CH 8 high\n"));
		}else{
			cliSerial->printf_P(PSTR("CH 8 low\n"));
		}

		if(cliSerial->available() > 0) {
			delay(20);
			while (cliSerial->read() != -1); /* flush */

			cliSerial->printf_P(PSTR("Done\n"));
			break;
		}
	}
	return 0;
}


static int8_t
test_adc(uint8_t argc, const Menu::arg *argv)
{
	cliSerial->printf_P(PSTR("Test ADC\n"));

	while(1) {
		delay(20);
		read_adc();
		update_sticks();
		cliSerial->printf("%d, | %d, %d, %d, %d | %d, %1.2f\n", adc_gimbal, adc_roll, adc_pitch, adc_throttle, adc_yaw, adc_speed, preset_speed);

		if(cliSerial->available() > 0) {
			delay(20);
			while (cliSerial->read() != -1); /* flush */

			cliSerial->printf_P(PSTR("Done\n"));
			break;
		}
	}
	return 0;
}

static int8_t
test_speed(uint8_t argc, const Menu::arg *argv)
{
	cliSerial->printf_P(PSTR("Test speed\n"));

	while(1) {
		delay(20);
		read_adc();
		cliSerial->printf("%d, | %d, %d, %d, %d | %d\n", adc_speed, adc_roll, adc_pitch, adc_throttle, adc_yaw, adc_gimbal);

		if(cliSerial->available() > 0) {
			delay(20);
			while (cliSerial->read() != -1); /* flush */

			cliSerial->printf_P(PSTR("Done\n"));
			break;
		}
	}
	return 0;
}



static int8_t
test_swop(uint8_t argc, const Menu::arg *argv)
{
	if(argc!=2){
		cliSerial->printf_P(PSTR("Usage: swop 1(on) : 0(off)\n"));
		return 0;
	}
	
	if(argv[1].i == 0){
		swop_yaw = false;
	}else{
		swop_yaw = true;
	}
	eeprom_write_byte((uint8_t *)	EE_SWOP_YAW,  	swop_yaw);
	
	
	//swop out the reverse param
	bool tmp1 = roll.get_reverse();
    bool tmp2 = yaw.get_reverse();
    roll.set_reverse(tmp2);
    yaw.set_reverse(tmp1);
    eeprom_write_byte((uint8_t *)	EE_CH1_REV,  	roll.get_reverse());
	eeprom_write_byte((uint8_t *)	EE_CH4_REV,  	yaw.get_reverse());
}


static int8_t
test_expo(uint8_t argc, const Menu::arg *argv)
{
	if(argc!=3)
	{
		cliSerial->printf_P(PSTR("Usage: expo CH<1:4,6> <1:100>\n"));
		return 0;
	}

	uint8_t ch  = constrain(argv[1].i, 1, 6);
	uint8_t expo  = constrain(argv[2].i, 0, 100);


	switch(ch){
		case 1:
		roll.set_expo(expo);
		eeprom_write_word((uint16_t *)	EE_CH1_EXPO,  	roll.get_expo());
		break;
		case 2:
		pitch.set_expo(expo);
		eeprom_write_word((uint16_t *)	EE_CH2_EXPO,  	pitch.get_expo());
		break;
		case 3:
		throttle.set_expo(expo);
		eeprom_write_word((uint16_t *)	EE_CH3_EXPO,  	throttle.get_expo());
		break;
		case 4:
		yaw.set_expo(expo);
		eeprom_write_word((uint16_t *)	EE_CH4_EXPO,  	yaw.get_expo());
		break;
		case 6:
		gimbal.set_expo(expo);
		eeprom_write_word((uint16_t *)	EE_CH6_EXPO,  	gimbal.get_expo());
		break;
	}

	return 0;
}

static int8_t
setup_reverse(uint8_t argc, const Menu::arg *argv)
{
	if(argc!=3)
	{
		cliSerial->printf_P(PSTR("Usage: rev CH<1:4,6> <1:0>\n"));
		return 0;
	}

	uint8_t _ch  = constrain(argv[1].i, 1, 6);
	uint8_t _rev  = constrain(argv[2].i, 0, 1);


	switch(_ch){
		case 1:
	    roll.set_reverse(_rev);		
        eeprom_write_byte((uint8_t *)	EE_CH1_REV,  	roll.get_reverse());
		break;
		case 2:
	    pitch.set_reverse(_rev);
    	eeprom_write_byte((uint8_t *)	EE_CH2_REV,  	pitch.get_reverse());
		break;
		case 3:
		throttle.set_reverse(_rev);
    	eeprom_write_byte((uint8_t *)	EE_CH3_REV,  	throttle.get_reverse());
		break;
		case 4:
    	yaw.set_reverse(_rev);
	    eeprom_write_byte((uint8_t *)	EE_CH4_REV,  	yaw.get_reverse());
		break;
		case 6:
	    gimbal.set_reverse(_rev);
    	eeprom_write_byte((uint8_t *)	EE_CH6_REV,  	gimbal.get_reverse());
		break;
	}

	return 0;
}



static int8_t
test_cal_sticks(uint8_t argc, const Menu::arg *argv)
{
	cliSerial->printf_P(PSTR("Stick Calibration\n\nPress enter when done.\n\n"));

	roll.zero_min_max();
	pitch.zero_min_max();
	yaw.zero_min_max();
	throttle.zero_min_max();
	gimbal.zero_min_max();

	while(1) {
		delay(20);
		read_adc();
		update_sticks();

		roll.update_min_max();
		pitch.update_min_max();
		throttle.update_min_max();
		yaw.update_min_max();
		gimbal.update_min_max();

		cliSerial->printf_P(PSTR("%d\t%d \t%d\t%d \t%d\t%d \t%d\t%d | \t%d\t%d | \t%d\t%d\n"),
					roll._adc_min, 		roll._adc_max,
					pitch._adc_min, 	pitch._adc_max,
					throttle._adc_min, 	throttle._adc_max,
					yaw._adc_min, 		yaw._adc_max,
					gimbal._adc_min, 	gimbal._adc_max);

		//cliSerial->printf("%d, %d, %d, %d\n", adc_roll, roll._adc_in, adc_yaw, yaw._adc_in);

		if(cliSerial->available() > 0) {
			delay(20);
			while (cliSerial->read() != -1); /* flush */
			trim_sticks();

			save_eeprom();

			print_radio_cal();
			cliSerial->printf_P(PSTR("Done"));
			break;
		}
	}
	return 0;
}


static void
print_radio_cal()
{

	cliSerial->printf_P(PSTR("rol: %d\t%d\t%d\n"),roll._adc_min, 			roll._adc_trim, 		roll._adc_max);
	cliSerial->printf_P(PSTR("pit: %d\t%d\t%d\n"),pitch._adc_min, 			pitch._adc_trim, 		pitch._adc_max);
	cliSerial->printf_P(PSTR("thr: %d\t%d\t%d\n"),throttle._adc_min,		throttle._adc_trim, 	throttle._adc_max);
	cliSerial->printf_P(PSTR("yaw: %d\t%d\t%d\n"),yaw._adc_min, 			yaw._adc_trim, 			yaw._adc_max);
	cliSerial->printf_P(PSTR("gimbal: %d\t%d\t%d\n"),gimbal._adc_min,  		gimbal._adc_trim, 		gimbal._adc_max);
	cliSerial->printf_P(PSTR("expo: %d\t%d\t%d\t%d\t%d\n"),roll.get_expo(), pitch.get_expo(), 		throttle.get_expo(),  yaw.get_expo(),  gimbal.get_expo());

}

static int8_t
test_ppm(uint8_t argc, const Menu::arg *argv)
{
	/*cliSerial->printf_P(PSTR("Set PPM\n\n"));
	uint8_t tmp  = constrain(argv[1].i, 1, 8) -1;
	pwm_output[tmp] = constrain(argv[2].i, 1000, 2000);
	return 0;
	*/

	cliSerial->printf_P(PSTR("Stick Calibration\n\nPress enter when done."));

	while(1) {
		delay(20);
		read_adc();
		update_sticks();

		cliSerial->printf("%d, %d, %d, %d | %1.3f\n", pwm_output[CH_1], pwm_output[CH_2], pwm_output[CH_3], pwm_output[CH_4], input_rate);

		if(cliSerial->available() > 0) {
			delay(20);
			while (cliSerial->read() != -1); /* flush */

			save_eeprom();

			cliSerial->printf_P(PSTR("Done"));
			break;
		}
	}
	return 0;


}



// the user wants the CLI. It never exits
static void
run_cli(FastSerial *port)
{
	cliSerial = port;
	Menu::set_port(port);
	port->set_blocking_writes(true);

	while (1) {
		main_menu.run();
	}
}


/*static void
print_blanks(int16_t num)
{
	while(num > 0) {
		num--;
		cliSerial->println("");
	}
}*/

/*static void
print_divider(void)
{
	for (int i = 0; i < 40; i++) {
		cliSerial->print_P(PSTR("-"));
	}
	cliSerial->println();
}
*/


static int8_t
test_eedump(uint8_t argc, const Menu::arg *argv)
{
	uintptr_t i, j;

	// hexdump the EEPROM
	for (i = 0; i < 1024; i += 16) {
		cliSerial->printf_P(PSTR("%04x:"), i);
		for (j = 0; j < 16; j++)
			cliSerial->printf_P(PSTR(" %02x"), eeprom_read_byte((const uint8_t *)(i + j)));
		cliSerial->println();
	}
	return(0);
}


static int8_t
setup_erase(uint8_t argc, const Menu::arg *argv)
{
	zero_eeprom();
	return 0;
}

static void zero_eeprom(void)
{
	byte b = 0;

	cliSerial->printf_P(PSTR("\nErasing EEPROM\n"));

	for (uintptr_t i = 0; i < 1024; i++) {
		eeprom_write_byte((uint8_t *) i, b);
	}

	cliSerial->printf_P(PSTR("done\n"));
}
