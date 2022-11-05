function [uit,s] = get(s,varargin)

% Set asset properties and return the updated staircase object
propertyArgIn = varargin;

while length(propertyArgIn) >= 1
    
   prop = propertyArgIn{1};
   propertyArgIn = propertyArgIn(2:end);
   
   switch prop
       case 'initialValue'
           uit = s.initialValue;
       case 'stepSize'
           uit = a.stepSize;
       case 'maxReversals'
           uit = a.maxReversals;
       case 'maximumtrials'
           uit = a.maximumtrials;
       case 'currentReversals'
           uit = a.currentReversals;
       case 'lastDirection'
           uit = a.lastDirection;
       case 'stimDistance'
           uit = s.stimDistance;
       case 'eccentricity'
           uit = s.eccentricity;
       case 'radius'
           uit = s.radius;
       case 'aspectratio'
           uit = s.aspectratio;
       case 'complete'
           uit = s.complete;
       case 'responses'
           uit = s.responses;
       case 'values'
           uit = s.values;
       case 'stepLimit'
           uit = s.stepLimit;
       case 'maxValue'
           uit = s.maxValue;
       case 'minValue'
           uit = s.minValue;
       case 'altVariable'
           uit = s.altVariable;
       case 'numUp'
           uit = s.numUp;
       case 'numDown'
           uit = s.numDown;
       case 'initialValue_random_range'
           uit = s.initialValue_random_range;
       case 'refPosition'
           uit = s.refPosition;
       case 'refIndex'
           uit = s.refIndex;
       case 'refContrast'
           uit = s.refContrast;
       case 'refSize'
           uit = s.refSize;
       case 'testSize'
           uit = s.testSize;
       case 'refOrientation'
           uit = s.refOrientation;
       case 'refScreen'
           uit = s.refScreen;    
       case 'refVelocity'
           uit = s.refVelocity;    
       case 'testScreen'
           uit = s.testScreen;      
       case 'testContrast'
           uit = s.testContrast;  
       case 'currentValue'
           s.currentValue;
           if isempty(s.currentValue)
               disp('*********************************************')
               disp('You have not initialized this staircase')
               disp('Make sure that you have run the initializeStaircase routine')
               disp('*********************************************')
               uit =NaN;
           else
               uit = s.currentValue;
           end
       case 'reversalflag'
           uit = s.reversalflag;
       case 'respRev'
           uit = s.respRev;
       case 'signs'
           uit = s.signs;
       case 'reversals'
           uit = s.reversals;
       otherwise
           error('Property does not exist')
   end
   
end