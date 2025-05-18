function [value,isterminal,direction] = phase1Events(t,Y,h_safe,mu_Moon,Rm,vtheta_thresh)
    altitude = Y(1) - Rm;
    vtheta   = Y(4);

    % Her iki koşul sağlandığında max(...) ≤ 0 olur, o anda durur
    value     = max(abs(vtheta)-vtheta_thresh, h_safe - altitude);
    isterminal= 1;   % ODE’yi durdur
    direction = -1;  % değerin azalarak 0’ı geçişini yakala
end
