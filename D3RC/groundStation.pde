// Receive buffer
static union {
	//int32_t long_value;
	int16_t int_value;
	uint8_t bytes[];
} bytes_union;


//	memcpy(bytes_union.bytes, &buff[1], 2);
//	wheel.left_distance += bytes_union.int_value;


void readCommands(void)
{
	uint8_t input;
	static uint8_t step;
	if(cliSerial->available()){
		switch(step){
			case 0:
				input = cliSerial->read();
				if(97 == input){
					step = 1;
				}
			break;

			case 1:
				input = cliSerial->read();
				if(124 == input){
					step = 2;
				}else{
					step = 0;
				}
			break;

			case 2:
				if(cliSerial->available() >= 6){
					int16_t tmp_roll, tmp_pitch;

					bytes_union.bytes[0] = cliSerial->read();
					bytes_union.bytes[1] = cliSerial->read();
					tmp_roll = bytes_union.int_value;

					bytes_union.bytes[0] = cliSerial->read();
					bytes_union.bytes[1] = cliSerial->read();
					tmp_pitch = bytes_union.int_value;


					bytes_union.bytes[0] = cliSerial->read();
					bytes_union.bytes[1] = cliSerial->read();
					tether_gimbal.sum = bytes_union.int_value;

					//cliSerial->printf("!%d, %d, %d\n", tmp_roll, tmp_pitch, tether_gimbal.sum);
					if((tmp_roll + tmp_pitch) == tether_gimbal.sum){
						tether_gimbal.roll = tmp_roll;
						tether_gimbal.pitch = tmp_pitch;
					}

					step = 0;
				}
			break;
		}
	}
}


// 27139, 9985