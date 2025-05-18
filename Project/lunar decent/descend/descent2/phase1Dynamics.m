function dYdt = phase1Dynamics(t,Y,mu_Moon,Rm,h_safe,T_max,Isp,g0,vtheta_thresh)
    % Y = [r; theta; vr; vtheta; m]
    r      = Y(1);
    vr     = Y(3);
    vtheta = Y(4);
    m      = Y(5);

    altitude = r - Rm;       % İrtifa [m]

    % --- Birim Vektörler ---
    e_r     = [1; 0];
    e_theta = [0; 1];

    % --- Kontrol Kanunu ---
    if altitude <= h_safe && vr < 0
        % Güvenli irtifa altına düşüyorsa radyal karşı thrust
        u = -sign(vr) * e_r;
    elseif abs(vtheta) > vtheta_thresh
        % Aksi halde retrograde tangensiyel thrust
        u = -sign(vtheta) * e_theta;
    else
        u = [0; 0];  % Artık ihtiyacımız yok
    end

    % --- Thrust ve Kütle Akışı ---
    if any(u)
        u_dir = u / norm(u);
        T     = T_max;
        mdot  = T/(Isp*g0);
    else
        u_dir = [0; 0];
        T     = 0;
        mdot  = 0;
    end

    % --- Denklemler ---
    ar       = -mu_Moon/r^2 + (T/m)*u_dir(1);
    atheta   =               (T/m)*u_dir(2);

    drdt     = vr;
    dthetadt = vtheta/r;
    dvrdt    = ar;
    dvthetadt= atheta;
    dmdt     = -mdot;

    dYdt = [drdt; dthetadt; dvrdt; dvthetadt; dmdt];
end
function [outputArg1,outputArg2] = untitled13(inputArg1,inputArg2)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end