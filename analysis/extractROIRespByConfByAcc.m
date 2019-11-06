function extractROIRespbyConfByAcc(project_params,which_subjects,coordinates, ROI_name)
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
            'DM429',['sub-',subj{i_s}.scanid],'SPM.mat');
        load(spmmat);
        names = SPM.xX.name;
        
        conf_mat = nan(8,5,6); %resp(CC,AA,YY,NN,CA,AC,YN,NY) x session x confidence level
        
        for i_b = 1:numel(names)
            
            regressor_name =names{i_b};
            
            %is this a trial?
            if regexp(regressor_name,'trialx')
                
                %extract trial information from regressor name
                matchexp = regexp(regressor_name, ...
                    'Sn\((?<run_num>\d+)\) trialx(?<resp>\w+)(?<conf_level>\d+)',...
                    'names');
                if numel(matchexp)>0
                    run_num = str2num(matchexp.run_num);
                    resp = find(strcmp({'CC','AA','YY','NN','CA','AC','YN','NY'},matchexp.resp));
                    conf_level = str2num(matchexp.conf_level);

                    %extract mean beta
                    beta_file = fullfile(p.stats_dir,...
                        'DM429',['sub-',subj{i_s}.scanid],sprintf('beta_%.04d.nii',i_b));

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
        
    end
    
    conf_CC(row_number, :) = nanmean(squeeze(conf_mat(1,:,:)));
    conf_AA(row_number, :) = nanmean(squeeze(conf_mat(2,:,:)));
    conf_YY(row_number, :) = nanmean(squeeze(conf_mat(3,:,:)));
    conf_NN(row_number, :) = nanmean(squeeze(conf_mat(4,:,:)));
    
    conf_CA(row_number, :) = nanmean(squeeze(conf_mat(5,:,:)));
    conf_AC(row_number, :) = nanmean(squeeze(conf_mat(6,:,:)));
    conf_YN(row_number, :) = nanmean(squeeze(conf_mat(7,:,:)));
    conf_NY(row_number, :) = nanmean(squeeze(conf_mat(8,:,:)));

    row_number = row_number+1;
    
end

save(fullfile(p.stats_dir,'DM429','group',ROI_name),...
    'conf_CC','conf_AA','conf_YY','conf_NN',...
    'conf_CA','conf_AC','conf_YN','conf_NY')

end