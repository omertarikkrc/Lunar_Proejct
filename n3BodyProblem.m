clear; clc; close all;
global m G n

%% Sabitler ve kütleler
n = 3;                % body sayısı
G = 6.6742867e-11;    %  Yer çekimi Sabiti
m1 = 5.9721426e24;    % Dünya
m2 = 7.3457576e22;    % Ay
m3 = 1000;            % Uzay Aracı
m = [m1 m2 m3];       % body mass matrix

%% Yarıçaplar ve yörünge bilgileri
RE = 6.3781366e6;
RM = 1.7374e6;
D_EM = 3.844e8;
r_park_E = RE + 660e3;
r_park_M = RM + 260e3;

%% Açı ve deltaV verisini dış dosyadan al
load('valid_theta_list.mat', 'filtered_theta', 'deltaV');
theta = filtered_theta(99);  % İstediğin açıyı buradan seç

%% Başlangıç vektörü oluşturulması
b0 = initial_conditions(theta, deltaV, G, m1, m2, D_EM, r_park_E);

%% Simülasyon süresi ve çözüm
sim_duration = 3 * 24 * 3600;   
tspan = [0 sim_duration];
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
[T, Y] = ode45(@SystemsOfEquations, tspan, b0, options);




%% Yörüngeleri çiz
figure; hold on; grid on;
plot(Y(:,1), Y(:,2), 'r', 'DisplayName', 'Dünya');
plot(Y(:,7), Y(:,8), 'b', 'DisplayName', 'Ay');
plot(Y(:,13), Y(:,14), 'g', 'DisplayName', 'Uzay Aracı');
legend show;
xlabel('x [m]'); ylabel('y [m]');
axis equal;
title('Dünya-Ay-Uzay Aracı Yörünge Takibi');

% %% --- ANİMASYONLU GÖSTERİM ---
% figure;
% hold on; grid on;
% axis equal;
% xlabel('x [m]'); ylabel('y [m]');
% title('Yörünge Takibi (Animasyon)');
% 
% % Görüş alanı sabit
% xlim([-2e8 8e8]);
% ylim([-2e8 8e8]);
% 
% % Cisim ikonları
% planetD = plot(0, 0, 'b.', 'MarkerSize', 20, 'DisplayName', 'Dünya');
% planetM = plot(0, 0, 'r.', 'MarkerSize', 12, 'DisplayName', 'Ay');
% spacecraft = plot(0, 0, 'k.', 'MarkerSize', 8, 'DisplayName', 'Uzay Aracı');
% 
% % Ay yüzeyi dairesi
% theta_circle = linspace(0, 2*pi, 100);
% moon_surface = plot(0, 0, 'r-', 'LineWidth', 1.2, 'DisplayName', 'Ay Yüzeyi');
% moon_park_orbit=plot(0, 0, 'b-', 'LineWidth', 1.2, 'DisplayName', ' Park Ay Orbit');
% % İz takibi
% traj = animatedline('Color', 'g', 'LineWidth', 1.5);
% legend show;
% 
% % Animasyon döngüsü
% for k = 1:50:length(T)
%     % Koordinatları al
%     xM = Y(k,7); yM = Y(k,8);
% 
%     % Ay yüzey çemberi
%     x_circle = xM + RM * cos(theta_circle);
%     y_circle = yM + RM * sin(theta_circle);
%     %park orbit
%     x_circle2 = xM + r_park_M * cos(theta_circle);
%     y_circle2 = yM + r_park_M * sin(theta_circle);
% 
%     % Güncellemeler
%     set(planetD, 'XData', Y(k,1),  'YData', Y(k,2));
%     set(planetM, 'XData', xM,      'YData', yM);
%     set(spacecraft, 'XData', Y(k,13), 'YData', Y(k,14));
%     set(moon_surface, 'XData', x_circle, 'YData', y_circle);
%     set(moon_park_orbit, 'XData', x_circle2, 'YData', y_circle2);
%     addpoints(traj, Y(k,13), Y(k,14));
%     drawnow;
%     pause(0.06);
% end
% %% --- UZAY ARACI MERKEZLİ ANİMASYON ---(dünyadan ayrılma ay yakalama)
% figure;
% hold on; grid on;
% axis equal;
% xlabel('x [m]'); ylabel('y [m]');
% title('Uzay Aracı Merkezli Animasyon');
% 
% xlim([-5e7 5e7]); 
% ylim([-5e7 5e7]);
% 
% % Grafik objeleri
% planetD = plot(0, 0, 'b.', 'MarkerSize', 20, 'DisplayName', 'Dünya');
% planetM = plot(0, 0, 'r.', 'MarkerSize', 12, 'DisplayName', 'Ay');
% moon_surface = plot(0, 0, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Ay Yüzeyi');
% moon_park_orbit=plot(0, 0, 'b-', 'LineWidth', 1.2, 'DisplayName', ' Park Ay Orbit');
% traj = animatedline('Color', 'g', 'LineWidth', 1.5);
% legend show;
% 
% % Ay yüzeyi çemberi (relatif çizilecek)
% theta_circle = linspace(0, 2*pi, 100);
% spacecraft = plot(0, 0, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k', 'DisplayName', 'Uzay Aracı');
% for k = 1:50:length(T)
% 
% 
%     % Mevcut uzay aracı konumu
%     x_sc = Y(k,13); y_sc = Y(k,14);
% 
%     % Diğer cisimlerin uzay aracına göre konumu
%     xD = Y(k,1) - x_sc;  yD = Y(k,2) - y_sc;
%     xM = Y(k,7) - x_sc;  yM = Y(k,8) - y_sc;
% 
%     % Ay yüzey çemberi (Ay merkezli çiz, uzay aracına göre konumlandır)
%     x_circle = xM + RM * cos(theta_circle);
%     y_circle = yM + RM * sin(theta_circle);
%     %park orbit
%     x_circle2 = xM + r_park_M * cos(theta_circle);
%     y_circle2 = yM + r_park_M * sin(theta_circle);
% 
% 
%     % Güncellemeler
%     set(planetD, 'XData', xD, 'YData', yD);
%     set(planetM, 'XData', xM, 'YData', yM);
%     set(moon_surface, 'XData', x_circle, 'YData', y_circle);
%     set(moon_park_orbit, 'XData', x_circle2, 'YData', y_circle2);
%     addpoints(traj, 0, 0);  % Uzay aracı hep merkezde (0,0)
%     drawnow;
%     pause(0.06);
% end
% 

%% 2. delta V ateşlemesi Ay yörüngesine oturma

% Ay ve uzay aracı arasındaki mesafe
r_diff = sqrt( (Y(:,13) - Y(:,7)).^2 + (Y(:,14) - Y(:,8)).^2 );

[fark, idx] = min(abs(r_diff - r_park_M));

pos_moon = Y(idx, 7:8);
vel_moon = Y(idx, 10:11);

pos_sat = Y(idx, 13:14);
vel_sat = Y(idx, 16:17);


% Gerçek o anki Ay–uzay aracı arası mesafe
r_current = norm(pos_sat - pos_moon);  % uzay aracının aya göre konumunun büyüklüğü

% Çembersel hız büyüklüğü (bu irtifada)
v_circ_mag = sqrt(G * m2 / r_current);

% Tangensiyel birim vektör (saat yönünün tersine)
r_rel_vec = pos_sat - pos_moon;
r_unit = r_rel_vec / norm(r_rel_vec);
t_unit = [-r_unit(2), r_unit(1)];

% Gerekli çembersel hız vektörü
v_circ = v_circ_mag * t_unit;

% Uzay aracının Ay'a göre hız vektörü
v_rel = vel_sat - vel_moon;

% Delta-V hesabı
deltaV = v_circ - v_rel;
deltaV_mag = norm(deltaV);

% Yazdır
fprintf('Gerçek irtifada gereken delta-V: %.3f m/s\n', deltaV_mag);
fprintf('Delta-V vektörü: [%.3f, %.3f] m/s\n', deltaV(1), deltaV(2));

%  Çembersel hız (o irtifada)
v_circ_mag = sqrt(G * m2 / r_current);
r_rel_vec = pos_sat - pos_moon;
r_unit = r_rel_vec / norm(r_rel_vec);
t_unit = [r_unit(2), -r_unit(1)];  % Tangensiyel yön (saat yönü)
v_circ = v_circ_mag * t_unit;

%  Göreli hız ve delta-V hesabı
v_rel = vel_sat - vel_moon;
deltaV = v_circ - v_rel;
deltaV_mag = norm(deltaV);
fprintf('Gerçek irtifada gereken delta-V: %.3f m/s\n', deltaV_mag);

%  Yeni hız (deltaV uygulandı)
vel_sat_new = vel_sat + deltaV;

%  Yeni başlangıç vektörü (Y formatında)
Y_new = Y(idx, :);
Y_new(16:17) = vel_sat_new;

%  Yeni simülasyon
T_M_park=2*pi*sqrt((r_current^3)/(G*m2)); % park orbit period
tspan2 = [0, 2*T_M_park];  % park orbit
[T2, Y2] = ode45(@SystemsOfEquations, tspan2, Y_new, options);

% 7. Görselleştirme
figure; hold on; axis equal; grid on;
plot(Y(:,13), Y(:,14), 'g--', 'DisplayName', 'Önceki Yörünge');
plot(Y2(:,13), Y2(:,14), 'g', 'LineWidth', 1.5, 'DisplayName', 'Ay Yörüngesi (Yakalama sonrası)');
plot(Y2(:,7), Y2(:,8), 'b', 'DisplayName', 'Ay');
% 8. Delta-V uygulama noktası
plot(pos_sat(1), pos_sat(2), 'ro', 'MarkerSize', 1, 'LineWidth', 2, ...
    'DisplayName', 'Delta-V Noktası');

legend show;
xlabel('x [m]'); ylabel('y [m]');
title('2. Delta-V Sonrası Uzay Aracının Ay Yörüngesi');

