% The purpose of this code is to make sure that I haven't confused any of
% the confidence mappings, i.e., that all participants used the confidence
% rating interface like I thought they did.
% I do this by checking that the mean confidence rating for 'yes' responses
% is higher than for 'no' responses. 

clear;
clc;

%% 1. LOAD DATA
data_struct = loadData();
subjects = {'01RoYi','02XiHo','03JaVe','04NiSi','05PeYa','06KuSh',...
    '07AnWo','08LiBa', '09KeVa', '10MaIv', '11YaSi', '12JaGu',...
    '13ChSc','14SaMc','15ChFi', '16JoDa', '17IvSi','18LuHe','19ElBo','20MiLa',...
    '21ShZh', '22PeYe','23InMa','24WePi','25AyLe', '26DeCa','27LoLi',...
    '28WiTa', '29CrRa','30OrAl', '31FeKu', '32EeXu', '33KaBh', '34AlGa','35MaRo'};

participants = readtable('D:\Documents\projects\inProgress\detectionVsDiscrimination_fMRI\data\data\participants.csv');

wrongMapping = nan(length(subjects),2); %first column: discrimination. second column: detection

%% 2. Check mapping 

for s = 1:length(subjects)
     
    subject = data_struct(subjects{s});
    
    wrongMapping(s,1) = nanmean(subject.DisConf(find(subject.DisCorrect==1)))...
                        - nanmean(subject.DisConf(find(subject.DisCorrect==0)));
                    
    wrongMapping(s,2) = nanmean(subject.DetConf(find(subject.DetCorrect==1)))...
                        - nanmean(subject.DetConf(find(subject.DetCorrect==0)));
end


