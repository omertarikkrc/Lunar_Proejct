% main_lunar_descent.m – 3 Fazlı Ay İnişi

clc; clear; close all;
run descent_params;    % Sabitler ve eşikler

%% --- Başlangıç Durumu (260 km yörünge)
x0 = Rm + 260e3; y0 = 0;
vx0 = 0; vy0 = sqrt(mu_moon/x0);  
m0  = m_dry + 4000;     % Örnek yakıt yükü

Y0 = [0,0, 0,0, x0,y0, vx0,vy0, m0];

%% --- FAZ 1
opts1 = odeset('RelTol',1e-6,'AbsTol',1e-6, 'Events',@phase1_events);
[t1,Y1,te1,Ye1,ie1] = ode45(@phase1_dynamics, [0 3600], Y0, opts1);

% Faz-1’in bitiş durumu
Y1_end = Ye1;           % [1×9] vektör
fprintf('Faz1 bitti: t=%.1f s, h=%.0f m\n', te1, norm(Y1_end(5:6))-Rm);

%% --- FAZ 2
opts2 = odeset('RelTol',1e-6,'AbsTol',1e-6, 'Events',@phase2_events);
[t2,Y2,te2,Ye2,ie2] = ode45(@phase2_dynamics, [te1 1e5], Y1_end, opts2);

Y2_end = Ye2;
fprintf('Faz2 bitti: t=%.1f s, h=%.0f m\n', te2, norm(Y2_end(5:6))-Rm);

%% --- FAZ 3
opts3 = odeset('RelTol',1e-6,'AbsTol',1e-6, 'Events',@phase3_events);
[t3,Y3,te3,Ye3,ie3] = ode45(@phase3_dynamics, [te2 1e5], Y2_end, opts3);

Y3_end = Ye3;
fprintf('Faz3 bitti: t=%.1f s, v=%.2f m/s\n', te3, norm(Y3_end(7:8)));

%% --- Son Grafikler
figure('Name','Ay İnişi Fazları','NumberTitle','off');
subplot(3,1,1);
plot(t1, vecnorm(Y1(:,5:6),2,2)-Rm); grid on;
ylabel('h [m]'); title('Faz 1: Frenleme ve İrtifa Koruma');

subplot(3,1,2);
plot(t2, vecnorm(Y2(:,5:6),2,2)-Rm); grid on;
ylabel('h [m]'); title('Faz 2: Serbest Düşüş');

subplot(3,1,3);
plot(t3, vecnorm(Y3(:,7:8),2,2)); grid on;
ylabel('v [m/s]'); xlabel('t [s]');
title('Faz 3: Yumuşak İniş – Düşey Hız');
