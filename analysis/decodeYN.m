addpath(project_params.spm_dir);
ROI_names = {'union_FPl','union_FPm','union_46','ventralStriatum',...
    'vmPFC_roi','precun_roi','pMFC_roi','ventricles_roi'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

group_accuracy_YN = nan(numel(ROI_names),46);
group_accuracy_discrimination = nan(numel(ROI_names),46);

for i_s = 1:46;
    
    %only analyze participants with 4 or 5 usable runs
    %check which runs are relevant
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    relevant_runs = find(exclusion_file==0 & conf_exclusion_file==0);
    
    if length(relevant_runs)<4
        fprintf('participant %s cannot be analyzed because it only has %d usable runs',...
            subj{i_s}.scanid, length(relevant_runs));
        continue
    else
        fprintf('participant %s will be analyzed because it has %d usable runs',...
            subj{i_s}.scanid, length(relevant_runs));
        fprintf('This is participant number %d for this analysis', sum(~isnan(group_accuracy_YN(1,:)))+1);
        SPM_dir = fullfile(p.stats_dir, 'DM103_unsmoothed',['sub-',subj{i_s}.scanid]);
        YN_dir = fullfile(SPM_dir,'TDT_det');
        dis_dir = fullfile(SPM_dir,'TDT_dis');
        roi_dir = fullfile(p.stats_dir, 'DM101',['sub-',subj{i_s}.scanid], 'TDT');
        
        if exist(YN_dir) ~= 7
            mkdir(YN_dir);
        end
        
         if exist(dis_dir) ~= 7
            mkdir(dis_dir);
        end
        
        % reslice masks
        ROIs = {};
        for i_mask = 1:length(ROI_names)
            ROI_name = ROI_names{i_mask};
            if ~exist(fullfile(dis_dir,[ROI_name,'.nii']))
              copyfile(fullfile(roi_dir,[ROI_name,'.nii']),fullfile(dis_dir,[ROI_name,'.nii']));
            end
            ROIs{i_mask} = fullfile(dis_dir,[ROI_name,'.nii']);
        end
        
        cfg = decoding_defaults;
        cfg.files.mask = ROIs;
        cfg.results.overwrite = 1;
        cfg.verbose = 0;
        
        dis_results = decoding_example('ROI','dis_high_correct','dis_low_correct',...
            SPM_dir,...
            dis_dir,...
            [],cfg);
        
        group_accuracy_discrimination(:,i_s) = dis_results.accuracy_minus_chance.output;
        dis_results.accuracy_minus_chance.output'
        
        YN_results = decoding_example('ROI','det_hit','det_CR',...
            SPM_dir,...
            YN_dir,...
            [],cfg);
        
        group_accuracy_YN(:,i_s) = YN_results.accuracy_minus_chance.output;
        YN_results.accuracy_minus_chance.output'
    end
    close all;
end