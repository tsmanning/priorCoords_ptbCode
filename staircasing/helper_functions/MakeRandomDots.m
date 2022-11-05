function [dots,xmax,ymax] = MakeRandomDots(dotsSize,xmax,ymax,numDots)

% Stimulus settings:
dots = zeros(3, numDots);

xmax = min(xmax, ymax) / 2;
ymax = xmax;

dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax;

