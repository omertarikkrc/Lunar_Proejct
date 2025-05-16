clear; clc; close all;
global m G n

%% Sabitler ve kütleler
n = 3;
G = 6.6742867e-11;

m1 = 5.9721426e24;    % Dünya
m2 = 7.3457576e22;    % Ay
m3 = 1000;            % Uzay Aracý
m = [m1 m2 m3];

%% Yarýçaplar ve yörünge bilgileri
RE = 6.3781366e6;
RM = 1.7374e6;
D_EM = 3.844e8;
r_park_E = RE + 660e3;
r_park_M = RM + 260e3;

%% Açý ve deltaV verisini dýþ dosyadan al
load('valid_theta_list.mat', 'filtered_theta', 'deltaV');
theta = filtered_theta(60);  % Ýstediðin açýyý buradan seç

%% Baþlangýç vektörü oluþturulmasý
b0 = initial_conditions(theta, deltaV, G, m1, m2, D_EM, r_park_E);

%% Simülasyon süresi ve çözüm
sim_duration = 3 * 24 * 3600;   % 6 gün
tspan = [0 sim_duration];
options = odeset('RelTol',1e-9,'AbsTol',1e-9);
[T, Y] = ode45(@SystemsOfEquations, tspan, b0, options);




%% Yörüngeleri çiz
figure; hold on; grid on;
plot(Y(:,1), Y(:,2), 'r', 'DisplayName', 'Dünya');
plot(Y(:,7), Y(:,8), 'b', 'DisplayName', 'Ay');
plot(Y(:,13), Y(:,14), 'g', 'DisplayName', 'Uzay Aracý');
legend show;
xlabel('x [m]'); ylabel('y [m]');
axis equal;
title('Dünya-Ay-Uzay Aracý Yörünge Takibi');

%% --- ANÝMASYONLU GÖSTERÝM ---
figure;
hold on; grid on;
axis equal;
xlabel('x [m]'); ylabel('y [m]');
title('Yörünge Takibi (Animasyon)');

% Görüþ alaný sabit
xlim([-2e8 8e8]);
ylim([-2e8 8e8]);

% Cisim ikonlarý
planetD = plot(0, 0, 'b.', 'MarkerSize', 20, 'DisplayName', 'Dünya');
planetM = plot(0, 0, 'r.', 'MarkerSize', 12, 'DisplayName', 'Ay');
spacecraft = plot(0, 0, 'k.', 'MarkerSize', 8, 'DisplayName', 'Uzay Aracý');

% Ay yüzeyi dairesi
theta_circle = linspace(0, 2*pi, 100);
moon_surface = plot(0, 0, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Ay Yüzeyi');

% Ýz takibi
traj = animatedline('Color', 'g', 'LineWidth', 1.5);
legend show;

% Animasyon döngüsü
for k = 1:50:length(T)
    % Koordinatlarý al
    xM = Y(k,7); yM = Y(k,8);

    % Ay yüzey çemberi
    x_circle = xM + RM * cos(theta_circle);
    y_circle = yM + RM * sin(theta_circle);

    % Güncellemeler
    set(planetD, 'XData', Y(k,1),  'YData', Y(k,2));
    set(planetM, 'XData', xM,      'YData', yM);
    set(spacecraft, 'XData', Y(k,13), 'YData', Y(k,14));
    set(moon_surface, 'XData', x_circle, 'YData', y_circle);
    addpoints(traj, Y(k,13), Y(k,14));
    drawnow;
    pause(0.06);
end
%% --- UZAY ARACI MERKEZLÝ ANÝMASYON ---
figure;
hold on; grid on;
axis equal;
xlabel('x [m]'); ylabel('y [m]');
title('Uzay Aracý Merkezli Animasyon');

xlim([-2e7 2e7]);  % Kamera alanýný küçültebilirsin
ylim([-2e7 2e7]);

% Grafik objeleri
planetD = plot(0, 0, 'b.', 'MarkerSize', 20, 'DisplayName', 'Dünya');
planetM = plot(0, 0, 'r.', 'MarkerSize', 12, 'DisplayName', 'Ay');
moon_surface = plot(0, 0, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Ay Yüzeyi');
traj = animatedline('Color', 'g', 'LineWidth', 1.5);
legend show;

% Ay yüzeyi çemberi (relatif çizilecek)
theta_circle = linspace(0, 2*pi, 100);
spacecraft = plot(0, 0, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k', 'DisplayName', 'Uzay Aracý');
for k = 1:50:length(T)


    % Mevcut uzay aracý konumu
    x_sc = Y(k,13); y_sc = Y(k,14);

    % Diðer cisimlerin uzay aracýna göre konumu
    xD = Y(k,1) - x_sc;  yD = Y(k,2) - y_sc;
    xM = Y(k,7) - x_sc;  yM = Y(k,8) - y_sc;

    % Ay yüzey çemberi (Ay merkezli çiz, uzay aracýna göre konumlandýr)
    x_circle = xM + RM * cos(theta_circle);
    y_circle = yM + RM * sin(theta_circle);

    % Güncellemeler
    set(planetD, 'XData', xD, 'YData', yD);
    set(planetM, 'XData', xM, 'YData', yM);
    set(moon_surface, 'XData', x_circle, 'YData', y_circle);
    addpoints(traj, 0, 0);  % Uzay aracý hep merkezde (0,0)
    drawnow;
    pause(0.06);
end
