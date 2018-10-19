function [  ] = tsv2DM2( events_file )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% 1. read table
table = tdfread(events_file,'\t');

%% 2. initialize variables
%     names of regressors
names{1} = 'CW_CW';
onsets{1} = [];
durations{1} = [];
pmod(1).name{1} = 'confidence';
pmod(1).param{1} = [];

names{2} = 'CW_CCW';
onsets{2} = [];
durations{2} = [];
pmod(2).name{1} = 'confidence';
pmod(2).param{1} = [];

names{3} = 'CCW_CW';
onsets{3} = [];
durations{3} = [];
pmod(3).name{1} = 'confidence';
pmod(3).param{1} = [];

names{4} = 'CCW_CCW';
onsets{4} = [];
durations{4} = [];
pmod(4).name{1} = 'confidence';
pmod(4).param{1} = [];

names{5} = 'Y_Y';
onsets{5} = [];
durations{5} = [];
pmod(5).name{1} = 'confidence';
pmod(5).param{1} = [];

names{6} = 'Y_N';
onsets{6} = [];
durations{6} = [];
pmod(6).name{1} = 'confidence';
pmod(6).param{1} = [];

names{7} = 'N_Y';
onsets{7} = [];
durations{7} = [];
pmod(7).name{1} = 'confidence';
pmod(7).param{1} = [];

names{8} = 'N_N';
onsets{8} = [];
durations{2} = [];
pmod(8).name{1} = 'confidence';
pmod(8).param{1} = [];

names{9} = 'index_finger_press';
onsets{9} = [];
durations{9} = [];

names{10} = 'middle_finger_press';
onsets{10} = [];
durations{10} = [];

names{11} = 'upper_thumb_press';
onsets{11} = [];
durations{11} = [];

names{12} = 'lower_thumb_press';
onsets{12} = [];
durations{12} = [];

%% 3. loop over events
for event = 1:length(table.onset)
    if strcmp(table.trial_type(event,1:2),'CC') %CW_CW
            onsets{1} = [onsets{1}; table.onset(event,:)];
            durations{1} = [durations{1}; 4];
            pmod(1).param{1} = [pmod(1).param{1}; str2num(table.confidence(event,:))];
            pmod(1).poly{1} = 1;
    elseif strcmp(table.trial_type(event,1:2),'CA') %CW_CCW
            onsets{2} = [onsets{2}; table.onset(event,:)];
            durations{2} = [durations{2}; 4];
            pmod(2).param{1} = [pmod(2).param{1}; str2num(table.confidence(event,:))];
            pmod(2).poly{1} = 1;
    elseif strcmp(table.trial_type(event,1:2),'AC') %CCW_CW
            onsets{3} = [onsets{3}; table.onset(event,:)];
            durations{3} = [durations{3}; 4];
            pmod(3).param{1} = [pmod(3).param{1}; str2num(table.confidence(event,:))];
            pmod(3).poly{1} = 1;
    elseif strcmp(table.trial_type(event,1:2),'AA') %CCW_CCW
            onsets{4} = [onsets{4}; table.onset(event,:)];
            durations{4} = [durations{4}; 4];
            pmod(4).param{1} = [pmod(4).param{1}; str2num(table.confidence(event,:))];
            pmod(4).poly{1} = 1;
    elseif strcmp(table.trial_type(event,1:2),'YY') %Yes_Yes
            onsets{5} = [onsets{5}; table.onset(event,:)];
            durations{5} = [durations{5}; 4];
            pmod(5).param{1} = [pmod(5).param{1}; str2num(table.confidence(event,:))];
            pmod(5).poly{1} = 1;
    elseif strcmp(table.trial_type(event,1:2),'YN') %Yes_No
            onsets{6} = [onsets{6}; table.onset(event,:)];
            durations{6} = [durations{6}; 4];
            pmod(6).param{1} = [pmod(6).param{1}; str2num(table.confidence(event,:))];
            pmod(6).poly{1} = 1;
     elseif strcmp(table.trial_type(event,1:2),'NY') %No_Yes
            onsets{7} = [onsets{7}; table.onset(event,:)];
            durations{7} = [durations{7}; 4];
            pmod(7).param{1} = [pmod(7).param{1}; str2num(table.confidence(event,:))];
            pmod(7).poly{1} = 1;
     elseif strcmp(table.trial_type(event,1:2),'NN') %No_No
            onsets{8} = [onsets{8}; table.onset(event,:)];
            durations{8} = [durations{8}; 4];
            pmod(8).param{1} = [pmod(8).param{1}; str2num(table.confidence(event,:))];
            pmod(8).poly{1} = 1;
    elseif table.trial_type(event,:)=='button press'
        if str2num(table.key_id(event,:))==50 %index finger
            onsets{9} = [onsets{9}; table.onset(event,:)];
            durations{9} = [durations{9}; 0];
        elseif str2num(table.key_id(event,:))==51 %middle finger
            onsets{10} = [onsets{10}; table.onset(event,:)];
            durations{10} = [durations{10}; 0];
        elseif str2num(table.key_id(event,:))==54 %upper thumb
            onsets{11} = [onsets{11}; table.onset(event,:)];
            durations{11} = [durations{11}; 0];
        elseif str2num(table.key_id(event,:))==55 %lower thumb
            onsets{12} = [onsets{12}; table.onset(event,:)];
            durations{12} = [durations{12}; 0];
        end     
    elseif strcmp(strtrim(table.trial_type(event,:)),'missed_trial')
            if length(onsets)==12
                names{13} = 'missed_trials';
                onsets{13} = [];
                durations{13} = [];
            end
            onsets{13} = [onsets{13}; table.onset(event,:)];
            durations{13} = [durations{13}; 4];
    end
end

%center confidence ratings
for i=1:8
    pmod(i).param{1} = pmod(i).param{1}-mean(pmod(i).param{1});
end

names{end+1} = 'instructions';
onsets{end+1} = [0, table.onset(40)+5];
durations{end+1} = [5,5];

filename = [events_file(1:end-11),'_DM2.mat'];
save(filename, 'names','onsets','pmod','durations');

end

