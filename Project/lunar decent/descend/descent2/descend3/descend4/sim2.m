% step2_elliptic_transfer.m
clear; clc; close all;
params;   % R_moon, mu_moon, h0, m_dry, Isp, g0 yükleniyor

%% 1) Circular Park Yörüngesi
ra   = R_moon + h0;           % [m]
r0   = [-ra; 0];              % Apogee konumu
v0   = [0;  sqrt(mu_moon/ra)];% Başlangıç hızı (+y yönünde)

%% 2) Eliptik Transfer Parametreleri
delta   = deg2rad(30);        % apogee’den sonraki 30°
phi_imp = pi + delta;         % true anomaly = 210°
r_tar   = R_moon;             % orijin focus’dan Ay yüzeyi

% Eksantriklik e ve yarı büyük eksen a
e  = (ra - r_tar)/(ra + r_tar*cos(phi_imp));
a  = ra / (1 + e);
p  = a*(1 - e^2);

% ΔV büyüklüğü (apogee’deki hız farkı)
v_circ = sqrt(mu_moon/ra);
v_ap   = sqrt(mu_moon*(2/ra - 1/a));
dv_imp = v_ap - v_circ;       % negatif ise retrograde
dv_mag = abs(dv_imp);

% Roket denkleminden kütle kaybı
v_e     = Isp * g0;
m_fuel0 = 6050;                         % Başlangıç yakıt [kg] (gerekirse değiştir)
m0      = m_dry + m_fuel0;             
mf      = m0 * exp(-dv_mag / v_e);      
fuel_used = m0 - mf;                    

fprintf('e=%.4f, a=%.1f km\n', e, a/1e3);
fprintf('ΔV=%.2f m/s → Yakıt kullanıldı: %.1f kg\n', dv_imp, fuel_used);
fprintf('ΔV=%.2f m/s → Yakıt kullanıldı: %.1f kg\n', dv_imp, fuel_used);

%% 3) Grafik Hazırlığı
theta = linspace(0,2*pi,500);
% Ay yüzeyi
x_moon = R_moon*cos(theta);
y_moon = R_moon*sin(theta);
% Circular orbit
x_circ = ra*cos(theta);
y_circ = ra*sin(theta);
% Eliptik transfer (focus odaklı polar)
phi_e  = linspace(0,2*pi,500);
r_e    = p./(1 + e*cos(phi_e));
x_ell  = r_e .* cos(phi_e);
y_ell  = r_e .* sin(phi_e);

%% 4) Plot
figure; hold on; axis equal; grid on;
% Ay
plot(x_moon, y_moon, 'k-', 'LineWidth',1.5);
% Dairesel
plot(x_circ, y_circ, 'g--', 'LineWidth',1);
% Eliptik
plot(x_ell,   y_ell,   'm--', 'LineWidth',1.2);
% Apogee başlangıç noktası
plot(r0(1), r0(2), 'ro', 'MarkerSize',8, 'LineWidth',1.5);
% ΔV vektörü (ok)
t_hat = v0 / norm(v0);                    % teğet birim vektör
dv_vec = -t_hat * dv_mag;                 % retrograde yön
scale = ra/1000;                            
quiver(r0(1), r0(2), dv_vec(1)*scale, dv_vec(2)*scale, 0, ...
       'r','LineWidth',1.5,'MaxHeadSize',2);

xlabel('x [m]'); ylabel('y [m]');
title('Adım 2: Circular → Elliptic Transfer ve ΔV');
legend('Ay yüzeyi','Circular Orbit','Eliptik Transfer', ...
       'Apogee','ΔV','Location','Best');
