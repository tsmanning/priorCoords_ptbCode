%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PsychToolbox LUMing Experiment
% 
% Emily Cooper 01/09/2012
%
% Source:
%
% Robin Held
% Banks Lab, UC Berkeley
%
% 06/05/08
%
% Some code taken from stereoteapotdemo created by Patrick Mineault
% (http://www.5etdemi.com/blog/archives/2007/05/ot-stereo-opengl-teapot
% -demo-for-psychtoolbox/)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = LUMExperiment(viewMode)
        
    clear all;
    
    %% Setup global variables

    global gmonitor              % Monitor structure.  Contains window size & screen sizes and positions in pixels and mm        
    global gwin                  % window for PTB
    global gexp                  % Structure containing the settings for the experiment
    global grender               % flag to render stimulus and fixation
    global gscell                % cells containing staircases
        
    computer = 0;               % 0 = debug on mac pro, 1 = mac pro, 2 = haploscope, 3 = in office OLED
    
    try
        
        % Setup experiment 
        % These values will be replaced later if not debuggin
        gexp.subject = 'xxx';
        gexp.ipd = 62;
        gexp.type = 1;
        gexp.training = 0;
        gexp.monitorDistanceMm = 550;
        
        gexp.testimg = 'testimg.jpg';
       
        % Obtain user input for the experimental setup
        gexp = LUMSetup(gexp,computer);

        %intialize luminance and disparity ranges
        gexp.luminanceRange = [5];
        gexp.disparityRange = [];
        
        % Create a flag for completion of the experiment
        gexp.completed = 0;
        
        % stim and fixation durations
        %gexp.fixDuration = .5;   % Duration of fixation stimulus (sec)
        %gexp.stimDuration = 15;      % Duration of stimulus (sec)
        
        % The experiment output array has the following format:
        % Column 1: Trial number
        % Column 2: Staircase number
        % Column 3: Monitor rotation
        % Column 4: Vergence distance
        % Column 5: Stimulus distance
        % Column 6: Front plane rotation (relevant for experiment 2, dual planes)
        % Column 7: Variable setting
        % Column 8: Response
        % Column 9: Response correctness
        
        % Initialize the trial number to 1:
        gexp.trialNum = 1;
                
        % Initially set fixation and stimulus render to 'off'
        grender.stimulus = 0;
        grender.fixation = 0;
        
        % Tell the user that the experiment is ready to proceed    
        dummy = input('Experiment Ready.  Press Enter to continue.');
        % Disable character output to window 
        ListenChar(2);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  BEGIN PTB SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % For Psychtoolbox 3.x
        % Disable the Warnings and checks, get on to app asap
        oldEnableFlag   = Screen('Preference', 'SuppressAllWarnings', 1);
        oldSyncTests    = Screen('Preference', 'SkipSyncTests', 1);
        oldVisualDebug  = Screen('Preference', 'VisualDebugLevel', 0);

        % Is the script running in OpenGL Psychtoolbox?
        AssertOpenGL;

        if(nargin() < 1)
            viewMode = 7; % Default to red/blue anaglyph
            % Find the screen to use for display:
            screenid = 1;
            %screenid = max(Screen('Screens'));
            
        else
            viewMode = 7; % LCD Shutter glasses
            screenid = 1;
        end    
                     
        % Open a double-buffered full-screen window on the main displays screen.
        % Anti-aliasing does not seem to be suppported for anaglyph or
        % shutter-glass stereo modes
        if computer == 0
            %[gwin,winRect] = Screen('OpenWindow', screenid, 0, [0 0 600 600], 32, 2, viewMode, [], []);
            [gwin,winRect] = Screen('OpenWindow', screenid, 0, [], 32, 2, viewMode, [], []);
        elseif computer == 1
            [gwin,winRect] = Screen('OpenWindow', screenid, 0, [], 32, 2, viewMode, [], []);
        elseif computer == 2
            [gwin, winRect] = PsychImaging('OpenWindow', screenid, 0, [], 32, 2, viewMode, 0);
        else
            [gwin,winRect] = Screen('OpenWindow', screenid, 0, [], 32, 2, viewMode, [], []);
        end
        
        %%%% HAPLOSCOPE
        
       % if stereoMode == 10
       %     % In dual-window, dual-display mode, we open the slave window on
       %     % the secondary screen. Please note that, after opening this window
       %     % with the same parameters as the "master-window", we won't touch
       %     % it anymore until the end of the experiment. PTB will take care of 
       %     % managing this window automatically as appropriate for a stereo
       %     % display setup. That is why we are not even interested in the window
       %     % handles of this window:
       %     if IsWin
       %         slaveScreen = 2;
       %     else
       %         slaveScreen = 1;
       %     end
       %     PsychImaging('OpenWindow', slaveScreen, BlackIndex(slaveScreen), [], [], [], stereoMode);
       % end
        
    
       %set up monitor and window sizes
       gmonitor = LUMMonitor(gmonitor,computer,winRect,gexp);
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  END PTB SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%
        %%% Begin default values
        %%%%%%%%%%%%%


        %%%%%%%%%%%%%
        %%% End default values
        %%%%%%%%%%%%%  
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  BEGIN EXPERIMENT SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        %%%%%%%%
        %%  Initialize staircase
        %%%%%%%%

        s = PTBStaircase;           % Instantiate a staircase
        % Set up the staircases' values.  Start with one staircase.  This
        % will later be duplicated and the appropriate values will be
        % changed for each staircase
        if (gexp.type == 1)     % Slant-nulling experiment
            gexp.fixDuration = 0.50;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 14.0;      % Duration of stimulus (sec)
            
            gscell{1} = set(s,...
                'initialValue',3,...
                'initialValue_random_range', 2,...
                'stepSize',1,... 
                'minValue',1,...
                'maxValue',5,....
                'maxReversals',8,...
                'dispRange',5,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',1.0,...
                'altVariable',gexp.luminanceRange,...
                'numUp',1,...
                'numDown',1);
            

                % Copy to other staircases
                %gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
                % Set the correct stimulus distances
                %gscell{2} = set(gscell{2}, 'dispRange',gexp.disparityRange);
                %gscell{3} = set(gscell{3}, 'dispRange',gexp.disparityRange);
                %gscell{4} = set(gscell{4}, 'dispRange',gexp.disparityRange);
                %gscell{5} = set(gscell{5}, 'dispRange',gexp.disparityRange);

        elseif (gexp.type == 2)         % Simulated head-roll experiment
            gexp.fixDuration = 0.1;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 0.1;    % Duration of stimulus (sec)
            gscell{1} = set(s,...
                'initialValue',0,... 
                'initialValue_random_range', 0,...
                'stepSize',2,...,
                'minValue',-90,...
                'maxValue',90,....
                'maxReversals',15,...
                'stimDistance',gexp.monitorDistanceMm,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',-2,...
                'altVariable',gexp.disparityRange,...
                'numUp',1,...
                'numDown',1);

            %gaperture.radiusDeg = 7.5;    % Aperture radius in degrees
            %gaperture.radius = gmonitor.distance * tan(gaperture.radiusDeg * pi / 180);
            %gaperture.aspect = 1.0;    %  Change the aspect ratio so it will be sure to fit within the physical aperture
            %gaperture.aspectRatioVar = 0.0;
          
        end
        

        % Initialize all of the staircases
        for i=1:length(gscell);  
            gscell{i}=initializeStaircase(gscell{i});
        end
        
        % Set initial staircase
        current_sc = PTBSelectStaircase(gscell);     
        
        % Retrive stimulus values
        updateConditions(current_sc);
        
              
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  END EXPERIMENT SETUP CODE
        %%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Set up variables for first trial
        startTrial = 1;
        acceptInput = 0;
        
        % Used to stop experiment
        escPressed = 0;
        
        % Key input loop
        while (current_sc > 0 && escPressed == 0)
            % Check if a new trial needs to start
            if (startTrial)
                % Get the time at the beginning of the trial.  This is used
                % to determine when to display the fixation cross and the
                % stimulus.
                initTime = GetSecs;
                startTrial = 0;
                acceptInput = 0;
            end
            
            % If the trial is over, accept user input
            if (acceptInput)
                % Call an outside function to interpret key presses.
                [response exit] = LUMKeyPress;

                % Was the esc key pressed?
                if exit
                    % Exit if 'esc' key is pressed
                    escPressed = 1;
                elseif response > 0
                    %gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;
                    
                    
                    % Store experiment state in output array
                    gexp.data(gexp.trialNum,1) = gexp.trialNum;
                    gexp.data(gexp.trialNum,2) = current_sc;
                    gexp.data(gexp.trialNum,3) = get(gscell{current_sc},'dispRange');
                    gexp.data(gexp.trialNum,4) = get(gscell{current_sc},'altVariable');
                    gexp.data(gexp.trialNum,5) = get(gscell{current_sc},'currentValue');
                    gexp.data(gexp.trialNum,6) = response;


                    % Print the experiment state to the output text file
                    fprintf(gexp.fid, '%i\t%i\t%i\t%i\t%i\t%f\t%f\t%i\t%i\n', gexp.data(gexp.trialNum,:)');
                    % Save the experiment state to a .mat file
                    save(gexp.filenamemat,'gexp','gmonitor','gscell');
                    % Increment the trial number
                    gexp.trialNum = gexp.trialNum + 1;
                    

                    % Store response in staircase
                    gscell{current_sc} = processResponse(gscell{current_sc},response);
                    % Choose the next stimulus
                    current_sc = PTBSelectStaircase(gscell);
                    if current_sc > 0
                        updateConditions(current_sc);
                        UpdateStimulus;
                        % Run the next trial
                        startTrial = 1;
                    end

                elseif response == 0
                    % Skip this trial
                    %gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;
                    % Choose the next stimulus
                    current_sc = PTBSelectStaircase(gscell);
                    if current_sc > 0
                        updateConditions(current_sc);
                        UpdateStimulus;
                        % Run the next trial
                        startTrial = 1;
                    end
                end
                
            end
            
            % Figure out what to display
            if (GetSecs - initTime) < gexp.fixDuration
                % Fixation should be up
                grender.fixation = 1;
                grender.stimulus = 0;

            elseif (GetSecs - initTime) < (gexp.fixDuration + gexp.stimDuration)
                        
                grender.fixation = 0;
                grender.stimulus = 1;
                    
            else
                % Trial is over.  Blank the screen and accept input
                
                grender.fixation = 0;
                grender.stimulus = 0;
                acceptInput = 1;
                
            end
                
            % Refresh the screen for each eye   
            RenderScene(0,gwin);
            %RenderScene(1,gwin);
            Screen('Flip', gwin);

        end
        
        gexp.completed = 1;
        fclose(gexp.fid);
        
        % Experiment is over.  Just show the fixation stimulus and wait for
        % the user to press 'Esc'
        grender.fixation = 1;
        while (escPressed == 0)
            % Call an outside function to interpret key presses.
            [response exit] = LUMKeyPress;

            % Was the esc key pressed?
            if exit
                escPressed = 1;
            end
            
            % Refresh the screen    
            RenderScene(0,gwin);
            %RenderScene(1,gwin);
            Screen('Flip', gwin);
        end   
            
        ListenChar(0);
        % Close onscreen window and release all other ressources:
        Screen('CloseAll');
        % Prompt to save the data in the subject's main data file
        if (gexp.training == 0)
            appendData;
        end
        % Reenable Synctests
        Screen('Preference','SkipSyncTests',1);
        clear all;
    catch
        ListenChar(0);
        Screen('CloseAll');
        % Prompt to save the data in the subject's main data file
        if (gexp.training == 0)
            appendData;
        end
        fclose(gexp.fid);
        psychrethrow(psychlasterror);
        clear all;
    end  
   

    
% Refresh display
% The items within this function must be executed each time a new stimulus
% is presented
function UpdateStimulus
    %global gdots
    global gexp
    
    %reset randomized parameters here?
    
    if (gexp.type == 1)
        % Create new random dot array
        gdots.front = 1; 
        gdots.front = 1;
    else
        % Create new random dot array
        gdots.front = 1; 
        gdots.front = 1;     
    end
        

% Render the stimulus
function RenderScene(whichEye,gwin)
global grender
    global gexp
        
    %% Render an eye
    %Screen('SelectStereoDrawBuffer', gwin, whichEye);
        
    if grender.stimulus
        if (gexp.type == 1)
            
            moviename=['./PTBstim/disp' num2str(gexp.disparityRange) '.avi'];
            [movie movieduration fps imgw imgh] = Screen('OpenMovie',gwin,moviename);
            Screen('SetMovieTimeIndex', movie, 0);
            rate=1;
            Screen('PlayMovie', movie, rate);
            while (1)
                tex = Screen('GetMovieImage', gwin, movie, 1);
                if tex<=0
                    break;
                end;
                %Draw the new texture immediately to screen:
                Screen('DrawTexture', gwin, tex);
                % Update display:
                Screen('Flip', gwin);
                % Release texture:
                Screen('Close', tex);
            end;
            Screen('CloseMovie', movie);
            
            moviename=['./PTBstim/lum0.' num2str(gexp.luminanceRange) '.avi'];
            [movie movieduration fps imgw imgh] = Screen('OpenMovie',gwin,moviename);
            Screen('SetMovieTimeIndex', movie, 0);
            rate=1;
            Screen('PlayMovie', movie, rate);
            while (1)
                tex = Screen('GetMovieImage', gwin, movie, 1);
                if tex<=0
                    break;
                end;
                %Draw the new texture immediately to screen:
                Screen('DrawTexture', gwin, tex);
                % Update display:
                Screen('Flip', gwin);
                % Release texture:
                Screen('Close', tex);
            end;
            Screen('CloseMovie', movie);
            
            %img = imread(gexp.testimg);
            %Screen('PutImage', gwin, img); % put image on screen
        end
    end
    if grender.fixation
        fiximg = ones(100,100,3);
        Screen('PutImage', gwin, fiximg); % put image on screen
    end
    
% Render the stimulus
% function RenderScene(whichEye,gwin)
%     global grender
%     global gexp
%     
%     %% Render an eye
%     Screen('SelectStereoDrawBuffer', gwin, whichEye);
%     
%     if grender.stimulus
%         if (gexp.type == 1)
%             img = imread(gexp.testimg);
%             Screen('PutImage', gwin, img); % put image on screen
%         end
%     end
%     if grender.fixation
%         fiximg = ones(100,100,3);
%         Screen('PutImage', gwin, fiximg); % put image on screen
%     end
    
    
% Update the stimulus conditions from the desired staircase.  Takes in
% staircase ID
function updateConditions(scnum)
    global gexp
    global gscell
    global ghinge
    global gdistances
    global gmonitor
    global gdots
    
    if gexp.type == 1
        %gdistances.vergence = get(gscell{scnum},'stimDistance');
        gexp.luminanceRange = get(gscell{scnum},'currentValue');
        gexp.disparityRange = get(gscell{scnum},'dispRange');
    elseif gexp.type == 10
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        gmonitor.distance = get(gscell{scnum},'CoPDistance');
        ghinge.hingeAngle = get(gscell{scnum},'currentValue');
        ghinge.pitchAngle = get(gscell{scnum},'pitchAngle');
        gdots.maxDisplacement = get(gscell{scnum},'hingeSizeMm');
        gdots.arraySize = (gdots.maxDisplacement/10);
    elseif gexp.type == 4
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        ghinge.rollAngle = ghinge.rollDirection * get(gscell{scnum},'currentValue');
    end
    
    display(['Current Value: ' num2str(get(gscell{scnum},'currentValue'))]);
   
        
% Append the data to a single file for this subject.
function appendData()
    global gexp
    
    % Ask the user if the data should be saved in the subject's main file
    saveBool = [];
    while (isempty(saveBool) || (saveBool ~= 'Y' && saveBool ~= 'N'))
        saveBool= input('Store data in subject''s main file? (y/n): ','s');
        saveBool = upper(saveBool);
    end
    
    if (saveBool == 'Y')
        outputName = [gexp.subject '.mat'];
        chdir(gexp.directory);
        if (exist(outputName,'file') == 2)
            % If the subject already has a data file, load it and add the
            % current data
            load(outputName);
            data.(genvarname(num2str(gexp.type))).(genvarname(gexp.subtype)).(genvarname(num2str(gexp.run))) = gexp;
            data.(genvarname(num2str(gexp.type))).(genvarname(gexp.subtype)).max = gexp.run;
            save(outputName,'data');
        else
            % Otherwise, create a new data file for this subject.
            data.(genvarname(num2str(gexp.type))).(genvarname(gexp.subtype)).(genvarname(num2str(gexp.run))) = gexp;
            data.(genvarname(num2str(gexp.type))).(genvarname(gexp.subtype)).max = gexp.run;
            save(outputName,'data');
        end
    end
        
    
        