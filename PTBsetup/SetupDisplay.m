function [ds] = SetupDisplay(pars)

% Setup structure specifying parameters of display, written to accomodate
% either testing display or oculus

%% Setup general display parameters

% Start Psychtoolbox and set preferences
PsychDefaultSetup(2);                 % clamps color range to [0,1]
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'Verbosity',2);
Screen('Preference', 'SkipSyncTests', 0);

% Get indices of all screens OS has listed
scrns = Screen('Screens');

% Setup user-specific display parameters
dispID   = pars{2};

switch dispID
    % Even if the specified display setup has only one display, double the
    % indices to match number of windows
    case 'labRig'
        ds.linux = false;
        ds.screenID = [2 3];
        
    case 'tylerHome'
        ds.linux = true;
        
        % Tell Screen to use iGPU, not dGPU (really just specific to linux laptops with hybrid graphics)
        PsychTweak('UseGPUIndex',2);

        ds.screenID = [0 0];
        
    case 'tylerAOC'
        ds.linux = true;
        
        % Tell Screen to use iGPU, not dGPU (really just specific to linux laptops with hybrid graphics)
        PsychTweak('UseGPUIndex',2);

        ds.screenID = [0 0];
    
    case 'tylerHomeWindows'
        ds.linux = false;
        ds.screenID = [0 1];
        
    case 'tylerLabMac'
        ds.linux = false;
        ds.screenID = [max(scrns) max(scrns)];
        
    case 'tylerLaptop'
        ds.linux = true;
        ds.screenID = [0 0];
        
    case 'tylerLaptopWindows'
        ds.linux = false;
        ds.screenID = [0 0];
        
    case 'claraLaptop'
        ds.linux = false;
        ds.screenID = [0 0];
        
end

% Get resolutions of each display
for ii = 1:numel(ds.screenID)
    ds.scres(ii) = Screen('Resolution',ds.screenID(ii));
end

% Specify number of samples per pixel for antialiasing
ds.multiSample = 8;


%% Open a window, return handles, and setup gamma/alpha correction

% PTB conventions: define window rect in px [left top right bottom] with
% top left of screen as the origin

switch dispID
    case 'labRig'
        ds.winRect = [];
        
    case 'tylerHome'
        windOff    = 1920;
        ds.winRect = [windOff                           0 windOff+0.5625*ds.scres(1).height   ds.scres(1).height;...
                      windOff+0.5625*ds.scres(2).height 0 windOff+0.5625*2*ds.scres(2).height ds.scres(2).height];
    case 'tylerAOC'
        windOff    = 1920;
        ds.winRect = [windOff                           0 windOff+0.5625*ds.scres(1).height   ds.scres(1).height;...
                      windOff+0.5625*ds.scres(2).height 0 windOff+0.5625*2*ds.scres(2).height ds.scres(2).height];
                  
    case 'tylerHomeWindows'
        windOff    = 0;
        ds.winRect = [windOff                           0 windOff+0.5625*ds.scres(1).height   ds.scres(1).height;...
                      windOff+0.5625*ds.scres(2).height 0 windOff+0.5625*2*ds.scres(2).height ds.scres(2).height];
        
    case 'tylerLabMac'
        ds.winRect = [0   0 450 800;...
                      451 0 901 800];
        
    case 'tylerLaptop'
        % For linux laptop, run two mini windows
        ds.winRect = [0   0 450 800;...
                      451 0 901 800];
                  
    case 'tylerLaptopWindows'
        % For windows laptop, run two mini windows
        ds.winRect = [0   0 450 800;...
                      451 0 901 800];
        
    case 'claraLaptop'
        % For windows laptop, run two mini windows
        ds.winRect = [0   0 450 800;...
                      451 0 901 800];
        
end

% Set to monocular viewing
mode = 0;

for ii = 1:2
    
    if strcmp(dispID,'labRig')
        % Only rotate screens in lab rig setup
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');
        PsychImaging('AddTask','General','UseDisplayRotation',270); 
        [ds.w(ii), ds.windowRect(ii,:)] = ...
            PsychImaging('OpenWindow',ds.screenID(ii),[0.5 0.5 0.5 0.5],[],[],[],mode,ds.multiSample);
    else
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');
        [ds.w(ii), ds.windowRect(ii,:)] = ...
            PsychImaging('OpenWindow',ds.screenID(ii),[0.5 0.5 0.5 0.5],ds.winRect(ii,:),[],[],mode,ds.multiSample);
    end
    
    Screen('Flip', ds.w(ii));
    
    [ds.xc(ii), ds.yc(ii)] = RectCenter(ds.windowRect(ii,:));
    ds.xyc(ii,:)           = [ds.xc(ii) ds.yc(ii)];
    
    % Setup alpha correction (transparency handling for multiple objects)
%     Screen('BlendFunction', ds.w(ii), 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%     Screen('BlendFunction', ds.w(ii), 'GL_ONE', 'GL_ONE');

    % Just turn off alpha blending since we don't need transparency
    Screen('BlendFunction', ds.w(ii), GL_ONE, GL_ZERO);
    
    % Get value for single frame duration (1/refresh rate)
    ds.ifi(ii) = Screen('GetFlipInterval', ds.w(ii));
    
    % Center text for each window
    ds.textCoords(ii,:) = ds.xyc(ii,:);
    
end


%% Setup screen/viewing params

% Grab saved monitor metrics
setupDir = which('SetupDisplay');
splitDir = regexp(setupDir,['\',filesep],'split');
if IsLinux || ismac
    % For when the base level dir is '/' - regexp returns empty first cell
    infoDir = [filesep,fullfile(splitDir{2:end-2}),filesep];
    
elseif IsWindows
    % Windows starts with C:,D:,etc so don't throw away first string
    infoDir = [fullfile(splitDir{1:end-2}),filesep];
    
end
load([infoDir,'/dispInfo/',dispID,'_dispInfo']);

% Setup single monitor metrics
ds.screenDistance   = pars{1};

if ~iscolumn(ds.screenDistance)
    ds.screenDistance = ds.screenDistance';
end

ds.viewingDistance  = ds.screenDistance;

% Monitor size (meters,pixels,degrees visual angle)
ds.xyM              = ds.windowRect(:,3:4).*dotPitch; 

% Linearize displays and save old LUT
%%%%%% using gamma as a variable name is problematic - change!
for ii = 1:2
    ds.oldLUT{ii}   = Screen('LoadNormalizedGammaTable', ds.w(ii), linspace(0,1,256)'.^(1/gamma(ii))*[1 1 1]);
end

for ii = 1:2
    % Display dimensions and viewing distance
    ds.xyPix(ii,:)            = [RectWidth(ds.windowRect(ii,:)) RectHeight(ds.windowRect(ii,:))];
    ds.xyDva(ii,:)            = 2*atand( ds.xyM(ii,:)./(2.*ds.screenDistance(ii)) );
    
    % Horizontal, Vertical, Diagonal fields of view (in deg)
    ds.hFOV(ii,1)             = ds.xyDva(ii,1);
    ds.vFOV(ii,1)             = ds.xyDva(ii,2);
    ds.dFOV(ii,1)             = sqrt(ds.xyDva(ii,1).^2 + ds.xyDva(ii,2).^2);
    
    % Viewport params
    ds.viewportWidthM(ii,1)   = ds.xyM(ii,1);
    ds.metersPerDegree(ii,1)  = ds.viewportWidthM(ii,1)/ds.hFOV(ii,1);
    ds.viewportWidthDeg(ii,1) = ds.hFOV(ii,1);
    
    % Pixel relationships
    ds.pixelsPerDegree(ii,1)  = sqrt(ds.xyPix(ii,1).^2 + ds.xyPix(ii,2).^2) ./ ds.xyDva(ii,1);
    ds.pixelsPerM(ii,1)       = 1./dotPitch(ii);
    
    % Set virtual height/width of the surround texture to cover device's field
    % of view
    ds.halfHeight(ii,1)   = ds.xyM(ii,2)/2;    % m
    ds.Height(ii,1)       = ds.halfHeight(ii,1)*2;
    ds.halfWidth(ii,1)    = ds.xyM(ii,1)/2;    % m
    ds.Width(ii,1)        = ds.halfWidth(ii,1)*2;
    ds.aspectratio(ii,1)  = ds.Height(ii,1) ./ ds.Width(ii,1);
    
    % Get frame rate
    ds.fps(ii,1) = Screen('FrameRate',ds.w(ii));
end

% Near monitor frame
[~,nearDispInd]    = min(ds.screenDistance);
[~,farDispInd]     = max(ds.screenDistance);

% Size of vignette box in m
%%%%%%%% should really try to use screen center var calculated above
ds.vignettePx       = (ds.windowRect(nearDispInd,3:4)-[ds.windowRect(nearDispInd,1) 0])*...
                      (min(ds.screenDistance)/max(ds.screenDistance));
ds.vignetteRect     = CenterRectOnPointd([0 0 ds.vignettePx],...
                      (ds.windowRect(nearDispInd,3)-ds.windowRect(nearDispInd,1))/2,...
                      (ds.windowRect(nearDispInd,4))/2);
                  
% Make it a matrix so you don't need to run logical test in exp loop
ds.vignetteRects(nearDispInd,:)   = ds.vignetteRect;
ds.vignetteRects(farDispInd,:)    = [0 0 ds.windowRect(farDispInd,3:4)];               


%% Setup text preferences (style: 1-bold,2-italic)
for ii = 1:2
    Screen('TextSize', ds.w(ii),20);
    Screen('TextStyle',ds.w(ii),1);
    Screen('TextColor',ds.w(ii),[255 255 255]);
end


end
