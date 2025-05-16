clear; clc;

%% GLOBAL TANIMLAR
global G m n

n = 3;                      % Dünya, Ay, Uzay Aracı
G = 6.6742867e-11;          % Evrensel çekim sabiti

% Kütleler
mE = 5.9721426e24;          % Dünya
mM = 7.3457576e22;          % Ay
m3 = 1000;                  % Uzay aracı
m  = [mE, mM, m3];

%% ORBIT PARAMETRELERİ
RE = 6.3781366e6;
RM = 1.7374e6;
mu_E = G * mE;
D_EM = 3.844e8;
r_park_E = RE + 660e3;
r_park_M = RM + 260e3;

v_circ_E = sqrt(mu_E / r_park_E);
v_esc_E  = sqrt(2 * mu_E / r_park_E);
deltaV   = v_esc_E - v_circ_E + 200;  % impulsive delta-V

%% SİMÜLASYON PARAMETRELERİ
sim_duration = 6 * 24 * 3600;   % [s], 6 gün
tspan = [0 sim_duration];
options = odeset('RelTol',1e-9,'AbsTol',1e-9);

%% AÇI TARAMASI
theta_range = linspace(deg2rad(224), deg2rad(227), 1000);
valid_theta = [];
filtered_theta = [];

for i = 1:length(theta_range)
    theta = theta_range(i);

    % Başlangıç durumu
    b0 = initial_conditions(theta, deltaV, G, mE, mM, D_EM, r_park_E);

    % ODE çözümü
    [T, Y] = ode45(@SystemsOfEquations, tspan, b0, options);

    % Uzay aracı ve Ay konumları
    x_s = Y(:,13); y_s = Y(:,14);
    x_m = Y(:,7);  y_m = Y(:,8);

    % Ay merkezli uzaklık
    r_sM = sqrt((x_s - x_m).^2 + (y_s - y_m).^2);

    % En yakın nokta tespiti
    [min_dist, idx] = min(abs(r_sM - r_park_M));

    if min_dist < 10e3  % ±10 km tolerans
        valid_theta(end+1) = theta;

        % Ay merkezli konum vektörü
        rel_pos = [x_s(idx) - x_m(idx), y_s(idx) - y_m(idx)];

        if rel_pos(1) < 0 && rel_pos(2) > 0
            % 2. bölgede ise filtreli listeye ekle
            filtered_theta(end+1) = theta;
            fprintf('2. bölgede başarılı temas: %.4f rad (%.2f°)\n', theta, rad2deg(theta));
        end
    end
end

% Sonuçları kaydet
if ~isempty(filtered_theta)
    save('valid_theta_list.mat', 'valid_theta', 'filtered_theta', 'deltaV');
    fprintf('Toplam %d başarılı theta bulundu.\n', length(valid_theta));
    fprintf('Bunlardan %d tanesi 2. bölgede.\n', length(filtered_theta));
else
    disp('Uygun theta değeri bulunamadı.');
end
