function [value, isterminal, direction] = freeFall_events(t, Y)
    global Rm

    % Yüzeyden istenen irtifa = 4000 m
    h_target = 4000;

    % Uzay aracının Ay merkezinden uzaklığı
    x_s = Y(5);  y_s = Y(6);
    r   = norm([x_s; y_s]);

    % Event: r – (Rm + h_target) = 0 olduğunda
    value      = r - (Rm + h_target);
    isterminal = 1;    % integratörü durdur
    direction  = 0;   % yalnızca düşerken (azalan r) tetikle
end
