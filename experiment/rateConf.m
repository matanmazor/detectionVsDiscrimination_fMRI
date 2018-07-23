function [rating]= rateConf(w)

global log
global params
global global_clock

timer = tic();

% initial confidence rating is determined randomly
rating = randperm(6,1);
circle_size = [-params.conf_width_px/2 -params.conf_height_px/2, ...
    params.conf_width_px/2 params.conf_height_px/2];

while toc(timer)<params.time_to_conf
    
    Screen('FillOval',w,[255,50,50]-(rating-1)/5*[205,0,-205],...
        [params.center params.center]+circle_size*sqrt(rating/6));
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size,4);
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(1/6),4);

    Screen('Flip',w);
    [ pressed, firstPress]= KbQueueCheck;
    if pressed
        log.events = [log.events; find(firstPress,1) toc(global_clock)];
        if firstPress(KbName('ESCAPE'))
            break;
        end
        if firstPress(KbName('3#'))
            rating=max(1,rating-1);
        elseif firstPress(KbName('4$'));
            rating=min(6,rating+1)
        end
    end
end

%fix confidence
while toc(timer)<params.time_to_conf+0.2
    
    Screen('FillOval',w,[255,75,75]-(rating-1)/5*[180,0,-180],...
        [params.center params.center]+circle_size*sqrt(rating/6));
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size,4);
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(1/6),4);

    Screen('FrameOval',w,[255,255,255],[params.center params.center]+circle_size*sqrt(rating/6),4);

    Screen('Flip',w);
    [ pressed, firstPress]= KbQueueCheck;
    if pressed
        log.events = [log.events; find(firstPress,1) toc(global_clock)];
        if firstPress(KbName('ESCAPE'))
            break;
        end
    end
end
end