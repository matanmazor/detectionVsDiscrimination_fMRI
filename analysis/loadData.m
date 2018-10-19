function data_struct = loadData()
% load data from all participants and arrange in a dictionary

data_struct = containers.Map;

% load subject list
load(fullfile('..','experiment','data','subjects.mat'));
subj_list = subjects.keys;

%load data
for i=1:length(subjects.keys) %don't analyze dummy subject 999MaMa
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
            subject_data.DetConf = [];
            subject_data.DisResp = [];
            subject_data.DetResp = [];
            subject_data.DisRT = [];
            subject_data.DetRT = [];
            subject_data.vTask = [];
            subject_data.DetSignal = [];
            subject_data.DisSignal = [];
            
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
                
                subject_data.DisWg = [subject_data.DisWg; params.DisWg];
                subject_data.DetWg = [subject_data.DetWg; params.DetWg];
                
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
            end
            data_struct(subj)=subject_data;
        end
    end
end
end
