function exp = PTBSetup

exp.subject = [];
exp.ipd = [];
exp.subject = [];
exp.type = [];
exp.monitorRotation = [];
exp.subtype = [];
exp.training = [];
exp.vergenceDist = [];
exp.frontAngle = [];

% Get subject initials
while (isempty(exp.subject))
    exp.subject = input('Enter subject''s initials: ','s'); 
end
% Make sure the initials are upper-cased
exp.subject = upper(exp.subject);

display(' ');

% Get subject's ipd
while (isempty(exp.ipd))
    exp.ipd = input('Enter subject''s IPD in mm: '); 
end
% Make sure the initials are upper-cased
exp.ipd = upper(exp.ipd);

display(' ');

% Enter experiment type
exp.type = 0;
while (isempty(exp.type) || (exp.type < 1 || exp.type > 10))
    exp.type = input('Enter experiment type: \n  1 == Single plane\n  2 == Dual planes\n  3 == Converging cameras\n  4 == Simulated head roll\n  5 == Single plane voronoi\n  6 == Single plane voronoi (monocular) \n  7 == Single plane square grid \n  8 == Single plane square grid (monocular) \n  9 == Single plane square grid (stereo, no aperture) \n  10 == Hinge square grid (monocular) \n');
end

display(' ');

% Is this a training session?
if (exp.type ~= 4)
    exp.training = -1;
    while (isempty(exp.training) || (exp.training ~= 0 && exp.training ~= 1))
        exp.training = input('Training? (0 or 1): ');
    end
    display(' ');
else
    exp.training = 0;
end

if (exp.training == 0)
    % Enter monitor rotation
    if (exp.type <= 2 || exp.type >= 5)
        while (isempty(exp.monitorRotation))
            exp.monitorRotation = input('Enter monitor rotation angle (deg): ');
        end
    else
        exp.monitorRotation = 0;
    end

    display(' ');
    
    % Enter the static rotation of the front plane if dual planes will be used
    if (exp.type == 2)
        while (isempty(exp.frontAngle))
            exp.frontAngle = input('Enter rotation for front plane (deg): ');
        end
    else
        exp.frontAngle = 0;
    end

    display(' ');
else
    exp.monitorRotation = 0;
    exp.frontAngle = 0;
end

% Enter camera vergence distance if this is experiment type 3
if (exp.training == 0)
    % Enter monitor rotation
    if (exp.type == 3)
        while (isempty(exp.vergenceDist))
            exp.vergenceDist= input('Enter vergence distance (mm): ');
        end
    else
        exp.vergenceDist = 550;
    end

    display(' ');
else
    exp.vergenceDist = 550;
end

% Enter experiment sub-type (decided starting slant for planar stimulus, etc.)
% Note: The dual-plane experiment does not have sub-types
if (exp.type ~= 2 && exp.training == 0)
    exp.subtype = 'X';
    while (isempty(exp.subtype) || (exp.subtype ~= 'A' && exp.subtype ~= 'B' && exp.subtype ~= 'C' && exp.subtype ~= 'P'))
        exp.subtype = input('Enter experiment sub-type (A, B, or C): ','s');
        exp.subtype = upper(exp.subtype);
        % Allow the user to enter 'P' if it's experiment type 3.
        if (exp.subtype == 'P' && exp.type ~= 3)
            exp.subtype = 'X';
        end  
    end
else
    exp.subtype = 'A';
end
display(' ');

% Move to the PTBHinge directory
%chdir('/Applications/MATLAB74/work/PTBHinge');

% Create directory for this subject
exp.directory = [pwd '/Data/' exp.subject];
[dum1 dum2 dum3] = mkdir(exp.directory);

% Create file
fid = 0;
exp.run = 0;
while (fid ~= -1)
    exp.run = exp.run + 1;
    % Format the run number so it takes up 3 characters
    if (exp.run < 10)
        run_text = ['00' num2str(exp.run)];
    elseif (exp.run < 100)
        run_text = ['0' num2str(exp.run)];
    else
        run_text = num2str(exp.run);
    end
    exp.filename = [exp.directory '/PTBHinge' exp.subject num2str(exp.type) exp.subtype num2str(exp.training) run_text];
    exp.filenametxt = [exp.filename '.txt'];
    exp.filenamemat = [exp.filename '.mat'];
    fid = fopen(exp.filenametxt,'r');
end
exp.fid = fopen(exp.filenametxt,'wt');
display(['Text Filename:  ' exp.filenametxt]);
display(['MAT Filename:  ' exp.filenamemat]);
display('  ');

if exp.training
    display('Set monitor distance and rotation to 550mm and 0 deg.');
    display('  ');  
end


% fclose(fid);  % This is commented out because it should be closed by
% StereoExperiment.m