% Run experiment on auto

clear all
close all

% DEFINE CURRENT DISTANCES OF SCREENS 
dists = [0.5;1];

% SET BEFORE RUNNING SUBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjID   = 'TSM';
% type     = 'demo';
type     = 'full';
runSetup = 1;
runDebug = 0;
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

contCombs3  = [0.5 0.1; 0.1 0.5];             % Reference/Test constrasts (%)
refPos3     = [1];                            % Ref Near/Far (Screen inds)
testPos3    = [1];                            % Test on same or different screen (1-y/2-n)
refVels3    = [8];                            % Reference velocities (deg/s)
stairTypes3 = [1 1; 2 1; 1 2];                % x up/y down (inds)

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
        [ds1,pa1,kb1,tx1,gSCell1] = runExperiment_RDS({subjID,['demoWithin',types{a}],1,perspective},dists,dispID,db,stairDemo1);
        [ds2,pa2,kb2,tx2,gSCell2] = runExperiment_RDS({subjID,['demoBetween',types{a}],2,perspective},dists,dispID,db,stairDemo2);
        
    case 'full'
%         if a == 1              
%             % Within
%             [ds1,pa1,kb1,tx1,gSCell1] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct1);
%             
%             % Between
%             [ds2,pa2,kb2,tx2,gSCell2] = runExperiment_RDS({subjID,['fullBetween',types{a}],2,perspective},dists,dispID,db,stairStruct2);
%         
%             % Size control
%             [ds3,pa3,kb3,tx3,gSCell3] = runExperiment_RDS({subjID,['fullWithin',types{a}],3,perspective},dists,dispID,db,stairStruct3);
%         else
%             % Between
%             [ds2,pa2,kb2,tx2,gSCell2] = runExperiment_RDS({subjID,['fullBetween',types{a}],2,perspective},dists,dispID,db,stairStruct2);
%             
            % Within
            [ds1,pa1,kb1,tx1,gSCell1] = runExperiment_RDS({subjID,['fullWithin',types{a}],1,perspective},dists,dispID,db,stairStruct1);
%             
%             % Size control
%             [ds3,pa3,kb3,tx3,gSCell3] = runExperiment_RDS({subjID,['fullWithin',types{a}],3,perspective},dists,dispID,db,stairStruct3);
%         end
        
end