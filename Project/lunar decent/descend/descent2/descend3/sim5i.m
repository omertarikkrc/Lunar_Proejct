% step4_descent_setup.m
clear; clc; close all;
params;   % R_moon, mu_moon, Isp, g0 vs.

% --- 1) İniş noktası (true anomaly = π–30°) ---
ra        = R_moon + 260e3;
delta     = deg2rad(30);
r_target  = R_moon + 10e3;
e         = (ra - r_target)/(ra - r_target*cos(delta));
a         = ra/(1 + e);
p         = a*(1 - e^2);
phi_imp   = pi - delta;
r_imp     = p / (1 + e*cos(phi_imp));
x_imp     =  r_imp * sin(phi_imp);
y_imp     = -r_imp * cos(phi_imp);

% --- 2) Gerçek hız vektörü v_imp (v_r negatif) ---
h_orb     = sqrt(mu_moon * p);
r_hat     = [ sin(phi_imp); -cos(phi_imp) ];
t_hat     = [ cos(phi_imp);  sin(phi_imp) ];
v_r       = -mu_moon/h_orb * e * sin(phi_imp);         % negatif işaret
v_t       =  mu_moon/h_orb * (1 + e*cos(phi_imp));     % teğetsel hız
v_imp     = v_r * r_hat + v_t * t_hat;                  % [vx; vy]

% --- 3) Başlangıç kütlesi ---
m_phase2_0 = 5000;   % kg

% --- 4) Başlangıç durum vektörü ---
y0 = [ x_imp; y_imp; v_imp; m_phase2_0 ];

% Kontrol amaçlı çıktılar
fprintf('Başl. konum = [%.1f, %.1f] m\n', x_imp, y_imp);
fprintf('Başl. hız = [%.3f, %.3f] m/s\n', v_imp(1), v_imp(2));
fprintf('Başl. kütle = %.1f kg\n', m_phase2_0);
