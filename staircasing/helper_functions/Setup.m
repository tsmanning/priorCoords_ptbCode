function exp = Setup(exp,computer)

if computer == 0
    
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
        
        exp.filename    = [exp.directory '/' exp.subject '_exptype' num2str(exp.type) '_training' num2str(exp.training) run_text];
        exp.filenametxt = [exp.filename '.txt'];
        exp.filenamemat = [exp.filename '.mat'];
        fid = fopen(exp.filenametxt,'r');
        
    end
    
    exp.fid = fopen(exp.filenametxt,'wt');
    display(['Text Filename:  ' exp.filenametxt]);
    display(['MAT Filename:  ' exp.filenamemat]);
    display('  ');
    
else
    
    exp.subject     = [];
    exp.ipd         = [];
    exp.subject     = [];
    exp.type        = [];
    exp.training    = [];
    
    % Get subject initials
    while (isempty(exp.subject))
        exp.subject = input('Enter subject''s initials: ','s');
    end
    
    % Make sure the initials are upper-cased
    exp.subject = upper(exp.subject);
    
    display(' ');
    
    % Enter experiment type
    exp.type = 0;
    while (isempty(exp.type) || (exp.type < 1 || exp.type > 10))
        exp.type = input('Enter experiment type: \n  1 == Contrast discrimination\n  2 == Other\n');
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
    
    display(' ');
    
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
        
        exp.filename = [exp.directory '/' exp.subject '_exptype' num2str(exp.type) '_training' num2str(exp.training) run_text];
        exp.filenametxt = [exp.filename '.txt'];
        exp.filenamemat = [exp.filename '.mat'];
        fid = fopen(exp.filenametxt,'r');
    end
    
    exp.fid = fopen(exp.filenametxt,'wt');
    display(['Text Filename:  ' exp.filenametxt]);
    display(['MAT Filename:  ' exp.filenamemat]);
    display('  ');
    
end
