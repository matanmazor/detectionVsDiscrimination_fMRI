clear all
clc;
close all;

subject_list = dir('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\data\sub-*');
subject_list = subject_list(3:end);

for s = 1:length(subject_list)
    
    event_files = dir(fullfile...
        ('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\data',...
        subject_list(s).name,'func','*.tsv'));
    
    for f = 1:length(event_files)
        
        cur_file = fullfile(...
        'D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\data',...
        subject_list(s).name,'func',event_files(f).name);
    
        tsv2DM0(cur_file);
        tsv2DM1(cur_file);
        tsv2DM2(cur_file);
        
        if ~exist(fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data',...
            subject_list(s).name,'DM'),'dir');
        
            mkdir(fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data',...
            subject_list(s).name,'DM'))
        
        end
        
       movefile([cur_file(1:end-11),'_DM0.mat'],...
            fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data',...
            subject_list(s).name,'DM',['run-',num2str(f),'_DM0.mat']))
        
       movefile([cur_file(1:end-11),'_DM1.mat'],...
            fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data',...
            subject_list(s).name,'DM',['run-',num2str(f),'_DM1.mat']));
        
        movefile([cur_file(1:end-11),'_DM2.mat'],...
            fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data',...
            subject_list(s).name,'DM',['run-',num2str(f),'_DM2.mat']));        
    end
end
