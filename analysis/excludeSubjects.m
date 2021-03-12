clear;
clc;

%% 1. LOAD DATA
data_struct = loadData();
% 
% 
% %% 2. Exclude
% 
% for s = 1:length(subjects)
%     
%     DisMisses = [];
%     DetMisses = [];
%     
%     DisAcc = [];
%     DetAcc = [];
%     
%     DisBias = [];
%     DetBias = [];
%     
%     minErrorCount = [];
%     
%     subject = data_struct(subjects{s});
%     
%     for run_num = 1:length(subject.DisRT)/40
%         
%         DisNaNCount = sum(isnan(subject.DisRT((run_num-1)*40+1:run_num*40)));
%         DetNaNCount = sum(isnan(subject.DetRT((run_num-1)*40+1:run_num*40)));
%         DisMeanCorrect = nanmean(subject.DisCorrect((run_num-1)*40+1:run_num*40));
%         DetMeanCorrect = nanmean(subject.DetCorrect((run_num-1)*40+1:run_num*40));
%         DisMeanResp = nanmean(subject.DisResp((run_num-1)*40+1:run_num*40));
%         DetMeanResp = nanmean(subject.DetResp((run_num-1)*40+1:run_num*40));
%         
%         %Additional exclusion criterion that is not in the original
%         %preregistered crieria: each run should have at least one of each
%         %error class (C/AC, AC/C, N/Y and Y/N). This is essential becasue
%         %otherwise model specification fails.
%         minErrorNum = min([...
%             sum(subject.DisResp((run_num-1)*40+1:run_num*40)==0 &...
%                     subject.DisCorrect((run_num-1)*40+1:run_num*40)==0),...
%             sum(subject.DetResp((run_num-1)*40+1:run_num*40)==1 &...
%                     subject.DetCorrect((run_num-1)*40+1:run_num*40)==0),... 
%             sum(subject.DisResp((run_num-1)*40+1:run_num*40)==0 &...
%                     subject.DisCorrect((run_num-1)*40+1:run_num*40)==0),...
%             sum(subject.DisResp((run_num-1)*40+1:run_num*40)==1 &...
%                     subject.DisCorrect((run_num-1)*40+1:run_num*40)==0)]);
%                 
%         DisMisses = [DisMisses DisNaNCount];
%         DetMisses = [DetMisses DetNaNCount];
%         DisAcc = [DisAcc DisMeanCorrect];
%         DetAcc = [DetAcc DetMeanCorrect];
%         DisBias = [DisBias DisMeanResp];
%         DetBias = [DetBias DetMeanResp];
%         
%         minErrorCount = [minErrorCount minErrorNum];
%         
%         range = zeros(size(subject.DisRT));
%         range((run_num-1)*40+1:run_num*40)=1;
%         
%         conf_matrix = [hist(subject.DetConf(subject.DetResp==1&range),1:6);... %yes responses
%             hist(subject.DetConf(subject.DetResp==0&range),1:6);... %no responses
%             hist(subject.DisConf(subject.DisResp==1&range),1:6);... %CW responses
%             hist(subject.DisConf(subject.DisResp==0&range),1:6)];    %CCW responses
%         normalized_conf_matrix = conf_matrix./(repmat(sum(conf_matrix,2),1,6));
%         
%         if any(normalized_conf_matrix(:)>0.95)
%             toExcludeFromConfAnalyses(s,run_num)=1;
%         end
%         
%     end
%     
%     % unlike the above confidence matrices, that only take into account one
%     % run at a time, this confidence rating is global:
%     global_conf_matrix = [hist(subject.DetConf(subject.DetResp==1&range),1:6);... %yes responses
%         hist(subject.DetConf(subject.DetResp==0),1:6);... %no responses
%         hist(subject.DisConf(subject.DisResp==1),1:6);... %CW responses
%         hist(subject.DisConf(subject.DisResp==0),1:6)];    %CCW responses
%     normalized_global_conf_matrix = conf_matrix./(repmat(sum(conf_matrix,2),1,6));
%     
%     if any(normalized_global_conf_matrix(:)>0.8)
%             toExcludeFromConfAnalyses(s,:)=1;
%     end
%     
%     if any(DisMisses>8)
%         
%         if mean(DisMisses)>8
%             toExclude(s,:)=toExclude(s,:)+7;
%         else
%             toExclude(s, find(DisMisses>8))=toExclude(s, find(DisMisses>8))+7;
%         end
%     end
%     
%     if any(DetMisses>8)
%         
%         if mean(DetMisses)>8
%             toExclude(s,:)= toExclude(s,:)+60;
%         else
%             toExclude(s,find(DetMisses>8))=toExclude(s,find(DetMisses>8))+60;
%         end
%     end
%     
%     if any(DisAcc<0.6)
%         if mean(DisAcc)<0.6
%             toExclude(s,:)=toExclude(s,:)+500;
%         else
%             toExclude(s,find(DisAcc<0.6))=toExclude(s,find(DisAcc<0.6))+500;
%         end
%     end
%     
%     if any(DetAcc<0.6)
%         if mean(DetAcc)<0.6
%             toExclude(s,:)=toExclude(s,:)+4000;
%         else
%             toExclude(s,find(DetAcc<0.6))=toExclude(s,find(DetAcc<0.6))+4000;
%         end
%     end
%     
%     if abs(mean(DisBias)-0.5)>0.25
%         toExclude(s,:)=toExclude(s,:)+30000;
%     elseif any(abs(DisBias-0.5)>0.3)
%         toExclude(s,find(abs(DisBias-0.5)>0.3))=...
%             toExclude(s,find(abs(DisBias-0.5)>0.3))+30000;
%     end
%     
%     if abs(mean(DetBias)-0.5)>0.25
%         toExclude(s,:)=toExclude(s,:)+200000;
%     elseif any(abs(DetBias-0.5)>0.3)
%         toExclude(s,find(abs(DetBias-0.5)>0.3))=...
%             toExclude(s,find(abs(DetBias-0.5)>0.3))+200000;
%     end
%     
% %     if any(minErrorCount==0)
% %         toExclude(s,find(minErrorCount==0))=toExclude(s,find(minErrorCount==0))+1000000;
% %     end
% 
% % 3. save exclusion files in participant's directory
% subject_id = participants.participant_id(...
%     strcmp(strtrim(participants.name_initials),subjects{s}));
% func_dir = fullfile('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\pp_data\',...
%     strtrim(subject_id{1}),'func'); 
% 
% 
% fid = fopen( fullfile(func_dir,'exclusion.txt'), 'wt' );
% fprintf( fid, '%d,%d,%d,%d,%d', toExclude(s,1), toExclude(s,2),...
%                     toExclude(s,3),toExclude(s,4), toExclude(s,5));
% fclose(fid);
% 
% fid = fopen( fullfile(func_dir,'conf_exclusion.txt'), 'wt' );
% fprintf( fid, '%d,%d,%d,%d,%d', toExcludeFromConfAnalyses(s,1),...
%                                 toExcludeFromConfAnalyses(s,2),...
%                                 toExcludeFromConfAnalyses(s,3),...
%                                 toExcludeFromConfAnalyses(s,4),...
%                                 toExcludeFromConfAnalyses(s,5));
% fclose(fid);

end


