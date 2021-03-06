// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-
//
#ifndef __ARDUCOPTER_CONFIG_H__
#define __ARDUCOPTER_CONFIG_H__
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
//
//  DO NOT EDIT this file to adjust your configuration.  Create your own
//  APM_Config.h and use APM_Config.h.example as a reference.
//
// WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
///
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// Default and automatic configuration details.
//
// Notes for maintainers:
//
// - Try to keep this file organised in the same order as APM_Config.h.example
//
#include "defines.h"


#define GIMBAL DISABLED
//#define GIMBAL ENABLED

#if BOARD_TYPE == PRO_MINI_BOARD
    // Analog pin 0 for gimbal control
    #define CH6_GIMBAL 0
    #define SW1 (1<<1)
    #define SW2 (1<<2)
    #define SW3 (1<<3)
    #define SW4 (1<<4)
    #define SW5 (1<<5)
    #define SW6 (1<<6)
    #define SW7 (1<<7)

#elif BOARD_TYPE == APM_BOARD
    // Analog pin 0 for gimbal control
    #define CH6_GIMBAL 4
    #define SW1 (1<<1)
    #define SW2 (1<<2)
    #define SW3 (1<<3)
    #define SW4 (1<<4)
    #define SW5 (1<<5)
    #define SW6 (1<<6)
    #define SW7 (1<<7)
#endif


//////////////////////CONFIGURATION///////////////////////////////
#define MAX_CHANNELS 8			//set the number of chanels
//#define PPM_FRAME 22500		//set the PPM frame length in microseconds (1ms = 1000µs)	//http://www.mftech.de/ppm_en.htm
#define PPM_FRAME 20025
#define PPM_PULSE 400			//set the pulse length
#define POLARITY 0				//set polarity of the pulses: 1 is positive, 0 is negative
//////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// Loiter position control gains
//
#ifndef RATE_ROLL_P
 # define RATE_ROLL_P             		.1f
#endif

#ifndef RATE_ROLL_I
 # define RATE_ROLL_I             		0.0f
#endif

#ifndef RATE_ROLL_D
 # define RATE_ROLL_D          			0
#endif

#ifndef RATE_ROLL_IMAX
 # define RATE_ROLL_IMAX          		500
#endif








#endif // __ARDUCOPTER_CONFIG_H__
