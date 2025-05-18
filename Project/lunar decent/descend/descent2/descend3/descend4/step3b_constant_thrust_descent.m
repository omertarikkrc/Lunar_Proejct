clear; clc;
params;

%% Başlangıç (Adım 3A'dan elde edilen veriler)
ra     = R_moon + h0;
delta  = deg2rad(30);
phi210 = pi + delta;
r_210  = R_moon;

e = (ra - r_210) / (ra + r_210 * cos(phi210));
a = ra / (1 + e);
p = a * (1 - e^2);

% Apogee'den eliptik hıza geçtikten sonra 10 km irtifada gelinen nokta
r0     = [-ra; 0];
v_ap   = sqrt(mu_moon*(2/ra - 1/a));
v0     = [0; v_ap];
y0_elliptic = [r0; v0];

% Bu noktadan 10 km irtifaya kadar yerçekimiyle ilerle
opts1 = odeset('Events', @(t,y) event_10km_altitude(t,y,R_moon), ...
               'RelTol',1e-6,'AbsTol',1e-6);
[~, Y_before_thrust] = ode45(@(t,y) twobody(t,y,mu_moon), [0 10000], y0_elliptic, opts1);

r_init = Y_before_thrust(end,1:2)';
v_init = Y_before_thrust(end,3:4)';
m0     = m_dry + 5000;  % istenirse arttırılabilir
y0     = [r_init; v_init; m0];

%% Thrust araması
T_vals = linspace(4000, 400000, 10000);  % N
T_found = NaN; v_touch = NaN;

for T = T_vals
    opts2 = odeset('Events', @(t,y) event_touchdown(t,y,R_moon), ...
                   'RelTol',1e-5,'AbsTol',1e-5);
    [t, Y] = ode45(@(t,y) thrust_dynamics(t,y,mu_moon,T,Isp,g0), [0 1000], y0, opts2);
    v_end = norm(Y(end,3:4));
    if v_end <= v_max
        T_found = T;
        v_touch = v_end;
        t_final = t;
        traj = Y;
        break;
    end
end

if isnan(T_found)
    error('Uygun thrust değeri bulunamadı. Aralığı genişletin.');
end

fprintf('Bulunan itki: %.1f N\nİniş hızı: %.2f m/s\n', T_found, v_touch);

%% Grafik
theta = linspace(0,2*pi,300);
x_moon = R_moon*cos(theta);
y_moon = R_moon*sin(theta);

figure; hold on; axis equal; grid on;
plot(x_moon, y_moon, 'k-', 'LineWidth', 1.5);
plot(traj(:,1), traj(:,2), 'r-', 'LineWidth', 1.5);
plot(r_init(1), r_init(2), 'bo', 'MarkerSize',8, 'LineWidth', 1.5);

xlabel('x [m]'); ylabel('y [m]');
title('Adım 3B: Sabit İtkiyle İniş');
legend('Ay Yüzeyi','İniş Trajektoryası','Thrust Başlangıcı','Location','Best');


function dydt = thrust_dynamics(~, y, mu, T, Isp, g0)
    r = y(1:2); v = y(3:4); m = y(5);
    a_grav = -mu / norm(r)^3 * r;
    dir_thrust = -v / norm(v);  % hızın tersi yön
    a_thrust = (T/m) * dir_thrust;
    mdot = -T / (Isp * g0);
    dydt = [v; a_grav + a_thrust; mdot];
end

function [value, isterm, direction] = event_touchdown(~, y, Rm)
    value = norm(y(1:2)) - Rm;
    isterm = 1;
    direction = -1;
end

function [value, isterm, direction] = event_10km_altitude(~, y, Rm)
    value = norm(y(1:2)) - (Rm + 10e3);
    isterm = 1;
    direction = -1;
end

function dydt = twobody(~, y, mu)
    r = y(1:2); v = y(3:4);
    dydt = [v; -mu / norm(r)^3 * r];
end
