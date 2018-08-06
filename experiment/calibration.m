clear all
workspace
version = '2018-05-14';
addpath('..\..\..\2018\preRNG\Matlab')

%PsychDebugWindowConfiguration()


global log
global params
global global_clock


prompt = {'Name: ', 'Practice ', 'Multiband'};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'Xtest','0','0'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;

KbQueueCreate;
KbQueueStart;

[w, rect] = Screen('OpenWindow', screenNumber, 0,[], 32, doublebuffer+1);

%load parameters
params = loadPars(w, rect, savestr, 1);

KbName('UnifyKeyNames');
AssertOpenGL;
PsychVideoDelayLoop('SetAbortKeys', KbName('Escape'));
HideCursor();
Priority(MaxPriority(w));

% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%MM: initialize log vector for confidence ratings
log.confidence = nan(params.Nsets,1);
%MM: initialize decision log
log.resp = zeros(params.Nsets,2);
log.detection = nan(params.Nsets,1);
log.Wg = nan(params.Nsets,1);
log.correct = nan(params.Nsets,1);
log.estimates = [];
log.events = [];


%% WAIT FOR 5
% Wait for the 6th volume to start the experiment.

num_five = 0;

while num_five<1
    Screen('DrawText',w,'Waiting for the scanner.',20,120,[255 255 255])
    vbl=Screen('Flip', w);
    [ ~, firstPress]= KbQueueCheck;
    if firstPress(params.scanner_signal)
        num_five = num_five+1;
    elseif firstPress(KbName('6^'))
        num_five = inf;
    elseif firstPress(KbName('ESCAPE'))
        Screen('CloseAll');
        clear;
        return
    end
end


%initialize

% All timings are relative to the onset of the 6th volume.
global_clock = tic();


correct_count = 0; %for staircasing

%% Strart the trials
for num_trial = 1:params.Nsets
    
    %% for staircasing
    if mod(num_trial,round(params.trialsPerBlock))<20
        step_size = 0.01;
    else
        step_size = 0.005;
    end
    
    if mod(num_trial,round(params.trialsPerBlock))==1
        
        if ~params.practice
            save(fullfile('data', params.filename),'params','log');
        end
        
        %detection or not?
        detection = params.vTask(ceil(num_trial/params.trialsPerBlock));
        
        if detection
            params.Wg = params.DetWg(end);
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes})
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes})
        else
            params.Wg = params.DisWg(end);
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{2},45)
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{1},45)
        end
        DrawFormattedText(w, 'or','center','center');
        DrawFormattedText(w, '?',params.positions{2}(3)+100,'center');
        
        vbl=Screen('Flip', w);
        
        instruction_clock = tic;
        while toc(instruction_clock)<5
            keysPressed = queryInput();
        end
    end
    
    %MM: generate the stimulus.
    target_xy = generate_stim(params, num_trial);
    target = Screen('MakeTexture',w, target_xy);
    
    %MM: save to log.
    log.Wg(num_trial) = params.vWg(num_trial)*params.Wg;
    log.direction(num_trial) = params.vDirection(num_trial);
    log.xymatrix{num_trial} = target_xy;
    log.detection(num_trial) = detection;
    
    response = [nan nan];
    
    % MM: fixation
    
    Screen('DrawDots', w, [0 0]', ...
        params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
    vbl=Screen('Flip', w);%initial flip
    
    trial_clock = tic;
    while toc(trial_clock)<1
        keysPressed = queryInput();
    end
    
    while toc(trial_clock)<1.5
        DrawFormattedText(w, '+','center','center');
        vbl=Screen('Flip', w);
        keysPressed = queryInput();
    end
    
    %MM: present stimulus
    
    %write to log
    log.events = [log.events; 0 toc(global_clock)];
    
    while toc(trial_clock)<1.5+params.display_time
        Screen('DrawTextures',w,target, [], [], 45);
        vbl=Screen('Flip', w);
    end
    
    
    while toc(trial_clock) <params.display_time+1.7
        DrawFormattedText(w, '+','center','center');
        vbl=Screen('Flip', w);
        keysPressed = queryInput();
        if detection
            if keysPressed(KbName(params.keys{params.yes}))
                response = [toc(trial_clock) 1];
            elseif keysPressed(KbName(params.keys{3-params.yes}))
                response = [toc(trial_clock) 0];
            end
        else
            if keysPressed(KbName(params.keys{params.vertical}))
                response = [toc(trial_clock) 1];
            elseif keysPressed(KbName(params.keys{3-params.vertical}))
                response = [toc(trial_clock) 0];
            end
        end
    end
    
    %% Wait for response
    if detection
        while toc(trial_clock) < params.display_time+params.time_to_respond+1.2
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes}, ...
                [],[], 0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes},...
                [],[], 0.5+0.5*(response(2)==0))
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
            if keysPressed(KbName(params.keys{params.yes}))
                response = [toc(trial_clock) 1];
            elseif keysPressed(KbName(params.keys{3-params.yes}))
                response = [toc(trial_clock) 0];
            end
        end
        
    else %discrimination
        while toc(trial_clock)<params.display_time+params.time_to_respond+1.2
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{2},...
                45,[],0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{1},...
                45,[],0.5+0.5*(response(2)==3))
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
            if keysPressed(KbName(params.keys{2}))
                response = [toc(trial_clock) 1];
            elseif keysPressed(KbName(params.keys{1}))
                response = [toc(trial_clock) 3];
            end
        end
    end
    log.resp(num_trial,:) = response;
    
    log.stimTime{num_trial} = vbl;
    
    
    % MM: check if the response was accurate or not
    if detection
        if log.resp(num_trial,2)== sign(params.vWg(num_trial))
            log.correct(num_trial) = 1;
        else
            log.correct(num_trial) = 0;
        end
    else
        if log.resp(num_trial,2) == params.vDirection(num_trial)
            log.correct(num_trial) = 1;
        else
            log.correct(num_trial) = 0;
        end
    end
    %MM: end of decision phase
    % monitor and update coherence levels
    if mod(num_trial, 10)==0
        if nanmean(log.correct(num_trial-9:num_trial))<0.6
            params.Wg = params.Wg+step_size;
        elseif nanmean(log.correct(num_trial-9:num_trial))>0.8
            params.Wg = params.Wg-step_size;
            if detection
                params.DetWg = [params.DetWg; params.Wg];
            else
                params.DisWg = [params.DisWg; params.Wg];
            end
        end
    end
end
    
    
    %% MM: write to log
    %MM: experimento is the log variable that includes all experiment
    %parameters and results.
    if ~params.practice
        
        log.date = date;
        log.filename = params.filename;
        log.version = version;
        save(fullfile('data', params.filename),'params','log');
        
    end
    
    %% close
    Priority(0);
    ShowCursor
    Screen('CloseAll');
