function [tx,pa] = initializeRDS(pa)

% Setup initial properties of the random dot stimulus, store in structure
% tx

%% In which location(s) are we plotting random dot stimuli?
   

%% Define center of RDS

% (rows: screen, column: top/bottom; px)
centW   = pa.centW;
centH   = pa.centH;


%% Define number of dots for each screen/position
tx.aperRad   = pa.apertureSize/2;
apertureArea = pi*(tx.aperRad).^2;
tx.numDots   = round(pa.dotDensity.*apertureArea);


%% Define random starting positions for each dot
tx.dotInitAngle  = cell(2,2);
tx.dotInitRad    = cell(2,2);
tx.dotInitPos    = cell(2,2);
tx.currentDotPos = cell(2,2);
tx.frameLifetime = cell(2,2);

% Loop over screens
for ii = 1:2
    
    % Loop over screen positions
    for jj = 1:2
        
        % Easier to define positions in polar coords first
        tx.dotInitAngle{ii,jj} = 2*pi*rand(tx.numDots(ii,jj),1);
        tx.dotInitRad{ii,jj}   = tx.aperRad(ii,jj)*sqrt(rand(tx.numDots(ii,jj),1));
        
        % Convert to x/y pixel values for drawdots
        dotInitPos              = [tx.dotInitRad{ii,jj}.*cos(tx.dotInitAngle{ii,jj}) + centW(ii,jj), ...
                                  tx.dotInitRad{ii,jj}.*sin(tx.dotInitAngle{ii,jj}) + centH(ii,jj)];
        tx.currentDotPos{ii,jj} = dotInitPos;
        
        % Initialize frame counter for each dot
        tx.frameLifetime{ii,jj} = ones(size(dotInitPos,1),1);
        
    end
    
end

end