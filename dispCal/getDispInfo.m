function [dispName,dotPitch,viewDist] = getDispInfo()

% Prompts user for information about display to feed into stimulus
% functions.
%
% Usage = [] = getDispInfo()

newDispYN = questdlg('Have you previously saved specs about your monitor(s)?','You got that mat file?','Yes','No','No');

scriptDir = which('getDispInfo');
splitDir = regexp(scriptDir,['\',filesep],'split');
if IsLinux || ismac
    % For when the base level dir is '/' - regexp returns empty first cell
    infoDir = [filesep,fullfile(splitDir{2:end-2}),filesep,'dispInfo',filesep];

elseif IsWindows
    % Windows starts with C:,D:,etc so don't throw away first string
    infoDir = [fullfile(splitDir{1:end-2}),filesep,'dispInfo',filesep];
    
end

if exist(infoDir,'dir') == 0
    mkdir(infoDir);
end
                 
switch newDispYN
    case 'Yes'
        cd(infoDir);
        file_name = ...
            uigetfile({'*.mat','MAT-files (*.mat)'},'Select display info file');
        
        % Grab just the bit before the underscore
        splitStr = regexp(file_name,'\_','split');
        
        dispName = splitStr{1};
%         cd(scriptDir);

        load([infoDir,dispName,'_dispInfo']);
        
        
    case 'No'
        % Prompt experimenter for display info
        numDisps = questdlg('Do you want to present stimuli on one or two displays?','How many displays?','One','Two','Two');
        
        switch numDisps
            case 'One'
                prompt   = {'Name for display (no spaces):','Pixel Pitch (mm):',...
                    'Monitor Viewing Distance (m):'};
                dlgtitle = 'Display information';
                dims     = [1 35];
                definput = {'My monitor','0.25','1.0'};
                dispInfo = inputdlg(prompt,dlgtitle,dims,definput);
                
                dispName = dispInfo{1};
                dotPitch = str2double(dispInfo{2})*0.001*[1;1];
                viewDist = str2double(dispInfo{3})*[1;1];
                
            case 'Two'
                prompt   = {'Name for display setup (no spaces):',...
                            'Pixel Pitch (Disp. 1, mm):',...
                            'Pixel Pitch (Disp. 2, mm):',...
                            'Monitor Viewing Distance (Disp. 1, m):',...
                            'Monitor Viewing Distance (Disp. 2, m):'};
                dlgtitle = 'Display information';
                dims     = [1 35];
                definput = {'My monitor','0.25','0.25','1.0','1.0'};
                dispInfo = inputdlg(prompt,dlgtitle,dims,definput); 
                
                dispName = dispInfo{1};
                dotPitch = [str2double(dispInfo{2});str2double(dispInfo{3})]*0.001;
                viewDist = [str2double(dispInfo{4});str2double(dispInfo{5})];
                
        end
        
        save([infoDir,dispInfo{1},'_dispInfo'],'dispName','dotPitch','viewDist');
        
    case 'Cancel'
        error('User canceled correction routine');
        
end

end
