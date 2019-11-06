function [] = checkT(T)
    for i_c = 1:length(T.contrasts)
        str = sprintf('In the contrast %s, there are a total of %d betas:',...
            T.contrasts{i_c}, sum(abs(T.contrastVectors(i_c,:))));
        for i_w = find(T.contrastVectors(i_c,:))
            str = strcat(str, ...
                sprintf('%s gets a weight of %d.\n',T.betas{i_w},T.contrastVectors(i_c,i_w)));
        end
        str
    end
end