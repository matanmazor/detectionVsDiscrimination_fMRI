function  [ax1,ax2,coefs] = plotQuadFit(project_params, subjects, ROI_label, ROI_name, single_trials)

%this is from colorbrewer: http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
load('cb.mat');

if nargin==4
    single_trials=0;
end

if single_trials
    [ax1_ROI,ax2_ROI, coefs] = printConfByRespSingleTrialModel(project_params, subjects, ROI_label, ROI_name);
else
    [ax1_ROI,ax2_ROI, coefs] = printConfByResp(project_params, subjects, ROI_label, ROI_name);
end
fig = figure;

ax1 = subplot(2,2,2);
copyobj(get(ax1_ROI,'children'),ax1);
xticks(1:6); xlim([0.5,6.5]); xlabel('confidence'); 
title('Detection');
children = get(ax1,'children');
% legend([children(2),children(3)],{'yes','no'})


ax2 = subplot(2,2,1);
copyobj(get(ax2_ROI,'children'),ax2);
xticks(1:6); xlim([0.5,6.5]);  xlabel('confidence'); 
ylabel([ROI_name, ' mean \beta']);
title('Discrimination')
linkaxes([ax1,ax2],'y')
children = get(ax2,'children');
% legend([children(2),children(3)],{'CW','CCW'})

ax3 = subplot(2,2,3:4); hold on;
b_yes = bar([3,9],[nanmean(coefs(:,2,1)) nanmean(coefs(:,1,1))],...
    'FaceColor',cb(2,:),'BarWidth',0.13);
errorbar([3,9],[nanmean(coefs(:,2,1)) nanmean(coefs(:,1,1))], ...
    [nanstd(coefs(:,2,1)) nanstd(coefs(:,1,1))]./sqrt(35),'.k');

b_no = bar([4,10],[nanmean(coefs(:,2,2)) nanmean(coefs(:,1,2))],...
    'FaceColor',cb(1,:),'BarWidth',0.13);
errorbar([4,10],[nanmean(coefs(:,2,2)) nanmean(coefs(:,1,2))],...
    [nanstd(coefs(:,2,2)) nanstd(coefs(:,1,2))]./sqrt(35),'.k');

b_C = bar([1,7],[nanmean(coefs(:,2,4)) nanmean(coefs(:,1,4))],...
    'FaceColor',cb(3,:),'BarWidth',0.13);
errorbar([1,7],[nanmean(coefs(:,2,4)) nanmean(coefs(:,1,4))],...
    [nanstd(coefs(:,2,4)) nanstd(coefs(:,1,4))]./sqrt(35),'.k')

b_A = bar([2,8],[nanmean(coefs(:,2,3)) nanmean(coefs(:,1,3))],...
    'FaceColor',cb(4,:),'BarWidth',0.13);
errorbar([2,8],[nanmean(coefs(:,2,3)) nanmean(coefs(:,1,3))],...
    [nanstd(coefs(:,2,3)) nanstd(coefs(:,1,3))]./sqrt(35),'.k')
% ylabel('coefficient value (a.u.)');

yticks(0);
xticks([2.5,8.5]); xticklabels({'linear','quadratic'});
ylabel('coefficient');
xlim([-1,12]);
s=hgexport('readstyle','presentation');
s.Format = 'png'; 
s.Width = 15;
s.Height = 12;

% if single_trials
%     hgexport(gcf,['figures/',ROI_label,'single_trials_coefficients'],s);
% else
%     hgexport(gcf,['figures/',ROI_label,'coefficients'],s);
% end
% end

