clear all
workspace
version = '2018-05-14';
addpath('..\..\..\2018\preRNG\Matlab')
% PsychDebugWindowConfiguration()

%{
  An adaptation of Ariel Zylberberg's code, originally used for exp. 1 in
    Zylberberg, A., Bartfeld, P., & Signman, M. (2012).
    The construction of confidence in percpetual decision.
    Frontiers in integrative neuroscience,6, 79.

  Adapted by Matan Mazor, 2018
%}

%% Psychtoolbox

prompt = {'Name: ', 'Practice '};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'Xtest','0'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;

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
global_clock = tic();

%% Strart the trials
for num_trial = 1:params.Nsets
    
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
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.vertical})
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{3-params.vertical})
        end
        DrawFormattedText(w, 'or','center','center');
        DrawFormattedText(w, '?',params.positions{2}(3)+100,'center');
        
        vbl=Screen('Flip', w);
        pause(5);
    end
    
    % monitor and update coherence levels
    % if you're in the first two blocks of the first session, reduce
    % coherence every 10 trials for the first 40 trials if performance was
    % above chance
    if mod(num_trial,2)==0 && num_trial>2&&...
            sum(log.correct(num_trial-2:num_trial-1))==2
        params.Wg = params.Wg-0.01;
    elseif mod(num_trial,2)==0 && num_trial>2&&...
            sum(log.correct(num_trial-2:num_trial-1))==0
        params.Wg = params.Wg+0.01;
    end
    if detection
        params.DetWg = [params.DetWg; params.Wg];
    else
        params.DisWg = [params.DisWg; params.Wg];
    end
    
    %MM: generate the stimulus.
    target_xy = generate_stim(params, num_trial);
    target = Screen('MakeTexture',w, target_xy);
    
    %MM: save to log.
    log.Wg(num_trial) = params.vWg(num_trial)*params.Wg;
    log.direction(num_trial) = params.vDirection(num_trial);
    log.xymatrix{num_trial} = target_xy;
    log.detection(num_trial) = detection;
    
    % MM: fixation
    
    Screen('DrawDots', w, [0 0]', ...
        params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
    vbl=Screen('Flip', w);%initial flip
    
    tini = GetSecs;
    while (GetSecs - tini)<1
        [keyIsDown, seconds, keyCode ] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            break;
        end
    end
    DrawFormattedText(w, '+','center','center');
    vbl=Screen('Flip', w);
    while (GetSecs - tini)<1.5
        [keyIsDown, seconds, keyCode ] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            break;
        end
    end
    %MM: present stimulus
    Screen('DrawTextures',w,target);
    vbl=Screen('Flip', w);
    
    while (GetSecs - tini)<params.display_time+1.5
        continue
    end
    
    DrawFormattedText(w, '+','center','center');
    vbl=Screen('Flip', w);
    while (GetSecs - tini)<params.display_time+0.1+1.5
        [keyIsDown, seconds, keyCode ] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            break;
        end
    end
    
    %% Wait for response
    response = [nan nan];
    if detection
        while (GetSecs - tini)<params.display_time+params.time_to_respond+1.5
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes}, ...
                [],[], 0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes},...
                [],[], 0.5+0.5*(response(2)==0))
            vbl=Screen('Flip', w);
            [keyIsDown, seconds, keyCode ] = KbCheck;
            if keyIsDown
                if keyCode(KbName('ESCAPE'))
                    break;
                end
                if keyCode(KbName(params.keys{params.yes}))
                    response = [GetSecs-tini 1];
                elseif keyCode(KbName(params.keys{3-params.yes}))
                    response = [GetSecs-tini 0];
                end
            end
        end
        
        
    else %discrimination
        while (GetSecs - tini)<params.display_time+params.time_to_respond+1.5
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.vertical},...
                [],[],0.5+0.5*(response(2)==1))
            Screen('DrawTexture', w, params.horiTexture, [], params.positions{3-params.vertical},...
                [],[],0.5+0.5*(response(2)==3))
            vbl=Screen('Flip', w);
            [keyIsDown, seconds, keyCode ] = KbCheck;
            if keyIsDown
                if keyCode(KbName('ESCAPE'))
                    break;
                end
                if keyCode(KbName(params.keys{params.vertical}))
                    response = [GetSecs-tini 1];
                elseif keyCode(KbName(params.keys{3-params.vertical}))
                    response = [GetSecs-tini 3];
                end
            end
        end
    end
    log.resp(num_trial,:) = response;
    
    log.stimTime{num_trial} = vbl;
    if keyCode(KbName('ESCAPE'))
        break;
    end
    
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
