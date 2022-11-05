% Part of PTBStaircase set.  Does NOT belong in the ~PTBStaircase
% directory.
% Robin Held 
% Banks Lab
% UC Berkeley

function [scnum] = PTBSelectStaircase(scell)

    % Input a cell composed of staircases and randomly select one that has not
    % been completed.  If all have been completed, return 0.

    % Initial scnum setting will be replaced later
    scnum = -1;

    % Get the number of staircases
    sc_length = length(scell);
    
    % Make sure at least one of the staircases is incomplete
    num_incomplete = 0;
    for i = 1:sc_length
        if ~get(scell{i},'complete')
            num_incomplete = num_incomplete + 1;
        end
    end
    
    if num_incomplete > 0
        while scnum <= 0
            
            % Randomly select a staircase number
            scnum = ceil(rand * sc_length);
            
            % Make sure that staircase is empty
            if get(scell{scnum},'complete')
                scnum = 0;
            end
            
        end
    else
        % Report that all of the staircases are complete
        scnum = 0;
    end
    
end