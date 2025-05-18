clc;
clear;
close all;

%% Parametreler
params;
global m_dry Isp g0 mu_moon R_moon

%% Başlangıç Kütlesi
m_fuel0 = 4000;            % Yakıt kütlesi [kg]
m0 = m_dry + m_fuel0;     % Toplam kütle

%% Thrust Aralığı
T_range = 15000:1000:30000;   % N
found = false;

for T = T_range
    %% Başlangıç Koşulları
    r0 = [R_moon; 0];          % konum
    v0 = [0; 0];               % hız
    state0 = [r0; v0; m0];     % durum

    %% ODE Çözümü
    Tmax = 1000;
    options = odeset('Events', @(t,Y) event_orbit_reached(t,Y));
    [t, Y] = ode45(@(t,Y) ascent_dynamics_pitch(t,Y,T), [0 Tmax], state0, options);

    % Eğer irtifaya ulaşılamadıysa (erken çıkış), döngüyü kır
    if norm(Y(end,1:2)) < (R_moon + 260e3 - 1)
        fprintf('Thrust %.0f N yetersiz, irtifaya ulaşılamadı. Döngü durduruluyor.\n', T);
        break;
    end

    % Çıkış bilgileri
    r_vec = Y(end,1:2)';
    v_vec = Y(end,3:4)';
    r_exit = norm(r_vec);
    v_exit = norm(v_vec);
    m_exit = Y(end,5);

    % Δv ve yakıt kontrolü
    [success, delta_v, fuel_needed] = compute_delta_v_and_fuel(v_exit, r_exit, m_exit);

    if success
        fprintf('Uygun thrust bulundu! T = %.0f N, deltav = %.2f m/s, Yakıt = %.2f kg\n', T, delta_v, fuel_needed);
        found = true;
        break;
    else
        fprintf('T = %.0f N → deltav = %.2f m/s ama yakıt yetmiyor (%.2f kg gerek)\n', T, delta_v, fuel_needed);
    end
end

if ~found
    fprintf(' Hiçbir thrust değeri çözüm üretmedi.');
end

%% Dinamik Fonksiyon (Thrust parametreli)
function dYdt = ascent_dynamics_pitch(t, Y, T)
    global Isp g0 mu_moon m_dry

    x = Y(1); y = Y(2);
    vx = Y(3); vy = Y(4);
    m  = Y(5);

    r_vec = [x; y];
    r = norm(r_vec);
    r_hat = r_vec / r;
    tang_hat = [-r_hat(2); r_hat(1)];

    % Pitch profili
    t1 = 0; t2 = 300; s = 0.02;
    w = 0.5 * (1 + tanh(s*(t - (t1 + t2)/2)));
    thrust_dir = (1 - w) * r_hat + w * tang_hat;
    thrust_dir = thrust_dir / norm(thrust_dir);

    % Yakıt akışı
    if m > m_dry && T > 0
        mdot = T / (Isp * g0);
        dm = -mdot;
    else
        T = 0; dm = 0;
    end

    a_thrust = T / m * thrust_dir;
    a_gravity = -mu_moon / r^2 * r_hat;
    a_total = a_thrust + a_gravity;

    dYdt = [vx;
            vy;
            a_total(1);
            a_total(2);
            dm];
end

%% Event
function [value, isterminal, direction] = event_orbit_reached(~, Y)
    global R_moon
    r = norm(Y(1:2));
    value = r - (R_moon + 260e3);
    isterminal = 1;
    direction = +1;
end

%% Δv ve yakıt fonksiyonu
function [success, delta_v, fuel_needed] = compute_delta_v_and_fuel(v_exit, r_exit, m_exit)
    global mu_moon Isp g0 m_dry

    v_circ = sqrt(mu_moon / r_exit);
    delta_v = v_circ - v_exit;

    if delta_v <= 0
        success = true;
        fuel_needed = 0;
        return;
    end

    m_after = m_exit * exp(-delta_v / (Isp * g0));
    fuel_needed = m_exit - m_after;

    success = (m_after >= m_dry);
end
