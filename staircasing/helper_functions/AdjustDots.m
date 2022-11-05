function surface = AdjustDots(surface,plane)
    global gdots
    global ghinge
    global gdistances
    global gmonitor
    global gexp
    
    if (gdots.surfaces == 2)
        % For the dual-plane experiments, the distance must be adjusted
        if (plane == 1)
            distToStim = gdistances.vergence - gdots.surfaceGap / 2;
            baseAngle = ghinge.front.baseAngle;
        else
            distToStim = gdistances.vergence + gdots.surfaceGap / 2;
            baseAngle = ghinge.back.baseAngle;
        end
    else
        baseAngle = ghinge.front.baseAngle;
        distToStim = gdistances.vergence;
    end
    % Find the scaling factor due to varying stimulus distances
    distance_scale = distToStim / gmonitor.distance;
    

    if (gexp.type ~= 12)
        % Flat stimulus
        % Determine the x-scaling factor to make sure the surface maintain the same
        % spacing regardless of stimulus rotation
        % This compensation deals with monitor rotation
        onScreenXPos = abs(surface.positionsAdj.left(:,:,1));
        phi = atan(onScreenXPos ./ gmonitor.distance);
        mScale  = sin(phi) ./ sin(pi / 2 + (gmonitor.rotation * pi / 180) - phi) .* gmonitor.distance ./ onScreenXPos;
        surface.positionsAdj.left(:,:,1) = surface.positionsAdj.left(:,:,1) .* mScale;
        % This compensation deals with software rotation
        onScreenXPos = abs(surface.positionsAdj.left(:,:,1));
        phi = atan(onScreenXPos .* distance_scale ./ distToStim);
        sScale  = sin(phi) ./ sin(pi / 2 + (0.5 * (180 - ghinge.hingeAngle) + baseAngle) * pi / 180 - phi) .* distToStim ./...
            onScreenXPos;
        surface.positionsAdj.left(:,:,1) = surface.positionsAdj.left(:,:,1) .* sScale;

    else
        % Curvature case
        % First scale the x- and y-positions
        surface.positionsAdj.left(:,:,1) = surface.positionsAdj.left(:,:,1) .* distance_scale;
        surface.positionsAdj.left(:,:,2) = surface.positionsAdj.left(:,:,2) .* distance_scale;
        surface.sizes.left = surface.sizes.left .* distance_scale;
        tempCoords = surface.positionsAdj.left(:,:,1);
        % Now find the adjust x-coordinates
        surface.positionsAdj.left(:,:,1) = (-4 .* distToStim^2 .* gexp.ipd .* surface.positionsAdj.left(:,:,1) - 2 .* distToStim .* ghinge.H .* ...
            gexp.ipd^2 .* surface.positionsAdj.left(:,:,1) + gexp.ipd^3 .* surface.positionsAdj.left(:,:,1) - gexp.ipd .* surface.positionsAdj.left(:,:,1) ...
            .* sqrt(16 .* distToStim^4 + 8 .* distToStim^2 .* gexp.ipd^2 + gexp.ipd^4 + 16 .* distToStim^2 .* ghinge.H^2 .* surface.positionsAdj.left(:,:,1).^2 ...
            - 32 .* distToStim .* ghinge.H .* gexp.ipd .* surface.positionsAdj.left(:,:,1).^2 + 16 .* gexp.ipd^2 .* surface.positionsAdj.left(:,:,1).^2)) ./ ...
            (2 .* (-4 .* distToStim^2 .* gexp.ipd - distToStim .* ghinge.H .* gexp.ipd^2 + 4 .* distToStim .* ghinge.H .* surface.positionsAdj.left(:,:,1).^2 - ...
            4 .* gexp.ipd .* surface.positionsAdj.left(:,:,1).^2));
        
        % Determine the z-coordinates neccesary to produce a
        % desired curvature
        surface.positionsAdj.left(:,:,3) = (-gexp.ipd * (4 * distToStim ^2 - 2 * ...
            distToStim * ghinge.H * gexp.ipd - gexp.ipd^2) - sqrt(gexp.ipd) * sqrt(16 * distToStim^4 * gexp.ipd ...
            + 8 * distToStim^2 * gexp.ipd^3 + gexp.ipd^5 - 64 * distToStim^3 * ghinge.H * ...
            surface.positionsAdj.left(:,:,1).^2 - 64 * distToStim^2 * gexp.ipd * ...
            surface.positionsAdj.left(:,:,1).^2 + 16 * distToStim^2 * ghinge.H^2 * ...
            gexp.ipd * surface.positionsAdj.left(:,:,1).^2 + 16 * distToStim * ghinge.H ...
            * gexp.ipd^2 * surface.positionsAdj.left(:,:,1).^2)) ./ (2 * gexp.ipd * (-4 * ...
            distToStim + ghinge.H*gexp.ipd)) - distToStim;
        % The z-positions must be flipped since the stimulus is located
        % along the z-axis relative to the camera
        surface.positionsAdj.left(:,:,3) = -surface.positionsAdj.left(:,:,3);
    end
         
%     % Double-check H-value
%     cot((atan(gexp.ipd / 2 / gdistances.vergence) - atan((surface.positionsAdj.left(1,1,1) + gexp.ipd / 2) / ...
%         (-surface.positionsAdj.left(1,1,3) + distToStim)))) - cot((-atan(gexp.ipd / 2 / gdistances.vergence) - atan((surface.positionsAdj.left(1,1,1) -...
%         gexp.ipd / 2) / (-surface.positionsAdj.left(1,1,3) + distToStim))))
%     H = ghinge.H
%     zPos = surface.positionsAdj.left(1,1,3)
    
    % The stimulus may contain individual z-vales for each dot, independent
    % of the surface's overall rotation.  This scaling factor compensates
    % for those positions.  
    % NOTE: Right now, the program assumes that either the dots have individual 
    % z-values OR the entire surface is rotated, but not both.
    if (gexp.type == 12)
         zScale = sqrt(tempCoords.^2 + distToStim^2) ./ sqrt(surface.positionsAdj.left(:,:,1).^2 + (surface.positionsAdj.left(:,:,3) + distToStim).^2);
         surface.positionsAdj.left(:,:,2) =  surface.positionsAdj.left(:,:,2) .* zScale;
         surface.sizes.left = surface.sizes.left .* zScale;
    else
        % First scale for software rotation
        surface.sizes.left = surface.sizes.left .* sqrt(surface.positionsAdj.left(:,:,1).^2 + distToStim^2 - ...
            2 * abs(surface.positionsAdj.left(:,:,1)) .* distToStim * cos(pi / 2 - baseAngle * pi / 180)) ./ distToStim .* distance_scale ;
        % Now scale for monitor rotation
        surface.sizes.left = surface.sizes.left .* sqrt( onScreenXPos.^2 + gmonitor.distance^2 - ...
            2 *  onScreenXPos .* gmonitor.distance * cos(pi / 2 - gmonitor.rotation * pi / 180)) ./ gmonitor.distance;

        % Adjust the y-coordinates to maintain even spacing.
        surface.positionsAdj.left(:,:,2) = surface.positionsAdj.left(:,:,2) .* sqrt(surface.positionsAdj.left(:,:,1).^2 + distToStim^2 - ...
            2 * abs(surface.positionsAdj.left(:,:,1)) .* distToStim * cos(pi / 2 - baseAngle * pi / 180)) ./ ...
            sqrt(onScreenXPos.^2 + distToStim^2) .* sqrt(onScreenXPos.^2 + gmonitor.distance^2 - 2 * onScreenXPos .* gmonitor.distance * ...
            cos(pi / 2 - gmonitor.rotation * pi / 180)) ./ sqrt(onScreenXPos.^2 + gmonitor.distance ^2).* distance_scale;
    end
    
    if (gexp.type ~= 12)
        % Flat stimulus
        % Right side  
        % Determine the x-scaling factor to make sure the surface maintain the same
        % spacing regardless of stimulus rotation
        onScreenXPos = abs(surface.positionsAdj.right(:,:,1));
        % This compensation deals with monitor rotation
        phi = atan(onScreenXPos ./ gmonitor.distance);
        mScale  = sin(phi) ./ sin(pi / 2 - (gmonitor.rotation * pi / 180) - phi) .* gmonitor.distance ./ onScreenXPos;
        surface.positionsAdj.right(:,:,1) = surface.positionsAdj.right(:,:,1) .* mScale;

        onScreenXPos = abs(surface.positionsAdj.right(:,:,1));
        phi = atan(onScreenXPos .* distance_scale ./ distToStim);
        sScale  = sin(phi) ./ sin(pi / 2 + (0.5 * (180 - ghinge.hingeAngle) - baseAngle) * pi / 180 - phi) .* distToStim ./...
            onScreenXPos;
        surface.positionsAdj.right(:,:,1) = surface.positionsAdj.right(:,:,1) .* sScale;
    else
        % Curvature case
        % First scale the x- and y-positions
        surface.positionsAdj.right(:,:,1) = surface.positionsAdj.right(:,:,1) .* distance_scale;
        surface.positionsAdj.right(:,:,2) = surface.positionsAdj.right(:,:,2) .* distance_scale;
        surface.sizes.right = surface.sizes.right .* distance_scale;
        tempCoords = surface.positionsAdj.right(:,:,1);
        % Now find the adjust x-coordinates
        surface.positionsAdj.right(:,:,1) = (-4 .* distToStim^2 .* gexp.ipd .* surface.positionsAdj.right(:,:,1) - 2 .* distToStim .* ghinge.H .* ...
            gexp.ipd^2 .* surface.positionsAdj.right(:,:,1) + gexp.ipd^3 .* surface.positionsAdj.right(:,:,1) - gexp.ipd .* surface.positionsAdj.right(:,:,1) ...
            .* sqrt(16 .* distToStim^4 + 8 .* distToStim^2 .* gexp.ipd^2 + gexp.ipd^4 + 16 .* distToStim^2 .* ghinge.H^2 .* surface.positionsAdj.right(:,:,1).^2 ...
            - 32 .* distToStim .* ghinge.H .* gexp.ipd .* surface.positionsAdj.right(:,:,1).^2 + 16 .* gexp.ipd^2 .* surface.positionsAdj.right(:,:,1).^2)) ./ ...
            (2 .* (-4 .* distToStim^2 .* gexp.ipd - distToStim .* ghinge.H .* gexp.ipd^2 + 4 .* distToStim .* ghinge.H .* surface.positionsAdj.right(:,:,1).^2 - ...
            4 .* gexp.ipd .* surface.positionsAdj.right(:,:,1).^2));
        
        % Determine the z-coordinates neccesary to produce a
        % desired curvature
        surface.positionsAdj.right(:,:,3) = (-gexp.ipd * (4 * distToStim ^2 - 2 * ...
            distToStim * ghinge.H * gexp.ipd - gexp.ipd^2) - sqrt(gexp.ipd) * sqrt(16 * distToStim^4 * gexp.ipd ...
            + 8 * distToStim^2 * gexp.ipd^3 + gexp.ipd^5 - 64 * distToStim^3 * ghinge.H * ...
            surface.positionsAdj.right(:,:,1).^2 - 64 * distToStim^2 * gexp.ipd * ...
            surface.positionsAdj.right(:,:,1).^2 + 16 * distToStim^2 * ghinge.H^2 * ...
            gexp.ipd * surface.positionsAdj.right(:,:,1).^2 + 16 * distToStim * ghinge.H ...
            * gexp.ipd^2 * surface.positionsAdj.right(:,:,1).^2)) ./ (2 * gexp.ipd * (-4 * ...
            distToStim + ghinge.H*gexp.ipd)) - distToStim;
        surface.positionsAdj.right(:,:,3) = -surface.positionsAdj.right(:,:,3);
    end
    
    % The stimulus may contain individual z-vales for each dot, independent
    % of the surface's overall rotation.  This scaling factor compensates
    % for those positions.  
    % NOTE: Right now, the program assumes that either the dots have individual 
    % z-values OR the entire surface is rotated, but not both.
    if (gexp.type == 12)
         zScale = sqrt(tempCoords.^2 + distToStim^2) ./ sqrt(surface.positionsAdj.right(:,:,1).^2 + (surface.positionsAdj.right(:,:,3) + distToStim).^2);
         surface.positionsAdj.right(:,:,2) =  surface.positionsAdj.right(:,:,2) .* zScale;
         surface.sizes.right = surface.sizes.right .* zScale;
    else
        % First scale for software rotation
        surface.sizes.right = surface.sizes.right .* sqrt(surface.positionsAdj.right(:,:,1).^2 + distToStim^2 - ...
            2 * abs(surface.positionsAdj.right(:,:,1)) .* distToStim * cos(pi / 2 + baseAngle * pi / 180)) ./ distToStim .* distance_scale;
        % Now scale for monitor rotation
        surface.sizes.right = surface.sizes.right .* sqrt( onScreenXPos.^2 + gmonitor.distance^2 - ...
            2 *  onScreenXPos .* gmonitor.distance * cos(pi / 2 + gmonitor.rotation * pi / 180)) ./ gmonitor.distance;

        % Adjust the y-coordinates to maintain even spacing.
        surface.positionsAdj.right(:,:,2) = surface.positionsAdj.right(:,:,2) .* sqrt(surface.positionsAdj.right(:,:,1).^2 + distToStim^2 - ...
            2 * abs(surface.positionsAdj.right(:,:,1)) .* distToStim * cos(pi / 2 + baseAngle * pi / 180)) ./ ...
            sqrt(onScreenXPos.^2 + distToStim^2) .* sqrt(onScreenXPos.^2 + gmonitor.distance^2 - 2 * onScreenXPos .* gmonitor.distance * ...
            cos(pi / 2 + gmonitor.rotation * pi / 180)) ./ sqrt(onScreenXPos.^2 + gmonitor.distance ^2).* distance_scale;
    end
      
    % Find (ROUGH) width modulations to deal with monitor rotation
    epsilon = atan(surface.sizes.left ./ 2 ./ gmonitor.distance);
    rho = pi/2 - epsilon + gmonitor.rotation * pi / 180;
    surface.aspect.left = sin(epsilon) * gmonitor.distance ./ sin(rho) ./ (surface.sizes.left ./ 2);
    
    % Obtain 3d coordinates of each dot
    coord = 1;
    for i = 1 : 4 : 2 * gdots.arraySize^2
        surface.vXYZ.left(1,i) = -surface.sizes.left(coord) / 2 * surface.aspect.left(coord);
        surface.vXYZ.left(1,i + 1) = surface.sizes.left(coord) / 2 * surface.aspect.left(coord);
        surface.vXYZ.left(1,i + 2) = surface.sizes.left(coord) / 2 * surface.aspect.left(coord);
        surface.vXYZ.left(1,i + 3) = -surface.sizes.left(coord) / 2 * surface.aspect.left(coord);
        surface.vXYZ.left(2,i) = -surface.sizes.left(coord) / 2;
        surface.vXYZ.left(2,i + 1) = -surface.sizes.left(coord) / 2;
        surface.vXYZ.left(2,i + 2) = surface.sizes.left(coord) / 2;
        surface.vXYZ.left(2,i + 3) = surface.sizes.left(coord) / 2;
        coord = coord + 1;
    end
    surface.vXYZ.left(3,:) = 0;
    
    % Rotate the surface to account for slant rotation
    surface.vXYZ.rotated.left = rotate3dY(surface.vXYZ.left, -ghinge.front.baseAngle - 0.5 * (180 - ghinge.hingeAngle));
    
    % Move the surface to the correct positions
    coord = 1;
    for i = 1 : 4 : 4 * gdots.arraySize^2 / 2
        [row col] = ind2sub([gdots.arraySize gdots.arraySize /2], coord);
        surface.vXYZ.left(1,i:i + 3) = surface.vXYZ.rotated.left(1,i:i + 3) + surface.positionsAdj.left(row,col,1);
        surface.vXYZ.left(2,i:i + 3) = surface.vXYZ.rotated.left(2,i:i + 3) + surface.positionsAdj.left(row,col,2);
        surface.vXYZ.left(3,i:i + 3) = surface.vXYZ.rotated.left(3,i:i + 3) + surface.positionsAdj.left(row,col,3);
        coord = coord + 1;
    end

    % Reshape into a vector for use by glDrawArrays
    surface.vXYZ.vector.left = reshape(surface.vXYZ.left, 1 , 6 * gdots.arraySize^2);

    % Find (ROUGH) width modulations to deal with monitor rotation
    epsilon = atan(surface.sizes.right ./ 2 ./ gmonitor.distance);
    rho = pi/2 - epsilon + gmonitor.rotation * pi / 180;
    surface.aspect.right = sin(epsilon) * gmonitor.distance ./ sin(rho) ./ (surface.sizes.right ./ 2);
    
    coord = 1;
    for i = 1 : 4 : 2 * gdots.arraySize^2
        surface.vXYZ.right(1,i) = -surface.sizes.right(coord) / 2 .* surface.aspect.right(coord);
        surface.vXYZ.right(1,i + 1) = surface.sizes.right(coord) / 2 * surface.aspect.right(coord);
        surface.vXYZ.right(1,i + 2) = surface.sizes.right(coord) / 2 * surface.aspect.right(coord);
        surface.vXYZ.right(1,i + 3) = -surface.sizes.right(coord) / 2 * surface.aspect.right(coord);
        surface.vXYZ.right(2,i) = -surface.sizes.right(coord) / 2;
        surface.vXYZ.right(2,i + 1) = -surface.sizes.right(coord) / 2;
        surface.vXYZ.right(2,i + 2) = surface.sizes.right(coord) / 2;
        surface.vXYZ.right(2,i + 3) = surface.sizes.right(coord) / 2;
        coord = coord + 1;
    end
    surface.vXYZ.right(3,:) = 0;
    
    surface.vXYZ.rotated.right = rotate3dY(surface.vXYZ.right, -ghinge.front.baseAngle + 0.5 * (180 - ghinge.hingeAngle));
    
    coord = 1;
    for i = 1 : 4 : 4 * gdots.arraySize^2 / 2
        [row col] = ind2sub([gdots.arraySize gdots.arraySize /2], coord);
        surface.vXYZ.right(1,i:i + 3) = surface.vXYZ.rotated.right(1,i:i + 3) + surface.positionsAdj.right(row,col,1);
        surface.vXYZ.right(2,i:i + 3) = surface.vXYZ.rotated.right(2,i:i + 3) + surface.positionsAdj.right(row,col,2);
        surface.vXYZ.right(3,i:i + 3) = surface.vXYZ.rotated.right(3,i:i + 3) + surface.positionsAdj.right(row,col,3);
        coord = coord + 1;
    end
    
    
    surface.vXYZ.vector.right = reshape(surface.vXYZ.right, 1 , 6 * gdots.arraySize^2);
    
%     % Debugging output
%     surface.positionsAdj.left(gdots.arraySize / 2,:,3)
%     surface.positionsAdj.right(gdots.arraySize / 2,:,3)