/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#define THISFIRMWARE "ArduRadio V.2"
/*
 *  ArduCopter Version 2.9
 *  Lead author:	Jason Short

 *  This firmware is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *
 *
 */

////////////////////////////////////////////////////////////////////////////////
// Header includes
////////////////////////////////////////////////////////////////////////////////

#include <FastSerial.h>
#include <AP_Common.h>
//#include <I2C.h>
#include <Wire.h>
#include <AC_PID.h>             // PID library

#include <AP_Param.h>
#include <DigitalWriteFast.h>
//#include <Wire.h>
#include <math.h>
#include <AP_Menu.h>
//#include <AP_TimerProcess.h>    // TimerProcess is the scheduler for MPU6000 reads.
#include <TX_Channel.h>
#include <avr/interrupt.h>

#include <Adafruit_ADS1015_orig.h>

#include "defines.h"
#include "config.h"

// Local modules
#include "Parameters.h"
// setup the var_info table
AP_Param param_loader(var_info, WP_START_BYTE);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
//
// Global parameters are all contained within the 'g' class.
//
static Parameters g;


//static bool pressed = false;

//Adafruit_ADS1015 ads;     /* Use thi for the 12-bit version */
Adafruit_ADS1015_orig ads;

// Setup Serial port
FastSerialPort0(Serial);
static FastSerial *cliSerial = &Serial;

uint8_t trim_counter;
uint8_t current_mode;
bool mode_change_flag;
int16_t mode_pwm[] = {1100, 1300, 1400, 1500, 1680, 1900};



// used to enter CLI
static uint8_t	crlf_count;

int16_t filter1[]={0,0,0,0};
int16_t filter2[]={0,0,0,0};
int16_t filter3[]={0,0,0,0};
int16_t filter4[]={0,0,0,0};
uint8_t pointer;

// This is the help function
// PSTR is an AVR macro to read strings from flash memory
// printf_P is a version of print_f that reads from flash memory
static int8_t   main_menu_help(uint8_t argc, const Menu::arg *argv)
{
    cliSerial->printf_P(PSTR("Commands:\n"
                         "  ppm\n"
                         "  cal\n"
                         "  adc\n"
                         "  expo\n"
                         "  tether\n"
                         "  show\n"
                         "  proto\n"
                         "  eedump\n"
                         "  erase\n"
                         "  reset\n"
                         "\n"));
    return(0);
}
static int8_t   test_ppm			(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   test_adc			(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   test_expo			(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   test_show			(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   setup_tether		(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   test_cal_sticks		(uint8_t argc, const Menu::arg *argv);         // in test.cpp
static int8_t   test_eedump			(uint8_t argc, const Menu::arg *argv);
static int8_t   test_proto		      (uint8_t argc, const Menu::arg *argv);
static int8_t   setup_factory       (uint8_t argc, const Menu::arg *argv);
static int8_t   setup_erase         (uint8_t argc, const Menu::arg *argv);


// Command/function table for the top-level menu.
const struct Menu::command main_menu_commands[] PROGMEM = {
//   command		function called
//   =======        ===============
    {"erase",                       setup_erase},
    {"reset",                       setup_factory},
    {"ppm",                	test_ppm},
    {"cal",	              	test_cal_sticks},
    {"adc",              	test_adc},
    {"expo",              	test_expo},
    {"tether",              setup_tether},
    {"proto",              test_proto},
    {"show",              	test_show},
    {"help",                main_menu_help},
    {"eedump",              test_eedump},

};

// Create the top-level menu object.
MENU(main_menu, THISFIRMWARE, main_menu_commands);

#define CH_1 0
#define CH_2 1
#define CH_3 2
#define CH_4 3
#define CH_5 4
#define CH_6 5
#define CH_7 6
#define CH_8 7

#define STEP 20

//EEPRROM
#define EE_CH1_LOW 0x01
#define EE_CH1_MID 0x03
#define EE_CH1_HIGH 0x05

#define EE_CH2_LOW 0x07
#define EE_CH2_MID 0x09
#define EE_CH2_HIGH 0x0B

#define EE_CH3_LOW 0x0D
#define EE_CH3_MID 0x0F
#define EE_CH3_HIGH 0x11

#define EE_CH4_LOW 0x13
#define EE_CH4_MID 0x15
#define EE_CH4_HIGH 0x17

#define EE_CH1_EXPO 0x19
#define EE_CH2_EXPO 0x1B
#define EE_CH3_EXPO 0x1D
#define EE_CH4_EXPO 0x1F

#define BUF_LEN 4


// Receive buffer
static union {
	//int32_t long_value;
	int16_t int_value;
	uint8_t bytes[];
} bytes_union;

struct Gimbal {
	uint8_t head1;
	uint8_t head2;
	int16_t roll;
	int16_t pitch;
	int16_t sum;
};

// Receive buffer
static union {
	Gimbal gimbal;
	uint8_t bytes[];
} _buffer;



uint8_t serialBuffer[BUF_LEN]={0,0,0,0};

static struct {
	int16_t roll;
	int16_t pitch;
	int16_t sum;
} gimbal;

int16_t adc_roll, adc_pitch, adc_throttle, adc_yaw;

//TX_Channel roll;
//TX_Channel pitch;
//TX_Channel throttle;
//TX_Channel yaw;
int16_t ppm_test = 1000;
int8_t ppm_dir = STEP;

int8_t press;

int16_t pwm_output[8];

// Time in microseconds of main control loop
static uint8_t counter_one_herz;

volatile uint16_t _ppm_sent;
volatile bool RC_flag;
static uint32_t fast_loopTimer;
static uint32_t bounce;
#define DEBOUNCER 100000

bool tetherGo = false;

void setup()
{
    // Load the default values of variables listed in var_info[]s
    //AP_Param::setup_sketch_defaults();

    Serial.begin(57600);
    const prog_char_t *msg = PSTR("\nInit 3DRC\nPress ENTER 3 times to start interactive setup\n");
    cliSerial->println_P(msg);
	init_arduRC();
}

#define SW2 (1<<2)
#define SW3 (1<<3)
#define SW4 (1<<4)
#define SW5 (1<<5)
#define SW6 (1<<6)
#define SW7 (1<<7)


void loop()
{
	uint32_t timer = micros();
	// 1,000,000 / 5,000 = 200hz
	if ((timer - fast_loopTimer) >= 5000) {
		fast_loopTimer = timer;
		read_adc();
	}

	// test switch output
	//test_switches();

    // Only do the CLI if the three carriage returns
    // happen within 5 seconds of boot
	if(timer < 5000000){
		cli_update();
	}else{
	    // else read input via serial for
	    // tether project
		readCommands();
	}

	// updated at 50hz by internal timers
	if(RC_flag){
		RC_flag = false;

		// g.tether =
		if(g.tether && tetherGo){
			update_tether();
		}else{
			update_sticks();
		}

		counter_one_herz++;
		if(counter_one_herz == 50){
			super_slow_loop();
			counter_one_herz = 0;
		}
	}

	// set by pin chnage interrupt
	if(mode_change_flag){
		mode_change_flag = false;
		if((timer - bounce) > DEBOUNCER){
			bounce = timer;
			if(g.tether){
				update_tether_options();
			}else{
				update_control_mode();
			}
		}
	}
}


static void
super_slow_loop()
{
    //Serial.println("hello");
}

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

static void
update_sticks()
{
	adc_roll 		= (filter1[0] + filter1[1] + filter1[2] + filter1[3]) / 4;
	adc_pitch 		= (filter2[0] + filter2[1] + filter2[2] + filter2[3]) / 4;
	adc_throttle 	= (filter3[0] + filter3[1] + filter3[2] + filter3[3]) / 4;
	adc_yaw 		= (filter4[0] + filter4[1] + filter4[2] + filter4[3]) / 4;

	g.roll.set_ADC(adc_roll);
	g.pitch.set_ADC(adc_pitch);
	g.throttle.set_ADC(adc_throttle);
	g.yaw.set_ADC(adc_yaw);

	pwm_output[CH_1] = g.roll.get_PWM(true);
	pwm_output[CH_2] = g.pitch.get_PWM(true);
	pwm_output[CH_3] = g.throttle.get_PWM(false);
	pwm_output[CH_4] = g.yaw.get_PWM(true);
}

static void
update_tether()
{
	adc_roll 		= (filter1[0] + filter1[1] + filter1[2] + filter1[3])/4;
	adc_pitch 		= (filter2[0] + filter2[1] + filter2[2] + filter2[3])/4;
	adc_throttle 	= (filter3[0] + filter3[1] + filter3[2] + filter3[3])/4;
	adc_yaw 		= (filter4[0] + filter4[1] + filter4[2] + filter4[3])/4;

	g.roll.set_ADC(adc_roll);
	g.pitch.set_ADC(adc_pitch);
	g.throttle.set_ADC(adc_throttle);
	g.yaw.set_ADC(adc_yaw);

	int16_t _roll = (g.roll.get_PWM(true) - 1500) * 9;
	int16_t _pitch = (g.pitch.get_PWM(true) - 1500) * 9;

	int32_t roll_error 	= constrain((_roll - gimbal.roll), -1500, 1500);
	//int32_t pitch_error = constrain((_pitch - gimbal.pitch), -1500, 1500);

    int16_t roll_out  	= g.pid_roll.get_pid(roll_error, .02);
    //int16_t pitch_out  	= g.pid_pitch.get_pid(pitch_error, .02);

	pwm_output[CH_1] 	= 1500 + constrain(roll_out, -500, 500);
	//pwm_output[CH_2] 	= 1500 + constrain(pitch_out, -500, 500);


	pwm_output[CH_2] 	= g.pitch.get_PWM(true);
	pwm_output[CH_3] 	= g.throttle.get_PWM(false);
	pwm_output[CH_4] 	= 1500;
}


static void
cli_update()
{
    // process received bytes
    while(cliSerial->available())
    {
        uint8_t c = cliSerial->read();

        /* allow CLI to be started by hitting enter 3 times, if no
         *  heartbeat packets have been received */
		if (c == '\n' || c == '\r') {
			crlf_count++;
		} else {
			crlf_count = 0;
		}
		if (crlf_count == 3) {
			run_cli(cliSerial);
		}
    }
}






//static int8_t
//test_mode(uint8_t argc, const Menu::arg *argv)
//{
/*
	int16_t pwm_out;
    cliSerial->printf_P(PSTR("Test Mode\n\n"));
    Serial.printf("expo %d, %1.4f\n", (int16_t)roll._expo, roll._expo_precalc);

	for(uint16_t i = 0; i <= 4000; i+=20){
		pwm_out = roll.get_PWM(i, true);
		delay(5);
		cliSerial->printf("%d, %d\n", i, pwm_out);
	}
*/
//    return 0;
//}
