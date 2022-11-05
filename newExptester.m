% test the staircase/RDS version of the depth/contrast motion task
subjID = 'tyler';
a = randi(2);
types = {'left','right'};
dists = [0.5;1];

    dispID = 'labRig';
%     dispID = 'tylerHome';
%     dispID = 'tylerLabMac';
%     dispID = 'tylerAOC';
%     dispID = 'tylerLaptop';
%     dispID = 'claraLaptop';
%     dispID = 'tylerHomeWindows';
%     dispID = 'tylerLaptopWindows';

% Set to autorun
db = 3;

% Determine how many staircases we want to make
blockType = 'within';
% blockType = 'between';

switch blockType
    case 'within'
        % Within a screen
%         contCombs  = [0.5 0.1; 0.1 0.5;0.5 0.5;0.1 0.1];             % Reference/Test constrasts (%)
        contCombs  = [0.5 0.1; 0.1 0.5];             % Reference/Test constrasts (%)
        refPos     = [1 2];                          % Ref Near/Far (inds)
        testPos    = [1];                            % Test on same or different screen (y/n)
        refVels    = [1 8];                          % Reference velocities (deg/s)
%         refVels    = [1];                          % Reference velocities (deg/s)
        stairTypes = [1 1; 2 1; 1 2];                % x up/y down (inds)
        
%         contCombs  = [0.1 0.5;0.5 0.1];     % Reference/Test constrasts (%)
%         refPos     = [1 2];                 % Ref Near/Far (inds)
%         testPos    = [1];                   % Test on same or different screen (y/n)
%         refVels    = [8];                   % Reference velocities (deg/s)
%         stairTypes = [1 1; 2 1; 1 2];       % x up/y down (inds)
        
        block      = 1;
        
    case 'between'
        % Between screens
        contCombs  = [0.5 0.5;0.1 0.1];              % Reference/Test constrasts (%)
        refPos     = [1 2];                          % Ref Near/Far (Screen inds)
        testPos    = [2];                            % Test on same or different screen (1-y/2-n)
        refVels    = [1 8];                          % Reference velocities (deg/s)
        stairTypes = [1 1; 2 1; 1 2];                % x up/y down (inds)
        
        block      = 2;
        
end

stairStruct.contCombs  = contCombs;
stairStruct.refPos     = refPos;
stairStruct.testPos    = testPos;
stairStruct.refVels    = refVels;
stairStruct.stairTypes = stairTypes;

[ds,pa,kb,tx,gSCell] = runExperiment_DepthControl({subjID,['demo',types{a}],block},dists,dispID,db,stairStruct);