function [percepGamLUT,OriginalLUT,Pow] = runPercepGammaCorrect(screenID,plotOn)

% Estimate bit -> luminance nonlinearity perceptually
% Dependencies: FitGamma (MATLAB Optimization toolbox)
% NOTE: This routine assumes spatial pixel independence & 8bit display, 
%       the results will be unreliable if this is not true.
%
% Usage: [percepGamLUT,OriginalLUT] = runGammaCorrect

close all

%% Setup Keyboard
KbName('UnifyKeyNames');

% Response keys
kb.upkey = KbName('UpArrow');           % Increment bit val +1
kb.downkey = KbName('DownArrow');       % Decrement bit val -1
kb.leftkey = KbName('LeftArrow');       % Decrement bit val -10
kb.rightkey = KbName('RightArrow');     % Increment bit val +10

kb.escapeKey = KbName('ESCAPE');        % End correction protocol
kb.spacebarKey = KbName('space');       % Lock in choice

% Initialize KbCheck
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);
KbReleaseWait;
kb.keyWasDown = 0;

%% Setup PTB
AssertOpenGL;
Screen('Preference','VisualDebugLevel', 1);
Screen('Preference','Verbosity',2);

linuxYN = false;

if ismac
    Screen('Preference', 'SkipSyncTests', 1);
    scrnNumbers = 0; 
    
elseif IsLinux
    scrnNumbers = 0;
    PsychTweak('UseGPUIndex',2);
    linuxYN = true;
    rects = [0 0 1920 1080; 0 0 2560 1440];
    
elseif IsWindows
    Screen('Preference', 'SkipSyncTests', 1);
    allScreens  = Screen('Screens');
    scrnNumbers = allScreens(end-1:end);
    
    for ii = 1:2
        scres = Screen('Resolution',scrnNumbers(ii));
        rects(ii,:) = [scres.width scres.height];
    end
    
end

% Run fullscreen on external monitor
winRect = [];


%% Prompt User for info about display

% newDispYN = questdlg('Have you previously registered metrics about your monitor?',...
%                      'Yes','No');
% 
% infoDir = [fileparts(which('runGammaCorrect')),'/savedDispInfo/'];
% if exist(infoDir,'dir') == 0
%     mkdir(infoDir);
% end
%                  
% switch newDispYN
%     case 'Yes'
%         prompt = {'Name for display:'};
%         dlgtitle = 'Display information';
%         dims = [1 35];
%         dispInfo = inputdlg(prompt,dlgtitle,dims);
%         
%         load([infoDir,dispInfo{1},'_percepGamLUT']);
%     case 'No'
%         % pixel pitch and resolution instead?
%         prompt = {'Name for display (no spaces):','Pixel Pitch (mm):',...
%                   'Monitor Viewing Distance (m):'};
%         dlgtitle = 'Display information';
%         dims = [1 35];
%         definput = {'My monitor','0.25','1.0'};
%         dispInfo = inputdlg(prompt,dlgtitle,dims,definput);
%         
%         dispName = dispInfo{1};
%         dotPitch = str2double(dispInfo{2})*0.001;
%         viewDist = str2double(dispInfo{3});
%     case 'Cancel'
%         error('User canceled correction routine');
% end

%% Fill screen, issue instructions

% Hide cursor and stop keypresses from showing in command window
HideCursor(scrnNumbers(screenID));
ListenChar(2); 

% Open window, hack to get true window dimensions for multi-disp Linux
w = Screen('OpenWindow',scrnNumbers(screenID),0,winRect);
trueRect = Screen(w,'Rect');

% Store original LUT
OriginalLUT = Screen('ReadNormalizedGammaTable', w);

% Load linear LUT (to ensure no corrections are in place)
linear = repmat([0:255]'./255,1,3);
LinearLUT = Screen('LoadNormalizedGammaTable',w,linear);

Screen('FillRect', w, 0);
Screen('DrawText', w, 'Perceptual Gamma Estimation:',125, 450, 255);
Screen('DrawText', w, 'This routine will generate a LUT for your display.',125, 500, 255);
Screen('DrawText', w, ['During the task, squint your eyes and adjust the',...
       ' background until it edges of the striped squares blend into it.'],125, 550, 255);
Screen('DrawText', w, 'Press ESC to exit, Press any key to start',125, 600, 255);
Screen('Flip', w);

% Wait for any key to be pressed
KbWait(-3);
kb.keyCode(kb.spacebarKey) = 0;
kb.keyCode(kb.escapeKey) = 0;
pause(0.25);
kb.keyIsDown = 0;

%% Generate Stimulus

% Generate horizontal/vertical line image for matching
linesIm = [zeros(1, 256); ones(1, 256)];
linesIm = 255*repmat(linesIm, 128, 1);
displayIm = [linesIm, linesIm'];

% Define luminance data points to test (interleaved here, sorted later)
vals = [0.5 0.25 0.75 0.125 0.875]; 

%% Run correction routine

v = 1;

while ~kb.keyCode(kb.escapeKey) && v ~= length(vals) + 1
    
    displayImtmp = displayIm;
    
    % Set initial background luminance
    bg = 128;
    
    keyCode = 0;
    
    % Adjust line contrast according to test condition
    display(['Testing normalized bit value: ' num2str(vals(v))]);
    switch vals(v)
        % Set contrast according to previous responses
        case 0.25
            displayImtmp(displayIm == 255) = matching_level(vals == 0.5);
        case 0.75
            displayImtmp(displayIm == 0) = matching_level(vals == 0.5);
        case 0.875
            displayImtmp(displayIm == 0) = matching_level(vals == 0.75);
        case 0.125
            displayImtmp(displayIm == 255) = matching_level(vals == 0.25);
    end
    
    % Display updated checkerboard
    displayTexture = Screen('MakeTexture', w, displayImtmp);
    
    dispNum = 0;
    
    % Background matching loop
    while ~kb.keyCode(kb.spacebarKey)
        
        if ~dispNum
            display(num2str(bg));
        end
        
        dispNum = 1;
        
        Screen('FillRect', w, bg);
        Screen('DrawTexture', w, displayTexture);
        Screen('DrawText', w, 'Adjust the background to match the squares:',125, 125, 0);
        Screen('DrawText', w, 'Left/right arrows --> Down/Up 10 bit values',125, 165, 0);
        Screen('DrawText', w, 'Up/Down arrows --> Refine by 1 bit value',125, 205, 0);
        Screen('DrawText', w, 'Spacebar --> Lock-in choice',125, 245, 0);
        Screen('Flip', w);
        
        % Query keyboard for user input and update background luminance
        % bit value
        [kb.keyIsDown,~,kb.keyCode] = KbCheck(-1);
        
        if kb.keyIsDown
            if kb.keyCode(kb.upkey)
                bg = bg + 1;
                dispNum = 0;
            elseif kb.keyCode(kb.rightkey)
                bg = bg + 10;
                dispNum = 0;
            elseif kb.keyCode(kb.leftkey)
                bg = bg - 10;
                dispNum = 0;
            elseif kb.keyCode(kb.downkey)
                bg = bg - 1;
                dispNum = 0;
            elseif kb.keyCode(kb.escapeKey)
                break
            end
            
            FlushEvents('keyDown');
            pause(0.25);
            kb.keyIsDown = 0;
        end     
    end
    
    % Output user's best match to standard
    matching_level(v) = bg;
    
    v = v + 1;
    kb.keyCode(kb.spacebarKey) = 0;
    
end

%% Create look-up table
if ~kb.keyCode(kb.escapeKey)
    % Lock in boundaries of test/match values to [0 ... 1] [0 ... 255]
    vals(end+1) = 0;
    vals(end+1) = 1;
    matching_level(end+1) = 0;
    matching_level(end+1) = 255;
    
    % Sort values
    [valsS,indS]    = sort(vals);
    matching_levelS = matching_level(indS);
    
    % Fit gamma power
    [~,Pow] = FitGamma(valsS',matching_levelS'/255,valsS',1);
%     Pow = 2.2;
    
    % Interpolate other bit values from fit
    invertedInput = ([0:255]'./255).^(Pow);
    percepGamLUT = [invertedInput invertedInput invertedInput];
    
    % Save and plot new gamma correction function
%     save([infoDir,dispInfo{1},'_percepGamLUT'],'dispName','dotPitch',...
%          'dispDim','viewDist','percepGamLUT');
    
if plotOn
    f1 = figure;
    f1.Position = [2000 600 800 350];
    hold on;
    
    subplot(1,2,1);
    hold on;
    plot(255*valsS,matching_levelS,'-o','MarkerFaceColor','k');
    plot(255*valsS,255*(valsS.^Pow));
    plot(255*valsS,255*(valsS.^(1/Pow)),'--');
    plot(255*valsS,255*valsS,'k:');
    legend('Matches','Fit',['Gamma Est. = ' num2str(1/Pow,2)],'Location','NorthWest'); 
    axis([0 255 0 255]);
    xlabel('Mean bit value');
    ylabel('Perceptually-matched value');
    
    subplot(1,2,2);
    hold on;
    title('fit quality');
    plot(255*valsS,255*valsS.^Pow - matching_levelS,'o','MarkerFaceColor','r');
    xlabel('mean central bit value');
    ylabel('fit difference'); 
    xlim([0 255]);
end
    
%     savefig(f1,[infoDir,dispInfo{1},'_percepGamLUT.fig']);
end

%% Restore keyboard function, original LUT, close up PTB windows
ListenChar(1);
Screen('LoadNormalizedGammaTable',w,OriginalLUT);
RestoreCluts;
sca;

end