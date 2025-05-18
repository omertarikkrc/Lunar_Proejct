% step5_descent_search.m
clear; clc; close all;
params;   % R_moon, mu_moon, Isp, g0 vs. yüklüyor

% --- 1) İniş başlangıç durumu (step4’den) ---
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
h_orb     = sqrt(mu_moon * p);
r_hat     = [ sin(phi_imp); -cos(phi_imp) ];
t_hat     = [ cos(phi_imp);  sin(phi_imp) ];
v_r       = mu_moon/h_orb * e * sin(phi_imp);%- vardi
v_t       =  mu_moon/h_orb * (1 + e*cos(phi_imp));
v_imp     = v_r * r_hat + v_t * t_hat;     % Başlangıç hızı [vx;vy]
m_phase2_0 = 5000;                         % Başlangıç kütlesi [kg]
y0        = [x_imp; y_imp; v_imp; m_phase2_0];

% --- 2) For döngülü T araması ---
T_min    = 5000;
T_max    = 7000;
N_steps  = 100;
T_vals   = linspace(T_min, T_max, N_steps);
T_found  = NaN;  v_touch = NaN;

for T_try = T_vals
    opts = odeset( ...
        'Events', @(t,y) event_altitude(t,y,R_moon), ...
        'RelTol',1e-3,'AbsTol',1e-3);
    [~,Y] = ode45(@(t,y) descent_ode(t,y,mu_moon,T_try,Isp,g0), ...
                  [0 1e5], y0, opts);
    v_end = norm(Y(end,3:4));
    if v_end <= 3
        T_found = T_try;
        v_touch = v_end;
        break;
    end
end

if isnan(T_found)
    error('Uygun sabit itki bulunamadı. Aralığı veya adım sayısını artırın.');
end

fprintf('Bulunan T = %.1f N, iniş hızı = %.2f m/s\n', T_found, v_touch);

% --- 3) İniş yolunu çiz ---
figure; 
plot(Y(:,1), Y(:,2), 'b-', 'LineWidth',1.5);
axis equal; grid on;
xlabel('x [m]'); ylabel('y [m]');
title('Phase 2: Sabit İtkiyle İniş Yolu');
legend(sprintf('T=%.1f N', T_found), 'Location','Best');

% --- Yardımcı fonksiyonlar ---
function dydt = descent_ode(~, y, mu, T, Isp, g0)
    r = y(1:2); v = y(3:4); m = y(5);
    r_norm = norm(r);
    a_grav = -mu/r_norm^3 * r;
    th_dir = -v/norm(v);                  % hareket yönünün tersi
    a_th   = (T/m) * th_dir;
    mdot   = -T/(Isp*g0);
    dydt   = [v; a_grav + a_th; mdot];
end

function [value, isterm, dir] = event_altitude(~, y, Rm)
    value     = norm(y(1:2)) - Rm;
    isterm    = 1;
    dir       = -1;
end
