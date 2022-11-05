%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PsychToolbox Hinge Experiment
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

function [] = PTBExperiment(viewMode)
        
    clear all;
    %% Setup global variables5

    global gdots                 % Dots structure. Contains position and size data.
    global gmonitor              % Monitor structure.  Contains window size & screen sizes and positions in pixels and mm      
    global gdistances            % Structure containing accommodation and vergence distances
    global geye                  % Structure containing interpupillary distance, clipping planes      
    global ghinge                % Structure containing settings related to the hinge (hinge vs slant, etc)
    global gaperture             % Structure containing values relavent to the software aperture
    global gtextures
    global gwin
    global gexp                  % Structure containing the settings for the experiment
    global grender               % Should the stimulus be rendered?
    global gscell                % Cell containing staircases
    global gvoronoi              % Structure containing voronoi information (coordinates, array size, perturbations, etc.)
    global testCalibration;         % Used to determine if test lines need to be drawn
    testCalibration.whichEye = 0;   % 1 = Left, 2 = Right, 0 = None.
        
    computer = 3;               % 0 = Rotating monitor, 1 = iMac, 2 = MacBook Pro, 3 = Emily's computer
    
    try
        
        % Setup experiment 
        % These values will be replaced later
        gexp.ipd = 62;
        gexp.subject = 'xxx';
        gexp.type = 4;
        gexp.monitorRotation = 0;
        gexp.subtype = 'A';
        gexp.training = 0;
       
        % Obtain user input for the experimental setup
        gexp = PTBSetup;
        
        % Set to 0 if the stimulus should include random dots
        gexp.gridDots = 0;
        
        % Set to 1 if the stimulus should use an aperture
        gexp.useAperture = 1;
        
        % Create a flag for completion of the experiment
        gexp.completed = 0;
        
        % Used for training
        gexp.currentCorrect = 1;
        gexp.numCorrect = 0;
        gexp.percentCorrect = 0;
        
        % Default values:
        gexp.fixDuration = 0.500;   % Duration of fixation stimulus (sec)
        gexp.stimDuration = 3;      % Duration of stimulus (sec)
        
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
        %%  BEGIN OPENGL SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % For Psychtoolbox 3.x
        % Disable the Warnings and checks, get on to app asap
        oldEnableFlag   = Screen('Preference', 'SuppressAllWarnings', 1);
        oldSyncTests    = Screen('Preference', 'SkipSyncTests', 1);
        oldVisualDebug  = Screen('Preference', 'VisualDebugLevel', 0);


        % Is the script running in OpenGL Psychtoolbox?
        AssertOpenGL;

        
        if(nargin() < 1)
            %viewMode = 7; % Default to red/blue anaglyph
            viewMode = 1;
            % Find the screen to use for display:
            screenid = max(Screen('Screens'));
        else
            viewMode = 1; % LCD Shutter glasses
            screenid = 0;
        end
        
        % Disable Synctests for this simple demo:
        Screen('Preference','SkipSyncTests',1);

        % Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
        % mogl OpenGL for Matlab wrapper:
        global GL;
        InitializeMatlabOpenGL(1);        
                     
        % Open a double-buffered full-screen window on the main displays screen.
        % Anti-aliasing does not seem to be suppported for anaglyph or
        % shutter-glass stereo modes
        if computer == 3
            %[gwin,winRect] = Screen('OpenWindow', screenid, 0, [0 0 1280 1024], 32, 2, viewMode, [], []);
            [gwin,winRect] = Screen('OpenWindow', screenid, 0, [0 0 200 200], 32, 2, viewMode, [], []);
        else
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', 'RotationCalib.mat');
            [gwin, winRect] = PsychImaging('OpenWindow', screenid, 0, [], 32, 2, viewMode, 0);
        end
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
        
        
        % Setup the monitor and window settings for the rotating monitor
        gmonitor.screen_width_p = winRect(3);
        gmonitor.screen_height_p = winRect(4);
        switch computer
            case 0 
                gmonitor.screen_width_mm = 406;
                gmonitor.screen_height_mm = 304;
            case 1
                gmonitor.screen_width_mm = 406;
                gmonitor.screen_height_mm = 304;
            case 2
                gmonitor.screen_width_mm = 357;
                gmonitor.screen_height_mm = 243;
            case 3
                gmonitor.screen_width_mm = 338;
                gmonitor.screen_height_mm = 272;
            otherwise
                gmonitor.screen_width_mm = 406;
                gmonitor.screen_height_mm = 304;
        end
                
        gmonitor.win_pos_x = 0;
        gmonitor.win_pos_y = 0;
        gmonitor.win_width_mm = gmonitor.screen_width_mm;
        gmonitor.win_height_mm = gmonitor.screen_height_mm;
        gmonitor.win_width_p = gmonitor.screen_width_p;
        gmonitor.win_height_p = gmonitor.screen_height_p;
        gmonitor.distance = 550;
        gmonitor.rotation = gexp.monitorRotation;
        gmonitor.mmToP = gmonitor.screen_width_mm / gmonitor.screen_width_p;
        
        % Setup the OpenGL rendering context of the onscreen window for use by
        % OpenGL wrapper. After this command, all following OpenGL commands will
        % draw into the onscreen window 'win':
        Screen('BeginOpenGL', gwin);
        
        % Turn on OpenGL local lighting model: The lighting model supported by
        % OpenGL is a local Phong model with Gouraud shading.
        glEnable(GL.LIGHTING);

        % Enable two-sided lighting - Back sides of polygons are lit as well.
        glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);

        % Enable proper occlusion handling via depth tests:
        glEnable(GL.DEPTH_TEST);

        % Enable smooth shading:
        glShadeModel(GL.SMOOTH);

        % Enable alpha blending and anti-aliasing:
        glEnable(GL.POLYGON_SMOOTH );
        glEnable(GL.LINE_SMOOTH);
		glHint(GL.POLYGON_SMOOTH_HINT, GL.NICEST);
        glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
		glEnable(GL.BLEND);  
		glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
        
        % Define lighting values 
        background = [0.0 0.0 0.0 1.0];
        mat_ambient = [ 1 1 1 1 ];
        mat_black = [0.0 0.0 0.0 1.0];
        light_ambient = [ 1 1 1 1 ];
		
        % Setup up lighting
        glDisable(GL.DITHER);
        glEnable(GL.NORMALIZE);	
        glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, mat_ambient);
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);
        glLightModelfv(GL.LIGHT_MODEL_AMBIENT, light_ambient);
        glColorMaterial(GL.FRONT_AND_BACK,GL.AMBIENT_AND_DIFFUSE);
        glEnable(GL_COLOR_MATERIAL);

        % Set projection matrix: This defines a perspective projection,
        % corresponding to the model of a pin-hole camera - which is a good
        % approximation of the human eye and of standard real world cameras --
        % well, the best aproximation one can do with 3 lines of code ;-)
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;

        % Setup modelview matrix: This defines the position, orientation and
        % looking direction of the virtual camera:
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;

        % Setup position and emission properties of the light source:

        % Set background color to 'black':
        glClearColor(0,0,0,0);
        
        % Setup texture bank
        gtextures = glGenTextures(5);
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  END OPENGL SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%
        %%% Begin default values
        %%%%%%%%%%%%%

        geye.clip_n = 10.0;    % Near clipping plane
        geye.clip_f = 10000.0;   % Far clipping plane

        % Setup initial values for the accommodation and vergence distances
        gdistances.accomm = 550;
        gdistances.vergence = 550;
        gdistances.converge = 0;     % For parallel camera setup, set this to 0
        gdistances.fixationOffset = 0;  % Set this to half the inter-plane distance if two planes are displayed

        % Setup hinge default settings
        ghinge.hingeAngle = 180;     % Angle of the hinge (if not a slant surface)
        ghinge.front.baseAngle = 0;        % Base angle of the stimulus' front surface
        ghinge.back.baseAngle = 0;        % Base angle of the stimulus' back surface, if used
        ghinge.rollAngle = 0;        % Amount of roll
        ghinge.rollAngleTemp = 0;
        ghinge.rollDirection = 1;    % Used to flip the direction of the simulated camera roll 
        ghinge.pitchAngle = 0; %amount of pitch forward or backward
        ghinge.rotatev = [ 0 1 0 ];  % The y-axis is the axis of rotation
        ghinge.rotateh = [ 0 0 1 ];  % The z-axis is the axis of rotation
        ghinge.H = -0.1127;            % The curvature of the surface.  Only used for converging camera experiments.

        % Setup dots
        gdots.meanSizeDeg = 0.15;      % Setup default dot size (degrees)
        gdots.meanSize = 2 * gmonitor.distance * tan(gdots.meanSizeDeg * pi / 180); % (On-screen coordinates)
        gdots.maxSizeDevDeg = 0.025;  % Used to decide magnitude of random numbers added to default dot size
        gdots.maxSizeDev = gmonitor.distance * tan(gdots.maxSizeDevDeg * pi / 180); % (On-screen coordinates)
        gdots.arraySize = 32;    % Length of one dimension of the dot array
        gdots.maxDisplacementDeg = 10; % Maximum x- or y-displacement from (0,0)
        gdots.maxDisplacement = gmonitor.distance * tan(gdots.maxDisplacementDeg * pi / 180); % (On-screen coordinates) 
        if gexp.type == 10
            gdots.maxDisplacement = 100; %For some reason this is 1/2 the value that shows up on Emily's office monitor
            %gdots.maxDisplacement = 250;
        end
        gdots.maxDispDevDeg = 1;    % Used to decide magnitude of random numbers added to default dot location
        gdots.maxDispDev = gmonitor.distance * tan(gdots.maxDispDevDeg * pi / 180); % (On-screen coordinates)   
        gdots.textureSize = 64;   % Length of one side of texture used to draw dots (must be power of 2, leave this alone)
        gdots.surfaces = 1;     % Are there one or two random-dot surfaces?
        gdots.surfaceGap = 0;  % Gap between surfaces (mm)
        
        % Setup voronoi
        gvoronoi.arraySize = 32;    % Length of one dimension of the dot array
        gvoronoi.maxDisplacementDeg = 10; % Maximum x- or y-displacement from (0,0)
        gvoronoi.maxDisplacement = gmonitor.distance * tan(gvoronoi.maxDisplacementDeg * pi / 180); % (On-screen coordinates) 
        gvoronoi.maxDispDevDeg = 1;    % Used to decide magnitude of random numbers added to default dot location
        gvoronoi.maxDispDev = gmonitor.distance * tan(gvoronoi.maxDispDevDeg * pi / 180); % (On-screen coordinates)   
        gvoronoi.lineWidth = 2;     % Width, in pixels, of the lines used to draw the voronoi surfaces

        % Setup aperture
        gaperture.radiusDeg = 6.5;    % Aperture radius in degrees
        gaperture.radius = gmonitor.distance * tan(gaperture.radiusDeg * pi / 180);
        gaperture.aspect = 0.8;    %  Base aspect ratio
        gaperture.aspectRatioVar = 0.2;
        gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;


        %%%%%%%%%%%%%
        %%% End default values
        %%%%%%%%%%%%%  
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  BEGIN EXPERIMENT SETUP CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % This setup function can be replaced by another
        %     HingeSetup;

        %%%%%%%%
        %%  Initialize staircase
        %%%%%%%%

        s = PTBStaircase;           % Instantiate a staircase
        % Set up the staircases' values.  Start with one staircase.  This
        % will later be duplicated and the appropriate values will be
        % changed for each staircase
        if (gexp.type == 1  || gexp.type == 5 || gexp.type == 6 || gexp.type == 7 || gexp.type == 8 || gexp.type == 9)     % Slant-nulling experiment
            gexp.fixDuration = 0.750;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 1.0;      % Duration of stimulus (sec)
            
            gscell{1} = set(s,...
                'initialValue',-gexp.monitorRotation - 20,...
                'initialValue_random_range', 5,...
                'stepSize',16,... 
                'minValue',-80,...
                'maxValue',80,....
                'maxReversals',10,...
                'stimDistance',350,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',1.0,...
                'altVariable',gexp.frontAngle,...
                'numUp',1,...
                'numDown',1);
            if (gexp.training)
                % Use a smaller number of staircases
                % Copy to other staircases
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} =  gscell{1};
                % Set the correct stimulus distances
                gscell{2} = set(gscell{2}, 'stimDistance',550);
                gscell{3} = set(gscell{3}, 'stimDistance',750);
                gscell{4} = set(gscell{4},'initialValue',-gexp.monitorRotation + 20);
                gscell{5} = gscell{4}; gscell{6} = gscell{4};
                gscell{5} = set(gscell{5}, 'stimDistance',550);
                gscell{6} = set(gscell{6}, 'stimDistance',750); 
            elseif (gexp.subtype == 'A' || gexp.subtype == 'B')
                if gexp.subtype == 'B'
                    gscell{1} = set(gscell{1},'initialValue',-gexp.monitorRotation + 20);
                end
                % Copy to other staircases
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
                % Set the correct stimulus distances
                gscell{2} = set(gscell{2}, 'stimDistance',450);
                gscell{3} = set(gscell{3}, 'stimDistance',550);
                gscell{4} = set(gscell{4}, 'stimDistance',650);
                gscell{5} = set(gscell{5}, 'stimDistance',750);
            else
                % Subtype C includes staircases from both A and B
                % Copy to other staircases
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
                % Set the correct stimulus distances
                gscell{2} = set(gscell{2}, 'stimDistance',450);
                gscell{3} = set(gscell{3}, 'stimDistance',550);
                gscell{4} = set(gscell{4}, 'stimDistance',650);
                gscell{5} = set(gscell{5}, 'stimDistance',750);
                gscell{6} =  gscell{1}; 
                gscell{6} = set(gscell{6},'initialValue',-gexp.monitorRotation + 20);
                % Copy to other staircases
                gscell{7} =  gscell{6}; gscell{8} =  gscell{6}; gscell{9} = gscell{6}; gscell{10} =  gscell{6}; 
                % Set the correct stimulus distances
                gscell{7} = set(gscell{7}, 'stimDistance',450);
                gscell{8} = set(gscell{8}, 'stimDistance',550);
                gscell{9} = set(gscell{9}, 'stimDistance',650);
                gscell{10} = set(gscell{10}, 'stimDistance',750);
            end
        elseif (gexp.type == 10)     % 90 Hinge Experiment (MONO)
            gexp.fixDuration = 0.750;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 1;      % Duration of stimulus (sec)
            gdistances.vergence = 300;
            gexp.exptenstereo = 0;
            
            gscell{1} = set(s,...
                'initialValue',90,...
                'initialValue_random_range', 30,...
                'stepSize',16,... 
                'minValue',0,...
                'maxValue',180,....
                'maxReversals',10,...
                'stimDistance',300,...
                'CoPDistance',300,...
                'pitchAngle',0,...
                'hingeSizeMm',60,...  %for some reason this is 1/2 the height in my office
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',1.0,...
                'altVariable',gexp.frontAngle,...
                'numUp',1,...
                'numDown',1);
            if (gexp.training)
                % Use a smaller number of staircases
                % Copy to other staircases
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
                % Set the correct stimulus distances
                %gscell{2} = set(gscell{2}, 'CoPDistance',100);
                %gscell{2} = set(gscell{2}, 'pitchAngle',0);
                %gscell{3} = set(gscell{3}, 'CoPDistance',300);
                %gscell{2} = set(gscell{3}, 'pitchAngle',0);
                %gscell{4} = set(gscell{4}, 'CoPDistance',700);
                %gscell{2} = set(gscell{4}, 'pitchAngle',0);
                %gscell{5} = set(gscell{5}, 'CoPDistance',900); 
                %gscell{2} = set(gscell{5}, 'pitchAngle',0);
            %elseif (gexp.subtype == 'A' || gexp.subtype == 'B' || gexp.subtype == 'C')
            elseif (gexp.subtype == 'A') %% pitch and cop distance manipulation
                
                counter = 2; %1 was already made
                %for each pitch angle
                for p = [0]
                    %for each CoP other than actual
                    for c = [100 150 300 550 800]
                        if (p == 0 && c == 300) %if the conditions are the same as the first staircare
                            counter = counter;
                        else
                            gscell{counter} = gscell{1};
                            gscell{counter} = set(gscell{counter}, 'CoPDistance',c);
                            gscell{counter} = set(gscell{counter}, 'stimDistance',c);
                            gscell{counter} = set(gscell{counter}, 'pitchAngle',p);
                            counter = counter + 1; 
                        end
                    end
                end
            elseif (gexp.subtype == 'B') %% pitch and cop distance manipulation
                gscell{1} = set(gscell{1}, 'CoPDistance',500);
                gscell{1} = set(gscell{1}, 'stimDistance',500);
                counter = 2; %1 was already made
                %for each pitch angle
                for p = [0]
                    %for each CoP other than actual
                    for c = [350 500 700]
                        if (p == 0 && c == 500) %if the conditions are the same as the first staircare
                            counter = counter;
                        else
                            gscell{counter} = gscell{1};
                            gscell{counter} = set(gscell{counter}, 'CoPDistance',c);
                            gscell{counter} = set(gscell{counter}, 'stimDistance',c);
                            gscell{counter} = set(gscell{counter}, 'pitchAngle',p);
                            counter = counter + 1; 
                        end
                    end
                end    
                
                
                               
            elseif (gexp.subtype == 'C')  %% pitch, cop, and size manipulation
                
                counter = 2; %1 was already made
                %for each hinge height (mm)
                for h = [30 60 100]
                %for each pitch angle
                for p = [0 5 10 20 45 70]
                    %for each CoP other than actual
                    for c = [100 250 450 700 1000]
                        if (p == 0 && c == 450 && h == 60) %if the conditions are the same as the first staircare
                            counter = counter;
                        else
                            gscell{counter} = gscell{1};
                            gscell{counter} = set(gscell{counter}, 'CoPDistance',c);
                            gscell{counter} = set(gscell{counter}, 'pitchAngle',p);
                            gscell{counter} = set(gscell{counter}, 'hingeSizeMm',h);
                            counter = counter + 1; 
                        end
                    end
                end
                end
                

            end    
        elseif gexp.type == 2      % Slant-matching (two-plane) experiment
            gexp.fixDuration = 0.750;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 1.5;      % Duration of stimulus (sec)
            
            % Set the number of surfaces to 2
            gdots.surfaces = 2;
            % Set up the staircase cells
            gscell{1} = set(s,...
                'initialValue', gexp.frontAngle - 20,... 
                'initialValue_random_range', 5,...
                'stepSize',16,... 
                'minValue',-75,...
                'maxValue',75,....
                'maxReversals',10,...
                'stimDistance',550,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',1.0,...
                'altVariable',gexp.frontAngle,...
                'numUp',1,...
                'numDown',1);
            if (gexp.training)
                % Use a smaller number of staircases
                 % Copy to other staircases
                gscell{2} =  gscell{1}; 
                % Set the correct stimulus distances
                gscell{2} = set(gscell{2}, 'initialValue',gexp.frontAngle - 20);
            else
                % Copy to other staircases (6 total)
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} =  gscell{1}; gscell{5} =  gscell{1}; gscell{6} =  gscell{1};
                % Half of the staircases will start with an initial value of
                % -20 deg, while the rest will start with +20 deg.  This means
                % there is no "Type B" for this experiment type
                gscell{4} = set(gscell{4}, 'initialValue',gexp.frontAngle + 20);
                gscell{5} = set(gscell{5}, 'initialValue',gexp.frontAngle + 20);
                gscell{6} = set(gscell{6}, 'initialValue',gexp.frontAngle + 20);     
            end
            % Set the vergence value (this will be constant)
            gdistances.vergence = 550;
            % Set the rotation of the front plane.  This should be derived
            % from the completion of experiment 1 so that the front plane
            % appears frontoparallel
            ghinge.front.baseAngle = gexp.frontAngle;
            % Set the gap between the surface
            gdots.arraySize = 24; 
            gdots.surfaces = 2;
            gdots.surfaceGap = 200;
            gdistances.fixationOffset = gdots.surfaceGap / 2;
            
        elseif (gexp.type == 3)         % Converging-cameras experiment
            gexp.fixDuration = 0.750;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 1.0;    % Duration of stimulus (sec)
            
            gscell{1} = set(s,...
                'initialValue',-0.5,...
                'initialValue_random_range', 0.1,...
                'stepSize',0.256,...,
                'minValue',-0.8,...
                'maxValue',0.8,....
                'maxReversals',10,...
                'stimDistance',350,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',0.004,...
                'altVariable',gexp.frontAngle,...
                'numUp',1,...
                'numDown',1);
            
            % If this is a training session, keep the camera parallel.
            % Otherwise, make them converge.
            if (gexp.training == 0)
                gdistances.converge = 1; 
                if (gexp.vergenceDist == -1)
                    % If the convergence distance is less than one, set the cameras
                    % to parallel by setting the vergence distance very
                    % large
                    gexp.vergenceDist = 1000000000;
                end
            end
             
            if (gexp.training)
                % Use a smaller number of staircases and reduce the max
                % number of reversals
                gscell{1} = set(gscell{1}, 'maxReversals',7);
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1};
                gscell{2} = set(gscell{2}, 'stimDistance',550);
                gscell{3} = set(gscell{3}, 'stimDistance',750);
                gscell{4} = set(gscell{4},'initialValue',0.2);
                gscell{5} = gscell{4}; gscell{6} = gscell{4};
                gscell{5} = set(gscell{5}, 'stimDistance',550);
                gscell{6} = set(gscell{6}, 'stimDistance',750);
                
            elseif (gexp.subtype == 'A' || gexp.subtype == 'B')
                if gexp.subtype == 'B'
                    gscell{1} = set(gscell{1},'initialValue',0.2);
                end
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
                gscell{2} = set(gscell{2}, 'stimDistance',450);
                gscell{3} = set(gscell{3}, 'stimDistance',550);
                gscell{4} = set(gscell{4}, 'stimDistance',650);
                gscell{5} = set(gscell{5}, 'stimDistance',750);
            elseif (gexp.subtype == 'P')
                gscell{1} = set(gscell{1}, 'initialValue',-0.12);
                gscell{1} = set(gscell{1}, 'initialValue_random_range', 0);
                gscell{1} = set(gscell{1}, 'stimDistance',550);
                gdistances.converge = 1;
                gexp.stimDuration = 5.0;
                gexp.gridDots = 1;
                gdots.arraySize = 32;
            else
                % Subtype C contains staircases from A and B
                gscell{2} =  gscell{1}; gscell{3} =  gscell{1};
                gscell{2} = set(gscell{2}, 'stimDistance',550);
                gscell{3} = set(gscell{3}, 'stimDistance',1000);
                gscell{4} = gscell{1}; 
                gscell{4} = set(gscell{4},'initialValue',.2);
                % Copy to other staircases
                gscell{5} =  gscell{4}; gscell{6} =  gscell{4};
                % Set the correct stimulus distances
                gscell{5} = set(gscell{5}, 'stimDistance',550);
                gscell{6} = set(gscell{6}, 'stimDistance',1000);
%                 % Subtype C contains staircases from A and B
%                 gscell{2} =  gscell{1}; gscell{3} =  gscell{1}; gscell{4} = gscell{1}; gscell{5} =  gscell{1}; 
%                 gscell{2} = set(gscell{2}, 'stimDistance',450);
%                 gscell{3} = set(gscell{3}, 'stimDistance',550);
%                 gscell{4} = set(gscell{4}, 'stimDistance',650);
%                 gscell{5} = set(gscell{5}, 'stimDistance',750);
%                 gscell{6} = gscell{1}; 
%                 gscell{6} = set(gscell{6},'initialValue',.2);
%                 % Copy to other staircases
%                 gscell{7} =  gscell{6}; gscell{8} =  gscell{6}; gscell{9} = gscell{6}; gscell{10} =  gscell{6}; 
%                 % Set the correct stimulus distances
%                 gscell{7} = set(gscell{7}, 'stimDistance',450);
%                 gscell{8} = set(gscell{8}, 'stimDistance',550);
%                 gscell{9} = set(gscell{9}, 'stimDistance',650);
%                 gscell{10} = set(gscell{10}, 'stimDistance',750); 
                
            end   
            
            % Adjust the aperture to make sure that the stimulus is wide
            % enough to make a reliable estimate of curvature
            gaperture.radiusDeg = 10;    % Aperture radius in degrees
            gaperture.radius = gmonitor.distance * tan(gaperture.radiusDeg * pi / 180);
            gaperture.aspect = 1;    %  Base aspect ratio
            gaperture.aspectRatioVar = 0.2;
            gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;

        elseif (gexp.type == 4)         % Simulated head-roll experiment
            gexp.fixDuration = 0.1;   % Duration of fixation stimulus (sec)
            gexp.stimDuration = 0.1;    % Duration of stimulus (sec)
            gscell{1} = set(s,...
                'initialValue',0,... 
                'initialValue_random_range', 0,...
                'stepSize',2,...,
                'minValue',-90,...
                'maxValue',90,....
                'maxReversals',15,...
                'stimDistance',750,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'stepLimit',-2,...
                'altVariable',gexp.frontAngle,...
                'numUp',1,...
                'numDown',1);
            if gexp.subtype == 'B'
                 gscell{1} = set(gscell{1},'initialValue',0);
            end
            gaperture.radiusDeg = 7.5;    % Aperture radius in degrees
            gaperture.radius = gmonitor.distance * tan(gaperture.radiusDeg * pi / 180);
            gaperture.aspect = 1.0;    %  Change the aspect ratio so it will be sure to fit within the physical aperture
            gaperture.aspectRatioVar = 0.0;
%             ghinge.hingeAngle = 60;
            ghinge.front.baseAngle = 30;
            gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;
            % The initial version of this experiment just goes in one
            % direction until the observer can fuse the stimulus, and then
            % terminates
            gdots.arraySize = 24; 
%             gdots.surfaces = 2;
%             gdots.surfaceGap = 15;  % A gap of 30 mm centered around fixation at 550 mm should keep both planes in Panum's fusion area. 
            
        end
        
        % Initialize all of the staircases
        for i=1:length(gscell);  
            gscell{i}=initializeStaircase(gscell{i});
        end
        
        % Set initial staircase
        current_sc = PTBSelectStaircase(gscell);
        
        % Set the dot pattern to a grid, if applicable
        if (gexp.type >= 7 && gexp.type <= 9)
            % Square grid condition
            gexp.gridDots = 1;
            % Aperture
            gexp.useAperture = 1;
            % Keep the aperture the same between trials (circular)
            % Change the vertex spacing
            gdots.arraySize = 16;    % Length of one dimension of the dot array
        elseif (gexp.type == 10)
            % Square grid condition
            gexp.gridDots = 1;
            % Aperture
            gexp.useAperture = 0;
            % Keep the aperture the same between trials (circular)
            % Change the vertex spacing
            gdots.arraySize = 16;    % Length of one dimension of the dot array  
            %gdots.arraySize = gdots.maxDisplacement./10;
        end
        
        
        % Retrive stimulus values
        updateConditions(current_sc);
        %% Create arrays for dot positions and sizes
       
        
        
        % Create texture coordinate array
        for i = 1 : 4 : 2 * gdots.arraySize^2
            gdots.texCoords(1,i:i + 3) = [0.0 1.0 1.0 0.0];
            gdots.texCoords(2,i:i + 3) = [0.0 0.0 1.0 1.0];
        end
        
        % Reshape into a vector for use by glDrawArrays
        gdots.front.texCoordsVector = reshape(gdots.texCoords, 1, 4 * gdots.arraySize^2);
        gdots.back.texCoordsVector = reshape(gdots.texCoords, 1, 4 * gdots.arraySize^2);
        
        
        
        if (gexp.type < 5 || gexp.type >= 7)
            % Front surface first
            
            gdots.front = DotPositions(gdots.front,1);   % Call function to create initial set of random gdots
            gdots.front = AdjustDots(gdots.front,1);
            % Now the back
            if (gdots.surfaces == 2)
                gdots.back = DotPositions(gdots.back,2);   % Call function to create initial set of random dots
                gdots.back = AdjustDots(gdots.back,2);
            end
            
        elseif (gexp.type == 5 || gexp.type == 6)
            CreateVoronoiVertices;  % Call function to have voronoi vertices ready
        end
        
        % Create dot texture
        %if gexp.type ~= 10
        GenerateDotTexture;
        %end
        
              
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%  END EXPERIMENT SETUP CODE
        %%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Now we can close OpenGL for the time being
        Screen('EndOpenGL', gwin);
        
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
                [response exit] = PTBHingeKeyPress;

                % Was the esc key pressed?
                if exit
                    % Exit if 'esc' key is pressed
                    escPressed = 1;
                elseif response > 0
                    gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;
                    
                    % If this is a training run, use beeps to tell the user
                    % whether his/her response was correct
                    if gexp.training
                       if (gexp.type <= 2 || gexp.type >= 5)
                           % If it's the single plane experiment, see if the response was correct for the sign of the slant
                           if ((response == 1 && get(gscell{current_sc},'currentValue') <= 0) || (response == 2 && get(gscell{current_sc},'currentValue') >= 0))
                                % Correct case:  Play a sound increasing in frequency
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.10]*1400),44000);
                                gexp.currentCorrect = 1;
                                gexp.numCorrect = gexp.numCorrect + 1; 
                           else
                                % Incorrect case:  Play a sound decreasing in freq
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*1400),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*1400),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.10]*800),44000);
                                gexp.currentCorrect = 0;
                           end
                       elseif(gexp.type == 3)
                           % If it's the curving stimulus, see if the
                           % response was correct for the sign of the
                           % slant.  A flat surface at 0.550 m has an
                           % H-value of -0.11
                           if ((response == 1 && ghinge.H <= -0.11) || (response == 2 && ghinge.H >= -0.11))
                                % Correct case:  Play a sound increasing in frequency
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*800),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.10]*1400),44000);
                                gexp.currentCorrect = 1;
                                gexp.numCorrect = gexp.numCorrect + 1;
                           else
                                % Incorrect case:  Play a sound decreasing in freq
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*1400),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.05]*1400),44000);
                                sound(0.5*sin(2*pi*[0:1/44100:.10]*800),44000);
                                gexp.currentCorrect = 0;
                           end                           
                       end                        
                    end
                    
                    
                    
                    % Store experiment state in output array
                    gexp.data(gexp.trialNum,1) = gexp.trialNum;
                    gexp.data(gexp.trialNum,2) = current_sc;
                    gexp.data(gexp.trialNum,3) = gexp.monitorRotation;
                    gexp.data(gexp.trialNum,4) = gexp.vergenceDist;
                    gexp.data(gexp.trialNum,5) = get(gscell{current_sc},'stimDistance');
                    gexp.data(gexp.trialNum,6) = get(gscell{current_sc},'altVariable');
                    gexp.data(gexp.trialNum,7) = get(gscell{current_sc},'currentValue');
                    gexp.data(gexp.trialNum,8) = response;
                    gexp.data(gexp.trialNum,9) = gexp.currentCorrect;
                    if gexp.type == 10
                        gexp.data(gexp.trialNum,5) = get(gscell{current_sc},'CoPDistance');
                        gexp.data(gexp.trialNum,10) = get(gscell{current_sc},'pitchAngle');
                        gexp.data(gexp.trialNum,11) = get(gscell{current_sc},'hingeSizeMm');
                    end
                    % Print the experiment state to the output text file
                    fprintf(gexp.fid, '%i\t%i\t%i\t%i\t%i\t%f\t%f\t%i\t%i\n', gexp.data(gexp.trialNum,:)');
                    % Save the experiment state to a .mat file
                    save(gexp.filenamemat,'gexp','gdistances','gmonitor','ghinge','gdots');
                    % Refresh percent correct
                    gexp.percentCorrect = gexp.numCorrect / gexp.trialNum;
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
                    gaperture.currentAspect = gaperture.aspect - gaperture.aspectRatioVar + 2 * rand * gaperture.aspectRatioVar;
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
                if (gexp.type ~= 4)
                    grender.stimulus = 0;
                end
                % The fixation should not be rolled in the rolling screen
                % experiment
                if (gexp.type == 4 && ghinge.rollAngle ~= 0)
                    ghinge.rollAngleTemp = ghinge.rollAngle;
%                     ghinge.rollAngle = 0;      
                end
            elseif (GetSecs - initTime) < (gexp.fixDuration + gexp.stimDuration)
%                 if (gexp.type == 4 && (GetSecs - initTime) > (gexp.fixDuration + 0.5 * gexp.stimDuration))
%                     % Show the stimulus
                    ghinge.rollAngle = ghinge.rollAngleTemp;
%                 end
                        
                grender.stimulus = 1;
%                 if (gexp.type == 4)
%                     grender.fixation = 0;
%                 else
%                     grender.fixation = 1;
%                 end
                % Set the correct roll amount
%                 ghinge.rollAngle = get(gscell{current_sc},'currentValue');
                    
            else
                % Trial is over.  Blank the screen and accept input
                if (gexp.type ~= 4)
                    grender.fixation = 0;
                    grender.stimulus = 0;
                end
                acceptInput = 1;
            end
                
            % Refresh the screen    
            RenderScene(0,gwin);
            RenderScene(1,gwin);
            Screen('Flip', gwin);

        end
        
        gexp.completed = 1;
        fclose(gexp.fid);
        
        % Experiment is over.  Just show the fixation stimulus and wait for
        % the user to press 'Esc'
        grender.fixation = 1;
        while (escPressed == 0)
            % Call an outside function to interpret key presses.
            [response exit] = PTBHingeKeyPress;

            % Was the esc key pressed?
            if exit
                escPressed = 1;
            end
            
            % Refresh the screen    
            RenderScene(0,gwin);
            RenderScene(1,gwin);
            Screen('Flip', gwin);
        end   
            
        ListenChar(0);
        % Close onscreen window and release all other ressources:
        Screen('CloseAll');
        if (gexp.training)
            % Display percentage of correct answers for training mode
            display(['Percent Correct: ' num2str(gexp.percentCorrect)]);
        end
        % Prompt to save the data in the subject's main data file
        if (gexp.training == 0)
            appendData;
        end
        % Reenable Synctests after this simple demo:
        Screen('Preference','SkipSyncTests',1);
        clear all;
    catch
        ListenChar(0);
        Screen('CloseAll');
        if (gexp.training)
            % Display percentage of correct answers for training mode
            display(['Percent Correct: ' num2str(gexp.percentCorrect)]);
        end
        % Prompt to save the data in the subject's main data file
        if (gexp.training == 0)
            appendData;
        end
        fclose(gexp.fid);
        psychrethrow(psychlasterror);
        clear all;
    end
    

       
% Create array for positions and size of random dots
function surface = DotPositions(surface,plane)
    global gdots;
    global gaperture;
    global gexp;
    global gdistances;
    
    % Need the number of surface in the array to be even to avoid problems at
    % the seam of the hinge
    %if gexp.type ~= 10
    if mod(gdots.arraySize,2) ~=0
        gdots.arraySize = gdots.arraySize + 1;
    end
    %end

    
    if (gdots.surfaces == 2)
        % For the dual-plane experiments, the distance must be adjusted
        if (plane == 1)
            distToStim = gdistances.vergence - gdots.surfaceGap / 2;
        else
            distToStim = gdistances.vergence + gdots.surfaceGap / 2;
        end
    else
        distToStim = gdistances.vergence;
    end

    %%%%%%%% Create arrays of dot locations
    
    if gexp.type == 10
        clear surface
    end
    
    %% Create a grid pattern
    % Left
    
    surface.positions.left(:,:,1) =  ones(gdots.arraySize,1) * (-gdots.maxDisplacement:(2 * gdots.maxDisplacement / (gdots.arraySize - 1)):...
        -(gdots.maxDisplacement / (gdots.arraySize - 1)));
    surface.positions.left(:,:,2) =  (-gdots.maxDisplacement:(2 * gdots.maxDisplacement / (gdots.arraySize - 1)):gdots.maxDisplacement)' * ones(1,gdots.arraySize / 2);
    surface.positions.left(:,:,3) = 0;
    % Right
    surface.positions.right(:,:,1) =   ones(gdots.arraySize,1) * (gdots.maxDisplacement / (gdots.arraySize - 1):(2 * gdots.maxDisplacement / (gdots.arraySize - 1))...
        :gdots.maxDisplacement);
    surface.positions.right(:,:,2) =  (-gdots.maxDisplacement:(2 * gdots.maxDisplacement / (gdots.arraySize - 1)):gdots.maxDisplacement)' * ones(1,gdots.arraySize / 2);
    surface.positions.right(:,:,3) = 0;
    
    %add center seam if doing hinge exp, and randomize rectangle shape, and
    %hinge width
    
    if gexp.type == 10
        clear surface;
        %randomize height and width of grid rectangles
        numColumns = gdots.arraySize + round((rand*gdots.arraySize)-(gdots.arraySize/2));
        numRows = gdots.arraySize + round((rand*gdots.arraySize)-(gdots.arraySize/2));
        %round to nearest even number
        numColumns = ceil((numColumns + 1)/2)*2;
        numRows = ceil((numRows + 1)/2)*2;
        
        %add a little randomness to the width + height of the hinge sides
        %take 30 percent of hinge width
        randPercentWidth = gdots.maxDisplacement*.3;
        randPercentHeight = gdots.maxDisplacement*.3;
        %randomly add or subtract 
        randPercentWidth = (rand*2*randPercentWidth)-randPercentWidth;
        randPercentHeight = (rand*2*randPercentHeight)-randPercentHeight;

        % Left
        %surface.positions.left(:,:,1) =  ones(numRows,1) * (-gdots.maxDisplacement:(gdots.maxDisplacement / (numColumns/2 - 1 )):0);
        surface.positions.left(:,:,1) =  ones(numRows,1) * (-gdots.maxDisplacement-randPercentWidth:((gdots.maxDisplacement+randPercentWidth) / (numColumns/2 - 1 )):0);
        surface.positions.left(:,:,2) =  [(-gdots.maxDisplacement-randPercentHeight:((gdots.maxDisplacement+randPercentHeight) / (numRows/2 - 1)):0)' * ones(1,numColumns / 2) ; (0:((gdots.maxDisplacement+randPercentHeight) / (numRows/2 - 1)):gdots.maxDisplacement+randPercentHeight)' * ones(1,numColumns / 2)];
        surface.positions.left(:,:,3) = 0;
        %     surface.positions.left(:,:,1) =  ones(gdots.arraySize,1) * (-gdots.maxDisplacement:(gdots.maxDisplacement / (gdots.arraySize/2 - 1 )):0);
        %     surface.positions.left(:,:,2) =  [(-gdots.maxDisplacement:(gdots.maxDisplacement / (gdots.arraySize/2 - 1)):0)' * ones(1,gdots.arraySize / 2) ; (0:(gdots.maxDisplacement / (gdots.arraySize/2 - 1)):gdots.maxDisplacement)' * ones(1,gdots.arraySize / 2)];
        %     surface.positions.left(:,:,3) = 0;
        % Right
        %surface.positions.right(:,:,1) =  ones(numRows,1) * (0:(gdots.maxDisplacement / (numColumns/2 - 1 )):gdots.maxDisplacement);
        surface.positions.right(:,:,1) =  ones(numRows,1) * (0:((gdots.maxDisplacement+randPercentWidth) / (numColumns/2 - 1 )):gdots.maxDisplacement+randPercentWidth);
        surface.positions.right(:,:,2) =  [(-gdots.maxDisplacement-randPercentHeight:((gdots.maxDisplacement+randPercentHeight) / (numRows/2 - 1)):0)' * ones(1,numColumns / 2) ; (0:((gdots.maxDisplacement+randPercentHeight) / (numRows/2 - 1)):gdots.maxDisplacement+randPercentHeight)' * ones(1,numColumns / 2)];
        surface.positions.right(:,:,3) = 0;
        
%         surface.positions.right(:,:,1) =   ones(gdots.arraySize,1) * (0:(gdots.maxDisplacement / (gdots.arraySize/2 - 1 ))...
%             :gdots.maxDisplacement);
%         surface.positions.right(:,:,2) =  [(-gdots.maxDisplacement:(gdots.maxDisplacement / (gdots.arraySize/2 - 1)):0)' * ones(1,gdots.arraySize / 2) ; (0:(gdots.maxDisplacement / (gdots.arraySize/2 - 1)):gdots.maxDisplacement)' * ones(1,gdots.arraySize / 2)];
%         surface.positions.right(:,:,3) = 0;
    end
    
    
        
    %% If the experiment calls for it, add random perturbations to the 
    %% x- and y-coordinates
    if (gexp.gridDots == 0)
        % Left
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positions.left(1:gdots.arraySize,1:gdots.arraySize / 2,1)...
            + randn(gdots.arraySize,gdots.arraySize / 2) .* gdots.maxDispDev;
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) = surface.positions.left(1:gdots.arraySize,1:gdots.arraySize / 2,2)...
            + randn(gdots.arraySize,gdots.arraySize / 2) .* gdots.maxDispDev;
        % Right
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positions.right(1:gdots.arraySize,1:gdots.arraySize / 2,1)...
            + randn(gdots.arraySize,gdots.arraySize / 2) .* gdots.maxDispDev;
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,2) = surface.positions.right(1:gdots.arraySize,1:gdots.arraySize / 2,2)...
            + randn(gdots.arraySize,gdots.arraySize / 2) .* gdots.maxDispDev;
        %% Surface sizes
        % Left
        surface.sizes.left = ones(gdots.arraySize, gdots.arraySize / 2) * gdots.meanSize + randn(gdots.arraySize, gdots.arraySize / 2) * gdots.maxSizeDev;
        % Right
        surface.sizes.right = ones(gdots.arraySize, gdots.arraySize / 2) * gdots.meanSize + randn(gdots.arraySize, gdots.arraySize / 2) * gdots.maxSizeDev;  
    elseif (gexp.type == 10)
        %don't adjust for hinge exp
        surface.positionsAdj.left   = surface.positions.left;
        surface.positionsAdj.right  = surface.positions.right;
        %% Surface sizes
        surface.sizes.left          = ones(numRows, numColumns/2) * gdots.meanSize;
        surface.sizes.right         = ones(numRows, numColumns/2) * gdots.meanSize; 
        gdots.numRows               = numRows;
        gdots.numColumns            = numColumns;
    else
        % Left
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positions.left(1:gdots.arraySize,1:gdots.arraySize / 2,1);
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) = surface.positions.left(1:gdots.arraySize,1:gdots.arraySize / 2,2);
        % Right
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positions.right(1:gdots.arraySize,1:gdots.arraySize / 2,1);
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,2) = surface.positions.right(1:gdots.arraySize,1:gdots.arraySize / 2,2);
            %% Surface sizes
        % Left
        surface.sizes.left = ones(gdots.arraySize, gdots.arraySize / 2) * gdots.meanSize;
        % Right
        surface.sizes.right = ones(gdots.arraySize, gdots.arraySize / 2) * gdots.meanSize;  
    end
    
    

    
    %% If any x-coordinates are greater than 0 for the left side, then the
    %% surface will appear on the wrong side of the hinge stimulus and ruin the
    %% stimulus.  Correct for this by setting any x-values greater than 0
    %% to 0.  Same goes for y-coordinates.
    if (gexp.type == 3)
        % Left
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1)  = surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) +...
            (surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,1) > 0) * 10000; 
        % Right    
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) + ...
            (surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) < 0) * 10000;
    elseif (gexp.type ~= 3) && (gexp.type ~= 10)
        % Left
        surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1)  = surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) .*...
            (surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,1) <= 0); 
        % Right    
        surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,1) = surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) .* ...
            (surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) >= 0);
    end
    % Left
    surface.positionsAdj.left(:,:,3) = surface.positions.left(:,:,3);
    % Right
    surface.positionsAdj.right(:,:,3) = surface.positions.right(:,:,3);
    


    
    
%     %% Experiment 4 uses an X-pattern of dots, accomplished by setting the
%     %% y-values equal to the x-values.
%     if gexp.type == 4
%         % Left
%         surface.positionsAdj.left(1:gdots.arraySize / 2,:,2) =  surface.positionsAdj.left(1:gdots.arraySize / 2,:,1);
%         surface.positionsAdj.left(gdots.arraySize / 2 + 1:gdots.arraySize,:,2) =  -surface.positionsAdj.left(gdots.arraySize / 2 + 1:gdots.arraySize,:,1);
%         surface.positionsAdj.left(:,:,3) = 0;
%         % Right
%         surface.positionsAdj.right(1:gdots.arraySize / 2,:,2) =  surface.positionsAdj.right(1:gdots.arraySize / 2,:,1);
%         surface.positionsAdj.right(gdots.arraySize / 2 + 1:gdots.arraySize,:,2) =  -surface.positionsAdj.right(gdots.arraySize / 2 + 1:gdots.arraySize,:,1);
%         surface.positionsAdj.right(:,:,3) = 0;
%     end   

    %% Make sure that the surface fits within the aperture
    if gexp.useAperture
        if (gexp.type < 7)
            % Left
            surface.gdistances.left = sqrt(surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1).^2 ./ gaperture.currentAspect^2 + ...
                surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2).^2) .* (distToStim ./(distToStim + ...
                 surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,3)));
            surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) =  surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) + ...
                (surface.gdistances.left > gaperture.radius) * 10000;
            surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) =  surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) +  ...
                (surface.gdistances.left > gaperture.radius) * 10000;
            % Right
            surface.gdistances.right = sqrt(surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1).^2 ./ gaperture.currentAspect^2 + ...
                surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2).^2) .* (distToStim ./ (distToStim + ...
                 surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,3)));
            surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) =  surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) + ...
                (surface.gdistances.right > gaperture.radius) * 10000;
            surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2) =  surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2) + ...
                (surface.gdistances.right > gaperture.radius) * 10000;
        else
            % Left
            surface.gdistances.left = sqrt(surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1).^2 + ...
                surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2).^2) .* (distToStim ./(distToStim + ...
                 surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2,3)));
            surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) =  surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 1) + ...
                (surface.gdistances.left > gaperture.radius) * 10000;
            surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) =  surface.positionsAdj.left(1:gdots.arraySize,1:gdots.arraySize / 2, 2) +  ...
                (surface.gdistances.left > gaperture.radius) * 10000;
            % Right
            surface.gdistances.right = sqrt(surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1).^2  + ...
                surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2).^2) .* (distToStim ./ (distToStim + ...
                 surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2,3)));
            surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) =  surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 1) + ...
                (surface.gdistances.right > gaperture.radius) * 10000;
            surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2) =  surface.positionsAdj.right(1:gdots.arraySize,1:gdots.arraySize / 2, 2) + ...
                (surface.gdistances.right > gaperture.radius) * 10000;
            surface.positionsAdj.left(:,:,1) = gaperture.currentAspect .* surface.positionsAdj.left(:,:,1);
            surface.positionsAdj.right(:,:,1) = gaperture.currentAspect .* surface.positionsAdj.right(:,:,1);
        end 
    end
    

    
    
    

    
% Find the vertices for the voronoi texture
% NOTE:  Currently does NOT support hinges
function CreateVoronoiVertices
    global gdistances
    global gmonitor
    global gvoronoi
    global gaperture
    
    % Create initial 2d grid composed of points
    gvoronoi.X = ones(gvoronoi.arraySize,1) * (-gvoronoi.maxDisplacement:(2 * gvoronoi.maxDisplacement / (gvoronoi.arraySize - 1)):gvoronoi.maxDisplacement);
    gvoronoi.Y = (-gvoronoi.maxDisplacement:(2 * gvoronoi.maxDisplacement / (gvoronoi.arraySize - 1)):gvoronoi.maxDisplacement)' * ones(1,gvoronoi.arraySize);
    gvoronoi.X = gvoronoi.X + randn(gvoronoi.arraySize,gvoronoi.arraySize) .* gvoronoi.maxDispDev;
    gvoronoi.Y = gvoronoi.Y + randn(gvoronoi.arraySize,gvoronoi.arraySize) .* gvoronoi.maxDispDev;
    
    %% Make sure that the points fit within the aperture
    gvoronoi.distances = sqrt(gvoronoi.X.^2 ./ gaperture.currentAspect^2 + gvoronoi.Y.^2);
    gvoronoi.X = gvoronoi.X .* (gvoronoi.distances < gaperture.radius);
    gvoronoi.Y = gvoronoi.Y .* (gvoronoi.distances < gaperture.radius);
    
    % Get the scaling factor for the stimulus distance
    distToStim = gdistances.vergence;
    distance_scale = distToStim / gmonitor.distance;
    % Scale the coordinates
    gvoronoi.X = gvoronoi.X .* distance_scale;
    gvoronoi.Y = gvoronoi.Y .* distance_scale;
    
    % Get the voronoi coordinates
    [gvoronoi.vX, gvoronoi.vY] = voronoi(gvoronoi.X,gvoronoi.Y);


% Draw the dot stimulus
function CreateDotStimulus(gwin)
    global ghinge
    global gdots
    global gdistances
    global gmonitor
    global GL
    global gtextures

    glClear;
%     glMatrixMode(GL.MODELVIEW);
%    	glLoadIdentity();
    glDisable(GL.DEPTH_TEST);
    glEnable(GL.TEXTURE_2D);
    
    % Display front surface
    glPushMatrix;
        % Perform transforms for entire surface
        glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence + gdots.surfaceGap / 2);
        glRotated(ghinge.front.baseAngle,ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));

        % Setup the drawing arrays and texture reference
        glEnableClientState(GL.VERTEX_ARRAY);
        glEnableClientState(GL.TEXTURE_COORD_ARRAY);
%         glEnable(GL.TEXTURE_2D);
        % If two surfaces are being displayed, use the dimmer dot texture
        % for the front
        if (gdots.surfaces == 2)
            glBindTexture(GL.TEXTURE_2D, gtextures(2));
        else
            glBindTexture(GL.TEXTURE_2D, gtextures(1));
        end
        glTexCoordPointer(2, GL.DOUBLE, 0, gdots.front.texCoordsVector);

        % Setup texture painting properties
        glTexEnvf(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.REPLACE);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
        glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);

        % Left side first
        glPushMatrix();
            % Perform hinge rotation
            glRotated(0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % Obtain bounding vertices for the gdots on the left side
            glVertexPointer(3, GL.DOUBLE, 0, gdots.front.vXYZ.vector.left);  
            % Draw all of the dots
            glDrawArrays(GL.QUADS, 0, 4 * gdots.arraySize ^2 / 2);
        glPopMatrix();
    
        % Now the right side
        glPushMatrix();
            glRotated(-0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            glVertexPointer(3, GL.DOUBLE, 0, gdots.front.vXYZ.vector.right);  
            glDrawArrays(GL.QUADS, 0, 4 * gdots.arraySize ^2 / 2);
        glPopMatrix();

    glPopMatrix;

    % Display back surface?
    if (gdots.surfaces == 2)
        glPushMatrix;
            % Perform transforms for entire surface
            glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence - gdots.surfaceGap / 2);
            glRotated(ghinge.back.baseAngle,ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));

            % Setup the drawing arrays and texture reference
            glEnableClientState(GL.VERTEX_ARRAY);
            glEnableClientState(GL.TEXTURE_COORD_ARRAY);
%             glEnable(GL.TEXTURE_2D);
            glBindTexture(GL.TEXTURE_2D, gtextures(3));
            glTexCoordPointer(2, GL.DOUBLE, 0, gdots.back.texCoordsVector);

            % Setup texture painting properties
            glTexEnvf(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.REPLACE);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);

            % Left side first
            glPushMatrix();
                % Perform hinge rotation
                glRotated(0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
                % Obtain bounding vertices for the dots on the left side
                glVertexPointer(3, GL.DOUBLE, 0, gdots.back.vXYZ.vector.left);  
                % Draw all of the dots
                glDrawArrays(GL.QUADS, 0, 4 * gdots.arraySize ^2 / 2);
            glPopMatrix();

            % Now the right side
            glPushMatrix();
                glRotated(-0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
                glVertexPointer(3, GL.DOUBLE, 0, gdots.back.vXYZ.vector.right);  
                glDrawArrays(GL.QUADS, 0, 4 * gdots.arraySize ^2 / 2);
            glPopMatrix();
        glPopMatrix;
    end

    glDisable(GL.TEXTURE_2D);
    glEnable(GL.DEPTH_TEST);
    
% Draw the grid stimulus
function CreateLineStimulus(gwin)
    global ghinge
    global gdots
    global gdistances
    global gmonitor
    global GL

    glClear;
    
    
    % Set line width and color
    glLineWidth(4);
    glColor3f(1.0,0.0,0.0);
    
    % Display front surface
    glPushMatrix;
        % Perform transforms for entire surface
        glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence + gdots.surfaceGap / 2);
        glRotated(ghinge.front.baseAngle,ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
        glRotated(ghinge.pitchAngle,1.0,0,0);

        % Left side first
        glPushMatrix();
            % Perform hinge rotation
            glRotated(0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % Columns first
            for j = 1:gdots.arraySize/2
            %for j = 1:gdots.front.positionsAdj.left(1,:,1)
            
                glBegin(GL.LINE_STRIP)
                for i = 1:gdots.arraySize
                %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                    if (gdots.front.positionsAdj.left(i,j,1) < 1000)  % Check if the vertex is w/in the aperture
                        glVertex2f(gdots.front.positionsAdj.left(i,j,1),gdots.front.positionsAdj.left(i,j,2));
                    end
                end
                glEnd();
            end
            % Now rows
            for i = 1:gdots.arraySize
            %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                glBegin(GL.LINE_STRIP)
                for j = 1:gdots.arraySize/2
                %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                    if (gdots.front.positionsAdj.left(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.left(i,j,1),gdots.front.positionsAdj.left(i,j,2));
                    end
                end
                if (gdots.front.positionsAdj.left(i,j,1) < 1000)
                    glVertex2f(0,gdots.front.positionsAdj.left(i,j,2));
                end
                glEnd();
            end
        glPopMatrix();
        
        % Right side
        glPushMatrix();
            % Perform hinge rotation
            glRotated(-0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % Columns first
            for j = 1:gdots.arraySize/2
            %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                glBegin(GL.LINE_STRIP)
                for i = 1:gdots.arraySize
                %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                    if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.right(i,j,1),gdots.front.positionsAdj.right(i,j,2));
                    end
                end
                glEnd();
            end
            % Now rows
            for i = 1:gdots.arraySize
            %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                glBegin(GL.LINE_STRIP)
%                 if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                    glVertex2f(0,gdots.front.positionsAdj.right(i,1,2));
%                 end
                for j = 1:gdots.arraySize/2
                %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                    if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.right(i,j,1),gdots.front.positionsAdj.right(i,j,2));
                    end
                end
                glEnd();
            end
        glPopMatrix();
    glPopMatrix;
    
% Draw the grid stimulus for type 10, with random number of rows and
% columns
function CreateLineStimulusRand(gwin)
    global ghinge
    global gdots
    global gdistances
    global gmonitor
    global GL

    glClear;

    
    
    % Set line width and color
    glLineWidth(4);
    glColor3f(1.0,0.0,0.0);
    
    % Display front surface
    glPushMatrix;
        % Perform transforms for entire surface
        glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence + gdots.surfaceGap / 2);
        glRotated(ghinge.front.baseAngle,ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
        glRotated(ghinge.pitchAngle,1.0,0,0);

        % Left side first
        glPushMatrix();
            % Perform hinge rotation
            glRotated(0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % Columns first
            for j = 1:gdots.numColumns/2
            %for j = 1:gdots.front.positionsAdj.left(1,:,1)
            
                glBegin(GL.LINE_STRIP)
                for i = 1:gdots.numRows
                %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                    if (gdots.front.positionsAdj.left(i,j,1) < 1000)  % Check if the vertex is w/in the aperture
                        glVertex2f(gdots.front.positionsAdj.left(i,j,1),gdots.front.positionsAdj.left(i,j,2));
                    end
                end
                glEnd();
            end
            % Now rows
            for i = 1:gdots.numRows
            %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                glBegin(GL.LINE_STRIP)
                for j = 1:gdots.numColumns/2
                %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                    if (gdots.front.positionsAdj.left(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.left(i,j,1),gdots.front.positionsAdj.left(i,j,2));
                    end
                end
                if (gdots.front.positionsAdj.left(i,j,1) < 1000)
                    glVertex2f(0,gdots.front.positionsAdj.left(i,j,2));
                end
                glEnd();
            end
        glPopMatrix();
        
        % Right side
        glPushMatrix();
            % Perform hinge rotation
            glRotated(-0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % Columns first
            for j = 1:gdots.numColumns/2
            %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                glBegin(GL.LINE_STRIP)
                for i = 1:gdots.numRows
                %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                    if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.right(i,j,1),gdots.front.positionsAdj.right(i,j,2));
                    end
                end
                glEnd();
            end
            % Now rows
            for i = 1:gdots.numRows
            %for i = 1:gdots.front.positionsAdj.left(:,1,1)
                glBegin(GL.LINE_STRIP)
%                 if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                    glVertex2f(0,gdots.front.positionsAdj.right(i,1,2));
%                 end
                for j = 1:gdots.numColumns/2
                %for j = 1:gdots.front.positionsAdj.left(1,:,1)
                    if (gdots.front.positionsAdj.right(i,j,1) < 1000)
                        glVertex2f(gdots.front.positionsAdj.right(i,j,1),gdots.front.positionsAdj.right(i,j,2));
                    end
                end
                glEnd();
            end
        glPopMatrix();
    glPopMatrix;    

% Draw the voronoi stimulus
function CreateVoronoiStimulus(gwin)
    global ghinge
    global gdots
    global gdistances
    global gmonitor
    global GL
    global gaperture
    global gvoronoi
    
    glClear;
%     glDisable(GL.DEPTH_TEST);
    
    % Determine maximum displacement of a vertex from the origin
    scaledRadius = gaperture.radius * gdistances.vergence / gmonitor.distance;
    
    % Set line width and color
    glLineWidth(gvoronoi.lineWidth);
    glColor3f(1.0,0.0,0.0);
    
    % Display surface
    glPushMatrix;
        % Perform transforms for entire surface
        glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence);
        glRotated(ghinge.front.baseAngle,ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));

        % Draw each line segment, but make sure none extend outside the
        % desired stimulus size
        for i=1:length(gvoronoi.vX(1,:))
            if sqrt(gvoronoi.vX(1,i)^2 + gvoronoi.vY(1,i)^2) < scaledRadius && sqrt(gvoronoi.vX(2,i)^2 + gvoronoi.vY(2,i)^2) < scaledRadius
                glBegin(GL.LINES);
                    glVertex2f(gvoronoi.vX(1,i), gvoronoi.vY(1,i));
                    glVertex2f(gvoronoi.vX(2,i), gvoronoi.vY(2,i));
                glEnd;
            end
        end
    glPopMatrix;

%     glEnable(GL.DEPTH_TEST);
    
% Draw the fixation stimulus
function CreateFixation(gwin,whichEye)
    global ghinge
    global gdistances
    global gmonitor
    global GL
    global gtextures
    
    distanceFactor = (gdistances.vergence + gdistances.fixationOffset) / gmonitor.distance;
    if (gmonitor.rotation <= -45)
        widthFactor = 1.5;
    elseif (gmonitor.rotation <= -30)
        widthFactor = 1.25;
    else
        widthFactor = 3;
    end

    % Display fixation stimulus
    glPushMatrix; 
        glTranslatef(0.0, 0.0, gmonitor.distance - gdistances.vergence - gdistances.fixationOffset);
        
        % Setup the texture reference
        glEnable(GL.TEXTURE_2D);
        glBindTexture(GL.TEXTURE_2D, gtextures(4));

        glPushMatrix();
            glRotated(0.5 * (180 - ghinge.hingeAngle),ghinge.rotatev(1),ghinge.rotatev(2),ghinge.rotatev(3));
            % If it's the right eye, flip the texture
            if (whichEye == 1)
                glRotated(180,0,0,1);
            end
            DrawTexturedQuad(25 * distanceFactor * widthFactor,25 * distanceFactor);
        glPopMatrix();

        glDisable(GL.TEXTURE_2D);
        glEnable(GL.DEPTH_TEST);
    glPopMatrix;

    
% Refresh display
% The items within this function must be executed each time a new stimulus
% is presented
function UpdateStimulus
    global gdots
    global gexp
    global gdistances
    global gmonitor
    
    if (gexp.type < 5)
        % Create new random dot array
        gdots.front = DotPositions(gdots.front,1); 
        gdots.front = AdjustDots(gdots.front,1);
        if (gdots.surfaces == 2)
            gdots.back = DotPositions(gdots.back,2); 
            gdots.back = AdjustDots(gdots.back,2);
        end
    elseif (gexp.type < 7)
        % Create new voronoi pattern
        CreateVoronoiVertices;
    elseif (gexp.type >=7)
        % Create new grid array
        gdots.front = DotPositions(gdots.front,1); 
        % Get the scaling factor for the stimulus distance
        distToStim = gdistances.vergence;
        distance_scale = distToStim / gmonitor.distance;
        % Scale the coordinates
        gdots.front.positionsAdj.left(:,:,1) = gdots.front.positionsAdj.left(:,:,1) .* distance_scale;
        gdots.front.positionsAdj.left(:,:,2) = gdots.front.positionsAdj.left(:,:,2) .* distance_scale;
        gdots.front.positionsAdj.right(:,:,1) = gdots.front.positionsAdj.right(:,:,1) .* distance_scale;
        gdots.front.positionsAdj.right(:,:,2) = gdots.front.positionsAdj.right(:,:,2) .* distance_scale;
        
    end
        

% Render the stimulus
function RenderScene(whichEye,gwin)
    global GL
    global grender
    global gexp
    global testCalibration
    
    %% Render an eye
    Screen('SelectStereoDrawBuffer', gwin, whichEye);
    Screen('BeginOpenGL', gwin);
    
    glClear;
    glMatrixMode(GL.MODELVIEW);
   	glLoadIdentity();
    glDisable(GL.DEPTH_TEST)

    % Draw the dots
    if (gexp.type == 6 || gexp.type == 8 || (gexp.type == 10 && gexp.exptenstereo == 0))
        % Monocular condition
        StereoProjection(2);
    else
        StereoProjection(whichEye);
    end
    
    if grender.stimulus
        if (gexp.type < 5)
            CreateDotStimulus(gwin);
        elseif (gexp.type >= 7 && gexp.type < 10)
            CreateLineStimulus(gwin);
        elseif (gexp.type == 10)
            CreateLineStimulusRand(gwin);
        else
            CreateVoronoiStimulus(gwin);
        end
    end
    if grender.fixation
        CreateFixation(gwin,whichEye);
    end
    
    % Display the calibration lines if requested.  These correspond to
    % wires on the loom, which should have been used to calibrate the
    % display using the cyclopean eye.
    glColor3f(1, 1, 1);
    % Set up variables for moving lines
    z1 = 325;
    z2 = 225;
    xR = 50;
    xL = -50;
    
    switch testCalibration.whichEye
        case 1
            leftX = (z1 + z2) / (z1) * (gexp.ipd / 2 + xL) - gexp.ipd / 2;
            centerX = (z1 + z2) / (z1) * (gexp.ipd / 2) - gexp.ipd / 2;
            rightX = (z1 + z2) / (z1) * (gexp.ipd / 2 + xR) - gexp.ipd / 2;
            %% Left eye
            % Left line
            glBegin(GL.LINES);
                glVertex3d(leftX, -100, 0);
                glVertex3d(leftX, 100, 0);
            glEnd;
            % Center line
            glBegin(GL.LINES);
                glVertex3d(centerX, -100, 0);
                glVertex3d(centerX, 100, 0);
            glEnd;
            % Right line
            glBegin(GL.LINES);
                glVertex3d(rightX, -100, 0);
                glVertex3d(rightX, 100, 0);
            glEnd;
        case 2
            leftX = (z1 + z2) / (z1) * (xL - gexp.ipd / 2) + gexp.ipd / 2;
            centerX = -((z1 + z2) / (z1) * (gexp.ipd / 2) - gexp.ipd / 2);
            rightX = (z1 + z2) / (z1) * (xR - gexp.ipd / 2) + gexp.ipd / 2;
            %% Right eye
            % Left line
            glBegin(GL.LINES);
                glVertex3d(leftX, -100, 0);
                glVertex3d(leftX, 100, 0);
            glEnd;
            % Center line
            glBegin(GL.LINES);
                glVertex3d(centerX, -100, 0);
                glVertex3d(centerX, 100, 0);
            glEnd;
            % Right line
            glBegin(GL.LINES);
                glVertex3d(rightX, -100, 0);
                glVertex3d(rightX, 100, 0);
            glEnd;  
        otherwise
    end
    
    glEnable(GL.DEPTH_TEST);    
    glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    Screen('EndOpenGL', gwin);
    
% Update the stimulus conditions from the desired staircase.  Takes in
% staircase ID
function updateConditions(scnum)
    global gexp
    global gscell
    global ghinge
    global gdistances
    global gmonitor
    global gdots
    
    if gexp.type == 1 || gexp.type == 5 || gexp.type == 6 || gexp.type == 7 || gexp.type == 8 || gexp.type == 9
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        ghinge.front.baseAngle = get(gscell{scnum},'currentValue');
    elseif gexp.type == 10
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        gmonitor.distance = get(gscell{scnum},'CoPDistance');
        ghinge.hingeAngle = get(gscell{scnum},'currentValue');
        ghinge.pitchAngle = get(gscell{scnum},'pitchAngle');
        gdots.maxDisplacement = get(gscell{scnum},'hingeSizeMm');
        gdots.arraySize = (gdots.maxDisplacement/10);
    elseif gexp.type == 2
        ghinge.back.baseAngle = get(gscell{scnum},'currentValue');    
    elseif gexp.type == 3
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        ghinge.H = get(gscell{scnum},'currentValue');
    elseif gexp.type == 4
        gdistances.vergence = get(gscell{scnum},'stimDistance');
        ghinge.rollAngle = ghinge.rollDirection * get(gscell{scnum},'currentValue');
%         ghinge.rollDirection = -ghinge.rollDirection;
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
        
    
        