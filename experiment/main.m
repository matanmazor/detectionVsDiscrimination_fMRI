clear all
version = '2018-07-23';
addpath('..\..\..\2018\preRNG\Matlab')

% PsychDebugWindowConfiguration()

%{
  fMRI experiment, run in the Wellcome Centre for Human Neuroimaging.
  Code snnippets adapted from:

    Zylberberg, A., Bartfeld, P., & Signman, M. (2012).
    The construction of confidence in percpetual decision.
    Frontiers in integrative neuroscience,6, 79.

  and from
    
    

  Matan Mazor, 2018
%}

%global variables
global log
global params
global global_clock
global w %psychtoolbox window

prompt = {'Name: ', 'Practice: ', 'Multiband: '};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'999MaMa','0','0'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;

%The fMRI button box does not work well with KbCheck. I use KbQueue
%instead here, to get precise timings and be sensitive to all presses.
KbQueueCreate;
KbQueueStart;

%Open window.
[w, rect] = Screen('OpenWindow', screenNumber, 0,[], 32, doublebuffer+1);

%Load parameters
params = loadPars(w, rect, savestr, 0);

KbName('UnifyKeyNames');
AssertOpenGL;
PsychVideoDelayLoop('SetAbortKeys', KbName('Escape'));
HideCursor();
Priority(MaxPriority(w));

% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initialize log with NaNs where possible.
log.confidence = nan(params.Nsets,1);
log.resp = zeros(params.Nsets,2);
log.detection = nan(params.Nsets,1);
log.Wg = nan(params.Nsets,1);
log.correct = nan(params.Nsets,1);
log.estimates = [];
log.events = [];


%% WAIT FOR 5
% Wait for the 6th volume to start the experiment. 

excludeVolumes = 5;
if params.multiband
    slicesperVolume = 36;
else
    slicesperVolume = 48;
end

%initialize
num_five = 0;
while num_five<excludeVolumes*slicesperVolume
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

% All timings are relative to the onset of the 6th volume.
global_clock = tic();

%% MAIN LOOP:
for num_trial = 1:params.Nsets
    
    % At the beginning of each experimental block:
    if mod(num_trial,round(params.trialsPerBlock))==1
        
        %1. Save data to file
        if ~params.practice
            save(fullfile('data', params.filename),'params','log');
        end
        
        %2. Set task to detection or discrimination
        detection = params.vTask(ceil(num_trial/params.trialsPerBlock));
        
        %3. Load the relevant Wg parameter.
        if detection
            params.Wg = params.DetWg(end);
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes})
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes})
        else
            params.Wg = params.DisWg(end);
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{2},45)
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{1},45)
        end
        
        %4. Present instructions on the screen.
        DrawFormattedText(w, 'or','center','center');
        DrawFormattedText(w, '?',params.positions{2}(3)+100,'center');
        
        vbl=Screen('Flip', w);
        
        %5. Leave the instructions on the screen for 5 seconds.
        if num_trial==1
            remove_instruction_time=5;
        else
            remove_instruction_time = params.onsets(num_trial-1)+5;
        end
        
        while toc(global_clock)<remove_instruction_time
            keysPressed = queryInput();
        end
    end
    
    % Monitor and update thw Wg parameter based on performance every 20
    % trials. 
    if mod(num_trial, 20)==1 && mod(num_trial,params.trialsPerBlock)~=1
        current_performance = mean(log.correct(num_trial-20:num_trial-1));
        if current_performance>0.9
            params.Wg = params.Wg*0.8;
        elseif current_performance<0.5
            params.Wg = params.Wg/0.8;
        end
        if detection
            params.DetWg = [params.DetWg; params.Wg];
        else
            params.DisWg = [params.DisWg; params.Wg];
        end
    end
    
    % Generate the stimulus.
    target_xy = generate_stim(params, num_trial);
    target = Screen('MakeTexture',w, target_xy);
    
    % Save to log.
    log.Wg(num_trial) = params.vWg(num_trial)*params.Wg;
    log.direction(num_trial) = params.vDirection(num_trial);
    log.xymatrix{num_trial} = target_xy;
    log.detection(num_trial) = detection;
    
    % Present a dot at the centre of the screen.
    Screen('DrawDots', w, [0 0]', ...
        params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
    vbl=Screen('Flip', w);%initial flip
    
    while toc(global_clock)<params.onsets(num_trial)-0.5
        keysPressed = queryInput();
    end
    
    % Present the fixation cross.
    DrawFormattedText(w, '+','center','center');
    vbl=Screen('Flip', w);
    
    while toc(global_clock)<params.onsets(num_trial)
        keysPressed = queryInput();
    end
    
    % Present the stimulus.
    tini = GetSecs;
    Screen('DrawTextures',w,target, [], [], 45);
    vbl=Screen('Flip', w);
    
    % The onset of the stimulus is encoded in the log as '0'.
    log.events = [log.events; 0 toc(global_clock)];
    
    while (GetSecs - tini)<params.display_time
        keysPressed = queryInput();
    end
    
    % Present the fixation cross.
    DrawFormattedText(w, '+','center','center');
    vbl=Screen('Flip', w);
    while (GetSecs - tini)<params.display_time+0.1
        keysPressed = queryInput();
    end
    
    %% Wait for response
    response = [nan nan];
    
    if detection
        while (GetSecs - tini)<params.display_time+params.time_to_respond
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes}, ...
                [],[], 0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes},...
                [],[], 0.5+0.5*(response(2)==0))
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
            if keysPressed(KbName(params.keys{params.yes}))
                response = [GetSecs-tini 1];
            elseif keysPressed(KbName(params.keys{3-params.yes}))
                response = [GetSecs-tini 0];
            end
        end
        
    else %discrimination
        while (GetSecs - tini)<params.display_time+params.time_to_respond
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{2},...
                45,[],0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{1},...
                45,[],0.5+0.5*(response(2)==3))
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
            if keysPressed(KbName(params.keys{2}))
                response = [GetSecs-tini 1];
            elseif keysPressed(KbName(params.keys{1}))
                response = [GetSecs-tini 3];
            end
        end
    end
    
    % Write to log.
    log.resp(num_trial,:) = response;
    log.stimTime{num_trial} = vbl;
    if keysPressed(KbName('ESCAPE'))
        Screen('CloseAll');
    end
    
    % Check if the response was accurate or not
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
    
    %% CONFIDENCE JUDGMENT
    if ~isnan(response(2))
        log.confidence(num_trial) = rateConf();
    end
end

%% MM: write to log

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
