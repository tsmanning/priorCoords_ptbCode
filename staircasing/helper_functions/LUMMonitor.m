function monitor = LUMMonitor(monitor,computer,winRect,gexp)


        % Setup the monitor and window settings
        
        %monitor in pixels
        gmonitor.screen_width_p = winRect(3);
        gmonitor.screen_height_p = winRect(4);
        
        %monitor in mm (note: need to measure this manually
        switch computer
            case 0
                gmonitor.screen_width_mm = 338;
                gmonitor.screen_height_mm = 272;
                
                display('You are debugging');
                
            case 1
                gmonitor.screen_width_mm = 338;
                gmonitor.screen_height_mm = 272;
                
                display(['You are using your macbook: ' num2str(gmonitor.screen_width_mm) ...
                        ' by ' num2str(gmonitor.screen_height_mm) 'mm.']);
            case 2
                gmonitor.screen_width_mm = 357;
                gmonitor.screen_height_mm = 243;
                
                display(['You are using the haploscope: ' num2str(gmonitor.screen_width_mm) ...
                        ' by ' num2str(gmonitor.screen_height_mm) 'mm.']);
                
            otherwise
                gmonitor.screen_width_mm = 406;
                gmonitor.screen_height_mm = 304;
                
                display(['You are using a mystery machine: ' num2str(gmonitor.screen_width_mm) ...
                        ' by ' num2str(gmonitor.screen_height_mm) 'mm.']);
        end
        
        gmonitor.win_pos_x = 0;
        gmonitor.win_pos_y = 0;
        gmonitor.win_width_mm = gmonitor.screen_width_mm;
        gmonitor.win_height_mm = gmonitor.screen_height_mm;
        gmonitor.win_width_p = gmonitor.screen_width_p;
        gmonitor.win_height_p = gmonitor.screen_height_p;
        gmonitor.distance = gexp.monitorDistanceMm;
        gmonitor.mmToP = gmonitor.screen_width_mm / gmonitor.screen_width_p;