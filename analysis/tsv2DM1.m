function [  ] = tsv2DM1( events_file )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% 1. read table
table = tdfread(events_file,'\t');

%% 2. initialize variables
%     names of regressors
names{1} = 'correct_trial';
onsets{1} = [];
durations{1} = [];
pmod(1).name{1} = 'confidence';
pmod(1).param{1} = [];

names{2} = 'incorrect_trial';
onsets{2} = [];
durations{2} = [];
pmod(2).name{1} = 'confidence';
pmod(2).param{1} = [];

names{3} = 'index_finger_press';
onsets{3} = [];
durations{3} = [];

names{4} = 'middle_finger_press';
onsets{4} = [];
durations{4} = [];

names{5} = 'upper_thumb_press';
onsets{5} = [];
durations{5} = [];

names{6} = 'lower_thumb_press';
onsets{6} = [];
durations{6} = [];


%% 3. loop over events
for event = 1:length(table.onset)
    if table.trial_type(event,:)=='button press'
        if str2num(table.key_id(event,:))==50 %middle finger
            onsets{3} = [onsets{3}; table.onset(event,:)];
            durations{3} = [durations{3}; 0];
        elseif str2num(table.key_id(event,:))==51 %index finger
            onsets{4} = [onsets{4}; table.onset(event,:)];
            durations{4} = [durations{4}; 0];
        elseif str2num(table.key_id(event,:))==54 %upper thumb
            onsets{5} = [onsets{5}; table.onset(event,:)];
            durations{5} = [durations{5}; 0];
        elseif str2num(table.key_id(event,:))==55 %lower thumb
            onsets{6} = [onsets{6}; table.onset(event,:)];
            durations{6} = [durations{6}; 0];
        end
    elseif table.trial_type(event,1)==table.trial_type(event,2) %correct trial
            onsets{1} = [onsets{1}; table.onset(event,:)];
            durations{1} = [durations{1}; 4];
            pmod(1).param{1} = [pmod(1).param{1}; str2num(table.confidence(event,:))];
            pmod(1).poly{1} = 1;
    elseif strcmp(strtrim(table.trial_type(event,:)),'missed_trial')
            if length(onsets)==6
                names{7} = 'missed_trials';
                onsets{7} = [];
                durations{7} = [];
            end
            onsets{7} = [onsets{7}; table.onset(event,:)];
            durations{7} = [durations{7}; 4];
    else %incorrect trial
            onsets{2} = [onsets{2}; table.onset(event,:)];
            durations{2} = [durations{2}; 4];
            pmod(2).param{1} = [pmod(2).param{1}; str2num(table.confidence(event,:))];
            pmod(2).poly{1} = 1;
    end
end
pmod(1).poly{1} = pmod(1).poly{1}-mean(pmod(1).poly{1});
pmod(2).poly{1} = pmod(2).poly{1}-mean(pmod(2).poly{1});

filename = [events_file(1:end-11),'_DM1.mat'];
save(filename, 'names','onsets','pmod','durations');
end

