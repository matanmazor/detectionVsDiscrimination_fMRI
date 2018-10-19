function meta_getonsetsModel_GLM1(project_params, subjects, this_model)
% Script constructs and estimates 1st-level design matrix
% Adds motion covariates (realignment + derivatives)
% Flexibly includes physiology covariates (Spike)
%
% Dan Bang danbang.db@gmail.com 2018

load('D:\Documents\software\MetaLabCore\project_params.mat')
addpath(project_params.spm_dir)

cwd=pwd;

%% Options for processing
compute_conditions  = 1;
construct_design    = 1;
estimate_design     = 1;
model_physiology    = 1;

% %% Scan parameters
% n_block     = 5;
% TR          = 3.36;
% nslices     = 48;
% hpcutoff    = 128;  % hp filter
% timeNorm    = 1000; % term for normalise times to seconds
% 
% %% Directories
% fs               = filesep;
% dir_spm          = 'path_spm';
% dir_brain        = 'path_preprocessed_scan_data';
% dir_epi          = 'Functional';
% dir_run          = 'Run';
% dir_spike        = 'Spike';
% dir_behaviour    = 'path_behavioural_data';
% dir_stats        = ['Functional_1st_level',fs,this_model];
% dir_info         = 'path_subject_information';
% 
% %% Load physiology details
% load([dir_info,fs,'fil_subject_spike.mat']);


%% loop through subjects
for n = 1:length(subjects)
           
    %% Create output directory
    outputDir=fullfile(project_params.data_dir, subjects{n}, 'functional_1st_level', this_model);
    % if it does not exits, make it and go into it
    if ~exist(outputDir,'dir')
        mkdir(outputDir);
    % if it does exist, go into it and delete existing contrast files
    else cd(outputDir);
        delete('SPM.mat','*.img','*.hdr'); 
    end
    
    %=========================================================================
    %% Get onsets in scans from behavioural datafiles and define images
    %======================================================================
    
    cd(cwd);   
    n_block = numel(dir(fullfile(project_params.data_dir,subjects{n},'func','run-*')));
    
    %% Functional data
    for k = 1:n_block;
        if compute_conditions
            %% Display
            disp(['Computing event onsets for subject ',num2str(subjects(i_sbj)),' -- session ',num2str(k)]);
            %% Behavioural data
        end
        
        %==========================================================================
        %% Construct design matrix
        %==========================================================================
        
        % Load files we have just created
        epiDir = fullfile(project_params.data_dir, subjects{n},...
                  project_params.dir_epi, ['run-',num2str(k)]);
        conditionFile = fullfile(project_params.data_dir, subjects{n},...
                        'DM', ['run-',num2str(k),'_',this_model]);
        % Get text file with movement regressors and concatenate with
        % first derivative
        mCorrFile = spm_select('List',epiDir,'^rp_af.*\.txt$');
        M = textread([epiDir,fs,mCorrFile]);
        R = [M [zeros(1,6); diff(M)]];
        % Add physiology data to nuisance matrix
        if model_physiology
            % But only if data was recorded / is usable
            if subj{subjects(n)}.spike(k)
                if subjects(n)<9
                spikeFile = [dir_brain,fs,'s',num2str(subjects(i_sbj)),fs,dir_spike,fs,'s',num2str(subjects(i_sbj)),'_ex_b',num2str(k),'_R_session1'];
                else
                spikeFile = [dir_brain,fs,'s',num2str(subjects(i_sbj)),fs,dir_spike,fs,'s',num2str(subjects(i_sbj)),'_b',num2str(k),'_R_session1'];    
                end
                temp = load(spikeFile,'R');
                R = [R temp.R(1:size(R,1),:)];
            end
        end
        % Write matrix
        cd(outputDir);
        multiFile = sprintf('multireg%d.mat',k);
        save(multiFile, 'R');
        % Assign .mat file with onsets/names/pmods in to path
        conditionPath = [outputDir,fs,conditionFile];
        multiregPath = [outputDir,fs,multiFile];     
        % Get epi files for this session
        epiDir = [dir_brain,fs,'s',num2str(subjects(i_sbj)),fs,dir_epi,fs,dir_run,num2str(k)];
        % select scans and concatenate
        f      = spm_select('List',epiDir,'^swuaf.*\.nii$');     % Select smoothed normalised images
        files  = cellstr([repmat([epiDir fs],size(f,1),1) f]);
        % prepare job
        jobs{1}.stats{1}.fmri_spec.sess(k).scans = files; 
        jobs{1}.stats{1}.fmri_spec.sess(k).multi = {conditionPath};
        jobs{1}.stats{1}.fmri_spec.sess(k).multi_reg = {multiregPath};
        % high pass filter
        jobs{1}.stats{1}.fmri_spec.sess(k).hpf = hpcutoff;
        jobs{1}.stats{1}.fmri_spec.sess(k).cond = struct([]);
        jobs{1}.stats{1}.fmri_spec.sess(k).regress = struct([]);
        % clear temporary variables for next run
        f = []; files = [];   
    end
    
    %==========================================================================
    %======================================================================
    jobs{1}.stats{1}.fmri_spec.dir = {outputDir};
    % timing variables
    jobs{1}.stats{1}.fmri_spec.timing.units     = 'secs';
    jobs{1}.stats{1}.fmri_spec.timing.RT        = TR;
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t    = nslices;
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t0   = nslices/2;   
    % basis functions
    jobs{1}.stats{1}.fmri_spec.bases.hrf.derivs = [0 0];
    % model interactions (Volterra) OPTIONS: 1|2 = order of convolution
    jobs{1}.stats{1}.fmri_spec.volt             = 1;
    % global normalisation
    jobs{1}.stats{1}.fmri_spec.global           = 'None';
    % explicit masking
    jobs{1}.stats{1}.fmri_spec.mask             = {[dir_spm,fs,'tpm/mask_ICV.nii']};
    % serial correlations
    jobs{1}.stats{1}.fmri_spec.cvi              = 'AR(1)';
    % no factorial design
    jobs{1}.stats{1}.fmri_spec.fact             = struct('name', {}, 'levels', {});
    
    
    %==========================================================================
    %% run model specification
    %==========================================================================
    
    if construct_design
        % save and run job
        cd(outputDir);
        save specify.mat jobs
        disp(['RUNNING model specification for subject ', num2str(subjects(i_sbj))]);
        spm_jobman('run','specify.mat');
        clear jobs
    end
    
    % Ensure implicit masking is switched off
    load SPM
    SPM.xM.TH = repmat(-Inf, length(SPM.xM.TH), 1);
    SPM.xM.I = 0;
    save SPM SPM
    
    %% Estimate
    % setup job structure for model estimation and estimate
    % ---------------------------------------------------------------------
    if estimate_design
        jobs{1}.stats{1}.fmri_est.spmmat = {[outputDir,fs,'SPM.mat']};
        save estimate.mat jobs
        disp(['RUNNING model estimation for subject ',num2str(subjects(i_sbj))])
        spm_jobman('run','estimate.mat');
        clear jobs
    end
end
cd(cwd);

end