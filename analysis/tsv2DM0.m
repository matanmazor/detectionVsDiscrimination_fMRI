function [  ] = tsv2DM0( events_file )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% 1. read table
table = tdfread(events_file,'\t');

%% 2. initialize variables
%     names of regressors
names{1} = 'detection';
onsets{1} = [];
durations{1} = [];


names{2} = 'discrimination';
onsets{2} = [];
durations{2} = [];



%% 3. loop over events
for event = 1:length(table.onset)
    if table.trial_type(event,1)=='Y' 
            onsets{1} = [onsets{1}; table.onset(event,:)];
            durations{1} = [durations{1}; 4];
    elseif table.trial_type(event,1)=='N' 
            onsets{1} = [onsets{1}; table.onset(event,:)];
            durations{1} = [durations{1}; 4];
    elseif table.trial_type(event,1)=='C' 
            onsets{2} = [onsets{2}; table.onset(event,:)];
            durations{2} = [durations{2}; 4];
    elseif table.trial_type(event,1)=='A' 
            onsets{2} = [onsets{2}; table.onset(event,:)];
            durations{2} = [durations{2}; 4];
    end
            
end

filename = [events_file(1:end-11),'_DM0.mat'];
save(filename, 'names','onsets','durations');
end

