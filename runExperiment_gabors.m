function [ds,pa,kb,tx,gSCell] = runExperiment_gabors(varargin)

% Top level script for distance-dependence in prior estimation
%
% Experimental parameters and data stored in one of three structures:
%   - ds: display information and stimulus physical parameters
%   - kb: key presses throughout experiment
%   - pa: trial parameters and saved subject responses

%% General Setup
close all;

% Initialize display & experimental parameters

% Parameter defaults
pars = {[0.5;1],...                 % 1 - array of display distances (m; m1-left, m2-right)
        'AOC',...                   % 2 - Display ID (for loading luminance lookup table)
        1};                         % 3 - debug setting (0 - normal, 1 -debug,
                                    %                    2 - run self, 3 - autorun)
        
% If parameters passed as arguments
if nargin > 0
    autoPars = varargin{1};          % Pass cell array with SubID,block,session info
    pars{1}  = varargin{2};          % array of display distances (m; m1-left, m2-right)
    pars{2}  = varargin{3};          % Display ID
    pars{3}  = varargin{4};          % Set to autorun
    stairPars  = varargin{5};        % Staircase parameters
else
    autoPars = [];
end
      
if pars{3} == 1
    suppressSave = 1;
else
    suppressSave = 0;
end

% Setup display
[ds] = SetupDisplay(pars);                     

% Set up the experimental parameters
[pa] = SetupParameters_gabors(pars,ds,autoPars);

% Define keyboard mappings
[kb] = SetupKeyboard();                        

HideCursor(ds.screenID(1));                    % Hide cursor on stimulus display
ListenChar(2);                                 % Listen to keypresses, but don't display them


%% Setup staircasing
global gSCell

% Define staircase object
s         = PTBStaircase;

% Initialize cell array of staircases
gSCell    = cell(1);

% Set values of first staircase
gSCell{1} = set(s,...
                'initialValue_random_range',stairPars.initialValue_random_range,...
                'stepSize',stairPars.stepSize,... 
                'stepLimit',stairPars.stepLimit,...                
                'minValue',stairPars.minValue,...
                'maxValue',stairPars.maxValue,...
                'maxReversals',stairPars.maxReversals,...
                'maximumtrials',stairPars.maximumtrials,...
                'currentReversals',0,...
                'lastDirection',0,...
                'complete',0,...
                'numUp',2,...
                'numDown',1);
            
% Determine how many staircases we want to make
contCombs  = stairPars.contCombs;   % Reference/Test constrasts (%)
refPos     = stairPars.refPos;      % Ref Near/Far (inds)
testPos    = stairPars.testPos;     % Test on same or different screen (y/n)
refVels    = stairPars.refVels;     % Reference velocities (deg/s)
stairTypes = stairPars.stairTypes;  % x up/y down (inds)

% Stacking between and within screen judgments on top of each other
% pa.numStaircases = size(contCombs,1)*numel(refPos)*numel(refVels)*size(stairTypes,1) + ...
%                                      numel(refPos)*numel(refVels)*size(stairTypes,1);
pa.numStaircases = size(contCombs,1)*numel(refPos)*numel(refVels)*size(stairTypes,1);
                                 
scInds = makeCombos([size(contCombs,1) numel(refPos) numel(refVels) size(stairTypes,1)]);
% scInds2 = makeCombos([1                 numel(refPos) numel(refVels) size(stairTypes,1)]);
% scInds  = [scInds1; scInds2];

% Columns: [Contrast pair, reference screen, reference velocity, staircase type, test screen]
scInds    = [scInds ones(size(scInds,1),1)];
pa.scInds = scInds;

for ii = 1:pa.numStaircases
        
        % Copy over staircase to other cells & tweak individual parameters
        gSCell{ii} = gSCell{1};
        gSCell{ii} = set(gSCell{ii},'refContrast',contCombs(scInds(ii,1),1));
        gSCell{ii} = set(gSCell{ii},'testContrast',contCombs(scInds(ii,1),2));
        gSCell{ii} = set(gSCell{ii},'refScreen',refPos(scInds(ii,2)));
        gSCell{ii} = set(gSCell{ii},'refVelocity',refVels(scInds(ii,3)));
        gSCell{ii} = set(gSCell{ii},'numUp',stairTypes(scInds(ii,4),1));
        gSCell{ii} = set(gSCell{ii},'numDown',stairTypes(scInds(ii,4),2));    
        gSCell{ii} = set(gSCell{ii},'testScreen',testPos(scInds(ii,5)));
        gSCell{ii} = set(gSCell{ii},'refPosition',randi(2));
        
        minVal = exp( log(refVels(scInds(ii,3))) - 1.8);
        maxVal = min([exp( log(refVels(scInds(ii,3))) + 1.8) 20]);
        
        if minVal < 0.5
            minVal = 0.1;
        end        
        gSCell{ii} = set(gSCell{ii},'minValue',minVal);
        gSCell{ii} = set(gSCell{ii},'maxValue',maxVal);
        gSCell{ii} = set(gSCell{ii},'initialValue_random_range',maxVal-minVal);
        
        
end
      
% Initialize all of the staircases (i.e. randomize starting value)
for i = 1:length(gSCell)
    gSCell{i} = initializeStaircase(gSCell{i});
end

% Randomly select an initial staircase
currentScInd = PTBSelectStaircase(gSCell);


%% Begin Pre-experiment Epoch

 dText = 'above and below a red dot.';
 rText = 'UP or DOWN / LEFT or RIGHT ARROW';
 inst  = {'UP or DOWN FASTER?','LEFT or RIGHT FASTER?'};
 breakText = {'Time for a break.','Press SPACEBAR when you are ready to continue.'};
  
 % Display instructions on the closest display
 [~,instrDisp] = min(pars{1}); 
 
 readyToBegin = 0;
while ~readyToBegin   
    
    for ii = 1:2
    DrawFormattedText(ds.w(ii),'In the following trials, you will view two moving patterns',...
        'center',ds.textCoords(ii,2)-150);
    DrawFormattedText(ds.w(ii),unicode2native(dText),...
        'center',ds.textCoords(ii,2)-100);
    DrawFormattedText(ds.w(ii),['Press ',rText,' \n to indicate which pattern appeared to move faster.'],...
        'center',ds.textCoords(ii,2)+50);
    DrawFormattedText(ds.w(ii),'Ready to start the experiment? Press SPACEBAR to confirm.',...
        'center',ds.textCoords(ii,2)+250);
    
    Screen('DrawingFinished', ds.w(ii));
    ds.vbl = Screen('Flip', ds.w(ii));
    end
    
    % Query keyboard for subject response
    [kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);

    if kb.keyIsDown && kb.keyCode(kb.spacebarKey)
        readyToBegin=1;
        kb.keyCode(kb.spacebarKey) = 0;
        
        WaitSecs(0.5);
    end
end

%% Start Experiment

% Initialize pars
ds.tElapsed        = 0;
ds.fCount          = 0;
pa.experimentOnset = ds.vbl;
pa.breakCounter    = 0;
pa.breakTime       = 0;
pa.velmat          = [];
pa.mfCounter       = 0;

kb.responseGiven   = 0;
pa.lapseTrial      = 0;
pa.EOTflag         = 0;
pa.stimOrder       = [];
ds.flipTimes       = [];
pa.flipTest        = 0;
pa.flipRef         = 0;
pa.phases = [];

% Initialize new trial
[ds,pa,kb,gSCell] = SetupNewTrial_gabors(ds,pa,kb,gSCell,currentScInd);

% Initialize gabor stimulus
[tx]       = initializeGaborTex(ds,pa);

% Clear text from screen
Screen('FillRect',ds.w(1),[ 0 0 0 ]);
Screen('FillRect',ds.w(2),[ 0 0 0 ]);
Screen('Flip', ds.w(1));
ds.vbl = Screen('Flip', ds.w(2));

% Experimental loop
while (currentScInd) && ~kb.keyCode(kb.escapeKey)

     % Check if subject exceeded allotted response time
    if (ds.vbl > pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA + pa.trialDuraB + pa.respDura) && ~pa.breakTime
        pa.lapseTrial = 1;
    end
    
    % Check to see if subject gave a response after last draw (& is in
    % response epoch)
    [pa,kb]     = GetResponse_RDS(pa,ds,kb);
    
    % Control of stimulus epochs
    if (ds.vbl < pa.trialOnset + pa.fixDuraA) && ~pa.breakTime
        
        if pa.refFirst || pa.trialEpochs == 1
            pa.flipRef  = 1;
            pa.flipTest = 0;
        else
            pa.flipRef  = 0;
            pa.flipTest = 1;
        end
        
        % Fixation Epoch 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if pa.refFirst || pa.trialEpochs == 1
            % Fill window with mean gray background
            Screen('FillRect',pa.refWind,[0 0 0 1]);
            Screen('FillRect',pa.refWind,pa.bgLum,ds.vignetteRects(pa.refScreen,:));
            
            % Draw fixation target (find another way to make this [1 0 0 0])?
            Screen('glPoint',pa.refWind,[1 0 0 1],pa.fpx(pa.refScreen),pa.fpy(pa.refScreen),pa.fpsz(pa.refScreen));
        else
            % Fill window with mean gray background
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            Screen('FillRect',pa.testWind,pa.bgLum,ds.vignetteRects(pa.testScreen,:));
            
            % Draw fixation target (find another way to make this [1 0 0 0])?
            Screen('glPoint',pa.testWind,[1 0 0 1],pa.fpx(pa.testScreen),pa.fpy(pa.testScreen),pa.fpsz(pa.testScreen));
        end
        
    elseif (ds.vbl > pa.trialOnset + pa.fixDuraA) && ...
           (ds.vbl < pa.trialOnset + pa.fixDuraA + pa.trialDuraA) && ~pa.breakTime
        
        % Stimulus presentation epoch 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Draw Gabors for this frame 
        % (if/else block randomizes whether ref or test presented first)
        if pa.refFirst || pa.trialEpochs == 1
            % Exp 2: ref OR Exp 1: position 1

            % Fill window with mean gray background
            Screen('FillRect',pa.refWind,[0 0 0 1]);
            Screen('FillRect',pa.refWind,pa.bgLum,ds.vignetteRects(pa.refScreen,:));
            
            % Draw Gabor texture
            Screen('DrawTextures',pa.refWind,tx.gaborTex{pa.refScreen},[],squeeze(tx.dstRects(pa.refPos,:,pa.refScreen))',...
                              tx.rotAngles(1),[],[],tx.modulateColor,[],...
                              kPsychDontDoRotation,tx.gaborPars(:,pa.refPos,pa.refScreen));

            % Draw fixation target
            Screen('glPoint',pa.refWind,[1 0 0 1],pa.fpx(pa.refScreen),pa.fpy(pa.refScreen),pa.fpsz(pa.refScreen));
           
            % Advance phases for next frame (deg of cycle) to produce apparent motion
            % [parameters,position,screen/distance]
            % pa.thisPhaseOff: (ind 1: ref, ind 2: test)
            tx.gaborPars(1,pa.refPos,pa.refScreen) = tx.gaborPars(1,pa.refPos,pa.refScreen) + pa.thisPhaseOff(1);

        else
            % Exp 2: test

            % Fill window with mean gray background
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            Screen('FillRect',pa.testWind,pa.bgLum,ds.vignetteRects(pa.testScreen,:));
            
            % Draw Gabor texture
            Screen('DrawTextures',pa.testWind,tx.gaborTex{pa.testScreen},[],squeeze(tx.dstRects(pa.testPos,:,pa.testScreen))',...
                              tx.rotAngles(1),[],[],tx.modulateColor,[],...
                              kPsychDontDoRotation,tx.gaborPars(:,pa.testPos,pa.testScreen));

            % Draw fixation target
            Screen('glPoint',pa.testWind,[1 0 0 1],pa.fpx(pa.testScreen),pa.fpy(pa.testScreen),pa.fpsz(pa.testScreen));
                          
            % Advance phases for next frame (deg of cycle) to produce apparent motion
            % [parameters,position,screen/distance]
            tx.gaborPars(1,pa.testPos,pa.testScreen) = tx.gaborPars(1,pa.testPos,pa.testScreen) + pa.thisPhaseOff(2);

        end

        if pa.trialEpochs == 1
            % Exp 1: position 2 (test)

            Screen('DrawTextures',pa.refWind,tx.gaborTex{pa.refScreen},[],squeeze(tx.dstRects(pa.testPos,:,pa.refScreen))',...
                              tx.rotAngles(1),[],[],tx.modulateColor,[],...
                              kPsychDontDoRotation,tx.gaborPars(:,pa.testPos,pa.refScreen));

            % Advance phases for next frame (deg of cycle) to produce apparent motion
            % [parameters,position,screen/distance]
            tx.gaborPars(1,pa.testPos,pa.refScreen) = tx.gaborPars(1,pa.testPos,pa.refScreen) + pa.thisPhaseOff(2);
        end

        pa.phases = [pa.phases;[squeeze(tx.gaborPars(1,:,pa.refScreen)) ds.vbl]];


    elseif (ds.vbl > pa.trialOnset + pa.fixDuraA + pa.trialDuraA) && ...
           (ds.vbl < pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA) && ...
           pa.trialEpochs == 2 && ~pa.breakTime
        
        pa.flipRef  = 1;
        pa.flipTest = 1;
       
        % Fixation Epoch 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if pa.refFirst || pa.trialEpochs == 1
            Screen('FillRect',pa.refWind,[0 0 0 1]);
            
            % Fill window with mean gray background
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            Screen('FillRect',pa.testWind,pa.bgLum,ds.vignetteRects(pa.testScreen,:));
            
            % Draw fixation target (find another way to make this [1 0 0 0])?
            Screen('glPoint',pa.testWind,[1 0 0 1],pa.fpx(pa.testScreen),pa.fpy(pa.testScreen),pa.fpsz(pa.testScreen));
        else
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            
            % Fill window with mean gray background
            Screen('FillRect',pa.refWind,[0 0 0 1]);
            Screen('FillRect',pa.refWind,pa.bgLum,ds.vignetteRects(pa.refScreen,:));
            
            % Draw fixation target (find another way to make this [1 0 0 0])?
            Screen('glPoint',pa.refWind,[1 0 0 1],pa.fpx(pa.refScreen),pa.fpy(pa.refScreen),pa.fpsz(pa.refScreen));
        end
        
        
    elseif (ds.vbl > pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA) && ...
           (ds.vbl < pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA + pa.trialDuraB) && ...
           pa.trialEpochs == 2 && ...
           ~kb.responseGiven && ~pa.breakTime
        
        if pa.refFirst
            pa.flipRef  = 0;
            pa.flipTest = 1;
        else
            pa.flipRef  = 1;
            pa.flipTest = 0;
        end

        % Stimulus presentation epoch 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Draw Gabors for this frame 
        % (if/else block randomizes whether ref or test presented first)
        if pa.refFirst
            % Exp 2: test
            
            % Fill window with mean gray background
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            Screen('FillRect',pa.testWind,pa.bgLum,ds.vignetteRects(pa.testScreen,:));
                       
            % Draw Gabor texture
            Screen('DrawTextures',pa.testWind,tx.gaborTex{pa.testScreen},[],squeeze(tx.dstRects(pa.testPos,:,pa.testScreen))',...
                              tx.rotAngles(1),[],[],tx.modulateColor,[],...
                              kPsychDontDoRotation,tx.gaborPars(:,pa.testPos,pa.testScreen));

            % Draw fixation target
            Screen('glPoint',pa.testWind,[1 0 0 1],pa.fpx(pa.testScreen),pa.fpy(pa.testScreen),pa.fpsz(pa.testScreen));              
                          
            % Advance phases for next frame (deg of cycle) to produce apparent motion
            tx.gaborPars(1,pa.testPos,pa.testScreen) = tx.gaborPars(1,pa.testPos,pa.testScreen) + pa.thisPhaseOff(2);

        else
            % Exp 2: ref

            % Fill window with mean gray background
            Screen('FillRect',pa.refWind,[0 0 0 1]);
            Screen('FillRect',pa.refWind,pa.bgLum,ds.vignetteRects(pa.refScreen,:));
            
            % Draw Gabor texture
            Screen('DrawTextures',pa.refWind,tx.gaborTex{pa.refScreen},[],squeeze(tx.dstRects(pa.refPos,:,pa.refScreen))',...
                              tx.rotAngles(1),[],[],tx.modulateColor,[],...
                              kPsychDontDoRotation,tx.gaborPars(:,pa.refPos,pa.refScreen));
                          
            % Draw fixation target
            Screen('glPoint',pa.refWind,[1 0 0 1],pa.fpx(pa.refScreen),pa.fpy(pa.refScreen),pa.fpsz(pa.refScreen));
                          
            % Advance phases for next frame (deg of cycle) to produce apparent motion
            tx.gaborPars(1,pa.refPos,pa.refScreen) = tx.gaborPars(1,pa.refPos,pa.refScreen) + pa.thisPhaseOff(1);

        end

        pa.phases = [pa.phases;[squeeze(tx.gaborPars(1,:,pa.refScreen)) ds.vbl]];
        



    elseif (ds.vbl > pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA + pa.trialDuraB) && ...
            ~kb.responseGiven && ~pa.lapseTrial && ~pa.breakTime
        
        pa.flipRef  = 1;
        pa.flipTest = 1;
        
        % Response Epoch (limited to 3sec)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Fill windows with mean gray background
        Screen('FillRect',pa.refWind,[0 0 0 1]);
        Screen('FillRect',pa.refWind,[0.5 0.5 0.5 1],ds.vignetteRects(pa.refScreen,:));
        
        Screen('TextSize', pa.refWind,50);
        Screen('TextColor',pa.refWind,[1 1 1]);
        DrawFormattedText(pa.refWind,inst{pa.trialEpochs},'center',ds.textCoords(1,2)-00);
        
        if pa.trialEpochs == 2
        Screen('FillRect',pa.testWind,[0 0 0 1]);
        Screen('FillRect',pa.testWind,[0.5 0.5 0.5 1],ds.vignetteRects(pa.testScreen,:));
        
        Screen('TextSize', pa.testWind,50);
        Screen('TextColor',pa.testWind,[1 1 1]);
        DrawFormattedText(pa.testWind,inst{pa.trialEpochs},'center',ds.textCoords(2,2)-100);
        end
        
    elseif (((ds.vbl > pa.trialOnset + pa.fixDuraA + pa.fixDuraB + pa.trialDuraA) && kb.responseGiven) || ...
            pa.lapseTrial) && ~pa.breakTime
        
        pa.flipRef  = 1;
        pa.flipTest = 1;
        
        % ITI/Next trial setup
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        
        % Use response to update staircase and stimulus
        gSCell{currentScInd}  = processResponse(gSCell{currentScInd},pa.response(pa.thisTrial,9));
        
        % Select a new staircase for the next trial
        currentScInd          = PTBSelectStaircase(gSCell);
        
        % Setup next trial if some staircases are left
        if currentScInd > 0
            [ds,pa,kb,gSCell] = SetupNewTrial_gabors(ds,pa,kb,gSCell,currentScInd);
        end
        
        % Define Gabor pars on next trial
        tx.gaborPars(1,:,1)                            = 360*rand(1,2);      % Phase offset
        tx.gaborPars(1,:,2)                            = 360*rand(1,2);      % Phase offset
        tx.gaborPars(4,pa.refPos,pa.refScreen)         = [pa.refCont];             % Contrast/position
        tx.gaborPars(4,~(pa.refPos-1)+1,pa.testScreen) = [pa.testCont];      % Contrast/position
        tx.rotAngles                                   = pa.trialDir*[1 1];        % Drift direction
         
        kb.responseGiven = 0;      
        
        % Clear next fixation screen to gray
%         Screen('FillRect',pa.refWind,[ 0 0 0 1]);
%         Screen('FillRect',pa.refWind,[ 0.5 0.5 0.5 1],ds.vignetteRects(pa.refScreen,:));
        
        % Clear other screen to black
        Screen('FillRect',pa.refWind,[0 0 0]);
        Screen('FillRect',pa.testWind,[0 0 0]);
        
        % Reset lapse flag
        if pa.lapseTrial
            pa.lapseTrial = 0;
        end
        
%         % Set end of trial flag to clear screen (kinda clunky logic here,
%         % prob fix later)
%         pa.EOTflag = 1;
        
        % Check if it's time for a break
        if pa.currentTime - pa.breakCounter >= pa.breakInterval*60
            pa.breakTime = 1;
        end
        
    elseif pa.breakTime
        
        pa.flipRef  = 1;
        pa.flipTest = 1;
        
        % Get a rough estimate of how far along the participant is    
        for ii = 1:pa.numStaircases
            
            completeFlag = get(gSCell{ii},'complete');
            
            if completeFlag
                currentNumTrials(ii) = stairPars.maximumtrials;
            else
                currentNumTrials(ii) = length(get(gSCell{ii},'respRev'));
            end
            
        end
        
        percComplete = round(100*sum(currentNumTrials)/(30*pa.numStaircases));
        
        % Show break text
        Screen('FillRect',pa.refWind,[0 0 0 1]);
        Screen('FillRect',pa.refWind,[0.5 0.5 0.5 1],ds.vignetteRects(pa.refScreen,:));
        
        Screen('TextSize', pa.refWind,30);
        Screen('TextColor',pa.refWind,[1 1 1]);
        DrawFormattedText(pa.refWind,breakText{1},'center',ds.textCoords(1,2)-100);
        DrawFormattedText(pa.refWind,breakText{2},'center',ds.textCoords(1,2)-50);
        DrawFormattedText(pa.refWind,['Percentage complete: ',num2str(percComplete),'%'],'center',ds.textCoords(1,2));
        
        if pa.trialEpochs == 2
            Screen('FillRect',pa.testWind,[0 0 0 1]);
            Screen('FillRect',pa.testWind,[0.5 0.5 0.5 1],ds.vignetteRects(pa.testScreen,:));
            
            Screen('TextSize', pa.testWind,30);
            Screen('TextColor',pa.testWind,[1 1 1]);
            DrawFormattedText(pa.testWind,breakText{1},'center',ds.textCoords(2,2)-100);
            DrawFormattedText(pa.refWind,breakText{2},'center',ds.textCoords(2,2)-50);
            DrawFormattedText(pa.refWind,['Percentage complete: ',num2str(percComplete),'%'],'center',ds.textCoords(2,2));
        end
        
        % Check if participant has pressed the spacebar
        [kb.keyIsDown, ~, kb.keyCode] = KbCheck(-1);
        
        if kb.keyIsDown && kb.keyCode(kb.spacebarKey)
            
            pa.breakTime               = 0;
            pa.breakCounter            = ds.vbl - pa.experimentOnset;
            kb.keyCode(kb.spacebarKey) = 0;
            kb.keyIsDown               = 0;
            
            WaitSecs(0.5);
            
            pa.trialOnset              = GetSecs;
            
        end
        
    end

    % Compute simulation time for this draw cycle:
    ds.tElapsed = (ds.vbl - pa.experimentOnset) * 1;
    
    % Flip screen buffer, get VBL time, and update frame count
    tic
    if pa.flipTest
    Screen('DrawingFinished', pa.testWind);
    Screen('Flip', pa.testWind,[],[],0);
    end
    if pa.flipRef
    Screen('DrawingFinished', pa.refWind);
    Screen('Flip', pa.refWind,[],[],0);
    end
    flipTime = toc;
    
    ds.flipTimes = [ds.flipTimes flipTime];
    
    ds.vblLast = ds.vbl;
    ds.vbl     = GetSecs;
    ds.delta   = ds.vbl - ds.vblLast;
    
    % Identify missed frames as an interval between the current frame and
    % last that is greater than 1.5x the expected interval (and we're past
    % the first frame)
    if (ds.delta > ds.ifi(pa.refScreen)*1.5) && (ds.fCount~=0) && pa.mfCounter < 6
        %%% want to record this in response structure too
        warning('Missed frame');
        pa.mfCounter = pa.mfCounter + 1;
    end
    
    ds.fCount = ds.fCount + 1;
    ds.deltas(1,ds.fCount) = ds.delta;
    ds.deltas(2,ds.fCount) = pa.refScreen;
%     pa.calcTime(ds.fCount) = toc;
end

%% Save Data and Exit

% Save experimental structures to .mat file
if ~suppressSave
    pa.dataFile = fullfile(pa.dataDir,...
        [pa.subjectID '-' pa.date '-' num2str(pa.block) '.mat']);
    save(pa.dataFile, 'pa', 'ds', 'kb','gSCell');
end

% Calculate average framerate:
ds.meanFPS = ds.fCount / (ds.vbl - pa.experimentOnset);

% Output end of experiment instructions to screen
Screen('TextSize', ds.w(instrDisp),30);
Screen('TextColor',ds.w(instrDisp),[1 1 1]);
Screen('FillRect',ds.w(1),[ 0 0 0 ]);
Screen('FillRect',ds.w(2),[ 0 0 0 ]);
DrawFormattedText(ds.w(instrDisp),'DONE. Shutting everything down.','center',ds.textCoords(1,2));
Screen('DrawingFinished',ds.w(instrDisp));

Screen('Flip',ds.w(1));
Screen('Flip',ds.w(2));

WaitSecs(1);

% Show cursor, start displaying keypresses, and close all display windows
if strcmp(pa.block,'10') && isfield(ds,'oldLUT')
    % If gamma LUT was changed, change it back
    Screen('LoadNormalizedGammaTable',ds.w,ds.oldLUT);
end

ShowCursor(ds.screenID);
ListenChar(1);
sca;

% Let OS set application priorities by itself again
Priority(0);

end

