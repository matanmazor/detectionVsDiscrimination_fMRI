addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

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
        SPM_dir = fullfile(p.stats_dir, 'DM103_unsmoothed',['sub-',subj{i_s}.scanid]);
        YN_dir = fullfile(SPM_dir,'TDT_det_SL');
        dis_dir = fullfile(SPM_dir,'TDT_dis_SL');
        roi_dir = fullfile(p.stats_dir, 'DM101',['sub-',subj{i_s}.scanid], 'TDT');
        
        if exist(YN_dir) ~= 7
            mkdir(YN_dir);
        end
        
         if exist(dis_dir) ~= 7
            mkdir(dis_dir);
        end
        
       
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct'},[1 -1],regressor_names,SPM_dir);
        cfg.files.mask = {fullfile(SPM_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        plot_design(cfg);
        cfg.results.dir = dis_dir;
        vfg.verbose = 0;
        results2 = decoding(cfg);
        close all;
        
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'det_hit',...
            'det_CR'},[1 -1],regressor_names,SPM_dir);
        cfg.files.mask = {fullfile(SPM_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        plot_design(cfg);
        cfg.results.dir = YN_dir;
        vfg.verbose = 0;
        results2 = decoding(cfg);
        close all;
        
    end
end