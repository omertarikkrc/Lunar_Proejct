% step1_circular_orbit.m
clear; clc; close all;
params;              % R_moon, mu_moon, h0, vb.

% 1) Park yörüngesi yarıçapı
ra = R_moon + h0;    % [m]

% 2) Başlangıç konumu ve hızı (Ay merkezli, saat yönünde dönüş için)
r0 = [-ra; 0];                              % x = -ra, y = 0
v0 = [0;  sqrt(mu_moon/ra)];                % |v| = sqrt(mu/ra), +y yönünde

% 3) Yörünge çizimi
theta   = linspace(0,2*pi,500);
x_orbit = ra * cos(theta);
y_orbit = ra * sin(theta);

figure;
plot(x_orbit, y_orbit, 'b-', 'LineWidth',1.5); hold on;
plot(r0(1), r0(2), 'ro', 'MarkerSize',8, 'LineWidth',1.5);

% 4) Başlangıç hızı okunu çiz (ölçek kat sayısını ihtiyaca göre ayarla)
scale = ra/10000;
quiver(r0(1), r0(2), v0(1)*scale, v0(2)*scale, 0, 'r', 'LineWidth',1.5, 'MaxHeadSize',2);

axis equal; grid on;
xlabel('x [m]'); ylabel('y [m]');
title('Adım 1: Dairesel Park Yörüngesi (Saat Yönünde)');
legend('Circular Orbit','Initial Position & Velocity','Location','Best');
