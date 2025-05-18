% step7_plot_trajectory_vs_time_lines.m
clear; clc; close all;
params;   % R_moon, mu_moon, Isp, g0, v_max

%% 1) Orbit parametreleri
ra      = R_moon + 260e3;      % circular park orbit yarıçapı
delta   = deg2rad(30);         
rp      = R_moon + 10e3;       % perigee yarıçapı
e       = (ra - rp)/(ra - rp*cos(delta));
a       = ra/(1 + e);
p       = a*(1-e^2);

%% 2) Elliptik geçiş segmenti (apogee → perigee)
phi_start = pi;
phi_end   = pi - delta;
phi_seg   = linspace(phi_start, phi_end, 200);
r_seg     = p ./ (1 + e*cos(phi_seg));
x_seg     =  r_seg .* sin(phi_seg);
y_seg     = -r_seg .* cos(phi_seg);

%% 3) İniş başlangıcı (elliptik perigee)
x_imp   = x_seg(end);
y_imp   = y_seg(end);

% Başlangıç hızı
h_orb   = sqrt(mu_moon * p);
r_hat   = [ sin(phi_end); -cos(phi_end) ];
t_hat   = [ cos(phi_end);  sin(phi_end) ];
v_r     = -mu_moon/h_orb * e * sin(phi_end);
v_t     =  mu_moon/h_orb * (1 + e*cos(phi_end));
v_imp   = v_r * r_hat + v_t * t_hat;      
m0      = 5000;                           % kg
y0      = [x_imp; y_imp; v_imp; m0];      

%% 4) Sabit itkiyle inişi simüle et
T_found    = 5020.2;
opts       = odeset('Events', @(t,y) event_altitude(t,y,R_moon), ...
                    'RelTol',1e-6,'AbsTol',1e-6);
[t_descent, Y] = ode45(@(t,y) descent_ode(t,y,mu_moon,T_found,Isp,g0), ...
                       [0 1e5], y0, opts);

%% 5) Ay ve full circular orbit
theta0 = linspace(0,2*pi,300);
x_moon = R_moon*cos(theta0);
y_moon = R_moon*sin(theta0);
x_circ = ra*cos(theta0);
y_circ = ra*sin(theta0);

%% 6) Çizim
figure('Position',[100 100 800 600]);
hold on; axis equal; grid on;

% Ay yüzeyi
plot(x_moon, y_moon, 'k-', 'LineWidth',1.5);

% Circular orbit (tam daire)
plot(x_circ, y_circ, 'g--', 'LineWidth',1);

% Elliptik geçiş segmenti
plot(x_seg, y_seg, 'm-', 'LineWidth',1.8);

% Sabit itki inişi trajektoryası
plot(Y(:,1), Y(:,2), 'r-', 'LineWidth',1.8);

% İtki başlangıç noktası
plot(x_imp, y_imp, 'ko', 'MarkerSize',8, 'LineWidth',1.5);

xlabel('x [m]'); 
ylabel('y [m]'); 
title('Uzay Aracı Trajektorisi: Circular → Elliptic → Descent');
legend('Ay yüzeyi', 'Circular Orbit', 'Elliptik Geçiş', ...
       ['Descent (T=' num2str(T_found,'%.0f') ' N)'], ...
       'İtki Başlangıcı', 'Location','Best');
% … ana script kodun buraya …

% -------- Yerel fonksiyonlar --------
function dydt = descent_ode(~, y, mu, T, Isp, g0)
    r_vec  = y(1:2);
    v_vec  = y(3:4);
    m      = y(5);
    r_norm = norm(r_vec);
    a_grav = -mu/r_norm^3 * r_vec;
    dir_th = v_vec/norm(v_vec);
    a_th   = (T/m) * dir_th;
    mdot   = -T/(Isp*g0);
    dydt   = [v_vec; a_grav + a_th; mdot];
end

function [value, isterm, dir] = event_altitude(~, y, Rm)
    value  = norm(y(1:2)) - Rm;
    isterm = 1;
    dir    = -1;
end
