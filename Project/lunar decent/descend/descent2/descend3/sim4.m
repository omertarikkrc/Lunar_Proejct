% step3_animation.m
clear; clc; close all;
params;                        % R_moon, mu_moon vs.

% --- Eliptik segment parametreleri ---
ra       = R_moon + 260e3;
delta    = deg2rad(30);
r_target = R_moon + 10e3;
e        = (ra - r_target)/(ra - r_target*cos(delta));
a        = ra/(1 + e);
p        = a*(1 - e^2);

% --- Açılar ve konum dizileri ---
N_anim  = 100;
phi_vec = linspace(pi, pi-delta, N_anim);  % apogee → iniş
r_anim  = p ./ (1 + e*cos(phi_vec));
x_anim  =  r_anim .* sin(phi_vec);
y_anim  = -r_anim .* cos(phi_vec);

% --- Statik elemanlar: Ay çemberi ve elips segmenti ---
theta0  = linspace(0,2*pi,200);
x_moon  = R_moon * cos(theta0);
y_moon  = R_moon * sin(theta0);
figure; hold on; grid on; axis equal;
plot(x_moon, y_moon, 'k-', 'LineWidth',1.5);
plot(x_anim, y_anim, 'b--', 'LineWidth',1);

% --- Animasyon için hareketli işaretçi ---
hMarker = plot(x_anim(1), y_anim(1), 'ro', 'MarkerSize',8, 'LineWidth',1.5);

xlabel('x [m]'); ylabel('y [m]');
title('Animasyon: ΔV sonrası iniş segmenti');

% --- Döngü ile animasyon ---
for i = 1:N_anim
    set(hMarker, 'XData', x_anim(i), 'YData', y_anim(i));
    drawnow;
    pause(0.03);   % animasyon hızı için küçük bekleme
end
