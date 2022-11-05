function s = LoadScreenInfo(scr)

if isempty(scr)
    scr = 'laptop';
end

if strcmp(scr,'laptop')
    
    s.viewDistCm      = 57;
    
    s.screenWidthCm     = 33.2;
    s.screenHeightCm    = 20.7;
    
    s.Gamma             = 2.2;

end

