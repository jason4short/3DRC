// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifndef _DEFINES_H
#define _DEFINES_H

// Just so that it's completely clear...
#define ENABLED                 1
#define DISABLED                0

// this avoids a very common config error
#define ENABLE ENABLED
#define DISABLE DISABLED

// used to debounce button input
#define DEBOUNCER 100000


#define CH_1 0
#define CH_2 1
#define CH_3 2
#define CH_4 3
#define CH_5 4
#define CH_6 5
#define CH_7 6
#define CH_8 7


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


#define SW2 (1<<2)
#define SW3 (1<<3)
#define SW4 (1<<4)
#define SW5 (1<<5)
#define SW6 (1<<6)
#define SW7 (1<<7)




#endif // _DEFINES_H
