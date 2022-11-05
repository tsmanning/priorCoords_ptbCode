 % Run experiment on auto

clear all
close all

% DEFINE CURRENT DISTANCES OF SCREENS [L,R]
dists = [0.5;1];
% dists = [1;0.5];

% SET BEFORE RUNNING SUBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjID   = 'test';
% type     = 'demo';
type     = 'full';
runSetup = 1;
runDebug = 0;
day      = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If first time running subject (i.e. setting type to 'demo'), set to:
% subjID = [];
% type = 'demo';
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shuffle the random number generator (for subject ID
rng('shuffle');

% Get randomized subject ID if it's not already defined above
if isempty(subjID)
   [subjID] = genRandID();
   disp(subjID);
end


%% Setup experiment pars
if runDebug
%     dispID = 'labRig';
%     dispID = 'tylerHome';
%     dispID = 'tylerLabMac';
    dispID = 'tylerAOC';
%     dispID = 'tylerLaptop';
%     dispID = 'claraLaptop';
%     dispID = 'tylerHomeWindows';
%     dispID = 'tylerLaptopWindows';

    db = 3;
else
    dispID = 'labRig';
    
    % Set to 3 to autorun from this script
    db = 3;
end

a = randi(2);
types = {'left','right'};

% Define size of far stimulus s.t. it appears to be at distance x when
% world size is maintained (1/Dfar)
% (e.g. 1   & screen at 1m = maintain world size;
%       0.5 & screen at 1m = simulate world size at 2m)

% perspective = 0;      % Maintain retinal size
perspective = 1;      % Maintain world size
% perspective = (1/0.25);


%% Setup Staircasing

% Define universal staircase parameters
stairStruct.stepSize                  = 0.5;    % log(deg/s)
stairStruct.stepLimit                 = 0.1;    % log(deg/s)
stairStruct.maxReversals              = 14;     % #
stairStruct.maximumtrials             = 50;     % #
stairStruct.minValue                  = 0.1;    % deg/s
stairStruct.maxValue                  = 20;     % deg/s
stairStruct.initialValue_random_range = ...     % deg/s
    stairStruct.maxValue - stairStruct.minValue;

% Define which staircases to run in each task block

% Within screen judgment
stairStruct1 = stairStruct;

contCombs1  = [0.5 0.1; 0.1 0.5];             % Reference/Test constrasts (%)
refPos1     = [1 2];                          % Ref Near/Far (inds)
testPos1    = [1];                            % Test on same or different screen (y/n)
refVels1    = [8];                            % Reference velocities (deg/s)
stairTypes1 = [2 1; 1 2];                     % x up/y down (inds)

stairStruct1.contCombs  = contCombs1;
stairStruct1.refPos     = refPos1;
stairStruct1.testPos    = testPos1;
stairStruct1.refVels    = refVels1;
stairStruct1.stairTypes = stairTypes1;

% Between screens judgment
stairStruct2 = stairStruct;

contCombs2  = [0.5 0.5];                      % Reference/Test constrasts (%)
refPos2     = [1 2];                          % Ref Near/Far (Screen inds)
testPos2    = [2];                            % Test on same or different screen (1-y/2-n)
refVels2    = [8];                            % Reference velocities (deg/s)
stairTypes2 = [2 1; 1 2];                     % x up/y down (inds)

stairStruct2.contCombs  = contCombs2;
stairStruct2.refPos     = refPos2;
stairStruct2.testPos    = testPos2;
stairStruct2.refVels    = refVels2;
stairStruct2.stairTypes = stairTypes2;

% Size control judgment
stairStruct3 = stairStruct;

contCombs3  = [0.5 0.5];                      % Reference/Test constrasts (%)
[~,refPos3] = min(dists);                     % Ref Near/Far (Screen inds)
testPos3    = [1];                            % Test on same or different screen (1-y/2-n)
refVels3    = [8];                            % Reference velocities (deg/s)
stairTypes3 = [1 1; 1 2];                     % x up/y down (inds)

stairStruct3.contCombs  = contCombs3;
stairStruct3.refPos     = refPos3;
stairStruct3.testPos    = testPos3;
stairStruct3.refVels    = refVels3;
stairStruct3.stairTypes = stairTypes3;


%% Run experiment
switch type
    case 'demo'
        stairDemo1 = stairStruct1;
        stairDemo1.maximumtrials = 1;
        stairDemo2 = stairStruct2;
        stairDemo2.maximumtrials = 1;                                        
        
        % Demos
        if day == 1
            [ds1,pa1,kb1,tx1,gSCell1] = runExperiment_RDS({subjID,['demoWithin',types{a}],1,perspective},dists,dispID,db,stairDemo1);
        elseif day == 2
            [ds2,pa2,kb2,tx2,gSCell2] = runExperiment_RDS({subjID,['demoBetween',types{a}],2,perspective},dists,dispID,db,stairDemo2);
        end

    case 'full'
        if day == 1
            % Within (0.5 deg/s)
            stairStruct1.refVels      = 0.5;
            [ds1,pa1,kb1,tx1,gSCell1] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct1);
            
            % 1 deg/s
            stairStruct2              = stairStruct1;
            stairStruct2.refVels      = 1;
            [ds2,pa2,kb2,tx2,gSCell2] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct2);
            
            % 2 deg/s
            stairStruct3              = stairStruct1;
            stairStruct3.refVels      = 2;
            [ds3,pa3,kb3,tx3,gSCell3] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct3);
            
            % 4 deg/s
            stairStruct4              = stairStruct1;
            stairStruct4.refVels      = 4;
            [ds4,pa4,kb4,tx4,gSCell4] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct4);
            
            % 8 deg/s
            stairStruct5              = stairStruct1;
            stairStruct5.refVels      = 8;
            [ds5,pa5,kb5,tx5,gSCell5] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct5);
        
        elseif day == 2
%             % Between (1m)
%             stairStruct7              = stairStruct2;
%             stairStruct7.refVels      = 4;
%             perspective               = 1;
%             [ds7,pa7,kb7,tx7,gSCell7] = runExperiment_RDS({subjID,['fullWithin',types{a}],2,perspective},dists,dispID,db,stairStruct7);
%             
%             % 0.5m
%             stairStruct8              = stairStruct2;
%             stairStruct8.refVels      = 4;
%             perspective               = 0;
%             [ds8,pa8,kb8,tx8,gSCell8] = runExperiment_RDS({subjID,['fullWithin',types{a}],2,perspective},dists,dispID,db,stairStruct8);
%             
%             % 0.75m
%             stairStruct9              = stairStruct2;
%             stairStruct9.refVels      = 4;
%             perspective               = (0.75);
%             [ds9,pa9,kb9,tx9,gSCell9] = runExperiment_RDS({subjID,['fullWithin',types{a}],2,perspective},dists,dispID,db,stairStruct9);
%             
            % 0.25m
            stairStruct11              = stairStruct2;
            stairStruct11.refVels      = 4;
            perspective                = (1/0.25);
            [ds11,pa11,kb11,tx11,gSCell11] = runExperiment_RDS({subjID,['fullWithin',types{a}],2,perspective},dists,dispID,db,stairStruct11);
%             
%             % Size control
%             stairStruct10              = stairStruct3;
%             stairStruct10.refVels      = 4;
%             perspective                = 1;
%             [ds10,pa10,kb10,tx10,gSCell10] = runExperiment_RDS({subjID,['fullWithin',types{a}],3,perspective},dists,dispID,db,stairStruct10);
        end
        
end