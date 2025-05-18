clear; clc; close all;
params;

%% 1. Eliptik Yörünge Tanımı (Apogee → 210° noktası)
ra     = R_moon + h0;
delta  = deg2rad(30);
phi210 = pi + delta;
r_210  = R_moon;

e = (ra - r_210) / (ra + r_210 * cos(phi210));
a = ra / (1 + e);
p = a * (1 - e^2);

%% 2. Apogee’den başla → eliptik yörüngeye geç
r0     = [-ra; 0];
v_ap   = sqrt(mu_moon*(2/ra - 1/a));
v0     = [0; v_ap];
y0_elliptic = [r0; v0];

% ODE ile sadece 10 km irtifaya kadar çöz
opts1 = odeset('Events', @(t,y) event_10km_altitude(t,y,R_moon), ...
               'RelTol',1e-6,'AbsTol',1e-6);
[t1, Y1] = ode45(@(t,y) twobody(t,y,mu_moon), [0 10000], y0_elliptic, opts1);

% 10 km noktasındaki konum ve hız
r_init = Y1(end,1:2)';
v_init = Y1(end,3:4)';
m0     = m_dry + 5000;
y0     = [r_init; v_init; m0];

%% 3. For döngüsüyle sabit thrust ile inişi bul
T_vals = linspace(4000, 400000, 10000);  % N
T_found = NaN;

for T = T_vals
    opts2 = odeset('Events', @(t,y) event_touchdown(t,y,R_moon), ...
                   'RelTol',1e-5,'AbsTol',1e-5);
    [t2, Y2] = ode45(@(t,y) thrust_dynamics(t,y,mu_moon,T,Isp,g0), [0 1000], y0, opts2);
    v_end = norm(Y2(end,3:4));
    if v_end <= v_max
        T_found = T;
        traj = Y2;
        break;
    end
end

if isnan(T_found)
    error('Uygun itki değeri bulunamadı.');
end

fprintf(' Bulunan itki: %.1f N\n İniş hızı: %.2f m/s\n', T_found, v_end);

%% 4. Grafik (tek figürde tüm yörünge)
theta = linspace(0,2*pi,500);
x_moon = R_moon*cos(theta);
y_moon = R_moon*sin(theta);
x_circ = (R_moon+h0)*cos(theta);
y_circ = (R_moon+h0)*sin(theta);

% Eliptik yörüngenin sadece apogee → 10 km arası kısmı
phi_start = pi;
phi_end = acos((p / (R_moon + 10e3) - 1) / e);  % true anomaly sınırı
phi_range = linspace(phi_start, phi_end, 300);
r_phi     = p ./ (1 + e*cos(phi_range));
x_ell     = r_phi .* cos(phi_range);
y_ell     = r_phi .* sin(phi_range);

% Plot
figure; hold on; axis equal; grid on;
plot(x_moon, y_moon, 'k-', 'LineWidth', 1.5);               % Ay yüzeyi
plot(x_circ, y_circ, 'b--', 'LineWidth', 1);                % Lunar Park orbit
plot(x_ell, y_ell, 'm-', 'LineWidth', 1.5);                 % Eliptik segment
plot(traj(:,1), traj(:,2), 'r-', 'LineWidth', 1.8);         % İniş
plot(r_init(1), r_init(2), 'ro', 'MarkerSize',6,'LineWidth',1.5); % Thrust başlangıcı

% Hız vektörünün ters yönü (thrust yönü)
scale = 5e3;
v_hat = -v_init / norm(v_init);
quiver(r_init(1), r_init(2), v_hat(1)*scale, v_hat(2)*scale, ...
       0, 'g', 'LineWidth', 1.5, 'MaxHeadSize', 2);

xlabel('x [m]'); ylabel('y [m]');
title('Adım 3: Park Orbit → Eliptik Transfer → Sabit Thrust ile İniş');
legend('Ay Yüzeyi','Park Orbit','Eliptik Yörünge','İniş Yolu',...
       'Thrust Başlangıcı','10km altitute thrust direction','Location','Best');

%% 5. Yakıt Hesapları
m_f = traj(end,5);                      % yüzeye temas anındaki kütle
yakit_kalan = m_f - m_dry;
yakit_harcanan = m0 - m_f;

fprintf("\n===  Yakıt Bilgileri ===\n");
fprintf("Başlangıç kütlesi (thrust öncesi): %.2f kg\n", m0);
fprintf("Kalan kütle (iniş sonunda): %.2f kg\n", m_f);
fprintf("Harcanan yakıt: %.2f kg\n", yakit_harcanan);
fprintf("Kalan yakıt: %.2f kg\n", yakit_kalan);



%% 6. Zaman Bazlı Grafikler (Yükseklik ve Hız)

r_vec = traj(:,1:2);                     % konumlar
v_vec = traj(:,3:4);                     % hızlar
r_norm = vecnorm(r_vec, 2, 2);           % |r| = yükseklik + R_moon
altitude = r_norm - R_moon;             % gerçek yükseklik
speed = vecnorm(v_vec, 2, 2);           % hız büyüklüğü

figure;
subplot(2,1,1);
plot(t2, altitude/1e3, 'b-', 'LineWidth',1.5);
xlabel('Zaman [s]');
ylabel('Yükseklik [km]');
title('Yükseklik – Zaman');
grid on;

subplot(2,1,2);
plot(t2, speed, 'r-', 'LineWidth',1.5);
xlabel('Zaman [s]');
ylabel('Hız [m/s]');
title('Hız – Zaman');
grid on;

%% 7. Apogee'den Ay yüzeyine tam animasyon

% 1. Apogee → 10 km segmenti
r1 = Y1(:,1:2);
t1 = t1;  % eliptik süre

% 2. 10 km → yüzey iniş segmenti
r2 = traj(:,1:2);
t2 = t2 + t1(end);  % zamanları birleştirirken t2'yi kaydır

% 3. Birleştir
r_full = [r1; r2];
t_full = [t1; t2];

% 4. Ay yüzeyi
theta = linspace(0,2*pi,300);
x_moon = R_moon*cos(theta);
y_moon = R_moon*sin(theta);

% 5. Animasyon
figure('Color','w');
hold on; axis equal; grid on;
plot(x_moon, y_moon, 'k-', 'LineWidth',1.5);          % Ay yüzeyi
plot(r_full(:,1), r_full(:,2), 'r--');                % tam yol
marker = plot(r_full(1,1), r_full(1,2), 'ro', 'MarkerSize',8, 'MarkerFaceColor','r');

xlim([min(r_full(:,1))-5e4, max(r_full(:,1))+5e4]);
ylim([min(r_full(:,2))-5e4, max(r_full(:,2))+5e4]);
title('Tam İniş Animasyonu: Apogee → Ay Yüzeyi');

for i = 1:5:length(r_full)
    set(marker, 'XData', r_full(i,1), 'YData', r_full(i,2));
    pause(0.3);
end


%% function definitions
function dydt = twobody(~, y, mu)
    r = y(1:2); v = y(3:4);
    dydt = [v; -mu / norm(r)^3 * r];
end

function dydt = thrust_dynamics(~, y, mu, T, Isp, g0)
    r = y(1:2); v = y(3:4); m = y(5);
    a_grav = -mu / norm(r)^3 * r;
    dir_thrust = -v / norm(v);  % hızın tersi yön
    a_thrust = (T/m) * dir_thrust;
    mdot = -T / (Isp * g0);
    dydt = [v; a_grav + a_thrust; mdot];
end

function [value,isterminal,direction] = event_10km_altitude(~, y, Rm)
    value = norm(y(1:2)) - (Rm + 10e3);
    isterminal = 1;
    direction = -1;
end

function [value,isterminal,direction] = event_touchdown(~, y, Rm)
    value = norm(y(1:2)) - Rm;
    isterminal = 1;
    direction = -1;
end
