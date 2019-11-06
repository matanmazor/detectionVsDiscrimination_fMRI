addpath(project_params.spm_dir);
ROI_names = {'union_FPl','union_FPm','union_46','ventralStriatum',...
    'vmPFC_roi','precun_roi','pMFC_roi','ventricles_roi'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

group_accuracy_cross1 = nan(numel(ROI_names),46);
group_accuracy_cross2 = nan(numel(ROI_names),46);

for i_s = 1:46
    
    %only analyze participants with 4 or 5 usable runs
    %check which runs are relevant
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    relevant_runs = find(exclusion_file==0 & conf_exclusion_file==0);
    
    if length(relevant_runs)<4
        fprintf('participant %s cannot be analyzed because it only has %d usable runs \n',...
            subj{i_s}.scanid, length(relevant_runs));
        continue
    else
        fprintf('participant %s will be analyzed because it has %d usable runs \n',...
            subj{i_s}.scanid, length(relevant_runs));
        fprintf('This is participant number %d for this analysis \n', sum(~isnan(group_accuracy_cross1(1,:)))+1);
        SPM_dir = fullfile(p.stats_dir, 'DM102_unsmoothed',['sub-',subj{i_s}.scanid]);
        cross1_dir = fullfile(SPM_dir,'TDT_TrainDetTestDis');
        cross2_dir = fullfile(SPM_dir,'TDT_TrainDisTestDet');
        dis_dir = fullfile(SPM_dir,'TDT_dis');
        roi_dir = fullfile(p.stats_dir, 'DM101',['sub-',subj{i_s}.scanid], 'TDT');
        
        if exist(cross1_dir) ~= 7
            mkdir(cross1_dir);
        end
        
        if exist(cross2_dir) ~= 7
            mkdir(cross2_dir);
        end
        
        ROIs = {};
        for i_mask = 1:length(ROI_names)
            ROI_name = ROI_names{i_mask};
            ROIs{i_mask} = fullfile(dis_dir,[ROI_name,'.nii']);
        end
       
        %%% Train on detection, test on discrimination
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'det_high_correct','det_low_correct','dis_high_correct',...
            'dis_low_correct'},[1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross1_dir;
        cfg.verbose = 0;
        results1 = decoding(cfg);
        
        group_accuracy_cross1(:,i_s) = results1.accuracy_minus_chance.output;
        results1.accuracy_minus_chance.output'
        
        %%%% Train on discrimination, test on detection
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct', 'det_high_correct','det_low_correct',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross2_dir;
        cfg.verbose = 0;
        results2 = decoding(cfg);
        
        group_accuracy_cross2(:,i_s) = results2.accuracy_minus_chance.output;
        results2.accuracy_minus_chance.output'
        
        close all
    end
end