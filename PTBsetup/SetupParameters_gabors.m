function [pa] = SetupParameters_gabors(pars,ds,autoPars)

% Define parameter structure for experiment
%
% Usage: [pa] = SetupParameters(pars,ds,autoPars)

%% Setup subject/directory parameters
if pars{3} == 1
    
    % Debug mode
    pa.subjectName = 'debug';
    pa.subjectID = 'debug';
    pa.blockType = 'debug';
    pa.block     = 1;
    pa.session   = '1';
    
elseif pars{3} == 2
    
    % Tyler running Tyler
    pa.subjectName = 'tyler';
    pa.block = '1';
    
elseif pars{3} == 3
    
    % When running from Autorun_script
    pa.subjectID = autoPars{1};
    pa.blockType = autoPars{2};
    pa.block = autoPars{3};
    pa.perspective = autoPars{4};
    
else
    pa.subjectID = ...
        input('Enter Subject ID: ','s');                 % Query experimenter for sub. ID
    pa.blockType = ...
        input('Enter Block Type (test/train): ','s');    % Query experimenter for block type
    pa.block = ...
        input('Enter Block Num: ','s');                  % Query experimenter for block #
    
end
pa.date = datestr(now,30);

workDir = which('RunExperiment_gabors');
pa.workDir = workDir(1:end-(numel('RunExperiment_gabors')+2));

% Check for/make top level dir for subject
fs = filesep;
splitDir = regexp(workDir,['\',fs],'split');

if IsLinux || ismac
    
    % For when the base level dir is '/' - regexp returns empty first cell
    pa.dataDir = [fs,fullfile(splitDir{2:end-3}),fs,fullfile('3-Data','priorCoordsRDS',pa.subjectID),fs];
    
elseif IsWindows
    
    % Windows starts with C:,D:,etc so don't throw away first string
    pa.dataDir = [fullfile(splitDir{1:end-3}),fs,fullfile('3-Data','priorCoordsRDS',pa.subjectID),fs];
    
end

if exist(pa.dataDir,'dir') == 0
   mkdir(pa.dataDir); 
end

% Create random number stream to randomize trial parameters
% (use 'Mersenne twister' RNG to generate stream based on current time)
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);
defaultStream = RandStream.getGlobalStream;

% Save RNG seed
pa.savedState = defaultStream.State;


%% Experimental structure/design

% Define key stim parameters in deg VA, convert below to px
fpSize      = 0.2;      % deg
pa.StimDiam = 3;        % deg (size of aperture for RDS)
StimCentV   = 4;        % deg (vertical offset from FP)
pa.GaborSF  = 1;        % cyc/deg
diam2SD     = 5;        % stimulus is how many SD wide?
textScF     = 6;        % how many SD in texture support?

% Set stim duration
pa.trialDura = 1;       % sec

% Set fixation durations
pa.fixDura   = 1.25;     % sec

% Set break interval
pa.breakInterval = 15;   % min
% pa.breakInterval = 0.25;   % min

% Set response duration
pa.respDura  = 3; 

% Fixation point properties (px)
pa.fpx     = 0.5*ds.xyPix(:,1);
pa.fpy     = 0.5*ds.xyPix(:,2);
pa.fpsz    = tand(fpSize)*ds.screenDistance.*ds.pixelsPerM;       % px

% Set background luminance [R G B A]
% pa.bgLum   = [1/3*ones(1,3) 1];
pa.bgLum   = [1/2*ones(1,3) 1];

% Gabor parameters (maintaining retinal size)
pa.driftDir     = [90 270];   % deg

pa.gaborFreq    = (tand(1/pa.GaborSF)*ds.screenDistance.*ds.pixelsPerM).^-1;              % cyc/px (set to 2cyc/deg)
pa.gaborSig     = round(tand(pa.StimDiam/diam2SD)*ds.screenDistance.*ds.pixelsPerM);      % px (set sigma to 0.5deg)
pa.texSize      = pa.gaborSig*textScF;                                                    % px (set radius to 3SD)
pa.apertureSize = round(tand(pa.StimDiam)*ds.screenDistance.*ds.pixelsPerM) .* ones(2,2); % px 

% Gabor center positions (rows: screen, column: top/bottom; px - vertical offset of +/-6deg from FP)
pa.centW = repmat(ds.xyPix(:,1)/2,[1 2]);
pa.centH = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1];

if pa.block == 3
    
    %%% Size control
    if 0
        % THIS IS THE TWO DIFFERENT SIZES ON SAME SCREEN CONTROL
        % (this depends on previous assignments above)
        
        [~,farInd]      = max(ds.screenDistance);
        
        % Decrease eccentricity offset by difference in stimulus radius (in m)
          eccScale(farInd,:) = tand(pa.StimDiam/2)*diff(ds.screenDistance).*max(ds.pixelsPerM)*[1 -1];
%         eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

        % Vertical center of the screen plus constant aperture offset (m) minus difference in aperture size
        pa.centH     = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] - eccScale;
    else
        % THIS IS THE FAR SIZE ON NEAR SCREEN CONTROL
        pa.apertureSize = round(tand(pa.StimDiam/2)*min(ds.screenDistance).*ds.pixelsPerM) .* ones(2,2); % px
        pa.gaborFreq    = (tand(1/pa.GaborSF*0.5)*min(ds.screenDistance).*ds.pixelsPerM).^-1;            % cyc/px
        pa.gaborSig     = round(tand(pa.StimDiam/2/diam2SD)*min(ds.screenDistance).*ds.pixelsPerM);        % px
        pa.texSize      = pa.gaborSig*textScF;                                                           % px

        eccScale        = zeros(2,2);
        % Only care about near screen inds for the eccentricity adjustment
        [~,farInd]      = min(ds.screenDistance);

        % Decrease eccentricity offset by difference in stimulus radius (in m)
        %     eccScale(farInd,:) = tand(pa.StimDiam/2)*(1/dScale-min(ds.screenDistance)).*max(ds.pixelsPerM)*[1 -1];
        eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

        % Vertical center of the screen plus constant aperture offset (m) minus difference in aperture size
        pa.centH     = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] - eccScale;
    end

end

if pa.perspective == 1
    %%% Maintain world size (overwrites previous assignments)
    pa.apertureSize = round(tand(pa.StimDiam)*min(ds.screenDistance).*ds.pixelsPerM) .* ones(2,2); % px
    pa.gaborFreq    = (tand(1/pa.GaborSF)*min(ds.screenDistance).*ds.pixelsPerM).^-1;
    pa.gaborSig     = round(tand(pa.StimDiam/diam2SD)*min(ds.screenDistance).*ds.pixelsPerM);
    pa.texSize      = pa.gaborSig*textScF;

    eccScale        = zeros(2,2);
    % Only care about far screen inds for the eccentricity adjustment
    [~,farInd]      = max(ds.screenDistance);

    % Decrease eccentricity offset by difference in stimulus radius (in m)
%     eccScale(farInd,:) = tand(pa.StimDiam/2)*abs(diff(ds.screenDistance)).*max(ds.pixelsPerM)*[1 -1];
    eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

    % Vertical center of the screen plus constant aperture offset minus difference in aperture size
    pa.centH     = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] - eccScale;

end

if (pa.perspective ~= 1) && (pa.perspective ~= 0)
    
    dScale = pa.perspective;

    %%% Change size as fraction of true distance of the far screen
    pa.apertureSize(2,:) = round(tand(pa.StimDiam)*dScale*min(ds.screenDistance).*max(ds.pixelsPerM)) .* ones(1,2); % px
    pa.gaborFreq(2)      = (tand(1/pa.GaborSF)*dScale*min(ds.screenDistance).*max(ds.pixelsPerM)).^-1;
    pa.gaborSig(2)       = round(tand(pa.StimDiam/diam2SD)*dScale*min(ds.screenDistance).*max(ds.pixelsPerM));
    pa.texSize(2)        = pa.gaborSig(2)*textScF;

    eccScale        = zeros(2,2);
    % Only care about far screen inds for the eccentricity adjustment
    [~,farInd]      = max(ds.screenDistance);

    % Decrease eccentricity offset by difference in stimulus radius (in m)
%     eccScale(farInd,:) = tand(pa.StimDiam/2)*(1/dScale-min(ds.screenDistance)).*max(ds.pixelsPerM)*[1 -1];
    eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

    % Vertical center of the screen plus constant aperture offset minus difference in aperture size
    pa.centH     = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] + eccScale;

end

% Define viewing distances of two screens
pa.distances  = pars{1};    

% Initialize response matrix
pa.response = [];
pa.quitFlag = 0;

% Initialize trial counter
pa.trialNumber = 0;

end