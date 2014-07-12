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


// -------------------------------

void
TX_Channel::zero_min_max()
{
    _adc_min = _adc_max = 600;
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

float
TX_Channel::get_PWM_angle(bool _raw)
{
	float input;
    float _adc_trim_high = _adc_trim + _dead_zone;
    float _adc_trim_low  = _adc_trim - _dead_zone;
		
	if(_adc_in > _adc_trim_high){ // above dead_zone:
        input = (_adc_in - _adc_trim_high) / (_adc_max - _adc_trim_high);
        
	}else if(_adc_in < _adc_trim_low){ // below dead_zone:
        input = -(_adc_trim_low - _adc_in) / (_adc_trim_low - _adc_min);
	
	}else{
	    input = 0;
	
	}
	if(_reverse)
	    input = -input;
	    
	input = max(input, -1);
	input = min(input, 1);
	

	if(input < 0){
		input = -(pow(-input, _expo_precalc));
        if(_raw)
            return input;
        else
    		return 1500 + (int16_t)(input * 500.0f);
	}else if (input > 0){
		input = pow(input, _expo_precalc);
        if(_raw)
            return input;
        else
    		return 1500 + (int16_t)(input * 500.0f);
	}else{
        if(_raw)
            return 0;
        else
    		return 1500;
	}
}

int16_t
TX_Channel::get_PWM_linear()
{
	float input;
    // this is for linear inputs like throttle
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

void
TX_Channel::set_reverse(bool reverse)
{
    _reverse = reverse;
}

bool
TX_Channel::get_reverse(void)
{
    return _reverse;
}

void
TX_Channel::set_dead_zone(int16_t dead_zone)
{
    _dead_zone = dead_zone;
}

int16_t
TX_Channel::get_dead_zone(void)
{
    return _dead_zone;
}

void
TX_Channel::set_expo(uint8_t expo)
{
	_expo = expo;
	_expo = max(_expo, 0);
	_expo = min(_expo, 100);
	_expo_precalc = pow(4.0,((float)_expo/100.0));
	Serial.printf_P(PSTR("set_exp %d = %1.4f\n\n"), expo, _expo_precalc);

    //_expo.save();
}

uint8_t
TX_Channel::get_expo(void)
{
    return _expo;
}


void
TX_Channel::load_eeprom(void)
{
    /*
    _adc_min.load();
    _adc_trim.load();
    _adc_max.load();
    _expo.load();
    _dead_zone.load();
    */
	_expo_precalc = pow(4.0,((float)_expo/100.0));
	Serial.printf_P(PSTR("load_exp %1.4f\n\n"), _expo_precalc);
}

void
TX_Channel::save_eeprom(void)
{
    /*_adc_min.save();
    _adc_trim.save();
    _adc_max.save();
    _expo.save();
    _dead_zone.save();
    */
}
