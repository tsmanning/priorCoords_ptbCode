% Part of PTBStaircase class
% Robin Held 
% Banks Lab
% UC Berkeley
% 
% Revised/modified Tyler Manning Feb 2022

% This function takes in the latest response and updates the number of
% reversals, step size, etc.
% Here, 0 means the response should be skipped, 1 means 'less,' (or
% in the case of slant nulling, that the stimulus appeared to have
% negative slant), and 2 means 'more'

function [ms] = processResponse(ms,response)

    % Skip if the response is a nan (lapse trial)
    if ~isnan(response)
        
        % Add response to response vector.
        
        % Recode in terms of reference/test, not key index since the
        % position of the stimuli are randomized
        if response == ms.refIndex
            % Reference seen faster
            respRev = 2;
        else
            % Test seen faster
            respRev = 1;
        end
        
        ms.respRev = [ms.respRev(:)' respRev];
        
        % Check whether this is the first response
        if length(ms.respRev) ~= 1
            
            % Check whether the current response is the same as the last
            if  respRev ~= ms.respRev(length(ms.respRev) - 1)
        
                % If so, initialize run counter
                ms.responserun = 1;  
                
            else  
                
                % If not, increment run counter
                ms.responserun = ms.responserun + 1;
                
            end
            
            % Check if we've hit the trial maximum for this staircase
            if length(ms.respRev) > ms.maximumtrials
                ms.complete = 1;
                disp('Staircase terminated, trial count exceeded');
            end
            
        else
            
            % This is the first response, so make sure the first value was recorded
            ms.values(1)   = ms.currentValue;
            
            % Start the response counter for current run
            ms.responserun = 1.1;  
            
        end
        
         % Determine the next stimulus value and if this trial was a reversal if the staircase is not complete
         revFlag = 0;
         
         if ~ms.complete
            
            if response == ms.refIndex
                % Responded that reference was faster, increase speed of test
                stepSign = 1; 
            else
                % Responded that test was faster, decrease speed of test
                stepSign = -1; 
            end
            
            % Adjust stimulus if we've reached x up/y down steps
            if ((stepSign == 1  && ms.responserun >= ms.numUp)  || ...
                (stepSign == -1 && ms.responserun >= ms.numDown)) 
            
                % Make sure the new value is not outside the acceptable range
                newValue = exp(log(ms.currentValue) + stepSign * ms.stepSize);
                
                if newValue > ms.maxValue
                    newValue = ms.maxValue;
                elseif newValue < ms.minValue
                    newValue = ms.minValue;
                end
                
                % Reset responserun after an adjustment
                ms.responserun = 0;  
                
            else
                % Don't make an adjustment
                newValue = ms.currentValue;
                
                stepSign = 0;
            end
            
            % Check if sign change for this trial will be different from
            % last sign change
            if length(ms.respRev) ~= 1
                % Response vector is 1 element longer than sign vector
                if (length(ms.signs) >= (length(ms.respRev) - ms.numUp)) && ((length(ms.respRev) - ms.numUp)~=0)
                    if ( stepSign > 0 && ms.signs(length(ms.respRev) - ms.numUp) < 0 )
                        revFlag = 1;
                    end
                end
                if (length(ms.signs) >= (length(ms.respRev) - ms.numDown)) && ((length(ms.respRev) - ms.numDown)~=0)
                    if ( stepSign < 0 && ms.signs(length(ms.respRev) - ms.numDown) > 0 )
                        revFlag = 1;
                    end
                end
            end
            
            if revFlag
                % If so, this was a reversal
                ms.currentReversals                 = ms.currentReversals + 1;
                ms.reversalflag(length(ms.respRev)) = 1;
                
                % Check if the max # of reversals has been met
                if (ms.currentReversals == ms.maxReversals)
                    
                    ms.complete = 1;
                    disp('Staircase complete!');
                    
                else
                    
                    % Halve the step size
                    ms.stepSize = ms.stepSize / 2;
                    
                    % Make sure the stepSize is larger than the minimum
                    if abs(ms.stepSize) < abs(ms.stepLimit)
                        ms.stepSize = sign(ms.stepSize) * abs(ms.stepLimit);
                    end
                    
                end
            end

        end
        
        % Update array of values with new value if max # reversals not met
        if ~ms.complete
            ms.signs            = [ms.signs stepSign];
            
            ms.values           = [ms.values newValue];
            ms.currentValue     = newValue;
            ms.refPosition      = randi(2); % select random side for standard
        end
        
        ms.reversals        = [ms.reversals revFlag];
      
        if ~ms.complete
            % Debugging items
            display(['Reversals: ' num2str(ms.currentReversals)]);
            display(['Current Value: ' num2str(ms.currentValue)]);
            display(['Response: ' num2str(respRev)]);
            display(['This step sign: ' num2str(stepSign)]);
            %     display(['Last step sign: ' num2str(ms.signs(length(ms.respRev) - (ms.numDown)))]);
        end
        
    end  
    
    
end