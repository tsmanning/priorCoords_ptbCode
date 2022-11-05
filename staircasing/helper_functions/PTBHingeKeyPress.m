% Interprets key presses for the PTB Hinge Experiments
function [response exit] = PTBHingeKeyPress
%     global gexp
%     global grender
%     global gmonitor
%     global ghinge

    % Create reference variables for possible keys
        one = KbName('1!');
        onepad = KbName('1');
        two = KbName('2@');
        twopad = KbName('2');
        three = KbName('3#');
        threepad = KbName('3');
    if IsOSX || IsOS9
        escapeKey = KbName('ESCAPE');
        left = KbName('LeftArrow');
        right = KbName('RightArrow');
        up = KbName('UpArrow');
        down = KbName('DownArrow');
        space = KbName('SPACE');
      % on a Windows system keypad and keyboard inputs
      % seem to be the same, but Mac treats each
      % device separately        
        devices=PsychHID('Devices');
        kbsNum = find([devices(:).usageValue] == 6);
        if isempty(kbsNum) 
            error('No keyboard devices were found.')
        end
    elseif IsWin
        escapeKey = KbName('esc');
        left = KbName('left');
        right = KbName('right');
        up = KbName('up');
        down = KbName('down');
        space = KbName('space');
    end
    
   [keyIsDown, seconds, keyCode]=KbCheck;
   %poll all other keyboard devices on a mac
   if ~IsWin && length(kbsNum) > 1
       for i=1:length(kbsNum)
            [key, seconds, codes] = KbCheck( kbsNum(i) );
            %flag is thrown if a key is pressed on any of the keyboards
            keyIsDown = keyIsDown | key;
            keyCode = keyCode | codes;
       end
    end
    
    exit = 0;       % exit tells the program whether or not it should quit
    response = -1;   % default response
    
    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
%           %%%%% DEBUGGING CODE
%         if keyCode(left)
%             sound(0.5*sin(2*pi*[0:1/44100:.05]*300),44000);
%             sound(0.5*sin(2*pi*[0:1/44100:.10]*200),44000);
%             % Rotate the stimulus
%             ghinge.front.baseAngle =  mod(ghinge.front.baseAngle - 10,360);
%             update = 1;
%         elseif keyCode(right)
%             sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
%             sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
%             sound(0.5*sin(2*pi*[0:1/44100:.10]*1000),44000);
%             % Rotate the stimulus
%             ghinge.front.baseAngle =  mod(ghinge.front.baseAngle + 10,360);
%             update = 1;
%         elseif keyCode(up)
%             % Rotate the monitor
%             gmonitor.rotation =  mod(gmonitor.rotation + 10,360);
%             update = 1;
%         elseif keyCode(down)
%             % Rotate the monitor
%             gmonitor.rotation =  mod(gmonitor.rotation - 10,360);
%             update = 1;
%         elseif keyCode(space)
%             % Toggle display of stimulus
%             grender.stimulus = 1 - grender.stimulus;
        if (keyCode(one) || keyCode(onepad))
            response = 1;
        elseif (keyCode(two) || keyCode(twopad))
            response = 2;
        elseif (keyCode(three) || keyCode(threepad))
            response = 0;           % This tells the program to skip the trial
        elseif keyCode(escapeKey)
           % Tell the main program to exit 
           exit = 1;
        else
           % Unrecognized key.  Make error sound 
           sound(0.5*sin(2*pi*[0:1/44100:.05]*300),44000);
           sound(0.5*sin(2*pi*[0:1/44100:.20]*200),44000); 
        end

        % If the user holds down a key, KbCheck will report multiple events.
        % To condense multiple 'keyDown' events into a single event, we wait until all
        % keys have been released.
        while KbCheck; end
    end