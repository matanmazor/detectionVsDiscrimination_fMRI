function data_struct = loadData(reverse_correlation)
% load data from all participants and arrange in a dictionary

if nargin==0
    reverse_correlation=0;
end

data_struct = containers.Map;

% load subject list
load(fullfile('..','experiment','data','subjects.mat'));
subj_list = subjects.keys;

%load stimulus pattern
load('pattern.mat');
load('CW_pattern.mat');
load('CCW_pattern.mat');

%load data
for i=1:length(subj_list) %don't analyze dummy subject 999MaMa
    subj = subj_list{i};
    if str2num(subj(1:2))<95
        subj_files = dir(fullfile('..','experiment','data',[subj,'_session*.mat']));
        if ~isempty(subj_files)
            subject_data.DisWg = [];
            subject_data.DetWg = [];
            subject_data.DisDir = [];
            subject_data.DetDir = [];
            subject_data.DisCorrect = [];
            subject_data.DetCorrect = [];
            subject_data.DisConf = [];
            subject_data.DisConfInc = []; %increase confidence presses
            subject_data.DisConfDec = []; %decrease confidence presses
            subject_data.DetConf = [];
            subject_data.DetConfInc = [];
            subject_data.DetConfDec = [];           
            subject_data.DisResp = [];
            subject_data.DetResp = [];
            subject_data.DisRT = [];
            subject_data.DetRT = [];
            subject_data.vTask = [];
            subject_data.DetSignal = [];
            subject_data.DisSignal = [];
            subject_data.DetPatternFit = [];
            subject_data.DisCWFit = [];
            subject_data.DisCCWFit = [];
            subject_data.DetCWFit = [];
            subject_data.DetCCWFit = [];
            
            
            for j = 1:length(subj_files)
                load(fullfile('..','experiment','data',subj_files(j).name));
                
                %to deal with sessions that were interrupted before 600 trials:
                num_trials = length(log.resp);
                num_blocks = num_trials/params.trialsPerBlock;
                log.confidence = log.confidence(1:num_trials);
                log.resp = log.resp(1:num_trials,:);
                log.detection = log.detection(1:num_trials,:);
                log.correct = log.correct(1:num_trials,:);
                log.Wg = log.Wg(1:num_trials);
                params.vTask = params.vTask(1:num_blocks);
                trial_events = find(log.events(:,1)==0);
                if not(length(trial_events)==80)
                    error(sprintf('wrong number of events %d',...
                        length(trial_events)))
                end
                trial_events(81) = length(log.events)+1;
                [up_count, down_count] = deal(nan(80,1));
                for i_t = 1:80
                    up_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-55)<eps);
                    down_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-54)<eps);
                end
                if params.conf_mapping==2
                    inc_count = up_count; 
                    dec_count = down_count;
                else
                    inc_count = down_count;
                    dec_count = up_count;
                end
                
                subject_data.DisWg = [subject_data.DisWg; log.Wg(log.detection==0)];
                subject_data.DetWg = [subject_data.DetWg; log.Wg(log.detection==1)];
                
                % load trial-wise accuracy vectors (100 trials constitute one
                % block, 3 blocks constitute one session)
                subject_data.DisCorrect = [subject_data.DisCorrect; ...
                    log.correct(log.detection==0)];
                subject_data.DetCorrect = [subject_data.DetCorrect; ...
                    log.correct(log.detection==1)];
                
                % load confidence reports (same structure)
                subject_data.DisConf = [subject_data.DisConf; ...
                    log.confidence(log.detection==0)];
                subject_data.DetConf = [subject_data.DetConf; ...
                    log.confidence(log.detection==1)];
                subject_data.DisConfInc = [subject_data.DisConfInc; ...
                    inc_count(log.detection==0)];
                subject_data.DetConfInc = [subject_data.DetConfInc; ...
                    inc_count(log.detection==1)];     
                subject_data.DisConfDec = [subject_data.DisConfDec; ...
                    dec_count(log.detection==0)];
                subject_data.DetConfDec = [subject_data.DetConfDec; ...
                    dec_count(log.detection==1)]; 
                
                % load confidence reports (same structure)
                subject_data.DisDir = [subject_data.DisDir; ...
                    log.direction(log.detection==0)'];
                subject_data.DetDir = [subject_data.DetDir; ...
                    log.direction(log.detection==1)'];
                
                % load responses
                subject_data.DisResp = [subject_data.DisResp; ...
                    (log.resp(log.detection==0,2)-1)/2];
                subject_data.DetResp = [subject_data.DetResp; ...
                    log.resp(log.detection==1,2)];
                
                %load RTs
                subject_data.DisRT = [subject_data.DisRT; log.resp(log.detection==0,1)];
                subject_data.DetRT = [subject_data.DetRT; log.resp(log.detection==1,1)];
                
                %load task order vector. 1 for detection, 0 for discrimination
                subject_data.vTask = [subject_data.vTask; params.vTask];
                
                %load trial order vector
                subject_data.DetSignal = [subject_data.DetSignal;
                    log.Wg(log.detection==1)>0];
                subject_data.DisSignal = [subject_data.DisSignal;
                    log.direction(log.detection==0)'==3];
                
                %compute bonus
                subject_data.bonus = ((subject_data.DetCorrect(find(~isnan(subject_data.DetConf)))-0.5)'...
                    *subject_data.DetConf(find(~isnan(subject_data.DetConf)))+...
                (subject_data.DisCorrect(find(~isnan(subject_data.DisConf)))-0.5)'...
                *subject_data.DisConf(find(~isnan(subject_data.DisConf))))/100;
            
           if reverse_correlation %compute fit to stimulus pattern
                for i_t = 1:80
                    stim = log.xymatrix{i_t};
                    stim(~params.circleFilter) = mean(stim(params.circleFilter));
                    if log.detection(i_t)
                        subject_data.DetPatternFit(end+1) = ...
                            corr(pattern(params.circleFilter), stim(params.circleFilter));
                        subject_data.DetCWFit(end+1,:) = bandpower(stim',1,[1/24-eps,1/24+eps]);
                        subject_data.DetCCWFit(end+1,:) = bandpower(stim,1,[1/24-eps,1/24+eps]);
                    else
                        subject_data.DisCWFit(end+1,:) = bandpower(stim',1,[1/24-eps,1/24+eps]);
                        subject_data.DisCCWFit(end+1,:) = bandpower(stim,1,[1/24-eps,1/24+eps]);
                    end
                end
           end
            data_struct(subj)=subject_data;
        end
    end
end
end
