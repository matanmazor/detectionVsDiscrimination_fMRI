function [rating]= rateConf()

global params
global w

timer = tic();

% initial confidence rating is determined randomly
rating = randperm(6,1);
circle_size = [-params.conf_width_px/2 -params.conf_height_px/2, ...
    params.conf_width_px/2 params.conf_height_px/2];

while toc(timer)<params.time_to_conf
    
    if params.conf_mapping==1
        Screen('FillOval',w,[255,50,50]-(rating-1)/5*[205,0,-205],...
            [params.center params.center]+circle_size*sqrt(rating/6));
    elseif params.conf_mapping==2
        Screen('FillOval',w,[255,50,50]-(6-rating)/5*[205,0,-205],...
            [params.center params.center]+circle_size*sqrt((7-rating)/6));
    end
    
    for i=2:5
       Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(i/6),2);
    end
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size,4);
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(1/6),4);
    
    Screen('Flip',w);
    keysPressed = queryInput();
    %     if keysPressed(KbName('3#'))
    %         rating=max(1,rating-1);
    if keysPressed(KbName('6^'))
        rating = mod(rating+1,6);
        if rating == 0
            rating=6;
        end
    end
end

%fix confidence
while toc(timer)<params.time_to_conf+0.1
    
    if params.conf_mapping==1
        Screen('FillOval',w,[255,75,75]-(rating-1)/5*[180,0,-180],...
            [params.center params.center]+circle_size*sqrt(rating/6));
        Screen('FrameOval',w,[255,255,255],[params.center params.center]+...
            circle_size*sqrt(rating/6),4);
        
    elseif params.conf_mapping==2
        Screen('FillOval',w,[255,75,75]-(6-rating)/5*[180,0,-180],...
            [params.center params.center]+circle_size*sqrt((7-rating)/6));
        Screen('FrameOval',w,[255,255,255],[params.center params.center]+...
            circle_size*sqrt((7-rating)/6),4);
    end
    
    for i=2:5
       Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(i/6),2);
    end
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size,4);
    
    Screen('FrameOval',w,[255,255,255]/2,[params.center params.center]+circle_size*sqrt(1/6),4);
    
    
    Screen('Flip',w);
    keysPressed = queryInput();
end