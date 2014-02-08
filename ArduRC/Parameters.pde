/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-
/*
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 *  ArduCopter parameter definitions
 *
 */

#define GSCALAR(v, name, def) { g.v.vtype, name, Parameters::k_param_ ## v, &g.v, {def_value : def} }
#define GGROUP(v, name, class) { AP_PARAM_GROUP, name, Parameters::k_param_ ## v, &g.v, {group_info : class::var_info} }
#define GOBJECT(v, name, class) { AP_PARAM_GROUP, name, Parameters::k_param_ ## v, &v, {group_info : class::var_info} }
#define GOBJECTN(v, pname, name, class) { AP_PARAM_GROUP, name, Parameters::k_param_ ## pname, &v, {group_info : class::var_info} }

const AP_Param::Info var_info[] PROGMEM = {
    // @Param: SYSID_SW_MREV
    // @DisplayName: Eeprom format version number
    // @Description: This value is incremented when changes are made to the eeprom format
    // @User: Advanced
    GSCALAR(format_version, "SYSID_SW_MREV",   2),

    // @Param: SYSID_SW_TYPE
    // @DisplayName: Software Type
    // @Description: This is used by the ground station to recognise the software type (eg ArduPlane vs ArduCopter)
    // @User: Advanced
    GSCALAR(software_type,  "SYSID_SW_TYPE",   Parameters::k_software_type),

    // @Param: SYSID_THISMAV
    // @DisplayName: Mavlink version
    // @Description: Allows reconising the mavlink version
    // @User: Advanced
    GSCALAR(sysid_this_mav, "SYSID_THISMAV",   8),


    GGROUP(pid_pitch,  "PIT_", AC_PID),
    GGROUP(pid_roll,   "RLL", AC_PID),

    // RC channel
    //-----------
    // @Group: RC1_
    // @Path: ../libraries/RC_Channel/RC_Channel.cpp
    GGROUP(roll,    	"TX1_", TX_Channel),
    // @Group: RC2_
    // @Path: ../libraries/RC_Channel/RC_Channel.cpp
    GGROUP(pitch,    	"TX2_", TX_Channel),
    // @Group: RC3_
    // @Path: ../libraries/RC_Channel/RC_Channel.cpp
    GGROUP(throttle,    "TX3_", TX_Channel),
    // @Group: RC4_
    // @Path: ../libraries/RC_Channel/RC_Channel.cpp
    GGROUP(yaw,    		"TX4_", TX_Channel),
    // @Group: RC5_
    // @Path: ../libraries/RC_Channel/RC_Channel.cpp,../libraries/RC_Channel/RC_Channel_aux.cpp

    GSCALAR(tether, 	"TETHR",   0),

    AP_VAREND
};

static void load_parameters(void)
{
	cliSerial->printf_P(PSTR("Load Params from EEPROM %d...\n"), g.format_version.get());

    if (!g.format_version.load() ||
        g.format_version != Parameters::k_format_version) {

        // erase all parameters
        cliSerial->printf_P(PSTR("Firmware change: erasing EEPROM...\n"));
        AP_Param::erase_all();

        // save the current format version
        g.format_version.set_and_save(Parameters::k_format_version);
        cliSerial->println_P(PSTR("done."));
    } else {
        uint32_t before = micros();
        // Load all auto-loaded EEPROM variables
        AP_Param::load_all();
        cliSerial->printf_P(PSTR("load_all took %luus\n"), micros() - before);
    }
}
