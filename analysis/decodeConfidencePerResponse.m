addpath(project_params.spm_dir);
ROI_names = {'union_FPl','union_FPm','union_46','ventralStriatum',...
    'vmPFC_roi','precun_roi','pMFC_roi','ventricles_roi'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

[group_accuracy_A,group_accuracy_C,group_accuracy_Y,group_accuracy_N,...
    group_accuracy_AC, group_accuracy_CA, group_accuracy_YN, group_accuracy_NY] =...
    deal(nan(numel(ROI_names),46));

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
        fprintf('This is participant number %d for this analysis', sum(~isnan(group_accuracy_A(1,:)))+1);
        SPM_dir = fullfile(p.stats_dir, 'DM104_unsmoothed',['sub-',subj{i_s}.scanid]);
        roi_dir = fullfile(p.stats_dir, 'DM101',['sub-',subj{i_s}.scanid], 'TDT');
        
        
        % reslice masks
        ROIs = {};
        for i_mask = 1:length(ROI_names)
            ROI_name = ROI_names{i_mask};
            if ~exist(fullfile(A_dir,[ROI_name,'.nii']))
                copyfile(fullfile(roi_dir,[ROI_name,'.nii']),fullfile(A_dir,[ROI_name,'.nii']));
            end
            ROIs{i_mask} = fullfile(A_dir,[ROI_name,'.nii']);
        end
        
        responses = {'A','C','Y','N'};
        
        for i_r = 1:4
            
            response = responses{i_r};
            
            resp_dir = fullfile(SPM_dir,strcat('TDT_',response));
            
            cfg = decoding_defaults;
            
            regressor_names = design_from_spm(SPM_dir);
            
            cfg = decoding_describe_data(cfg,{strcat(response,'_high_correct'),...
                strcat(response,'_low_correct')},[1 -1],regressor_names,SPM_dir);
            
            cfg.files.mask = ROIs;
            
            cfg.analysis = 'ROI';
            
            cfg.results.overwrite = 1;
            
            cfg.design = make_design_cv(cfg);
            
            cfg.results.output = {'accuracy_minus_chance', ...
                'sensitivity','specificity','AUC_minus_chance'};
            
            cfg.results.dir = resp_dir;
            
            vfg.verbose = 0;
            
            try 
                [results,cfg] = decoding(cfg);
                switch response
                case 'A'
                 group_accuracy_A(:,i_s) = results.accuracy_minus_chance.output;
                case 'C'
                 group_accuracy_C(:,i_s) = results.accuracy_minus_chance.output;
                case 'Y'
                 group_accuracy_Y(:,i_s) = results.accuracy_minus_chance.output;
                case 'N'
                 group_accuracy_N(:,i_s) = results.accuracy_minus_chance.output;
            end
            catch fprintf('unbalanced training data')
            end
            
            close all;
            %         cfg.design = make_design_permutation(cfg,1000,1);
            %         [reference,cfg]=decoding(cfg);
            %         cfg.stats.test = 'permutation';
            %         cfg.stats.tail = 'right';
            %         cfg.stats.output = 'accuracy_minus_chance';
            %         p_values = decoding_statistics(cfg,results,reference);
            %         p_values(p_values == 1) = (cfg.design.n_sets*2-1)/(cfg.design.n_sets*2);
            
            

        end

        %%%% Train on Y, test on N
        cfg = decoding_describe_data(cfg,{'Y_high_correct',...
            'Y_low_correct', 'N_high_correct','N_low_correct',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = fullfile(SPM_dir,strcat('TDT_','TrainYTestN'));
        cfg.verbose = 0;
        try
            results = decoding(cfg);
            group_accuracy_YN(:,i_s) = results.accuracy_minus_chance.output;
            results.accuracy_minus_chance.output'
        catch continue
        end 
        close all
        
        
        %%%% Train on N, test on Y
        cfg = decoding_describe_data(cfg,{'N_high_correct',...
            'N_low_correct', 'Y_high_correct','Y_low_correct',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        cfg.results.dir = fullfile(SPM_dir,strcat('TDT_','TrainNTestY'));
        cfg.verbose = 0;
        try
            results = decoding(cfg);
            group_accuracy_NY(:,i_s) = results.accuracy_minus_chance.output;
            results.accuracy_minus_chance.output'
        catch continue
        end
        
        close all
        
        %%%% Train on A, test on C
        cfg = decoding_describe_data(cfg,{'A_high_correct',...
            'A_low_correct', 'C_high_correct','C_low_correct',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        cfg.results.dir = fullfile(SPM_dir,strcat('TDT_','TrainATestC'));
        cfg.verbose = 0;
        try
            results = decoding(cfg);
            group_accuracy_AC(:,i_s) = results.accuracy_minus_chance.output;
            results.accuracy_minus_chance.output'
        catch continue
        end
        
        close all
        
        %%%% Train on C, test on A
        cfg = decoding_describe_data(cfg,{'C_high_correct',...
            'C_low_correct', 'A_high_correct','A_low_correct',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        cfg.results.dir = fullfile(SPM_dir,strcat('TDT_','TrainCTestA'));
        cfg.verbose = 0;
        
        try
            results = decoding(cfg);
            group_accuracy_CA(:,i_s) = results.accuracy_minus_chance.output;
            results.accuracy_minus_chance.output'
        catch continue
        end
        
        close all
    end
    close all
    
end