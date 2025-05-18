clc;
clear;
close all;

%% Parametreler
params;
global m_dry Isp g0 mu_moon R_moon

%% Başlangıç Kütlesi
m_fuel0 = 4000;            % Yakıt kütlesi [kg]
m0      = m_dry + m_fuel0; % Toplam kütle

%% Thrust Aralığı
T_range = 4000:100:50000;   % N
results = [];                % [T, delta_v, fuel_needed, fuel_remain, success]

for T = T_range
    %% Başlangıç Koşulları
    r0     = [R_moon; 0];      % konum
    v0     = [0; 0];           % hız
    state0 = [r0; v0; m0];     % durum

    %% ODE Çözümü
    Tmax    = 1000;
    options = odeset('Events', @(t,Y) event_orbit_reached(t,Y));
    [t, Y]   = ode45(@(t,Y) ascent_dynamics_pitch(t,Y,T), [0 Tmax], state0, options);

    % Erken çıkış kontrolü
    if norm(Y(end,1:2)) < (R_moon + 260e3 - 1)
        results = [results; T, NaN, NaN, NaN, 0];
        continue;
    end

    %% Çıkış bilgileri
    r_vec      = Y(end,1:2)';   % pozisyon vektörü
    v_vec      = Y(end,3:4)';   % hız vektörü
    m_exit     = Y(end,5);      % kalan kütle
    
    % Kalkış sonrası elde kalan yakıt
    fuel_remain = m_exit - m_dry;

    %% Δv ve yakıt kontrolü
    [success, delta_v, fuel_needed, ~, ~, ~] = ...
        compute_delta_v_and_fuel(r_vec, v_vec, m_exit);

    %% Sonuçları kaydet
    results = [results; T, delta_v, fuel_needed, fuel_remain, success];
end

%% Başarılı senaryoları filtrele
valid = results(results(:,5) == 1, :);

if isempty(valid)
    fprintf('❌ Hiçbir thrust değeri çözüm üretmedi.\n');
else
    % En az yakıt kullanan senaryo
    [~, idx] = min(valid(:,3));
    best = valid(idx,:);
    fprintf('\n EN İYİ SONUÇ:\n Thrust       = %.0f N\n Δv          = %.2f m/s\n YakıtNeeded = %.2f kg\n FuelRemain  = %.2f kg\n', ...
            best(1), best(2), best(3), best(4));
end

%% Sonuç tablosunu yazdır
fprintf('\n--- Tüm Sonuçlar ---\n');
fprintf('Thrust (N)\tΔv (m/s)\tFuelNeeded(kg)\tFuelRemain(kg)\tBaşarılı\n');
for i = 1:size(results,1)
    fprintf('%10.0f\t%8.2f\t%14.2f\t%14.2f\t%3d\n', ...
            results(i,1), results(i,2), results(i,3), results(i,4), results(i,5));
end

%% Dinamik Fonksiyon (Thrust parametreli)
function dYdt = ascent_dynamics_pitch(t, Y, T)
    global Isp g0 mu_moon m_dry

    x = Y(1); y = Y(2);
    vx= Y(3); vy= Y(4);
    m = Y(5);

    r_vec = [x; y]; r = norm(r_vec);
    r_hat = r_vec/r; tang_hat = [-r_hat(2); r_hat(1)];

    % Pitch profili
    t1=0; t2=300; s=0.02;
    w = 0.5*(1 + tanh(s*(t-(t1+t2)/2)));
    thrust_dir = ((1-w)*r_hat + w*tang_hat); thrust_dir = thrust_dir/norm(thrust_dir);

    % Yakıt akışı
    if m>m_dry && T>0
        mdot = T/(Isp*g0);
        dm = -mdot;
    else
        T = 0; dm = 0;
    end

    % İvme
    a_thrust  = T/m * thrust_dir;
    a_gravity = -mu_moon/r^2 * r_hat;
    a_total   = a_thrust + a_gravity;

    dYdt = [vx; vy; a_total(1); a_total(2); dm];
end

%% Event: 260 km irtifaya ulaşınca dur
function [value, isterminal, direction] = event_orbit_reached(~, Y)
    global R_moon
    r = norm(Y(1:2));
    value      = r - (R_moon + 260e3);
    isterminal = 1;
    direction  = +1;
end

%% Δv ve yakıt hesap fonksiyonu
function [success, delta_v, fuel_needed, v_circ_vec, delta_v_vec, v_new_vec] = ...
    compute_delta_v_and_fuel(r_vec, v_vec, m_exit)
    global mu_moon Isp g0 m_dry

    r_norm = norm(r_vec);
    r_hat  = r_vec/r_norm; tang_hat = [-r_hat(2); r_hat(1)];
    v_circ = sqrt(mu_moon/r_norm); v_circ_vec = v_circ*tang_hat;

    delta_v_vec = v_circ_vec - v_vec;
    delta_v     = norm(delta_v_vec);

    if delta_v <= 0
        fuel_needed = 0; v_new_vec = v_vec; success = true;
        return;
    end

    m_after     = m_exit * exp(-delta_v/(Isp*g0));
    fuel_needed = m_exit - m_after;
    success     = (m_after >= m_dry);
    v_new_vec   = v_vec + delta_v_vec;
end
