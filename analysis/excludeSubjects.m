clear;
clc;

%% 1. LOAD DATA
data_struct = loadData();
subjects = {'01RoYi','02XiHo','03JaVe','04NiSi','05PeYa','06KuSh',...
    '07AnWo','08LiBa', '09KeVa', '10MaIv', '11YaSi', '12JaGu',...
    '13ChSc','14SaMc','15ChFi', '16JoDa', '17IvSi','18LuHe','19ElBo','20MiLa',...
    '21ShZh', '22PeYe','23InMa','24WePi','25AyLe', '26DeCa','27LoLi',...
    '28WiTa', '29CrRa','30OrAl', '31FeKu', '32EeXu', '33KaBh', '34AlGa','35MaRo'};
toExclude = zeros(length(subjects),5);

%% 2. Exclude

for s = 1:length(subjects)
    
    DisMisses = [];
    DetMisses = [];
    
    DisAcc = [];
    DetAcc = [];
    
    DisBias = [];
    DetBias = [];
    
    subject = data_struct(subjects{s});
    
    for run_num = 1:length(subject.DisRT)/40
        
        DisNaNCount = sum(isnan(subject.DisRT((run_num-1)*40+1:run_num*40)));
        DetNaNCount = sum(isnan(subject.DetRT((run_num-1)*40+1:run_num*40)));
        DisMeanCorrect = nanmean(subject.DisCorrect((run_num-1)*40+1:run_num*40));
        DetMeanCorrect = nanmean(subject.DetCorrect((run_num-1)*40+1:run_num*40));
        DisMeanResp = nanmean(subject.DisResp((run_num-1)*40+1:run_num*40));
        DetMeanResp = nanmean(subject.DetResp((run_num-1)*40+1:run_num*40));
        
        DisMisses = [DisMisses DisNaNCount];
        DetMisses = [DetMisses DetNaNCount];
        DisAcc = [DisAcc DisMeanCorrect];
        DetAcc = [DetAcc DetMeanCorrect];
        DisBias = [DisBias DisMeanResp];
        DetBias = [DetBias DetMeanResp];
        
        range = (run_num-1)*40+1:run_num*40;
        conf_matrix = [hist(subject.DetConf(subject.DetResp(range)==1),1:6);... %yes responses
                        hist(subject.DetConf(subject.DetResp(range)==0),1:6);... %no responses
                        hist(subject.DisConf(subject.DisResp(range)==1),1:6);... %CW responses
                        hist(subject.DisConf(subject.DisResp(range)==0),1:6)];    %CCW responses
        normalized_conf_matrix = conf_matrix./(repmat(sum(conf_matrix,2),1,6));
        if any(normalized_conf_matrix(:)>0.95) 
            toExclude(s,run_num)=0.5;
        end
        
    end
    
    if any(DisMisses>8)
        
        if mean(DisMisses)>8
            toExclude(s,:)=toExclude(s,:)+1;
        else
            toExclude(s, find(DisMisses>8))=toExclude(s, find(DisMisses>8))+1;
        end
    end
    
    if any(DetMisses>8)
        
        if mean(DetMisses)>8
            toExclude(s,:)= toExclude(s,:)+10;
        else
            toExclude(s,find(DetMisses>8))=toExclude(s,find(DetMisses>8))+10;
        end
    end
    
    if any(DisAcc<0.6)
        if mean(DisAcc)<0.6
            toExclude(s,:)=toExclude(s,:)+100;
        else
            toExclude(s,find(DisAcc<0.6))=toExclude(s,find(DisAcc<0.6))+100;
        end
    end
    
    if any(DetAcc<0.6)
        if mean(DetAcc)<0.6
            toExclude(s,:)=toExclude(s,:)+1000;
        else
            toExclude(s,find(DetAcc<0.6))=toExclude(s,find(DetAcc<0.6))+1000;
        end
    end
    
    if abs(mean(DisBias)-0.5)>0.25
        toExclude(s,:)=toExclude(s,:)+10000;
    elseif any(abs(DisBias-0.5)>0.3)
        toExclude(s,find(abs(DisBias-0.5)>0.3))=...
            toExclude(s,find(abs(DisBias-0.5)>0.3))+10000;
    end
    
    if abs(mean(DetBias)-0.5)>0.25
        toExclude(s,:)=toExclude(s,:)+100000;
    elseif any(abs(DetBias-0.5)>0.3)
        toExclude(s,find(abs(DetBias-0.5)>0.3))=...
            toExclude(s,find(abs(DetBias-0.5)>0.3))+100000;
    end
    
    
end


