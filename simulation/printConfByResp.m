function [ax1,ax2,coefs] = printConfByResp(trial_count,simulation_betas,simulation_name)


load(fullfile('..','analysis','cb.mat'));

A_num_trials = trial_count.A_num_trials;
C_num_trials = trial_count.C_num_trials;
Y_num_trials = trial_count.Y_num_trials;
N_num_trials = trial_count.N_num_trials;


%% get standard errors
for i=1:6
    A_standard_error(i) = nanstd(simulation_betas.conf_A(:,i))/sqrt(sum(~isnan(simulation_betas.conf_A(:,i))));
    C_standard_error(i) = nanstd(simulation_betas.conf_C(:,i))/sqrt(sum(~isnan(simulation_betas.conf_C(:,i))));
    Y_standard_error(i) = nanstd(simulation_betas.conf_Y(:,i))/sqrt(sum(~isnan(simulation_betas.conf_Y(:,i))));
    N_standard_error(i) = nanstd(simulation_betas.conf_N(:,i))/sqrt(sum(~isnan(simulation_betas.conf_N(:,i))));
end


%% plot
figure('visible','off');
ax1=subplot(1,2,1); hold on;
title('detection');
errorbar(1:6, nanmean(simulation_betas.conf_Y),Y_standard_error,'-k');
errorbar(0.2+(1:6), nanmean(simulation_betas.conf_N),N_standard_error,'-k');
yes_points = scatter(1:6,nanmean(simulation_betas.conf_Y),5*nanmean(Y_num_trials)'+1,cb(2,:),...
    'filled','MarkerEdgeColor','k');
no_points = scatter(0.2+(1:6),nanmean(simulation_betas.conf_N),5*nanmean(N_num_trials)'+1,cb(1,:),...
    'filled','MarkerEdgeColor','k');

%for overlap:
scatter(1:6,nanmean(simulation_betas.conf_Y),5*nanmean(Y_num_trials)'+1,cb(2,:),...
    'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
scatter(0.2+(1:6),nanmean(simulation_betas.conf_N),5*nanmean(N_num_trials)'+1,'k');

xlim([0,7]);
% ylim([-0.5, 1.2]);
xticks(1:6);
% xtickangle(45);
set(gca,'ytick',[0,1]);
ylabel(sprintf('mean \\beta in the %s','ROI_name'));
legend([yes_points,no_points],'yes','no')
xlabel('confidence');

ax2=subplot(1,2,2); hold on;
title('discrimination');
errorbar(1:6, nanmean(simulation_betas.conf_C),C_standard_error,'-k')
errorbar(0.2+(1:6), nanmean(simulation_betas.conf_A),A_standard_error,'-k')
CW_points = scatter(1:6,nanmean(simulation_betas.conf_C),5*nanmean(C_num_trials)'+1,cb(3,:),...
    'filled','MarkerEdgeColor','k');
CCW_points = scatter(0.2+(1:6),nanmean(simulation_betas.conf_A),5*nanmean(A_num_trials)'+1,cb(4,:),...
    'filled','MarkerEdgeColor','k');
% %for overlap:
scatter(1:6,nanmean(simulation_betas.conf_C),5*nanmean(C_num_trials)'+1,cb(3,:),...
    'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
scatter(0.2+(1:6),nanmean(simulation_betas.conf_A),5*nanmean(A_num_trials)'+1,'k');

xlim([0,7]);
% ylim([-0.5, 1.2]);
xticks(1:6);
% xtickangle(45);
set(gca,'ytick',[0,1]);
ylabel(sprintf('mean \\beta in the %s','ROI_name'));
legend([CW_points,CCW_points],'CW','CCW')
xlabel('confidence');

set(gca,'ytick',[]);
linkaxes([ax1,ax2],'y')
set(gca,'YColor','none')

% fig = gcf;
% fig.PaperUnits = 'inches';
% set(fig,'PaperPositionMode','auto');
% print(sprintf('figures/%s_conf',ROI_label),'-dpng','-r1200');
% print(sprintf('figures/%s_conf_300dpi',ROI_label),'-dpng','-r300');
N = size(simulation_betas.conf_C,1);

coefs = nan(N,3,4); %subjects, degrees, responses: YNAC
simulation_conf_betas = cat(3,simulation_betas.conf_Y, simulation_betas.conf_N, simulation_betas.conf_A, simulation_betas.conf_C);

for i_s = 1:N
    for i_r = 1:4
        confidence_levels=1:6;
        beta_values = simulation_conf_betas(i_s,:,i_r);
        confidence_levels(isnan(beta_values))=[];
        if numel(confidence_levels)>3
            beta_values(isnan(beta_values))=[];
            coefs(i_s,:,i_r) = polyfit(confidence_levels-mean(confidence_levels),...
                beta_values-mean(beta_values),2);
        end
    end
end


end
