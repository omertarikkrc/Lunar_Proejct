clear; clc;

%% Parametreler
G  = 6.6742867e-11;
mE = 5.9721426e24;
mM = 7.3457576e22;
RE = 6.3781366e6;
RM = 1.7374e6;
mu_E = G * mE;
D_EM = 3.844e8;
r_park_E = RE + 660e3;
r_park_M = RM + 260e3;

v_circ_E = sqrt(mu_E / r_park_E);
v_esc_E  = sqrt(2 * mu_E / r_park_E);
deltaV   = v_esc_E - v_circ_E;  % impulsive delta-V

sim_duration = 4 * 24 * 3600;   % [s], 4 gün
tspan = [0 sim_duration];
options = odeset('RelTol',1e-9,'AbsTol',1e-9);

%% Tarama ayarları
theta_range = linspace(0, 2*pi, 100);
success = false;

for i = 1:length(theta_range)
    theta = theta_range(i);
    
    % Başlangıç durumu
    b0 = initial_conditions(theta, deltaV, G, mE, mM, D_EM, r_park_E);

    % ODE çözümü
    [T, Y] = ode45(@SystemsOfEquations, tspan, b0, options);

    % Uzay aracının pozisyonları
    x_s = Y(:,13);
    y_s = Y(:,14);
    r_sM = sqrt((x_s - Y(:,7)).^2 + (y_s - Y(:,8)).^2);  % Araç-Ay arası mesafe

    % Ay park yörüngesine giriş kontrolü
    if any(abs(r_sM - r_park_M) < 10e3)  % ±10 km tolerans
        fprintf('Başarılı temas açısı: %.4f rad (%.2f°)\n', theta, rad2deg(theta));
        success = true;
        break
    end
end

if ~success
    disp('Hiçbir theta değeriyle başarılı temas sağlanamadı.');
end
