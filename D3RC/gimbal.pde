static void 
gimbal_run()
{
    // 50hz update
        
    // exit if the user inputs
    if(input_rate != 0){
        do_preset = false;
    }

    if(preset_change_flag) {
        preset_change_flag = false;
        update_preset(); 
    }
    // calc camera rotation
    if(do_preset){
        uint32_t delta_time = gimbal_timer - preset_time;
        camera_angle = camera_easing(delta_time, preset_start, preset_change, preset_duration);
    	
    	cliSerial->printf("run %ld\t%1.2f\n", delta_time, camera_angle);


        // check gimbal_timer to exit preset
        if(delta_time >= preset_duration){
    		cliSerial->printf("exit %ld\t%1.2f\n", delta_time, camera_angle);
            do_preset = false;
            current_preset_button = 0;
        }
    }else{
        calc_camera_rate();
        camera_angle += camera_rate * .02;
    }


    // Constrain limits of camera
    if(camera_angle < MIN_ANGLE){
        camera_rate = 0;
        camera_angle = MIN_ANGLE;
        
    }else if (camera_angle > MAX_ANGLE){
        camera_rate = 0;
        camera_angle = MAX_ANGLE;
    }
    
    // output rotation
    //pwm_output[CH_6] = ((camera_angle - 45)* 500) / 45;
    //1000 - 1520
    
    pwm_output[CH_6] = 1000 + (camera_angle / 90.0) * 520;
}



// For Presets
static float
camera_easing(float _time, float _start, float _change, float _duration)
{
    _time /= _duration/2;
	
    if (_time < 1) {
        return ((_change / 2) * (_time * _time)) + _start;
    }else{
        return ((-_change / 2) * ((--_time) * (_time - 2) - 1)) + _start;
    }
}



static void
calc_camera_rate()
{
    float desired_rate = calc_max_rate() * (input_rate * camera_accel);
    
    desired_rate -= (desired_rate - camera_rate_old) * .3;
    camera_rate_old = camera_rate;
    camera_rate = desired_rate;
}

static float
calc_max_rate()
{
    camera_angle = constrain(camera_angle, .1, 89.9);
    float new_speed;
                
    if(camera_angle < 45){
        // 0-45
        if(input_rate < 0){  // up
            new_speed = ease_user_input(camera_angle, 0, 45, 45);
        }else{
            new_speed = 45;
        }
    
    }else{
        // 45-90
        if(input_rate > 0){  // down
            new_speed = ease_user_input(90 - camera_angle, 0, 45, 45);
        }else{
            new_speed = 45;
        }
    }
    return new_speed;
}


static float 
ease_user_input (float _delta, float _start, float _change, float _duration)
{
    _delta = (_delta / _duration) - 1;
    return _change * sqrt(1 - (_delta  * _delta)) + _start;
}



static void
update_preset()
{
    // are we currently performing action?
    // If so just exit
    if(do_preset)
        return;
    
    cliSerial->printf("start %d, cam %1.2f\n", current_preset_button, camera_angle);

    if(current_preset_button == preset_A_button){
        if(isNear(camera_angle, preset_A_value, 1.0)){
            // don't do preset if we are within 1 degree
            // of the desired preset
            cliSerial->printf("near A \n");
            do_preset = false;
            return;
        }else{
            do_preset = true;
            preset_target   = preset_A_value;
        }
    }else{
        if(isNear(camera_angle, preset_B_value, 1.0)){
            // don't do preset if we are within 1 degree
            // of the desired preset
            cliSerial->printf("near B \n");
            do_preset = false;
            return;
        }else{
            do_preset = true;
            preset_target   = preset_B_value;
        }
    }
    
    cliSerial->printf("do preset \n");

    // setup to perform preset 
    preset_time     = gimbal_timer;
    preset_start    = camera_angle;
    preset_change   = preset_target - camera_angle; //  0 - 45 = -45
    
    preset_duration = abs(preset_change *  (MAX_SPEED + 0.5 - preset_speed));
	cliSerial->printf("preset_change %1.4f \n", preset_change);
	cliSerial->printf("preset_speed %1.4f \n", preset_speed);
	cliSerial->printf("preset_duration %1.4f \n", preset_duration);
    //preset_duration = 100;
}

static bool
isNear(float fixed, float newValue, float range)
{
    return fabs(fixed - newValue) <= range;
    //return false;
}


