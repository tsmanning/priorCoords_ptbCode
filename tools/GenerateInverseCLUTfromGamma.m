%% % A very simple routine that produces and displays an inverse gamma CLUT
% Written on 05/05/2020 by SK
% Takes a single input _gamma_, the estimated gamma coefficient.
clear all
load mySampledLuminance.mat
gamma = 2.29; % Obtained from https://skenny.shinyapps.io/CurveFitting/, y = x^gamma. 

%% Get the inverse gamma function

maxLum = max(luminance);
luminanceRamp=[0:1/255:1];
offset=0; 
invertedRamp=((maxLum-offset)*(luminanceRamp.^(1/gamma)))+offset %invert gamma w/o rounding
invertedRamp=invertedRamp./max(invertedRamp);%normalize inverse gamma table

%plot inverse gamma function
figure(3); clf; hold on;
pels=[0:255];
plot(pels,invertedRamp,'r');
axis('square');
xlabel('Pixel Values');
ylabel('Inverse Gamma Table');
strTitle{1}='Inverse Gamma Function,';
strTitle{2}=['gamma  = ',num2str(gamma),'; Offset = ',num2str(offset)];
title(strTitle);
hold off;

inverseCLUT = repmat(invertedRamp',1,3); % duplicate inverse gamma function to generate the gamma-correction CLUT, extended to the three RGB channels

%% Save inverse gamma table 
save inverseCLUT.mat inverseCLUT gamma
