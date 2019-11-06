function extractROIRespByConf(project_params,which_subjects,coordinates, ROI_name)
% Exctract four matrices with the mean activation for responsexconfidence
% level within this region.

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

fs = filesep;
p = project_params;

[conf_C, conf_A, conf_Y, conf_N] = deal(nan(numel(which_subjects),6));

row_number = 1;
for i_s = which_subjects
    
    fprintf('extracting betas for participant %s\n\n',subj{i_s}.scanid);
    % how many runs?
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    blockNo = sum(exclusion_file==0&conf_exclusion_file==0);
    usable_runs = find(exclusion_file==0&conf_exclusion_file==0);
    
    if blockNo ==0
        continue
    else
        spmmat = fullfile(p.stats_dir,...
            'DM427',['sub-',subj{i_s}.scanid],'SPM.mat');
        load(spmmat);
        names = SPM.xX.name;
        
        conf_mat = nan(4,5,6); %resp(C,A,Y,N) x session x confidence level
        
        for i_b = 1:numel(names)
            
            regressor_name =names{i_b};
            
            %is this a trial?
            if regexp(regressor_name,'trialx')
                
                %extract trial information from regressor name
                matchexp = regexp(regressor_name, ...
                    'Sn\((?<run_num>\d+)\) trialx(?<resp>\w)(?<conf_level>\d+)',...
                    'names');
                
                run_num = str2num(matchexp.run_num);
                resp = strfind('CAYN',matchexp.resp);
                conf_level = str2num(matchexp.conf_level);
                
                %extract mean beta
                beta_file = fullfile(p.stats_dir,...
                    'DM427',['sub-',subj{i_s}.scanid],sprintf('beta_%.04d.nii',i_b));
                
                if length(coordinates)==3
                    conf_mat(resp,run_num,conf_level) = spm_summarise(beta_file,...
                        struct('def','sphere', 'spec',8, 'xyz',coordinates'),@nanmean);
                else
                    conf_mat(resp,run_num,conf_level) = spm_summarise(beta_file,...
                        struct('def','mask', 'spec',coordinates),@nanmean);
                end
                
            end
        end
        
    end
    
    conf_C(row_number, :) = nanmean(squeeze(conf_mat(1,:,:)));
    conf_A(row_number, :) = nanmean(squeeze(conf_mat(2,:,:)));
    conf_Y(row_number, :) = nanmean(squeeze(conf_mat(3,:,:)));
    conf_N(row_number, :) = nanmean(squeeze(conf_mat(4,:,:)));

    row_number = row_number+1;
    
end

save(fullfile(p.stats_dir,'DM427','group',ROI_name),...
    'conf_C','conf_A','conf_Y','conf_N')

end