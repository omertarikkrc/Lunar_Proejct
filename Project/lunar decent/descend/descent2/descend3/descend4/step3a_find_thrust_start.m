clear; clc; close all;
params;

%% Eliptik yörünge tanımı
ra     = R_moon + h0;
delta  = deg2rad(30);           
phi210 = pi + delta;
r_210  = R_moon;

e = (ra - r_210) / (ra + r_210 * cos(phi210));
a = ra / (1 + e);
p = a * (1 - e^2);

%% Apogee konumu ve hız (ΔV sonrası)
r0    = [-ra; 0];
v_ap  = sqrt(mu_moon*(2/ra - 1/a));  % eliptik hız
v0    = [0; v_ap];                   % +y yönü (saat yönü)

y0    = [r0; v0];

%% ODE çözümü (r = R_moon + 10 km'de duracak)
opts = odeset('Events', @(t,y) event_10km_altitude(t,y,R_moon), ...
              'RelTol',1e-8, 'AbsTol',1e-9);
[t_out, Y_out] = ode45(@(t,y) twobody(t,y,mu_moon), [0 10000], y0, opts);

% thrust başlama anı
r_thrust = Y_out(end,1:2)';
v_thrust = Y_out(end,3:4)';
t_thrust = t_out(end);

%% Görselleştirme
theta = linspace(0,2*pi,500);
x_lunar_park=(R_moon+260e3) * cos(theta);
y_lunar_park=(R_moon+260e3) * sin(theta);
x_moon = R_moon * cos(theta);
y_moon = R_moon * sin(theta);

figure; hold on; axis equal; grid on;
plot(x_moon, y_moon, 'k-', 'LineWidth',1.5);             % Ay
plot(Y_out(:,1), Y_out(:,2), 'm-', 'LineWidth', 1.5);     % Yörünge
plot(r_thrust(1), r_thrust(2), 'ro', 'MarkerSize',2, 'LineWidth',1.5); % thrust başlangıç
plot(x_lunar_park, y_lunar_park, 'b--', 'LineWidth',1);   %lunar park orbit

scale=100000;% okun magnitude unu gormek icin yaptim
dir_thrust = -v_thrust / norm(v_thrust); % hiz vektor zıddı
quiver(r_thrust(1), r_thrust(2), dir_thrust(1)*scale, dir_thrust(2)*scale, 0, ...
       'g','LineWidth',1.5,'MaxHeadSize',2);
xlabel('x [m]'); ylabel('y [m]');

title('Adım 3A: Thrust Başlangıç Noktası (Eliptik Yörünge Sonrası)');
legend('Ay yüzeyi','Eliptik Yörünge','Thrust Başlangıcı',"Lunar Park Orbit","hız vektörünün tersi ",'Location','Best');
fprintf("Thrust başlama zamanı: %.2f s\n", t_thrust);
fprintf("Konum: [%.1f, %.1f] m\n", r_thrust(1), r_thrust(2));
fprintf("Hız:    [%.2f, %.2f] m/s\n", v_thrust(1), v_thrust(2));



function dydt = twobody(~, y, mu)
    r = y(1:2); v = y(3:4);
    a_grav = -mu / norm(r)^3 * r;
    dydt = [v; a_grav];
end

function [value, isterm, direction] = event_10km_altitude(~, y, Rm)
    value = norm(y(1:2)) - (Rm + 10e3);
    isterm = 1;
    direction = -1;
end
