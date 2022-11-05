function [] = DrawFixation(w,wlevel,glevel,fixationRadiusYPix,fixationRadiusXPix,screenLeftXCenterPix, screenRightXCenterPix, screenLeftYCenterPix, screenRightYCenterPix, dotSize)

fixationRadiusXPix2 = sqrt((fixationRadiusXPix.^2)/2);
fixationRadiusYPix2 = sqrt((fixationRadiusYPix.^2)/2);

Screen('DrawDots', w, [0 0], dotSize, [255 0 0], [screenLeftXCenterPix screenLeftYCenterPix] , 2);
Screen('DrawLine', w, [255 0 0], screenLeftXCenterPix-fixationRadiusXPix2,screenLeftYCenterPix-fixationRadiusYPix2,screenLeftXCenterPix+fixationRadiusXPix2,screenLeftYCenterPix+fixationRadiusYPix2 , 1);
Screen('DrawLine', w, [255 0 0], screenLeftXCenterPix+fixationRadiusXPix2,screenLeftYCenterPix-fixationRadiusYPix2,screenLeftXCenterPix-fixationRadiusXPix2,screenLeftYCenterPix+fixationRadiusYPix2 , 1);

Screen('DrawDots', w, [0 0], dotSize, [255 0 0], [screenRightXCenterPix screenRightYCenterPix] , 2);
Screen('DrawLine', w, [255 0 0], screenRightXCenterPix-fixationRadiusXPix2,screenRightYCenterPix-fixationRadiusYPix2,screenRightXCenterPix+fixationRadiusXPix2,screenRightYCenterPix+fixationRadiusYPix2 , 1);
Screen('DrawLine', w, [255 0 0], screenRightXCenterPix+fixationRadiusXPix2,screenRightYCenterPix-fixationRadiusYPix2,screenRightXCenterPix-fixationRadiusXPix2,screenRightYCenterPix+fixationRadiusYPix2 , 1);

Screen('DrawLine', w, [255 0 0], screenRightXCenterPix-fixationRadiusXPix,screenRightYCenterPix,screenRightXCenterPix,screenRightYCenterPix , 1);
Screen('DrawLine', w, [255 0 0], screenRightXCenterPix,screenRightYCenterPix-fixationRadiusYPix,screenRightXCenterPix,screenRightYCenterPix , 1);
Screen('DrawLine', w, [255 0 0], screenLeftXCenterPix+fixationRadiusXPix,screenLeftYCenterPix,screenLeftXCenterPix,screenLeftYCenterPix , 1);
Screen('DrawLine', w, [255 0 0], screenLeftXCenterPix,screenLeftYCenterPix+fixationRadiusYPix,screenLeftXCenterPix,screenLeftYCenterPix , 1);