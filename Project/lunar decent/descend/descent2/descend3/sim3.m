% step2_plot_deltaV_trueVec.m
clear; clc; close all;
params;   % R_moon, mu_moon tanımlı

% 1) Apogee ve hedef yarıçap
ra       = R_moon + 260e3;
delta    = deg2rad(30);
r_target = R_moon + 10e3;

% 2) Eksantriklik e ve yarı-büyük eksen a
e        = (ra - r_target)/(ra - r_target*cos(delta));
a        = ra/(1 + e);

% 3) Hız büyüklükleri (özellikle apogee)
v_circ   = sqrt(mu_moon/ra);
v_after  = sqrt(mu_moon*(2/ra - 1/a));

% 4) Orbit çizimi (saat yönünde)
theta_cw = linspace(0, -2*pi, 300);
x_orbit  = ra*cos(theta_cw);
y_orbit  = ra*sin(theta_cw);

% 5) Elliptik yörünge (saat yönünde)
theta_e  = linspace(pi, pi-2*pi, 500);
r_e      = a*(1 - e^2)./(1 + e*cos(theta_e));
x_ell    = r_e.*sin(theta_e);
y_ell    = -r_e.*cos(theta_e);

% 6) Ay yüzeyi
theta0   = linspace(0,2*pi,200);
x_moon   = R_moon*cos(theta0);
y_moon   = R_moon*sin(theta0);

% 7) İmpuls noktası (true anomaly = pi-delta)
phi      = pi - delta;
p        = a*(1-e^2);
r_imp    = p / (1 + e*cos(phi));
x_imp    =  r_imp * sin(phi);
y_imp    = -r_imp * cos(phi);

% 8) Gerçek hız vektörü
h_orb    = sqrt(mu_moon * p);
r_hat    = [ sin(phi); -cos(phi) ];
t_hat    = [ cos(phi);  sin(phi) ];
v_r      = mu_moon/h_orb * e * sin(phi);
v_t      = mu_moon/h_orb * (1 + e*cos(phi));
v_vec    = v_r * r_hat + v_t * t_hat;    % [vx; vy]

% 9) Thrust yönü
T_dir    = -v_vec / norm(v_vec);

% 10) Plot
scale = 50;
figure; hold on; grid on; axis equal;
plot(x_moon, y_moon, 'k-',    'LineWidth',1.5);
plot(x_orbit,y_orbit,'b--',   'LineWidth',1);
plot(x_ell,  y_ell,  'c--',   'LineWidth',1);
plot(0,ra,        'ro',      'MarkerSize',8,'LineWidth',1.5);  % Apogee
plot(x_imp,y_imp,'ms','MarkerSize',10,'LineWidth',2);          % 30° sonrası

% Apogee vektörleri
t0_hat = [1;0];  % apogee’de teğet sırf örnek
quiver(0, ra, v_circ*t0_hat(1)*scale, v_circ*t0_hat(2)*scale, ...
       'g','LineWidth',1.5,'MaxHeadSize',2);
quiver(0, ra, v_after*t0_hat(1)*scale, v_after*t0_hat(2)*scale, ...
       'r','LineWidth',1.5,'MaxHeadSize',2);
T_dir=-T_dir
% --- İniş noktasında thrust oku, autoscale kapalı ve uzunluğu büyük ---
arrow_len = 5e4;  % Oku istediğin uzunluğa göre ayarla
u = T_dir(1)*arrow_len;
v = T_dir(2)*arrow_len;
% quiver(x,y,u,v,0) ile autoscale’ı kapatıyoruz
quiver(x_imp, y_imp, u, v, 0, 'b', ...
       'LineWidth',1.5, 'MaxHeadSize',0.5);


xlabel('x [m]'); ylabel('y [m]');
title('Gerçek Hız Vektörü ve Thrust Yönü (30° sonrası)');
legend('Ay yüzeyi','Circ. orbit','Elliptik orbit','Apogee',...
       'İniş Noktası','v_{circ}','v_{after}','T yönü','Location','Best');
