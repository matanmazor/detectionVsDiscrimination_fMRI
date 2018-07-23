function keysPressed = queryInput()
%Query input from button box/scanner and write to log. 

global log
global global_clock

[ ~, keysPressed]= KbQueueCheck;
for i=1:length(find(keysPressed))
    log.events = [log.events; find(keysPressed,i) toc(global_clock)];
end
if keysPressed(KbName('ESCAPE'))
   Screen('CloseAll');
end

    
end

