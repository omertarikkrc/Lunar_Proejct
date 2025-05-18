clc; clear; close all;

%% Parametreler
params;
global m_dry Isp g0 mu_moon R_moon

%% Başlangıç Kütlesi
m_fuel0 = 5500;            % Yakıt kütlesi [kg] 
m0      = m_dry + m_fuel0; % Toplam kütle

%% Thrust Aralığı
T_range = 1000:1000:50000;
results  = nan(numel(T_range),5);
finalY   = cell(numel(T_range),1);

%% 2) Kalkış Simülasyonu ve Δv Arama
for i = 1:numel(T_range)
    T = T_range(i);

    % Başlangıç durumu [x; y; vx; vy; m]
    state0 = [R_moon; 0; 0; 0; m0];

    % 260 km’ye ulaştığında duracak event
    options = odeset('Events', @event_orbit_reached);

    % ODE45 ile kalkış
    [~, Y] = ode45(@(t,Y) ascent_dynamics_pitch(t,Y,T), [0 1000], state0, options);

    % Erken çıkış kontrolü
    if norm(Y(end,1:2)) < R_moon + 260e3 - 1
        results(i,:) = [T, NaN, NaN, NaN, 0];
        continue;
    end

    % Çıkış koşulları
    r_vec       = Y(end,1:2)';
    v_vec       = Y(end,3:4)';
    m_exit      = Y(end,5);
    fuel_remain = m_exit - m_dry;

    % Δv ve yakıt hesabı
    [success, delta_v, fuel_needed, ~, ~, v_new] = ...
        compute_delta_v_and_fuel(r_vec, v_vec, m_exit);

    % Sonucu kaydet
    results(i,:)  = [T, delta_v, fuel_needed, fuel_remain, success];
    finalY{i}     = [r_vec; v_new; m_exit - fuel_needed];
end

%% 3) En iyi senaryoyu seçme
valid = results(results(:,5)==1,:);
if isempty(valid)
    error('Hiçbir thrust değeri başarılı olmadı.');
end
[~, idx] = min(valid(:,3));
best     = valid(idx,:);
bestT    = best(1);

fprintf('→ En iyi thrust: %.0f N\nΔv: %.2f m/s\nYakıtNeeded: %.2f kg\nFuelRemain: %.2f kg\n', ...
        best(1), best(2), best(3), best(4));

%% 4) 2 Tur Circular Yörünge
state_new = finalY{find(T_range==bestT,1)};
r0_orb = norm(state_new(1:2));
v0_orb = norm(state_new(3:4));
T_orb  = 2*pi*r0_orb / v0_orb;
T_tot  = T_orb;

[t_orb, Y_orb] = ode45(@orbit_propagation, [0 T_tot], state_new);

%% 5) Çizim
figure; hold on; axis equal; grid on;

plot(Y_orb(:,1), Y_orb(:,2), 'b','LineWidth',1.2);
plot(Y_orb(1,1), Y_orb(1,2), 'ro','LineWidth',1.2);
plot(Y_orb(end,1), Y_orb(end,2), 'b>','LineWidth',1.2);
plot(R_moon*cos(0:0.01:2*pi), R_moon*sin(0:0.01:2*pi), 'k--');
title('2 period  Circular Park  Orbit (260 km)');
xlabel('x [m]'); ylabel('y [m]');
legend('Uydu Yörüngesi','Başlangıç noktası','Bitiş noktası','Ay Yüzeyi');

%% --- Local Functions ---

function dYdt = ascent_dynamics_pitch(t, Y, T)
    global Isp g0 mu_moon m_dry
    x=Y(1); y=Y(2); vx=Y(3); vy=Y(4); m=Y(5);
    r_vec=[x;y]; r=norm(r_vec);
    r_hat = r_vec/r; tang_hat = [-r_hat(2); r_hat(1)];
    % Pitch profili
    t1=0; t2=300; s=0.02;
    w = 0.5*(1 + tanh(s*(t - (t1+t2)/2)));
    thrust_dir = ((1-w)*r_hat + w*tang_hat); thrust_dir=thrust_dir/norm(thrust_dir);
    % Yakıt akışı
    if m>m_dry && T>0
        mdot = T/(Isp*g0); dm=-mdot;
    else
        dm=0; T=0;
    end
    % İvme
    a_th = (T/m)*thrust_dir;
    a_gr = -mu_moon/r^2 * r_hat;
    a_tot = a_th + a_gr;
    dYdt = [vx; vy; a_tot(1); a_tot(2); dm];
end

function [value, isterm, dir] = event_orbit_reached(t, Y)
    global R_moon
    value      = norm(Y(1:2)) - (R_moon + 260e3);
    isterm     = 1;
    dir        = +1;
end

function [success, dv, fuel, v_circ_vec, dv_vec, v_new] = ...
         compute_delta_v_and_fuel(r_vec, v_vec, m_exit)
    global mu_moon Isp g0 m_dry
    r=norm(r_vec); r_hat=r_vec/r; tang_hat=[-r_hat(2);r_hat(1)];
    v_circ= sqrt(mu_moon/r); v_circ_vec=v_circ*tang_hat;
    dv_vec = v_circ_vec - v_vec; dv=norm(dv_vec);
    if dv<=0
        success=true; fuel=0; v_new=v_vec; return;
    end
    m_after = m_exit * exp(-dv/(Isp*g0));
    fuel    = m_exit - m_after;
    success = (m_after>=m_dry);
    v_new   = v_vec + dv_vec;
end

function dYdt = orbit_propagation(t, Y)
    global mu_moon
    r = norm(Y(1:2));
    a = -mu_moon/r^3 * Y(1:2);
    dYdt = [Y(3); Y(4); a(1); a(2); 0];
end
