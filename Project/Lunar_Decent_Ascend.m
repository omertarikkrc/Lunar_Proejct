clc; clear; close all;

%% === SABİTLER ===
global G mu_moon g0 Isp ve T_const m_dry

G        = 6.67430e-11;             % Evrensel yerçekimi sabiti
mu_moon  = 4.9027692e12;            % Ay'ın çekim parametresi
Rm       = 1.7374e6;                % Ay yarıçapı [m]
g0       = 9.80665;                 % Dünya yerçekimi [m/s^2]
Isp      = 311;                     % Özgül itki [s]
ve       = Isp * g0;                % Egzoz hızı [m/s]
T_const  = 8200;                    % Sabit thrust [N]
m_dry    = 1000;                    % Kuru kütle [kg]

%% === BAŞLANGIÇ DURUMU ===
h_orbit = 260e3;                   % 260 km park yörüngesi
r0 = Rm + h_orbit;                 % Yarıçap [m]
v0 = sqrt(mu_moon / r0);          % Yörünge hızı [m/s]

x0 = r0;
y0 = 0;
vx0 = 0;
vy0 = v0;

m0 = 3000;                        % Başlangıç kütlesi [kg]
Y0 = [x0; y0; vx0; vy0; m0];       % Başlangıç durumu [x y vx vy m]

%% === SİMÜLASYON ===
tspan = [0 500];                   % 900 saniye simülasyon
options = odeset('RelTol',1e-5, 'AbsTol',1e-5);
[t_sol, Y_sol] = ode45(@descent_dynamics, tspan, Y0, options);

%% === YÜKSEKLİK ve HIZ HESABI ===
r_sol = vecnorm(Y_sol(:,1:2), 2, 2);
h_sol = r_sol - Rm;
v_sol = vecnorm(Y_sol(:,3:4), 2, 2);

%% === SONUÇ YAZDIR ===
fprintf('\n--- Simülasyon Sonu ---\n');
fprintf('İniş Yüksekliği: %.2f m\n', h_sol(end));
fprintf('İniş Hızı      : %.2f m/s\n', v_sol(end));
fprintf('Kalan Kütle    : %.2f kg\n', Y_sol(end,5));

%% === GRAFİK ===
figure;
subplot(2,1,1);
plot(t_sol, h_sol, 'b', 'LineWidth', 1.5);
ylabel('İrtifa [m]'); grid on;
title('Yüksekliğin Zamana Göre Değişimi');

subplot(2,1,2);
plot(t_sol, v_sol, 'r', 'LineWidth', 1.5);
xlabel('Zaman [s]');
ylabel('Hız [m/s]'); grid on;
title('Hızın Zamana Göre Değişimi');

fprintf('Harcanan Yakıt: %.2f kg\n', 3000 - Y_sol(end,5));
