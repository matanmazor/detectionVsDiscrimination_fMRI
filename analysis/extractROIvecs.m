function [] = extractROIvecs(project_params, which_subjects, DM)

extractROIvec(project_params,which_subjects,DM,[0,-57,18],'precuneus');
extractROIvec(project_params,which_subjects,DM,[0,17,46],'pMFC');
extractROIvec(project_params,which_subjects,DM,[0,46,-7],'vmPFC');
extractROIvec(project_params,which_subjects,DM,...
    'D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\analysis\ROIs\ventralStriatum.nii','ventral_striatum')

extractROIvec(project_params,which_subjects,DM,...
    'D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\analysis\ROIs\union_FPl.nii','FPl');

extractROIvec(project_params,which_subjects,DM,...
    'D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\analysis\ROIs\union_FPm.nii','FPm');

extractROIvec(project_params,which_subjects,DM,...
    'D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\analysis\ROIs\union_46.nii','BA46');

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

fs = filesep;
p = project_params;

load(fullfile(p.stats_dir, ['DM',num2str(DM)],'T.mat'));
if numel(T.contrasts)~=size(T.contrastVectors,1)
    error('number of contrast names does not match number of contrasts')
end

ROIs = {'vmPFC','pMFC','precuneus','ventral_striatum','FPl','FPm','BA46'};

for j = 1:length(T.contrasts)
    
    contrastFolder = fullfile(p.stats_dir,['DM',num2str(DM)],'group',T.contrasts{j});
    
    for i_roi = 1:numel(ROIs)
        cur = load(fullfile(contrastFolder,ROIs{i_roi}));
        means(i_roi) = nanmean(cur.ROI_vec);
        [h,p_value,ci,stats] = ttest(cur.ROI_vec);
        t(i_roi) = stats.tstat;
        p_values(i_roi) = p_value;
        std(i_roi) = nanstd(cur.ROI_vec);
        
    end
    roi_table = table(ROIs', means',t',p_values',std','VariableNames',...
        {'region','mean','t_value','p_value','std'});
    
    writetable(roi_table, fullfile(contrastFolder,'ROIs.csv'))
       
end
end

