function [subjID] = genRandID()
    
    % Generate a randomized ID for subject
    %
    % Usage: [subjID] = genRandID()
    
    numChars = 3;
    letters = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N',...
               'O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    
    IDinds = randi(26,numChars,1);
    
    IDchars = letters(IDinds);
    
    subjID = cellfun(@(x) x,IDchars);
    
end