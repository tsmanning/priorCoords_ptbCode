function monitor = Monitor(monitor,computer,winRect,gexp)


        % Setup the monitor and window settings
        
        %monitor in pixels
        monitor.screen_width_p = winRect(3);
        monitor.screen_height_p = winRect(4);
        
        %monitor in mm (note: need to measure this manually
        switch computer
            case 0
                monitor.screen_width_mm    = 332;
                monitor.screen_height_mm   = 207;
                monitor.gamma              = 2.2;
                monitor.glevel             = round((0.5^(1/monitor.gamma))*255);
                
                display('You are debugging');
                
            case 1
                monitor.screen_width_mm    = 332;
                monitor.screen_height_mm   = 207;
                monitor.gamma              = 2.2;
                
                display(['You are using your macbook: ' num2str(monitor.screen_width_mm) ...
                        ' by ' num2str(monitor.screen_height_mm) 'mm.']);
            case 2
                monitor.screen_width_mm = 357;
                monitor.screen_height_mm = 243;
                
                display(['You are using the haploscope: ' num2str(monitor.screen_width_mm) ...
                        ' by ' num2str(monitor.screen_height_mm) 'mm.']);
                
            otherwise
                monitor.screen_width_mm = 406;
                monitor.screen_height_mm = 304;
                
                display(['You are using a mystery machine: ' num2str(monitor.screen_width_mm) ...
                        ' by ' num2str(monitor.screen_height_mm) 'mm.']);
        end
        
        monitor.win_pos_x      = 0;
        monitor.win_pos_y      = 0;
        monitor.win_width_mm   = monitor.screen_width_mm;
        monitor.win_height_mm  = monitor.screen_height_mm;
        monitor.win_width_p    = monitor.screen_width_p;
        monitor.win_height_p   = monitor.screen_height_p;
        monitor.distance       = gexp.monitorDistanceMm;
        monitor.mmToP          = monitor.screen_width_mm / monitor.screen_width_p;
        