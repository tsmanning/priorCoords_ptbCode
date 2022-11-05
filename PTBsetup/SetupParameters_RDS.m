function [pa] = SetupParameters_RDS(pars,ds,autoPars)

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

workDir = which('RunExperiment_RDS');
pa.workDir = workDir(1:end-(numel('RunExperiment_RDS')+2));

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
fpSize      = 0.2;       % deg
pa.StimDiam = 3;         % deg (size of aperture for RDS)
StimCentV   = 4;         % deg (vertical offset from FP)
dotSize     = 0.1;       % deg
dotDensity  = 20;        % dots/deg^2


% Set stim duration
pa.trialDura = 1;        % sec

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
pa.bgLum   = [1/3*ones(1,3) 1];

% RDS parameters
pa.driftDir       = [90 270];   % deg
pa.coherence      = 0.9;          % percent
pa.persistTime    = nan;        % frames

pa.apertureSize   = round(tand(pa.StimDiam)*ds.screenDistance.*ds.pixelsPerM) .* ones(2,2); % px 
pa.dotSize        = tand(dotSize)*ds.screenDistance.*ds.pixelsPerM .* ones(2,2); % px
pa.dotDensity     = dotDensity./(ds.pixelsPerDegree.^2) .* ones(2,2);      % dots/px^2

% RDS center positions (rows: screen, column: top/bottom; px - vertical offset of +/-6deg from FP)
pa.centW = repmat(ds.xyPix(:,1)/2,[1 2]);
pa.centH = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1];

if pa.block == 3
    
    %%% Size control
    if 1
        % THIS IS THE TWO DIFFERENT SIZES ON SAME SCREEN CONTROL
        % (this depends on previous assignments above)
        pa.apertureSize = pa.apertureSize .* [1 0.5; 1 0.5]; % px
        pa.dotDensity   = dotDensity./(min(ds.pixelsPerDegree).^2) .* ones(2,2);      % dots/px^2   

        apertureDist = [zeros(2,1) abs(diff(pa.apertureSize/2,[],2))];
        pa.centH     = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] + apertureDist;

        pa.apertureSizes = {pa.apertureSize,fliplr(pa.apertureSize)};
        pa.dotSizes      = {pa.dotSize,fliplr(pa.dotSize)};
        pa.centHs        = {pa.centH,pa.centH - apertureDist - fliplr(apertureDist)};
        
    else
        % THIS IS THE FAR SIZE ON NEAR SCREEN CONTROL
        pa.apertureSize = round(tand(pa.StimDiam)*min(ds.screenDistance).*ds.pixelsPerM) .* ones(2,2); % px
        pa.dotSize      = tand(dotSize)*min(ds.screenDistance).*ds.pixelsPerM .* ones(2,2); % px
        pa.dotDensity   = dotDensity./(min(ds.pixelsPerDegree).^2) .* ones(2,2);      % dots/px^2


        eccScale        = zeros(2,2);
        % Only care about far screen inds for the eccentricity adjustment
        [~,farInd]      = min(ds.screenDistance);

        % Decrease eccentricity offset by difference in stimulus radius (in m)
        %     eccScale(farInd,:) = tand(pa.StimDiam/2)*(1/dScale-min(ds.screenDistance)).*max(ds.pixelsPerM)*[1 -1];
        eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

        % Vertical center of the screen plus constant aperture offset minus difference in aperture size
        pa.centH        = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] - eccScale;

    end
end

if pa.perspective == 1 && pa.block ~= 3
    %%% Maintain world size (overwrites previous assignments)
    pa.apertureSize = round(tand(pa.StimDiam)*min(ds.screenDistance).*ds.pixelsPerM) .* ones(2,2); % px
    pa.dotSize      = tand(dotSize)*min(ds.screenDistance).*ds.pixelsPerM .* ones(2,2); % px
    pa.dotDensity   = dotDensity./(min(ds.pixelsPerDegree).^2) .* ones(2,2);      % dots/px^2
    

    eccScale        = zeros(2,2);
    % Only care about far screen inds for the eccentricity adjustment
    [~,farInd]      = max(ds.screenDistance);

    % Decrease eccentricity offset by difference in stimulus radius (in m)
%     eccScale(farInd,:) = tand(pa.StimDiam/2)*(1/dScale-min(ds.screenDistance)).*max(ds.pixelsPerM)*[1 -1];
    eccScale(farInd,:) = (pa.apertureSize(2,1)/2 + tand(StimCentV - pa.StimDiam/2) - tand(StimCentV))*[1 -1];

    % Vertical center of the screen plus constant aperture offset minus difference in aperture size
    pa.centH        = ds.xyPix(:,2)/2 + tand(StimCentV)*ds.screenDistance.*ds.pixelsPerM*[1 -1] - eccScale;

end

if (pa.perspective ~= 1) && (pa.perspective ~= 0) && pa.block ~= 3
    
    % Scale factor for adjustment of far screen virtual distance
    dScale = pa.perspective;

    % Only care about far screen inds for the adjustments
    [farDist,farInd]      = max(ds.screenDistance);

    % Change size as fraction of true distance of the far screen
    pa.apertureSize(farInd,:) = round(tand(pa.StimDiam)*dScale*farDist.*max(ds.pixelsPerM)) .* ones(1,2); % px
%     pa.dotSize(farInd,:)      = tand(dotSize)*dScale*farDist.*max(ds.pixelsPerM).* ones(1,2); % px
    pa.dotDensity(farInd,:)   = dotDensity./(max(ds.pixelsPerDegree).^2) .* ones(1,2);      % dots/px^2
%     pa.dotDensity(farInd,:)   = dotDensity./(( ds.xyPix(farInd,1)/(2*atand(ds.xyM(farInd,1)/(2*farDist*dScale))) ).^2) .* ones(1,2);      % dots/px^2

    eccScale        = zeros(2,2);
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

pa.refLum = 0.5;

end