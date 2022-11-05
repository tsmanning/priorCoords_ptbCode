function [] = PlotStereoExp(pathname,filename)

if isempty(pathname)
	[filename,pathname,FilterIndex] = uigetfile('*.mat','Select Data Files to Load', ...
		'./_data/','MultiSelect','on')
end

trials = [];
conditions = {};
if iscellstr(filename)
	lf = length(filename);
else
	lf = 1;
end

for f = 1:lf
	if lf > 1
		display(filename{f});
		load([pathname filename{f}]);
	else
		display(filename);
		load([pathname filename]);
	end
	
	dat.stepSizesAm
	
	%store trial info
	
	trialstmp = dat.trials.mat;
	
	%remove repeat values
	dat.stepsPix = unique(dat.stepsPix);
	dat.stepsArcmin = unique(dat.stepsArcmin);
	
	%store disparities as arcmin
	%hack to fix haplo disparity sign
	if strcmp(dat.display,'OLEDhaplo');
		disptmp = repmat(-dat.stepsArcmin,size(trialstmp,1),1)';
	else
		disptmp = repmat(dat.stepsArcmin,size(trialstmp,1),1)';
	end
	disps = disptmp(repmat(dat.stepsPix,size(trialstmp,1),1)' == repmat(trialstmp(:,5),1,size(dat.stepsPix,2))');
	trialstmp(:,5) = disps;
	
	%store pedestals as arcmin
	if strcmp(dat.display,'OLEDhaplo');
		pedtmp = repmat(-dat.pedestalsArcmin,size(trialstmp,1),1)';
	else
		pedtmp = repmat(dat.pedestalsArcmin,size(trialstmp,1),1)';
	end
	peds = pedtmp(repmat(dat.pedestalsPix,size(trialstmp,1),1)' == repmat(trialstmp(:,8),1,size(dat.pedestalsPix,2))');
	trialstmp(:,8) = peds;
	
	trials = [trials ; trialstmp];
	
	%store condition names
	condstmp = {dat.conditiontypes{dat.trials.mat(:,3)}};
	conditions = [conditions condstmp];
	
	if(0)
	if f > 1
		dat.trials = [];
		[df, match, er1, er2] = comp_struct(dat,datold,0);
		display(er1)
	else
		dat.trials = [];
		datold = dat;
	end
	end
	
end

all.trials = trials;
all.conditions = [conditions];
all.conditionTypes = unique(all.conditions);
all.pedestals = unique(all.trials(:,8));
all.dispSign = unique(all.trials(:,2));
all.conditionNums = unique(all.trials(:,3));
all.steps = unique(all.trials(:,5));

colors = {'r','k','m','b','c'};


figure; hold on;

scnt2 = 1;

for p = 1:length(all.pedestals)
	
	subplot(2,2,p); hold on;
	for d = 1:length(all.dispSign)
		
		title(['pdstl = ' num2str(all.pedestals(p)) ' arcmin' ]);
		
		for c = 1:length(all.conditionNums)
			
			for s = 1:length(all.steps)
				
				% percent of time probe = closer
				total_trials = length(all.trials(all.trials(:,3) == all.conditionNums(c) & ...
					all.trials(:,8) == all.pedestals(p) & ...
					all.trials(:,2) == all.dispSign(d) & ...
					all.trials(:,5) == all.steps(s),7));
				total_yes = sum(all.trials(all.trials(:,3) == all.conditionNums(c) & ...
					all.trials(:,8) == all.pedestals(p) & ...
					all.trials(:,2) == all.dispSign(d) & ...
					all.trials(:,5) == all.steps(s),7));
				
				%plot(dat.stepsPix(d),total_yes/total_trials,[colors{c} 'o'])
				
				all.pmat(s,1) = all.steps(s);
				all.pmat(s,2) = total_yes;
				all.pmat(s,3) = total_trials;
				
			end
			
			
			
			priors.m_or_a = 'None';
			priors.w_or_b = 'None';
			priors.lambda = 'Uniform(0,.1)';
			priors.gamma  = 'Uniform(0,.1)';
			%priors.lambda = 'None';
			%priors.gamma  = 'None';
			
			
			if length(unique(all.pmat(:,1))) > 1
				dat.presults = BootstrapInference(all.pmat,priors,'nafc',1,'samples',200,'gammaislambda');
				plotPMF(dat.presults,'color',colors{c}); hold on;
			end
			scatter(all.pmat(:,1),all.pmat(:,2)./all.pmat(:,3),all.pmat(:,3).*10,colors{c},'filled');
			h(c) = plot(0,0,colors{c});
			lh{c} = all.conditionTypes{c};
			
		end
		
		
		
		legend(h,lh)
		scnt2 = scnt2 + 1;
		
	end
end

