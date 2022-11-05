function [ds,pa,kb,sc] = SetupNewTrial_gabors(ds,pa,kb,sc,scInd)

% Grab parameters for trial and reset flags
%
% Usage: [ds,pa,kb] = SetupNewTrial(ds,pa,kb)

% Only run new trial routine if partipant has responded or has lapsed
if kb.keyIsDown || pa.lapseTrial
    
    numStaircases = numel(sc);
    
    % Increment trial count and save current index
    pa.trialNumber = pa.trialNumber + 1;
    pa.thisTrial   = pa.trialNumber;
    pa.thisStaircase = scInd;
    
    pa.refCont    = get(sc{scInd},'refContrast');
    pa.testCont   = get(sc{scInd},'testContrast');
    
    pa.refLum     = -pa.bgLum(1)*(pa.refCont + 1)/(pa.refCont - 1);
    pa.testLum    = -pa.bgLum(1)*(pa.testCont + 1)/(pa.testCont - 1);
    
    pa.refVel     = get(sc{scInd},'refVelocity');
    pa.testVel    = get(sc{scInd},'currentValue');
    
    pa.refFirst   = rand(1)>0.5;
    pa.stimOrder  = [pa.stimOrder pa.refFirst];
    
    pa.refScreen  = get(sc{scInd},'refScreen');
    whereIsTest   = get(sc{scInd},'testScreen');
    if whereIsTest == 1
        pa.testScreen = pa.refScreen;
    elseif whereIsTest == 2
        pa.testScreen = ~(pa.refScreen - 1) + 1;
    end
    
    pa.refPos     = get(sc{scInd},'refPosition');
    
    % Grab staircase type to save (1u/1d, 2u/1d, 1u/2d)
    pa.stairType  = [get(sc{scInd},'numUp') get(sc{scInd},'numDown')];
    
    % Note whether this staircase indicates judgment between or within
    % screens
    if pa.refScreen == pa.testScreen
        pa.trialEpochs = 1;
        pa.fixDuraA    = pa.fixDura;
        pa.fixDuraB    = 0;
        pa.trialDuraA  = pa.trialDura;
        pa.trialDuraB  = 0;
        
        pa.testPos     = ~(pa.refPos - 1) + 1;
        
        sc{scInd}      = set(sc{scInd},'refIndex',pa.refPos);
    else
        pa.trialEpochs = 2;
        pa.fixDuraA    = pa.fixDura;
        pa.fixDuraB    = pa.fixDura;
        pa.trialDuraA  = pa.trialDura;
        pa.trialDuraB  = pa.trialDura;
        
        pa.testPos     = pa.refPos;
        
        sc{scInd}      = set(sc{scInd},'refIndex',pa.refScreen);
    end
    
    pa.trialDir   = pa.driftDir(randi(2));
    
    % Select window temporal order for this trial (index: 1 or 2)
    pa.refWind = ds.w(pa.refScreen);
    pa.testWind = ds.w(pa.testScreen);

    % Define framewise phase offset based on velocities 
    % (ind 1: ref, ind 2: test)
    % vel -> phase offset on each frame
    if ~IsLinux
        pa.thisPhaseOff(1)        = pa.refVel * ...
            ds.metersPerDegree(pa.refScreen) .* ds.pixelsPerM(pa.refScreen) .* ...
            pa.gaborFreq(pa.refScreen) / ds.fps(pa.refScreen) * 360;

        pa.thisPhaseOff(2) = pa.testVel * ...
            ds.metersPerDegree(pa.testScreen) .* ds.pixelsPerM(pa.testScreen) .* ...
            pa.gaborFreq(pa.testScreen) / ds.fps(pa.testScreen) * 360;
    else
        % need to set FPS manually in linux if screens differ
        pa.thisPhaseOff(1)        = pa.refVel * ...
            ds.metersPerDegree(pa.refScreen) .* ds.pixelsPerM(pa.refScreen) .* ...
            pa.gaborFreq(pa.refScreen) / 144 * 360;

        pa.thisPhaseOff(2) = pa.testVel * ...
            ds.metersPerDegree(pa.testScreen) .* ds.pixelsPerM(pa.testScreen) .* ...
            pa.gaborFreq(pa.testScreen) / 144 * 360;
    end

    % Reset response and feedback flags, trial onset time
    display(['Staircase: ',num2str(scInd),'/',num2str(numStaircases)]);
    
    kb.responseGiven = 0;
    kb.keyIsDown = 0;
    
    % If it's the first trial, get the time; if not, get the last frame
    % throw time
    if pa.trialNumber == 1
        pa.trialOnset = GetSecs;
    else
        pa.trialOnset = ds.vbl;
    end
end