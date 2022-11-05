%% % A very simple routine that samples luminance from multiple luminance 
% patches, saves them, and displays the results. Should first be run with 
% _Mode_ = 'sample', then after obtaining a Gamma coefficient with 
% companion file 'GenerateInverseClutFromGamma.m', the script can be rerun %
% with _Mode_ = 'linearize'.
%
%  Written on 05/05/2020 by SK
sca; close all; clearvars;

%% User set variables are: 
ModeMeasure = 'sample'; %'linearize'
nPatches = 32; % 32 luminance patches will be measured
preparationTime = 5; % 5 seconds

%% Initiate our clean workspace and apply basic PTB default settings
Screen('Preference', 'SkipSyncTests', 0)
PsychDefaultSetup(2);

%% I1 code to confirm the connection to I1 device.
if I1('IsConnected')
    %% % Use PTB to open up a testing window and setup the stimulus presentation code.
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, BlackIndex(screenNumber));
    
    %% Select and apply the CLUT that will be used during measurements
    switch ModeMeasure
        case 'sample'
            CLUT = repmat(linspace(0,1, 256)',1,3);
        case 'linearize'
            load inverseCLUT; %Load the results of GenerateInverseClutFromGamma.m
            CLUT = inverseCLUT;
    end
    
    originalCLUT = Screen('LoadNormalizedGammaTable',window,CLUT);
    [xCenter, yCenter] = RectCenter(windowRect);
    baseRect = windowRect;
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    HideCursor(screenNumber);
    
    %% Main stimulus loop
    Patches = linspace(0,1,nPatches); % create nPatches equally spaced from 0 to 1. These pixel values will later be internally converted to the nearest 8-bit cotour value
    Lxy = zeros(nPatches,3);% Initialize an empty matrix that will store our measurements
    
    for i = 1:nPatches
        %% Prepare a white square
        if i == 1
            text = sprintf('Turn off the lights in the room, position the i1 measurement device in the center of the screen. \n\n Measurements will start after %0.1f s.',preparationTime);
            Screen('DrawText', window, text,...
                100, 100, [255 255 255]);
            Screen('Flip', window);
            WaitSecs(preparationTime); % gives you some time to prepare and put the measurement device in the center of the for the first recording.
        end
        
        currentPatch = [Patches(i),Patches(i),Patches(i)]; %create a greyscale RGB vector for the current luminance patch
        Screen('FillRect', window, currentPatch, centeredRect);
        Screen('Flip', window); % Display the patch.
        % Wait until the luminance is updated, typically within tens of
        % milliseconds. The2 s wait period allows you to perceive the
        % discrete luminance increase, and can be reduced if you wish to
        % accelerate the execution of the measurement loop.
        WaitSecs(2);
        
        %% Now we can take a new CIE Lxy measurement.
        Lxy(i,:) = I1('GetTriStimulus'); % Save luminance and xy colour coordinates.
        WaitSecs(0.25);
    end
    %% Close our PTB stimulus window and terminate presentation
    
    if isequal('linearize', ModeMeasure)
        % Return the display to the non-linearized CLUT.
        % If this line is not run, the linearization CLUT will continue to be
        % applied until the computer is reset or another CLUT is applied.
        Screen('LoadNormalizedGammaTable',window,repmat(linspace(0,1, 256)',1,3));
    end
    
    sca;
    ShowCursor();
    
    %% Plot raw results and calculate the normalized data needed for the gamma function.
    luminance =Lxy(:,1); % Luminance (cd/m2) is stored in the first column, we do not need the CIE colour values in this tutorial.
    switch Mode
        case 'sample'
    figure(1)
        case 'linearize'
            figure(3)
    end
    
    scatter(Patches, luminance,4,'red', 'filled' )
    title('Sampled Luminance Function');
    xlabel('Pixel Values');
    ylabel('Luminance (cd/m2)')
    
    PatchesPixels = Patches';
    PatchesPixels = PatchesPixels(2:end);%trim zero level
    
    lums=luminance-luminance(1);%zero-correct sampled luminance values
    normalizedLum=lums./max(lums);%normalize sampled luminance values
    normalizedLum=normalizedLum(2:end);%trim zero level
    
    
    switch ModeMeasure
        case 'sample'
            save mySampledLuminance.mat   luminance Patches normalizedLum  PatchesPixels
        case 'linearize'
            save myLinearizedLuminance.mat luminance Patches normalizedLum PatchesPixels
    end
    
else
    fprintf('No I1 detected: Connect an X-Rite device purchased from VPixx Technologies by USB, and remove the cover before measuring.');
end