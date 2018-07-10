function [vDirection,vWg,vTask, vOnset] = get_trials_params(params)

Nsets = params.Nsets;
Nblocks = params.Nblocks;

% randomize blocks for detection/discrimination. Always interleaved, but
% first can be detection or discrimination
% 0 is discrimination, 1 detection
vTask = reshape([ones(Nblocks/2,1) zeros(Nblocks/2,1)]',Nblocks,1);
if binornd(1,0.5)
    vTask = 1-vTask;
end
%initialize
[vDirection, vWg] = deal([]);

for i=1:length(vTask)
    
    detection = vTask(i);
    block_array = [ones(Nsets/(Nblocks*4),1) ones(Nsets/(Nblocks*4),1); ...
        zeros(Nsets/(Nblocks*4),1) ones(Nsets/(Nblocks*4),1);...
        ones(Nsets/(Nblocks*4),1) 3*ones(Nsets/(Nblocks*4),1); ...
        zeros(Nsets/(Nblocks*4),1) 3*ones(Nsets/(Nblocks*4),1)];
    if ~detection
        block_array(:,1)=1;
    end
    
    %% randomize
    block_array = block_array(randperm(Nsets/Nblocks),:);
    vWg = [vWg; block_array(:,1)];
    vDirection = [vDirection; block_array(:,2)];
end
    trial_duration = params.fixation_time + params.display_time...
        + params.time_to_respond + params.time_to_conf;
    used_time = trial_duration*length(vWg)+10*length(vTask);
    spare_time = params.run_duration-used_time;
    gitter_vec = Scale(rand(size(vWg)));
    gitter_vec = gitter_vec/sum(gitter_vec)*spare_time;
    gitter_vec = gitter_vec+trial_duration;
    gitter_vec = [0; gitter_vec];
    gitter_vec(1:Nsets/Nblocks:end) = gitter_vec(1:Nsets/Nblocks:end)+10;
    vOnset = cumsum(gitter_vec);
end
