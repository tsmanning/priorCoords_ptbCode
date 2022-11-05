function a = set(a,varargin)

% Get asset properties from a selected staircase object
property_argin = varargin;

while length(property_argin) >= 2
    
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    switch prop
        case 'initialValue'
            a.initialValue = val;
        case 'stepSize'
            a.stepSize = val;
        case 'tGuessSd'
            a.tGuessSd = val;
        case 'maxReversals'
            a.maxReversals = val;
        case 'maximumtrials'
            a.maximumtrials = val;
        case 'currentReversals'
            a.currentReversals = val;
        case 'lastDirection'
            a.lastDirection = val;
        case 'stimDistance'
            a.stimDistance = val;
        case 'eccentricity'
            a.eccentricity = val;
        case 'radius'
            a.radius = val;
        case 'aspectratio'
            a.aspectratio = val;
        case 'complete'
            a.complete = val;
        case 'responses'
            a.responses = val;
        case 'values'
            a.values = val;
        case 'stepLimit'
            a.stepLimit = val;
        case 'maxValue'
            a.maxValue = val;
        case 'minValue'
            a.minValue = val;
        case 'altVariable'
            a.altVariable = val;
        case 'numUp'
            a.numUp = val;
        case 'numDown'
            a.numDown = val;
        case 'initialValue_random_range'
            a.initialValue_random_range = val;
        case 'refPosition'
            a.refPosition = val;
        case 'refIndex'
            a.refIndex = val;
        case 'refContrast'
            a.refContrast = val;
        case 'refSize'
            a.refSize = val;
        case 'testSize'
            a.testSize = val;
        case 'refOrientation'
            a.refOrientation = val;
        case 'refScreen'
            a.refScreen = val;    
        case 'refVelocity'
            a.refVelocity = val;    
        case 'testScreen'
            a.testScreen = val;      
        case 'testContrast'
            a.testContrast = val;   
        case 'respRev'
            a.respRev = val;  
        otherwise
            if ischar(prop)
                error(['Property ' prop ' does not exist in this class!'])
            else
                disp('Property: ')
                disp(prop)
                error('Property does not exist in this class!')
            end
    end
    
end