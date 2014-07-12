// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifndef _DEFINES_H
#define _DEFINES_H

// Just so that it's completely clear...
#define ENABLED                 1
#define DISABLED                0

// this avoids a very common config error
#define ENABLE ENABLED
#define DISABLE DISABLED


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

#define EE_CH6_LOW 0x21
#define EE_CH6_HIGH 0x23

#define EE_CH1_REV 0x25
#define EE_CH2_REV 0x26
#define EE_CH3_REV 0x27
#define EE_CH4_REV 0x28
#define EE_CH5_REV 0x29
#define EE_CH6_REV 0x2A
#define EE_CH7_REV 0x2B
#define EE_CH8_REV 0x2C
#define EE_CH6_EXPO 0x2D



#define ADC_AVR     1
#define ADC_I2C     2


#define APM_BOARD           1
#define PRO_MINI_BOARD      2

// used to debounce button input
#define DEBOUNCER 400000


#define CH_1 0
#define CH_2 1
#define CH_3 2
#define CH_4 3
#define CH_5 4
#define CH_6 5
#define CH_7 6
#define CH_8 7



#define preset_A_button 1
#define preset_B_button 2







#endif // _DEFINES_H
