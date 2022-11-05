function ms = PTBStaircase()

% Class constructor function

% Staircase class constructor
ms.initialValue              = [];
ms.initialValue_random_range = [];
ms.currentValue              = [];
ms.stepSize                  = [];
ms.maxValue                  = [];
ms.minValue                  = [];
ms.stepLimit                 = [];
ms.maxReversals              = [];
ms.maximumtrials             = [];           % If there are this many trials, mark the staircase as complete
ms.currentReversals          = [];
ms.lastDirection             = [];
ms.stimDistance              = [];
ms.aspectratio               = [];
ms.eccentricity              = [];
ms.radius                    = [];
ms.altVariable               = [];           % Some variable that is different for each staircase
ms.complete                  = [];           % Is this staircase complete (max # of reversals met)
ms.responses                 = [];           % Vector containing each response
ms.values                    = [];           % Vector containing each stimulus value
ms.signs                     = [];           % Vector of sign changes in stimulus value
ms.numUp                     = [];           % numUp and numDown are used for staircases that are
ms.numDown                   = [];           % not 1-up/1-down.  

ms.refContrast               = [];
ms.refSize                   = [];
ms.refOrientation            = [];
ms.refPosition               = [];
ms.refIndex                  = [];
ms.refScreen                 = [];           
ms.refVelocity               = [];

ms.testScreen                = [];
ms.testContrast              = [];
ms.testSize                  = [];

ms.respRev                   = [];
ms.reversals                 = [];
ms.reversalflag              = [];           % trials flagged on which a reversal occured
ms.responserun               = [];           % how many responses have been the same.
                                             % ... this assumes that the response is
                                             % ... right or wrong

ms = class(ms,'PTBStaircase');