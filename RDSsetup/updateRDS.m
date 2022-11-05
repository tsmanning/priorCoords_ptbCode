function [tx,velMatDeg,velMat] = updateRDS(tx,ds,pa)

% Take current set of dots, update their positions or extinguish them based
% on coherence, set lifetime, and bounding area of stimulus aperture

%% Get velocity matrix for this trial

velMat = zeros(2,2);

velMat(pa.testScreen,pa.testPos) = pa.testVel;
velMat(pa.refScreen,pa.refPos)   = pa.refVel;

velMatDeg = velMat;

% Convert from deg/s to px/frame
% [px/frame = deg/s * m/deg * px/m * s/frame]
velMat = velMat .* [ds.metersPerDegree ds.metersPerDegree] .* ...
                   [ds.pixelsPerM ds.pixelsPerM] .* [1./ds.fps 1./ds.fps]; 
               
% velMat = velMat .* [ds.metersPerDegree'; ds.metersPerDegree'] .* ...
%                    [ds.pixelsPerM ds.pixelsPerM] .* [1./ds.fps 1./ds.fps]; 
               
% Loop over screens
for ii = 1:2
    
    % Loop over screen positions
    for jj = 1:2
        
        %% Update dot positions
        
        % Calculate the vector along which coherent dots should be displaced
        % (in px, [x y])
        thisFrameOffset  = velMat(ii,jj)*[cosd(pa.trialDir) sind(pa.trialDir)];
        
        % Update dot positions normally if new position > radius of aperture,
        % otherwise randomly position dot within aperture
        newDotPos        = tx.currentDotPos{ii,jj} + thisFrameOffset;
        
        
        %% Check to see if updated dot position is out of range
        
        % Get radial distances of new positions from center of aperture
        newDotPosRad   = sqrt( sum( (newDotPos - [pa.centW(ii,jj) pa.centH(ii,jj)]).^2 ,2) );
        
        % Find indices of dots to replace and randomly select new x/y positions
        % along opposite side of the aperture for them to be placed on
        extinguishInds = newDotPosRad > (pa.apertureSize(ii,jj)/2);
        numNewDots     = sum(extinguishInds);
        
        if numNewDots > 0
            % All new dots will be placed at the aperture edge
            newDotRads     = tx.aperRad(ii,jj)*ones(numNewDots,1);
            
            % Randomly position them at different angles along opposite
            % side of aperture
            newDotAngs     = pi*rand(numNewDots,1) + pa.trialDir*(pi/180) + pi/2;
            
            newDotPos(extinguishInds,:) = [newDotRads.*cos(newDotAngs) + pa.centW(ii,jj) ...
                                           newDotRads.*sin(newDotAngs) + pa.centH(ii,jj)];
        end
        
        
        %% Extinguish dots according to persistence time, rebirthing them randomly
        
        if isnan(pa.persistTime)
            
            % just set persist time as time it takes for dots to traverse
            % the radius of the aperture
            persistTime = pa.StimDiam/2/velMatDeg(ii,jj)*ds.fps(ii);
            
        else
            
            persistTime = pa.persistTime;
            
        end
            
        % Update frame counter
        theseLifetimes                 = tx.frameLifetime{ii,jj} + 1;
        theseLifetimes(extinguishInds) = ones(numNewDots,1);
        
        % Find if any dots have persisted for just too long
        timeToDie  = theseLifetimes > persistTime;
        numNewDots = sum(timeToDie);
        
        % Randomly reposition them if so
        if numNewDots > 0
            newDotRads     = tx.aperRad(ii,jj)*sqrt(rand(numNewDots,1));
            newDotAngs     = 2*pi*rand(numNewDots,1);
            
            newDotPos(timeToDie,:)    = [newDotRads.*cos(newDotAngs) + pa.centW(ii,jj) ...
                                         newDotRads.*sin(newDotAngs) + pa.centH(ii,jj)];
            
            % ... and reset their counters
            theseLifetimes(timeToDie) = ones(numNewDots,1);
        end
        
        tx.frameLifetime{ii,jj}    = theseLifetimes;
        
        
        %% Randomly displace dots according to set coherence level
        
        numNewDots = 0;
        
        if pa.coherence ~= 1
            
            numTotalDots = size(newDotPos,1);
            numNewDots   = round((1-pa.coherence)*numTotalDots);
            randoInds    = datasample(1:numTotalDots,numNewDots,'replace',false);
            
            if numNewDots > 0
            % All new dots will be placed at the aperture edge
            newDotRads     = tx.aperRad(ii,jj)*sqrt(rand(numNewDots,1));
            
            % Randomly position them at different angles along opposite
            % side of aperture
%             newDotAngs     = pi*rand(numNewDots,1) + pa.trialDir*(pi/180) + pi/2;
            newDotAngs     = 2*pi*rand(numNewDots,1);
            
            newDotPos(randoInds,:) = [newDotRads.*cos(newDotAngs) + pa.centW(ii,jj) ...
                                      newDotRads.*sin(newDotAngs) + pa.centH(ii,jj)];
            end
            
        end
        
        
        %% Update current dot position array for the next frame
        tx.currentDotPos{ii,jj} = newDotPos;
        
        
    end
end

end