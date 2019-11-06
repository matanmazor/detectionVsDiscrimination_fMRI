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
        fprintf('participant %s cannot be analyzed because it only has %d usable runs \n',...
            subj{i_s}.scanid, length(relevant_runs));
        continue
    else
        fprintf('participant %s will be analyzed because it has %d usable runs \n',...
            subj{i_s}.scanid, length(relevant_runs));
        SPM102_dir = fullfile(p.stats_dir, 'DM102',['sub-',subj{i_s}.scanid]);
        SPM103_dir = fullfile(p.stats_dir, 'DM103',['sub-',subj{i_s}.scanid]);
        cross102a_dir = fullfile(SPM102_dir,'TDT_TrainDetTestDis_SL');
        cross102b_dir = fullfile(SPM102_dir,'TDT_TrainDisTestDet_SL');
        cross103a_dir = fullfile(SPM103_dir,'TDT_TrainYNTestDis_SL');
        cross103b_dir = fullfile(SPM103_dir,'TDT_TrainDisTestYN_SL');
        dis_dir = fullfile(SPM102_dir,'TDT_dis');
        
        
        if exist(cross102a_dir) ~= 7
            mkdir(cross102a_dir);
        end
        
        if exist(cross102b_dir) ~= 7
            mkdir(cross102b_dir);
        end
        
        if exist(cross103a_dir) ~= 7
            mkdir(cross103a_dir);
        end
        
        if exist(cross103b_dir) ~= 7
            mkdir(cross103b_dir);
        end
        
        
        %%% Train on detection, test on discrimination
        regressor_names = design_from_spm(SPM102_dir);
        cfg = decoding_describe_data(cfg,{'det_high_correct','det_low_correct','dis_high_correct',...
            'dis_low_correct'},[1 -1 1 -1],regressor_names,SPM102_dir,[1 1 2 2]);
        cfg.files.mask = {fullfile(SPM102_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross102a_dir;
        cfg.verbose = 0;
        results1 = decoding(cfg);
        
        
        %%% Train on discrimination, test on detection
        regressor_names = design_from_spm(SPM102_dir);
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct', 'det_high_correct','det_low_correct'},...
            [1 -1 1 -1],regressor_names,SPM102_dir,[1 1 2 2]);
        cfg.files.mask = {fullfile(SPM102_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross102b_dir;
        cfg.verbose = 0;
        results1 = decoding(cfg);
        
        %%% Train on YN, test on discrimination
        regressor_names = design_from_spm(SPM103_dir);
        cfg = decoding_describe_data(cfg,{'det_hit','det_CR','dis_high_correct',...
            'dis_low_correct'},[1 -1 1 -1],regressor_names,SPM103_dir,[1 1 2 2]);
        cfg.files.mask = {fullfile(SPM103_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross103a_dir;
        cfg.verbose = 0;
        results1 = decoding(cfg);
        
        %%% Train on YN, test on discrimination
        regressor_names = design_from_spm(SPM103_dir);
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct','det_hit','det_CR',},[1 -1 1 -1],...
            regressor_names,SPM103_dir,[1 1 2 2]);
        cfg.files.mask = {fullfile(SPM103_dir,'mask.nii')};
        cfg.analysis = 'searchlight';
        cfg.searchlight.radius = 12;
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross103b_dir;
        cfg.verbose = 0;
        results1 = decoding(cfg);
        
        close all
    end
end