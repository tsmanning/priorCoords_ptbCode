function [] = PlotStereoExp(filename)
 
if isempty(filename)
	[filename,pathname,FilterIndex] = uigetfile('*.mat','Select Data Files to Load', ...
		'./_data/','MultiSelect','on')
end
	
for f = 1:length(filename)
	load([pathname filename{f}]);
	keyboard
end
        colors = {'r','k','m','b','c'};
        
        
        figure; hold on;
        
        scnt2 = 1;
        
        for p = 1:length(dat.pedestalsPix)
            
            for d = 1:length(dat.dispSign)
                
                title(['pdstl = ' num2str(dat.pedestalsPix(p)) 'disp = ' num2str(dat.disp{dat.dispSign == dat.dispSign(d)})]);
                for c = 1:length(dat.conditions)
                    
                    for s = 1:length(dat.stepsPix)
                        
                        % percent of time probe = closer
                        total_trials = length(dat.trials.mat(dat.trials.mat(:,3) == dat.conditions(c) & dat.trials.mat(:,8) == dat.pedestalsPix(p) & dat.trials.mat(:,2) == dat.dispSign(d) & dat.trials.mat(:,5) == dat.stepsPix(s),7));
                        total_yes = sum(dat.trials.mat(dat.trials.mat(:,3) == dat.conditions(c) & dat.trials.mat(:,8) == dat.pedestalsPix(p) & dat.trials.mat(:,2) == dat.dispSign(d) & dat.trials.mat(:,5) == dat.stepsPix(s),7));
                        
                        %plot(dat.stepsPix(d),total_yes/total_trials,[colors{c} 'o'])
                        
                        dat.pmat(s,1) = -dat.stepsPix(s);
                        dat.pmat(s,2) = total_yes;
                        dat.pmat(s,3) = total_trials;
                        
                    end
                    
                    priors.m_or_a = 'None';
                    priors.w_or_b = 'None';
                    priors.lambda = 'Uniform(0,.1)';
                    priors.gamma  = 'Uniform(0,.1)';
                    dat.presults = BootstrapInference(dat.pmat,priors,'nafc',1,'gammaislambda');
                    
                    %dat.presults = BootstrapInference(dat.pmat,'gammaislambda');
                    %dat.presults = MapEstimate(dat.pmat);
                    plotPMF(dat.presults,'color',colors{c}); hold on;
                    h(c) = plot(0,0,colors{c});
                    lh{c} = dat.conditiontypes{dat.conditions(c)};
         
                end
                legend(h,lh)
                scnt2 = scnt2 + 1;
                
            end
		end
		
