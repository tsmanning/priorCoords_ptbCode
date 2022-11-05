function [nonlinLumProf,linLumProf,gamma] = runGammaCorrect(dispInfo,plotOn)

% Run physical gamma correction using x-rite i1Display Pro Plus and Sophie
% Kenny's calibration routine (taken from GenerateInverseCLUTfromGamma.m
% and i1_SampleLuminance.m)
% 
% REQUIRES i1 from VPIXX
%
% Usage: [nonlinLumProfT,linLumProf,gamma] = runGammaCorrect(dispInfo)

sca; 
close all; 

%% Load in saved display profile

load(dispInfo);


%% Measure initial luminance profile
instrStr.ModeMeasure     = 'sample';
instrStr.nPatches        = 32; % 32 luminance patches will be measured
instrStr.preparationTime = 5; % 5 seconds
instrStr.screenID        = 0;
instrStr.plotOn          = plotOn;

[nonlinLumProf] = runSampLinearize(instrStr);


%% Get Gamma coeff and calculate inverse CLUT
maxLum        = max(luminance);
luminanceRamp = [0:1/255:1];
offset        = 0; 

% Fit gamma
inVals        = linspace(0,1,instrStr.nPatches);
meas          = nonlinLumProf.luminance;
outVals       = linspace(0,1,instrStr.nPatches);
[~,gamma]     = FitGamma(inVals,meas,outVals,1);

% invert gamma w/o rounding
invertedRamp  = ((maxLum-offset)*(luminanceRamp.^(1/gamma))) + offset;

% normalize inverse gamma table
invertedRamp  = invertedRamp ./ max(invertedRamp);

% Get CLUT by copying gamma table to other subpixels
inverseCLUT   = repmat(invertedRamp',1,3);

if plotOn
    %plot inverse gamma function
    figure(3); 
    hold on;
    pels = [0:255];
    plot(pels,invertedRamp,'r');
    axis('square');
    xlabel('Pixel Values');
    ylabel('Inverse Gamma Table');
    strTitle{1} = 'Inverse Gamma Function,';
    strTitle{2} = ['gamma  = ',num2str(gamma),'; Offset = ',num2str(offset)];
    title(strTitle);
end


%% Measure linearized luminance profile
instrStr.ModeMeasure     = 'linearize';
instrStr.nPatches        = 32;
instrStr.preparationTime = 5;
instrStr.screenID        = 0;
instrStr.inverseCLUT     = inverseCLUT;
instrStr.gamma           = gamma;
instrStr.plotOn          = plotOn;

[linLumProf] = runSampLinearize(instrStr);


%% Save
save('dispInfo','dispName','dotPitch','viewDist','nonlinLumProf','linLumProf','gamma');


end
