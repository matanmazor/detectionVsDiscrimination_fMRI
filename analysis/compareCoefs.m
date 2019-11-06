function [] = compareCoefs(coefs) % coefs is subj x degree (2,1,0) x resp (Y,N,A,C)
    
    global_coefs = nanmean(coefs,3);
    task_coefs = nanmean(coefs(:,:,1:2),3)-nanmean(coefs(:,:,3:4),3);
    detection_coefs = nanmean(coefs(:,:,1:2),3);
    discrimination_coefs = nanmean(coefs(:,:,3:4),3);
    resp_coefs = squeeze(coefs(:,:,1)-coefs(:,:,2));
    disc_resp_coefs = squeeze(coefs(:,:,3)-coefs(:,:,4));

    [~,quad_global_p,~,quad_global_stats] = ttest(global_coefs(:,1))
%     [~,quad_discrimination_p,~,quad_discrimination_stats] = ttest(discrimination_coefs(:,1))
%     [~,quad_detection_p,~,quad_detection_stats] = ttest(detection_coefs(:,1))

%     [~,linear_global_p,~,liner_global_stats] = ttest(global_coefs(:,2))
%     [~,linear_discrimination_p,~,liner_discrimination_stats] = ttest(discrimination_coefs(:,2))
%     [~,linear_detection_p,~,liner_detection_stats] = ttest(detection_coefs(:,2))
% % 
    
%     [~,quad_global_p,~,quad_global_stats] = ttest(global_coefs(:,1))
    [~,quad_task_p,~,quad_task_stats] = ttest(task_coefs(:,1))
    [~,linear_task_p,~,linear_task_stats] = ttest(task_coefs(:,2))
    [~,quad_resp_p,~,quad_resp_stats] = ttest(resp_coefs(:,1))
    [~,linear_resp_p,~,linear_resp_stats] = ttest(resp_coefs(:,2))
    
%     [~,quad_disc_resp_p,~,quad_disc_resp_stats] = ttest(disc_resp_coefs(:,1))
%     [~,linear_disc_resp_p,~,linear_disc_resp_stats] = ttest(disc_resp_coefs(:,2))

end
