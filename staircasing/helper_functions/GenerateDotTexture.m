function GenerateDotTexture
    global gdots
    global gtextures
    global GL
    
    %%%%% Create bright stimulus texture first
    
    % Create the Gaussian distribution
    [X Y] = meshgrid(-1:2/(gdots.textureSize - 1):1, -1:2/(gdots.textureSize - 1):1);
    a = 0.6;
    Z = exp( - ((X / a).^2 + (Y / a).^2)) ;

    % Create the array of RGBA values
    subImage = [];
    % Red channel
    subImage(1,1:gdots.textureSize,1:gdots.textureSize) = 1.0;
    % Green channel
    subImage(2,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Blue channel
    subImage(3,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Alpha channel
    subImage(4,1:gdots.textureSize,1:gdots.textureSize) = Z;
     
    % Cast into float format
    subImage = single(subImage);

    %% Capture the texture
    glBindTexture(GL.TEXTURE_2D, gtextures(1));
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gdots.textureSize, gdots.textureSize, 0,GL.RGBA, GL.FLOAT, subImage);
    
%     %%%%% Create dim stimulus texture next
%     
%     % Create the Gaussian distribution
%     [X Y] = meshgrid(-1:2/(gdots.textureSize - 1):1, -1:2/(gdots.textureSize - 1):1);
%     a = 0.6;
%     Z = exp( - ((X / a).^2 + (Y / a).^2)) ;
% 
%     % Create the array of RGBA values
%     % Red channel
%     subImage(1,1:gdots.textureSize,1:gdots.textureSize) = 0.8;
%     % Green channel
%     subImage(2,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
%     % Blue channel
%     subImage(3,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
%     % Alpha channel
%     subImage(4,1:gdots.textureSize,1:gdots.textureSize) = Z;
%      
%     % Cast into float format
%     subImage = single(subImage);
% 
%     %% Capture the texture
%     glBindTexture(GL.TEXTURE_2D, gtextures(2));
%     glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gdots.textureSize, gdots.textureSize, 0,GL.RGBA, GL.FLOAT, subImage);
    
    %%%%% Create oriented dot texture next
    
    % Create the Gaussian distribution
    [X Y] = meshgrid(-1:2/(gdots.textureSize - 1):1, -1:2/(gdots.textureSize - 1):1);
    a = 0.8;
    
    % Horizontal orientation
    Z = exp( - ((2 * X / a).^2 + (Y / a).^2)) ;

    % Create the array of RGBA values
    % Red channel
    subImage(1,1:gdots.textureSize,1:gdots.textureSize) = 1.0;
    % Green channel
    subImage(2,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Blue channel
    subImage(3,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Alpha channel
    subImage(4,1:gdots.textureSize,1:gdots.textureSize) = Z;
     
    % Cast into float format
    subImage = single(subImage);

    %% Capture the texture
    glBindTexture(GL.TEXTURE_2D, gtextures(2));
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gdots.textureSize, gdots.textureSize, 0,GL.RGBA, GL.FLOAT, subImage);    
    
    % Vertical Orientation
    a = 0.8;
    Z = exp( - ((X / a).^2 + (2* Y / a).^2)) ;

    % Create the array of RGBA values
    % Red channel
    subImage(1,1:gdots.textureSize,1:gdots.textureSize) = 1.0;
    % Green channel
    subImage(2,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Blue channel
    subImage(3,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Alpha channel
    subImage(4,1:gdots.textureSize,1:gdots.textureSize) = Z;
     
    % Cast into float format
    subImage = single(subImage);

    %% Capture the texture
    glBindTexture(GL.TEXTURE_2D, gtextures(3));
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gdots.textureSize, gdots.textureSize, 0,GL.RGBA, GL.FLOAT, subImage);   
    
   
    
    %%%%%% Create fixation stimulus
    
%     % Gaussian-based
%     [Y X] = meshgrid(-1:2/(gdots.textureSize - 1):1, -1:2/(gdots.textureSize - 1):1);
%     a = 0.45;
%     Z = exp( - ((1.5 * Y / a).^2 + (1.5 * X / a).^2)) ;
%     Z2 = exp( - ((0.55*Y / a).^2 + (4*X / a).^2)) ;
    
    % Line with dot
    [Y X] = meshgrid(-1:2/(gdots.textureSize - 1):1, -1:2/(gdots.textureSize - 1):1);
    a = 0.8;
    % Line:
    Z = (abs(Y) <= 0.5) .* (abs(X) <= 0.03) .* exp( - ((1.75 * Y / a).^2));
%     % Dot:
    Z2 = exp( - ((12.0 * Y / a).^2 + (12.0 * X / a).^2)) ;
%     Z2 = zeros(gdots.textureSize,gdots.textureSize);
%     Z2 = (abs(X) <= 0.5) .* (abs(Y) <= 0.03) .* exp( - ((1.75 * X / a).^2));

    % Set all the values of the bottom half to 0.
    Z(:,round(length(Z(1,:))/2 + 1):length(Z(1,:))) = 0;
    
    % Create the array of RGBA values
    % Red channel
    subImage(1,1:gdots.textureSize,1:gdots.textureSize) = 1.0;
    % Green channel
    subImage(2,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Blue channel
    subImage(3,1:gdots.textureSize,1:gdots.textureSize) = 0.0;
    % Alpha channel
    subImage(4,1:gdots.textureSize,1:gdots.textureSize) = Z + Z2;
     
    % Cast into float format
    subImage = single(subImage);

    %% Capture the texture
    glBindTexture(GL.TEXTURE_2D, gtextures(4));
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gdots.textureSize, gdots.textureSize, 0,GL.RGBA, GL.FLOAT, subImage);