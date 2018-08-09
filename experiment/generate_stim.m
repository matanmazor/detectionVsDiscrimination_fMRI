function target = generate_stim(params, num_trial)

% after rotating 45 degrees, 'vertical' becomes clockwise and 'horizontal'
% becomes 'counterclockwise'.
directions = {'vertical',[],'horizontal'};

% make target patch
 grating   =    params.Wg  *  params.vWg(num_trial)* makeGrating(params.stimulus_width_px,[],1,...
    params.cycle_length_px,'pixels per period',directions{params.vDirection(num_trial)});

noise     = (1-(params.Wg *  params.vWg(num_trial))) * (2*rand(params.stimulus_width_px)-1);

noisyGrating = 2*Scale(grating+noise)-1;

% target    = round( 127 + 127 * p.stimContrast * (grating + noise) );
target    = round( 127 + 127 * params.stimContrast * noisyGrating );

target(params.circleFilter==0) = params.bg;


