function [dots,disp_center,xvel,yvel] = AnimateRandomDots(dots,disp_center,xmax,ymax,xvel,yvel,sigma,amp)




% Compute dot positions and offsets for next frame:
disp_center = disp_center + [xvel yvel];
if disp_center(1) > xmax || disp_center(1) < -xmax
    xvel = -xvel;
end

if disp_center(2) > ymax || disp_center(2) < -ymax
    yvel = -yvel;
end

dots(3, :) = -amp.*exp(-(dots(1, :) - disp_center(1)).^2 / (2*sigma*sigma)).*exp(-(dots(2, :) - disp_center(2)).^2 / (2*sigma*sigma));