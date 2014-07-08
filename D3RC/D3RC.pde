/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#define THISFIRMWARE "ArduRadio V.21"
/*
 *  ArduCopter Version 2.9
 *  Lead author:	Jason Short

 *  This firmware is free software; you can redistribute it and / or
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
#include <avr/eeprom.h>
#include <Wire.h>
#include <AC_PID.h>
#include <DigitalWriteFast.h>
#include <math.h>
#include <AP_Menu.h>
#include <TX_Channel.h>
#include <avr/interrupt.h>
#include "defines.h"
#include "config.h"

#include <Adafruit_ADS1015.h>
Adafruit_ADS1015 ads;    

// Setup Serial port
FastSerialPort0(Serial);
static FastSerial *cliSerial = &Serial;


TX_Channel roll;
TX_Channel pitch;
TX_Channel throttle;
TX_Channel yaw;
TX_Channel gimbal;

AC_PID  pid_pitch(RATE_ROLL_P,		RATE_ROLL_I,		RATE_ROLL_D,		RATE_ROLL_IMAX);
AC_PID  pid_roll(RATE_ROLL_P,		RATE_ROLL_I,		RATE_ROLL_D,		RATE_ROLL_IMAX);


// used to enter CLI
static uint8_t	crlf_count;

// -------------------------------------------
// Radio globals
// -------------------------------------------

uint8_t current_mode;
bool mode_change_flag;
int16_t mode_pwm[] = {1100, 1300, 1400, 1500, 1680, 1900};


// filters for 200hz reading
int16_t filter1[] = {0, 0, 0, 0};
int16_t filter2[] = {0, 0, 0, 0};
int16_t filter3[] = {0, 0, 0, 0};
int16_t filter4[] = {0, 0, 0, 0};
uint8_t pointer;


// final reading of stick input
int16_t adc_roll, adc_pitch, adc_throttle, adc_yaw, adc_gimbal;
int16_t pwm_output[8];

volatile bool RC_flag;

struct Tether_gimbal {
	uint8_t head1;
	uint8_t head2;
	int16_t roll;
	int16_t pitch;
	int16_t sum;
};

static struct {
	int16_t roll;
	int16_t pitch;
	int16_t sum;
} tether_gimbal;


// -------------------------------------------
// Tether globals
// -------------------------------------------

bool tether = false;
bool tetherGo = false;



// -------------------------------------------
// system globals
// -------------------------------------------

// Time in microseconds of main control loop
static uint8_t counter_one_herz;
static uint32_t fast_loopTimer;
// used to debounce button presses
static uint32_t bounce;


void setup()
{
    // Load the default values of variables listed in var_info[]s
    //AP_Param::setup_sketch_defaults();

    Serial.begin(57600);
    const prog_char_t *msg = PSTR("\nInit 3DRC\nPress ENTER 3 times to start interactive setup\n");
    cliSerial->println_P(msg);

	init_arduRC();

    //delay(500);
    cliSerial->printf_P(PSTR("Begin\n"));

	if(~PIND & SW3){
	    tether = true;
    	cliSerial->printf_P(PSTR("Tether ON\n"));
	}
}



void loop()
{
	uint32_t timer = micros();
	// 1,000,000 / 5,000 = 200hz
	// 1,000,000 / 20,000 = 50hz
	if((timer - fast_loopTimer) >= 20000){
		fast_loopTimer = timer;
		read_adc();
	}

	// test switch output
	///test_switches();

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

        // IS CH 7 high?
        if(~PINB & 1){
        	pwm_output[CH_7] = 1000;
        }else{
        	pwm_output[CH_7] = 2000;
        }

		// tether
		if(tether && tetherGo){
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
    		//cliSerial->printf_P(PSTR("CH7 %d\n"), pwm_output[CH_7]);

			if(tether){
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
cli_update()
{
    // process received bytes
    while(cliSerial->available())
    {
        uint8_t c = cliSerial->read();

        /* allow CLI to be started by hitting enter 3 times, if no
         *  heartbeat packets have been received */
		if(c == '\n' || c == '\r'){
			crlf_count++;
		}else{
			crlf_count = 0;
		}
		if(crlf_count == 3){
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

	for(uint16_t i = 0; i <= 4000; i += 20){
		pwm_out = roll.get_PWM(i, true);
		delay(5);
		cliSerial->printf("%d, %d\n", i, pwm_out);
	}
*/
//    return 0;
//}
