function [tx] = initializeGaborTex(ds,pa)

% Setup static and initial properties of Gabors to draw on the screen


%% Make the Gabor texture handle
%
% Michelson contrast:
%
% If you use the normalized 0-1 color range and select 'modulateColor' below
% as unit values, e.g., modulateColor = [1 1 1 0], and leave globalAlpha out
% or set it to its 1.0 default, then the following seems to apply:
%
% If you set the 'disableNorm' parameter to 1 to disable the builtin normf
% normalization and then specify contrastPreMultiplicator = 0.5 then the
% per gabor 'contrast' value will correspond to what practitioners of the
% field usually understand to be the contrast value of a gabor. Specifically,
% assuming a 0.5 (=50%) gray background and a properly gamma corrected /
% linearized display, the 'contrast' value, as described below, that you
% pass to Screen('DrawTexture',...) will then allow to directly specify
% Michelson contrast: 'contrast' = (Imax - Imin) / (Imin + Imax)
% of course assuming isolated, non-superimposing gabors, so the Michelson
% contrast corresponds to the maxima and minima of the gabor patch under
% a suitable phase shift, where the minimum or maximum of the patch lies
% in the center of the patch.
%


% 'disableNorm': If set to a value of 1, the
% special multiplicative normalization term normf = 1/(sqrt(2*pi) * sc)
% will not be applied to the computed gabor. By default (setting 0), it
% will be applied. This term seems to be a reasonable normalization of the
% total amplitude of the gabor, but it is not part of the standard
% definition of a gabor. Therefore we allow to disable this normalization.
disableNorm   = 1;

% Set all color channels in texture to full blast 
modulateColor = [1 1 1 1];

% Drop peak abs value of Gabor to 1
contPreMult   = 0.5;

% Gabors we're drawing here have a 1:1 aspect ratio
nonSym        = 0;

% Set Gabors to modulate around a mean gray
bgndColorOff  = [0.5 0.5 0.5 0.5];

% Define support (in px) for Gabor texture
tw            = 2*pa.texSize + 1;
th            = 2*pa.texSize + 1;

gaborTex      = cell(2,1);
for ii = 1:2
    gaborTex{ii}      = CreateProceduralGabor(ds.w(ii),tw(ii),th(ii),nonSym,bgndColorOff,disableNorm,contPreMult);
end


%% Define vertex attributes to pass to 'DrawTexture'
%
% The flag 'kPsychDontDoRotation' tells 'DrawTexture' not
% to apply its built-in texture rotation code for rotation, but just pass
% the rotation angle to the 'gabortex' shader -- it will implement its own
% rotation code, optimized for its purpose.
kPsyDontRot = 1;

% Define location of corners of texture to draw [left,top,right,bottom] in
% px coordinates
centW   = pa.centW;
centH   = pa.centH;

% dims: (top/bottom,rect bounds,screenID)
dstRects = zeros(2,4,2);
% Screen loop
for ii = 1:2
    
    % Position loop
    for jj = 1:2
        
        % Get rect exactly the size of texture
        texRect = Screen('Rect',gaborTex{ii});
        
        % Shift rect such that its cetner point is at centW/centH
        dstRects(jj,:,ii) = CenterRectOnPointd(texRect,centW(ii,jj),centH(ii,jj))';
        
    end
    
end

% Define rotation state of texture in degrees
rotAngles = pa.trialDir*[1 1];


%% Initial Gabor parameters
%
% Can pass both Gabors simultaneously with gaborPars, with columns
% representing each Gabor
%
% [phase,freq,sigma,contrast,aspect ratio, 0, 0, 0]'

% Initialize random Gabor phases (in deg)
phase   = 360*rand(1,2);
% Sigma that defines width of Gaussian window (px)
sig     = pa.gaborSig*[1 1];
% Grating frequency (cyc/px)
freq    = pa.gaborFreq*[1 1];
% A factor that is multiplied to the evaluated gabor equation before converting the
% value into a color value.
contScF(pa.refPos)  = pa.refCont;
contScF(~(pa.refPos-1) + 1) = pa.testCont;
% Aspect ratio (always just presenting circular texts, but this is ignored)
asRat   = [1 1];

% Collect parameters to pass to DrawTexture - need to append zeros since
% num parameters must be multiple of 4 (see ProceduralShadingAPI)
% [parameters,position,screen/distance]
gaborPars(:,:,1) = [phase;freq(1,:);sig(1,:);contScF;asRat;zeros(3,2)];
gaborPars(:,:,2) = [phase;freq(2,:);sig(2,:);contScF;asRat;zeros(3,2)];


%% Initialize DrawTextures
% Draw a Gabor here (or maybe try a different epoch?) to prep gfx
% hardware so initial setup time isn't in experimental loop

for ii = 1:2
    Screen('DrawTextures',ds.w(ii),gaborTex{ii},[],[],[],[],[],modulateColor,[],kPsyDontRot,gaborPars(:,:,ii));
end


%% Package everything up
% tx.gaborTex    = {gaborTex1,gaborTex2};
tx.gaborTex    = gaborTex;
tx.gaborPars   = gaborPars;
tx.dstRects    = dstRects;
tx.rotAngles   = rotAngles;
tx.kPsyDontRot = kPsyDontRot;
tx.modulateColor = modulateColor;
tx.tw          = tw;
tx.th          = th;

end