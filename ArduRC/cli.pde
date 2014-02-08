// Print the current configuration.
// Called by the setup menu 'show' command.
static int8_t
test_show(uint8_t argc, const Menu::arg *argv)
{
    // clear the area
    print_blanks(8);

    AP_Param::show_all();

    return(0);
}




static void
trim_sticks()
{
	g.roll.detect_trim();
	g.pitch.detect_trim();
	g.throttle.detect_trim();
	g.yaw.detect_trim();
}

static int8_t
test_proto(uint8_t argc, const Menu::arg *argv)
{
	/*
    cliSerial->printf_P(PSTR("Test Protocol\n"));
	int16_t tmp_roll, tmp_pitch;


	_buffer.gimbal.roll = 4500;
	_buffer.gimbal.pitch = -1200;
	_buffer.gimbal.sum = _buffer.gimbal.pitch + _buffer.gimbal.roll;


	bytes_union.bytes[1] = _buffer.bytes[3];
	bytes_union.bytes[0] = _buffer.bytes[2];
	tmp_roll = bytes_union.int_value;


	bytes_union.bytes[1] = _buffer.bytes[5];
	bytes_union.bytes[0] = _buffer.bytes[4];
	tmp_pitch = bytes_union.int_value;


	bytes_union.bytes[1] = _buffer.bytes[7];
	bytes_union.bytes[0] = _buffer.bytes[6];
	gimbal.sum = bytes_union.int_value;

	cliSerial->printf("%d, %d, %d\n", tmp_roll, tmp_pitch, gimbal.sum);
	*/
    return 0;
}
//*/


static int8_t
test_adc(uint8_t argc, const Menu::arg *argv)
{
    cliSerial->printf_P(PSTR("Test ADC\n"));

    while(1) {
        delay(20);
        read_adc();
		update_sticks();
		cliSerial->printf("%d, %d, %d, %d\n", adc_roll, adc_pitch, adc_throttle, adc_yaw);

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
test_expo(uint8_t argc, const Menu::arg *argv)
{
    if(argc!=3)
    {
        cliSerial->printf_P(PSTR("Usage: set CH<1:4> <1:100>\n"));
        return 0;
    }

	uint8_t ch  = constrain(argv[1].i, 1, 4);
	uint8_t expo  = constrain(argv[2].i, 0, 100);

	switch(ch){
		case 1:
		g.roll.set_expo(expo);
		g.roll.save_eeprom();
		break;
		case 2:
		g.pitch.set_expo(expo);
		break;
		case 3:
		g.throttle.set_expo(expo);
		break;
		case 4:
		g.yaw.set_expo(expo);
		break;
	}

    return 0;
}

static int8_t
test_cal_sticks(uint8_t argc, const Menu::arg *argv)
{
    cliSerial->printf_P(PSTR("Stick Calibration\n\nPress enter when done.\n\n"));

	g.roll.zero_min_max();
	g.pitch.zero_min_max();
	g.yaw.zero_min_max();
	g.throttle.zero_min_max();

    while(1) {
        delay(20);
        read_adc();
		update_sticks();

		g.roll.update_min_max();
		g.pitch.update_min_max();
		g.throttle.update_min_max();
		g.yaw.update_min_max();

		cliSerial->printf_P(PSTR("%d\t%d \t%d\t%d \t%d\t%d \t%d\t%d\n"),
					g.roll._adc_min.get(), 		g.roll._adc_max.get(),
					g.pitch._adc_min.get(), 	g.pitch._adc_max.get(),
					g.throttle._adc_min.get(), 	g.throttle._adc_max.get(),
					g.yaw._adc_min.get(), 		g.yaw._adc_max.get());

		//cliSerial->printf("%d, %d, %d, %d\n", adc_roll, roll._adc_in, adc_yaw, yaw._adc_in);

        if(cliSerial->available() > 0) {
            delay(20);
            while (cliSerial->read() != -1); /* flush */
            trim_sticks();

            //save_eeprom();
			g.roll.save_eeprom();
			g.pitch.save_eeprom();
			g.throttle.save_eeprom();
			g.yaw.save_eeprom();

			print_radio_cal();
		    cliSerial->printf_P(PSTR("Done"));
            break;
        }
    }
    return 0;
}

//static void
//save_eeprom(){
/*
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
	*/
//}


//static void
//load_eeprom(){
/*
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
	*/
//}


static void
print_radio_cal()
{

	cliSerial->printf_P(PSTR("rol: %d\t%d\t%d\n"),g.roll._adc_min.get(), 		g.roll._adc_trim.get(), 		g.roll._adc_max.get());
	cliSerial->printf_P(PSTR("pit: %d\t%d\t%d\n"),g.pitch._adc_min.get(), 		g.pitch._adc_trim.get(), 		g.pitch._adc_max.get());
	cliSerial->printf_P(PSTR("thr: %d\t%d\t%d\n"),g.throttle._adc_min.get(), 	g.throttle._adc_trim.get(), 	g.throttle._adc_max.get());
	cliSerial->printf_P(PSTR("yaw: %d\t%d\t%d\n"),g.yaw._adc_min.get(), 		g.yaw._adc_trim.get(), 			g.yaw._adc_max.get());
	cliSerial->printf_P(PSTR("expo: %d\t%d\t%d\t%d\n"),g.roll.get_expo(), 		g.pitch.get_expo(), 			g.throttle.get_expo(), g.yaw.get_expo());
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

		cliSerial->printf("%d, %d, %d, %d\n", pwm_output[CH_1], pwm_output[CH_2], pwm_output[CH_3], pwm_output[CH_4]);

        if(cliSerial->available() > 0) {
            delay(20);
            while (cliSerial->read() != -1); /* flush */

            //save_eeprom();

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


static void
print_blanks(int16_t num)
{
    while(num > 0) {
        num--;
        cliSerial->println("");
    }
}

static void
print_divider(void)
{
    for (int i = 0; i < 40; i++) {
        cliSerial->print_P(PSTR("-"));
    }
    cliSerial->println();
}



static int8_t
test_eedump(uint8_t argc, const Menu::arg *argv)
{
    uintptr_t i, j;

    // hexdump the EEPROM
    for (i = 0; i < EEPROM_MAX_ADDR; i += 16) {
        cliSerial->printf_P(PSTR("%04x:"), i);
        for (j = 0; j < 16; j++)
            cliSerial->printf_P(PSTR(" %02x"), eeprom_read_byte((const uint8_t *)(i + j)));
        cliSerial->println();
    }
    return(0);
}


// Initialise the EEPROM to 'factory' settings (mostly defined in APM_Config.h or via defaults).
// Called by the setup menu 'factoryreset' command.
static int8_t
setup_factory(uint8_t argc, const Menu::arg *argv)
{
    int16_t c;

    cliSerial->printf_P(PSTR("\n'Y' = factory reset, any other key to abort:\n"));

    do {
        c = cliSerial->read();
    } while (-1 == c);

    if (('y' != c) && ('Y' != c))
        return(-1);

    AP_Param::erase_all();
    cliSerial->printf_P(PSTR("\nReboot APM"));

    delay(1000);
    //default_gains();

    for (;; ) {
    }
    // note, cannot actually return here
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

    for (uintptr_t i = 0; i < EEPROM_MAX_ADDR; i++) {
        eeprom_write_byte((uint8_t *) i, b);
    }

    cliSerial->printf_P(PSTR("done\n"));
}



static int8_t
setup_tether(uint8_t argc, const Menu::arg *argv)
{
    if (!strcmp_P(argv[1].str, PSTR("on"))) {
		g.tether.set_and_save(1);
	    cliSerial->printf_P(PSTR("\nTether on\n"));

    }else{
	    cliSerial->printf_P(PSTR("\nTether off\n"));
		g.tether.set_and_save(0);
    }
    return 0;
}
