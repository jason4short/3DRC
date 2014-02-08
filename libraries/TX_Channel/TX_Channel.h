// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-
//	Code by Jason Short. DIYDrones.com
/// @file	TX_Channel.h
/// @brief	TX_Channel manager, with EEPROM-backed storage of constants.

#ifndef TX_Channel_h
#define TX_Channel_h

#include <AP_Common.h>

/// @class	TX_Channel
/// @brief	Object managing one RC channel
class TX_Channel {
public:
    /// Constructor
    ///
    /// @param key      EEPROM storage key for the channel trim parameters.
    /// @param name     Optional name for the group.
    ///
    TX_Channel():
    	_reverse(false)
    {
    }

    // setup min and max radio values in CLI
    void        update_min_max();
    void        zero_min_max();
    // startup
    void        load_eeprom(void);
    void        save_eeprom(void);

    void        detect_trim(void);

	// returns the PWM output un microseconds
	// calculates the expo
    int16_t    	get_PWM(bool use_trim);
    void    	set_ADC(int16_t adc_input);

    // setup the control preferences
    void       	set_reverse(bool reverse);
    bool       	get_reverse(void);

    void       	set_expo(uint8_t expo);
    uint8_t    	get_expo(void);

	bool 		_reverse;

    int16_t     _adc_min;
    int16_t     _adc_trim;
    int16_t     _adc_max;
	int8_t	    _expo;
    int16_t 	_adc_in;

    float 		_expo_precalc;
    int16_t    	_adc_buffer;
    int16_t     _dead_zone;


private:
};

#endif

/*
    	_adc_min(0),
    	_adc_trim(2000),
    	_adc_max(4000)
*/