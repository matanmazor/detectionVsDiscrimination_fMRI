function params = loadPars(w, rect, savestr)

params.scanner_signal = KbName('5%');
params.subj = savestr{1};
params.practice = str2double(savestr{2});

load(fullfile('data','subjects.mat'));
if ismember(params.subj, subjects.keys)
    %when this equals 1, the 'vertical' response will be on the right.
    response_mappings = subjects(params.subj);
    params.vertical = response_mappings(1); 
    %when this equals 1, the 'Yes' response will be on the right.
    params.yes = response_mappings(2); 
else
    error('Participant is not in subjects list');
end

%MM: A while-loop to start next session in line.
if ~params.practice
    num_session=0;
    stopper=0;
    while stopper==0
        num_session = num_session + 1;
        aux_filename = strjoin({params.subj,...
                ['session',num2str(num_session)],'.mat'},'_');
        stopper = isempty(dir(fullfile('data',aux_filename)));
        if ~stopper
            old_params = load(fullfile('data',aux_filename));
        end
    end
    params.num_session = num_session;
    params.filename = aux_filename;
end

%% randomize
if ~params.practice
    subject_num = str2num(params.subj(1:2));
    serial_num = subject_num*100+num_session;
      params.protocolSum = preRNG('protocolFolder.zip',serial_num);
end

params.waitframes = 1; 
if params.practice || ~exist('old_params')
    params.DetWg = 0.6;
    params.DisWg = 0.6;
else
    params.DetWg = old_params.params.DetWg(end);
    params.DisWg = old_params.params.DisWg(end);
end

%% Visual properties
%background color
params.bg = 0;
%letter size
params.letter_size = 25;
%dot color
params.fix_color = [0 0 255];
params.displace = 300;
Screen('TextFont',w,'Corbel');
params.stimContrast = .9;


%% Timing
params.fixation_time = 0.8;
params.display_time = 1/30;
params.time_to_respond = 1.5;
params.time_to_conf = 2.5;


%% Number of trials and blocks
if params.practice
    params.trialsPerBlock = 4;
    params.Nblocks = 2;
else
    params.trialsPerBlock = 40;
    params.Nblocks = 2;
end
params.Nsets = params.trialsPerBlock*params.Nblocks;

distance_from_monitor = 77; % en cm
mon_width = 29; %VERIFICAR, ancho del monitor
mon_height = 21.5; %VERIFICAR
newResolution.width = 1024;
newResolution.height = 768;
cm_per_px_width  = mon_width/newResolution.width;
cm_per_px_height = mon_height/newResolution.height;
params.deg_per_px_width = cm_per_px_width * atan(1/distance_from_monitor) * 360/(2*pi);
params.deg_per_px_height = cm_per_px_height * atan(1/distance_from_monitor) * 360/(2*pi);

params.stimulus_width_deg = 3;
params.stimulus_width_px = round(params.stimulus_width_deg/params.deg_per_px_width);

params.fixation_diameter_deg = 0.2;
params.fixation_diameter_px = round(params.fixation_diameter_deg/params.deg_per_px_width);

params.cycles_deg      = 2;
params.cycle_length_deg = 1/params.cycles_deg;
params.cycle_length_px = round(params.cycle_length_deg/params.deg_per_px_width);

params.conf_diam_deg = 6;
params.conf_width_px = round(params.conf_diam_deg/params.deg_per_px_width);
params.conf_height_px = round(params.conf_diam_deg/params.deg_per_px_height);

% circle filter
x = [1:params.stimulus_width_px] - median(1:params.stimulus_width_px);
[xx yy] = meshgrid(x);

params.stimRadii    = sqrt(xx.^2 + yy.^2);
params.circleFilter = (params.stimRadii <= params.stimulus_width_px/2);

params.annulus_diameter = 6.5; %degrees

[params.center(1), params.center(2)] = RectCenter(rect);
params.rect = rect;
params.yesTexture = Screen('MakeTexture', w, imread(fullfile('textures','yes.png')));
params.noTexture = Screen('MakeTexture', w, imread(fullfile('textures','no.png')));
params.horiTexture = Screen('MakeTexture', w, imread(fullfile('textures','hori.png')));
params.vertTexture = Screen('MakeTexture', w, imread(fullfile('textures','vert.png')));

params.positions = {[params.center(1)-250, params.center(2)-50,...
                            params.center(1)-150, params.center(2)+50],...
             [params.center(1)+150, params.center(2)-50,...
                            params.center(1)+250, params.center(2)+50]};

params.keys = {'1!','2@'};

%MM: direction and coherence for every trial
if params.practice == 2
    params.vDirection = ones(params.Nsets,1)+ 2*binornd(1,0.5,params.Nsets,1);
    params.vCoh = binornd(1,0.5,params.Nsets,1);
    params.vTask = [1, 1];
elseif params.practice == 1
    params.vDirection = ones(params.Nsets,1)+ 2*binornd(1,0.5,params.Nsets,1);
    params.vCoh = ones(params.Nsets,1);
    params.vTask = [0,0];
else
    params.run_duration = 9*60; %seconds;
    [params.vDirection, params.vWg, params.vTask, params.onsets] = ...
    get_trials_params(params);
end
end