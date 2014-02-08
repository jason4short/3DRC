// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifndef PARAMETERS_H
#define PARAMETERS_H

#include <AP_Common.h>

// Global parameter class.
//
class Parameters {
public:
    // The version of the layout as described by the parameter enum.
    //
    // When changing the parameter enum in an incompatible fashion, this
    // value should be incremented by one.
    //
    // The increment will prevent old parameters from being used incorrectly
    // by newer code.
    //
    static const uint16_t        k_format_version = 1;

    // The parameter software_type is set up solely for ground station use
    // and identifies the software type (eg ArduPilotMega versus
    // ArduCopterMega)
    // GCS will interpret values 0-9 as ArduPilotMega.  Developers may use
    // values within that range to identify different branches.
    //
    static const uint16_t        k_software_type = 3;          // 0 for APM
                                                                // trunk

    // Parameter identities.
    //
    // The enumeration defined here is used to ensure that every parameter
    // or parameter group has a unique ID number.	This number is used by
    // AP_Param to store and locate parameters in EEPROM.
    //
    // Note that entries without a number are assigned the next number after
    // the entry preceding them.	When adding new entries, ensure that they
    // don't overlap.
    //
    // Try to group related variables together, and assign them a set
    // range in the enumeration.	Place these groups in numerical order
    // at the end of the enumeration.
    //
    // WARNING: Care should be taken when editing this enumeration as the
    //			AP_Param load/save code depends on the values here to identify
    //			variables saved in EEPROM.
    //
    //
    enum {
        // Layout version number, always key zero.
        //
        k_param_format_version = 0,
        k_param_software_type,
        k_param_sysid_this_mav,
        k_param_pid_pitch,
        k_param_pid_roll,
        k_param_roll,
        k_param_pitch,
        k_param_throttle,
        k_param_yaw,
        k_param_tether

    };

    AP_Int16	format_version;
    AP_Int8 	software_type;
    AP_Int16	sysid_this_mav;

	TX_Channel roll;
	TX_Channel pitch;
	TX_Channel throttle;
	TX_Channel yaw;

    AC_PID  	pid_pitch;
    AC_PID  	pid_roll;
    AP_Int8 	tether;

    // Note: keep initializers here in the same order as they are declared
    // above.
    Parameters() :
        roll(),
        pitch(),
        throttle(),
        yaw(),

        // PID controller	initial P	        initial I		    initial D			initial imax
        //-----------------------------------------------------------------------------------------------------
        pid_pitch			(RATE_ROLL_P,		RATE_ROLL_I,		RATE_ROLL_D,		RATE_ROLL_IMAX),
        pid_roll			(RATE_ROLL_P,		RATE_ROLL_I,		RATE_ROLL_D,		RATE_ROLL_IMAX)
    {
    }
};

extern const AP_Param::Info        var_info[];

#endif // PARAMETERS_H

