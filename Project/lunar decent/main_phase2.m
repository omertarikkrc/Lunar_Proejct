%% main_phase2.m – FAZ 2: Serbest Düşüş (events olmadan)
clc; clear; close all;
global G m Rm

% 1) Phase 1’den yüklenen son durum
data = load('phase1_end.mat','Y_sol');
Y1_end = data.Y_sol(end,:);

% 2) Sabitler ve kütleler
G  = 6.67430e-11;
Rm = 1.7374e6;
m  = [7.3457576e22, 1000];

% 3) Serbest düşüş denklemi (thrust yok)
tspan = [0 1e6];  
options = odeset('RelTol',1e-6, 'AbsTol',1e-6);
[t2, Y2] = ode45(@freeFall_dynamics, tspan, Y1_end, options);

% 4) h ve v dizileri
pos_s = Y2(:,5:6);
vel_s = Y2(:,7:8);
h2 = vecnorm(pos_s,2,2) - Rm;
v2 = vecnorm(vel_s,2,2);

% 5) h<4000 m olan ilk indeks
idx4000 = find(h2 <= 4000, 1, 'first');
if isempty(idx4000)
    error('4000 m seviyesine kadar düşüş gerçekleşmedi.');
end

% 6) O anki durum
t_at4km  = t2(idx4000);
Y_at4km  = Y2(idx4000,:);
h_at4km  = h2(idx4000);
v_at4km  = v2(idx4000);
m_at4km  = Y_at4km(9);

% 7) Sonuçları yazdır
fprintf('\n--- FAZ 2 SONU (4 km DÜŞÜŞ) ---\n');
fprintf('Zaman       : %.2f s\n', t_at4km);
fprintf('İrtifa      : %.2f m\n', h_at4km);
fprintf('Hız         : %.2f m/s\n', v_at4km);
fprintf('Kalan kütle : %.2f kg\n', m_at4km);

% 8) Grafik
figure('Name','FAZ 2: Serbest Düşüş','NumberTitle','off');
subplot(2,1,1);
plot(t2, h2,'b','LineWidth',1.5); grid on;
xlabel('Zaman [s]'); ylabel('İrtifa [m]');
title('FAZ 2: Serbest Düşüş – İrtifa');

subplot(2,1,2);
plot(t2, v2,'r','LineWidth',1.5); grid on;
xlabel('Zaman [s]'); ylabel('Hız [m/s]');
title('FAZ 2: Serbest Düşüş – Hız');
