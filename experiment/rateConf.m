function [rating]= rateConf(w)

global log
global params
global global_clock

timer = tic();

% initial confidence rating is determined randomly
rating = randperm(6,1);
circle_size = [-params.conf_width_px/2 -params.conf_height_px/2, ...
    params.conf_width_px/2 params.conf_height_px/2];
while toc(timer)<params.time_to_conf-0.1
    KbReleaseWait([],params.time_to_conf-toc(timer));
    
    Screen('FillOval',w,[255,255,255]-(rating-1)/5*[0,255,255],...
        [params.center params.center]+circle_size*sqrt(rating/6));
    
    Screen('FrameOval',w,[255,255,255],[params.center params.center]+circle_size,4);
    
    Screen('FrameOval',w,[255,255,255],[params.center params.center]+circle_size*sqrt(1/6),4);

    Screen('Flip',w);
    [keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown
        log.events = [log.events; find(keyCode,1) toc(global_clock)];
        if keyCode(KbName('ESCAPE'))
            break;
        end
        if keyCode(KbName('3#'))
            rating=max(1,rating-1)
            pause(0.1)
        elseif keyCode(KbName('4$'))
            rating=min(6,rating+1)
            pause(0.1)
        end
    end
end
end