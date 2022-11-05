function [lumProf] = runSampLinearize(instrStr)

%% % A very simple routine that samples luminance from multiple luminance
% patches, saves them, and displays the results. Should first be run with
% _Mode_ = 'sample', then after obtaining a Gamma coefficient with
% companion file 'GenerateInverseClutFromGamma.m', the script can be rerun %
% with _Mode_ = 'linearize'.
%
%  Written on 05/05/2020 by SK

%% User set variables are:
ModeMeasure     = instrStr.ModeMeasure; 
nPatches        = instrStr.nPatches;
preparationTime = instrStr.preparationTime;
plotOn          = instrStr.plotOn;


%% Initiate our clean workspace and apply basic PTB default settings
Screen('Preference', 'SkipSyncTests', 0)
PsychDefaultSetup(2);


%% I1 code to confirm the connection to I1 device.

% Check for device
if ~I1('IsConnected')
error(['No I1 detected: Connect an X-Rite device purchased from VPixx Technologies by USB,',...
        ' and remove the cover before measuring.']);
end

% Use PTB to open up a testing window and setup the stimulus presentation code.
% screenNumber         = max(Screen('Screens'));
screenNumber         = instrStr.screenID;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, BlackIndex(screenNumber));

% Select and apply the CLUT that will be used during measurements
switch ModeMeasure
    case 'sample'
        LUTtype = 'nonlinearized';
        CLUT = repmat(linspace(0,1, 256)',1,3);
        
    case 'linearize'
        LUTtype = 'linearized';
        CLUT = instrStr.inverseCLUT;
        
end

thisCLUT           = Screen('LoadNormalizedGammaTable',window,CLUT);

[xCenter, yCenter] = RectCenter(windowRect);
baseRect           = windowRect;
centeredRect       = CenterRectOnPointd(baseRect, xCenter, yCenter);

HideCursor(screenNumber);

%% Main stimulus loop

% Create nPatches equally spaced from 0 to 1. These pixel values will later be internally
% converted to the nearest 8-bit cotour value
Patches = linspace(0,1,nPatches);

% Initialize an empty matrix that will store our measurements
Lxy     = zeros(nPatches,3);

for i = 1:nPatches
    
    % Prepare a white square
    if i == 1
        text = sprintf(['Turn off the lights in the room, position the i1 measurement',...
            ' device in the center of the screen. \n\n Measurements will start after %0.1f s.'],...
            preparationTime);
        Screen('DrawText', window, text,...
            100, 100, [255 255 255]);
        Screen('Flip', window);
        
        % Time to prepare and put the measurement device in the center of the for the first recording.
        WaitSecs(preparationTime);
    end
    
    % Create a greyscale RGB vector for the current luminance patch
    currentPatch = [Patches(i),Patches(i),Patches(i)];
    Screen('FillRect', window, currentPatch, centeredRect);
    Screen('Flip', window); % Display the patch.
    
    % Wait until the luminance is updated, typically within tens of
    % milliseconds. The 2s wait period allows you to perceive the
    % discrete luminance increase, and can be reduced if you wish to
    % accelerate the execution of the measurement loop.
    WaitSecs(2);
    
    % Now we can take a new CIE Lxy measurement.
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

% Luminance (cd/m2) is stored in the first column, we do not need the CIE colour values in this tutorial.
luminance = Lxy(:,1);

if plotOn
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
end

PatchesPixels = Patches';
PatchesPixels = PatchesPixels(2:end); %trim zero level

% zero-correct sampled luminance values
lums          = luminance-luminance(1);

% normalize sampled luminance values
normalizedLum = lums./max(lums);

% trim zero level
normalizedLum = normalizedLum(2:end);

lumProf.luminance     = luminance;
lumProf.Patches       = Patches;
lumProf.normalizedLum = normalizedLum;
lumProf.PatchesPixels = PatchesPixels;
lumProf.CLUT          = thisCLUT;
lumProf.LUTtype       = LUTtype;


end