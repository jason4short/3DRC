// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-
/*
 *       TX_Channel.cpp - Radio library for Arduino
 *       Code by Jason Short. DIYDrones.com
 *
 *       This library is free software; you can redistribute it and / or
 *               modify it under the terms of the GNU Lesser General Public
 *               License as published by the Free Software Foundation; either
 *               version 2.1 of the License, or (at your option) any later version.
 *
 */

#include <math.h>
#include <avr/eeprom.h>
#include <FastSerial.h>

#if defined(ARDUINO) && ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#include "TX_Channel.h"

const AP_Param::GroupInfo TX_Channel::var_info[] PROGMEM = {
    // @Param: MIN
    // @DisplayName: TX min PWM
    // @Description: TX minimum PWM pulse width. Typically 1000 is lower limit, 1500 is neutral and 2000 is upper limit.
    // @Units: pwm
    // @Range: 800 2200
    // @Increment: 1
    // @User: Advanced
    AP_GROUPINFO("MIN",  0, TX_Channel, _adc_min, 1100),

    // @Param: TRIM
    // @DisplayName: TX trim PWM
    // @Description: TX trim (neutral) PWM pulse width. Typically 1000 is lower limit, 1500 is neutral and 2000 is upper limit.
    // @Units: pwm
    // @Range: 800 2200
    // @Increment: 1
    // @User: Advanced
    AP_GROUPINFO("TRIM", 1, TX_Channel, _adc_trim, 1500),

    // @Param: MAX
    // @DisplayName: TX max PWM
    // @Description: TX maximum PWM pulse width. Typically 1000 is lower limit, 1500 is neutral and 2000 is upper limit.
    // @Units: pwm
    // @Range: 800 2200
    // @Increment: 1
    // @User: Advanced
    AP_GROUPINFO("MAX",  2, TX_Channel, _adc_max, 1900),

    // @Param: REV
    AP_GROUPINFO("EXPO",  3, TX_Channel, _expo, 0),

    // @Param: DZ
    // @DisplayName: TX dead-zone
    // @Description: dead zone around trim.
    // @Units: pwm
    // @Range: 0 200
    // @User: Advanced
    AP_GROUPINFO("DZ",   5, TX_Channel, _dead_zone, 50),

    AP_GROUPEND
};




// -------------------------------

void
TX_Channel::zero_min_max()
{
    _adc_min = _adc_max = 900;
}

void
TX_Channel::update_min_max()
{
    _adc_min = min(_adc_min, _adc_in);
    _adc_max = max(_adc_max, _adc_in);
}

// -------------------------------

// setup the control preferences
void
TX_Channel::detect_trim(void)
{
	// read in the ADC input,
	// save as ADC_trim
	_adc_trim = _adc_in;
}


void
TX_Channel::set_ADC(int16_t adc_input)
{
	_adc_in = adc_input;
	/*
	// filter
	if(_adc_in == 0){
		_adc_in = adc_input;
	}

	_adc_in = (adc_input + _adc_in) / 2;
	*/
}

int16_t
TX_Channel::get_PWM(bool use_trim)
{
	float input;
	if (!use_trim){
		input = (float)(_adc_in - (_adc_min + _dead_zone)) / (float)((_adc_max-_dead_zone) - (_adc_min + _dead_zone));
		input = pow(input, _expo_precalc);
		input = max(input, 0);
		input = min(input, 1);
		input *= 1000.0;

		if(_reverse){
			return 2000 - (int16_t)input;
		}else{
			return 1000 + (int16_t)input;
		}
	}

	if(_adc_in >= _adc_trim){
		input = (float)(_adc_in - _adc_trim) / (float)((_adc_max - _dead_zone) - _adc_trim);
	}else{
		input = (float)(_adc_in - _adc_trim) / (float)(_adc_trim - (_adc_min + _dead_zone));
	}
	input = max(input, -1);
	input = min(input, 1);
	//Serial.printf_P(PSTR("input %1.4f, %1.4f\n"), input, _expo_precalc);


	if(input < 0){
		//input = -((-input)^_expo_precalc);
		input = -(pow(-input, _expo_precalc));
		if(_reverse){
			return 1500 - (int16_t)(input * 500.0f);
		}else{
			return 1500 + (int16_t)(input * 500.0f);
		}
	}else{
		//input = input^_expo_precalc;
		input = pow(input, _expo_precalc);
		//input *= 1000.0;

		if(_reverse){
			return 1500 - (int16_t)(input * 500.0f);
		}else{
			return 1500 + (int16_t)(input * 500.0f);
		}
	}
}

void
TX_Channel::set_reverse(bool reverse)
{
    if (reverse) _reverse = -1;
    else _reverse = 1;
}

bool
TX_Channel::get_reverse(void)
{
    if (_reverse==-1) return 1;
    else return 0;
}

void
TX_Channel::set_expo(uint8_t expo)
{
	_expo = expo;
	_expo = max(_expo, 0);
	_expo = min(_expo, 100);
	_expo_precalc = pow(4.0,((float)_expo/100.0));
	Serial.printf_P(PSTR("set_exp %1.4f\n\n"), _expo_precalc);

    _expo.save();
}

uint8_t
TX_Channel::get_expo(void)
{
    return _expo;
}


void
TX_Channel::load_eeprom(void)
{
    _adc_min.load();
    _adc_trim.load();
    _adc_max.load();
    _expo.load();
    _dead_zone.load();
	_expo_precalc = pow(4.0,((float)_expo/100.0));
	Serial.printf_P(PSTR("load_exp %1.4f\n\n"), _expo_precalc);
}

void
TX_Channel::save_eeprom(void)
{
    _adc_min.save();
    _adc_trim.save();
    _adc_max.save();
    _expo.save();
    _dead_zone.save();
}
