function [pa,kb] = GetResponse_RDS_sizeControl(pa,ds,kb)
% Gets keyboard inputs and uses them for experiment
%
% Usage: [pa,kb] = GetResponse_RDS(pa,ds,kb)

% Get keyboard state
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);

respStatLR = [kb.keyCode(kb.rightkey) kb.keyCode(kb.leftkey)];
respStatUD = [kb.keyCode(kb.downkey)  kb.keyCode(kb.upkey)];

setupNewTrial = 0;

% Allow subject to lock in their response any time after the second stimulus has
% begun
if (sum(respStatLR + respStatUD) >= 1 && (ds.vbl > pa.trialOnset + pa.fixDura + pa.trialDuraA))...
   || pa.lapseTrial
    
    % Only register appropriate responses
    if (sum(respStatUD(1:2)) >= 1) && pa.trialEpochs == 1
        
        kb.responseGiven = 1;
        
        if kb.keyCode(kb.upkey)
            response = 2;
        elseif kb.keyCode(kb.downkey)
            response = 1;
        end
        
        setupNewTrial = 1;
        
    elseif (sum(respStatLR(1:2)) >= 1) && pa.trialEpochs == 2
        
        kb.responseGiven = 1;
        
        if kb.keyCode(kb.rightkey)
            response = 2;
        elseif kb.keyCode(kb.leftkey)
            response = 1;
        end
        
        setupNewTrial = 1;
        
    elseif pa.lapseTrial
        response = nan;
        
        setupNewTrial = 1;
    end
    
    % Recode responses in terms of test chosen 1/0 (y/n)?
    respRec = [];
    
    if setupNewTrial
                
        % Record responses and current trial parameters
        pa.responseTime = kb.secs - pa.trialOnset;
        pa.currentTime = ds.vbl - pa.experimentOnset;
        
        pa.response(pa.trialNumber,:) = ...
            [pa.trialNumber,...                   % 1
            pa.testCont,...                       % 2
            pa.testVel,...                        % 3
            pa.refCont,...                        % 4
            pa.refVel,...                         % 5
            pa.testScreen,...                     % 6
            pa.trialDir,...                       % 7
            pa.refPos,...                         % 8
            response,...                          % 9
            pa.thisStaircase,...                  % 10
            pa.stairType(1),...                   % 11
            pa.stairType(2),...                   % 12
            pa.responseTime,...                   % 13
            pa.currentTime,...                    % 14
            pa.refSz];                            % 15
    end
    
end

end