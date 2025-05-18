clc; clear; close all;

%% === GLOBAL DEĞİŞKENLER ===
global G m T_const Isp g0 ve Rm

% Fiziksel sabitler
G       = 6.67430e-11;        % Evrensel çekim sabiti
Rm      = 1.7374e6;           % Ay yarıçapı [m]
Isp     = 311;                % Özgül itki [s]
g0      = 9.80665;            % Dünya yerçekimi [m/s^2]
ve      = Isp * g0;           % Egzoz hızı
T_const = 12000;               % Sabit thrust [N]

% Kütleler
m_moon = 7.3457576e22;        % Ay kütlesi [kg]
m_dry  = 1000;                % Uzay aracı kuru kütle
m0     = 5000;                % Başlangıç kütle (yakıt dahil)
m = [m_moon, m_dry];          % Global vektör

%% === BAŞLANGIÇ DURUMU ===

% Ay sabit merkezde (veya duruyor)
x_m = 0; y_m = 0;
vx_m = 0; vy_m = 0;

% Uzay aracı 260 km irtifada, yörünge hızıyla başlıyor
r0 = Rm + 260e3;
x_s = r0; y_s = 0;
vx_s = 0; vy_s = sqrt(G * m_moon / r0);  % Dairesel yörünge

Y0 = [x_m, y_m, vx_m, vy_m, x_s, y_s, vx_s, vy_s, m0];

%% === ODE ÇÖZÜM ===
tspan = [0 1500];  % yeterli süre
options = odeset('RelTol',1e-8, 'AbsTol',1e-8);
[t_sol, Y_sol] = ode45(@SystemsOfEquations, tspan, Y0, options);

%% === HESAPLAMA ===
% Ay merkezli hız ve konum
pos_m = Y_sol(:,1:2);
pos_s = Y_sol(:,5:6);
vel_s = Y_sol(:,7:8);
rel_pos = pos_s - pos_m;
rel_vel = vel_s;  %  Ay sabit kabul ediliyor


% Tangensiyel hız bileşeni
r_unit = rel_pos ./ vecnorm(rel_pos,2,2);
t_unit = [-r_unit(:,2), r_unit(:,1)];
v_t = sum(rel_vel .* t_unit, 2);
save('phase1_end.mat','Y_sol');
%% === GRAFİK ===
figure;
subplot(3,1,1);
plot(t_sol, v_t, 'r', 'LineWidth', 1.5); grid on;
xlabel('Zaman [s]'); ylabel('Tangensiyel Hız [m/s]');
title('FAZ 1: Tangensiyel Hızın Azalması');

subplot(3,1,2);
plot(t_sol, Y_sol(:,9), 'b', 'LineWidth', 1.5); grid on;
xlabel('Zaman [s]'); ylabel('Kütle [kg]');
title('Kütlenin Azalması (Yakıt Tüketimi)');

% --- Yükseklik hesabı (Ay merkezli)
% pos_s zaten Y_sol(:,5:6) ile tanımlı, Rm da global
rel_pos = Y_sol(:,5:6) - Y_sol(:,1:2);   % Ay sabit → aynısı pos_s
h_sol   = vecnorm(rel_pos,2,2) - Rm;     % [m]

% --- İrtifa – Zaman Grafiği
subplot(3,1,3);
plot(t_sol, h_sol, 'LineWidth', 1.5);
grid on;
xlabel('Zaman [s]');
ylabel('İrtifa [m]');
title('FAZ 1: Yüksekliğin Zamana Göre Değişimi');
