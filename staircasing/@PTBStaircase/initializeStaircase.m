function [scell] = initializeStaircase(scell)

% Initialize staircase with a random starting value

% Returns the initial value plus or minus some offset within initialValue_random_range,
% rounded to the nearest minimum step unit

% Initialize in linear domain
% randomval            = rand * scell.initialValue_random_range;

% Initialize in log domain
logRange             = log(scell.initialValue_random_range) - log(scell.minValue);
randomval            = (rand * logRange) + log(scell.minValue);
randomval            = exp(randomval);

randomval            = floor(randomval / scell.stepLimit) * scell.stepLimit;
scell.currentValue   = randomval;
scell.initialValue   = randomval;

end


