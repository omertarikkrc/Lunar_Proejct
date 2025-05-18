% --- Parametreleri Yükle ---
params;  % G, mu_Moon, Rm, h_safe, T_max, Isp, g0, Y0 tanımlı

% --- FAZ1 için ek eşik ---
vtheta_thresh = 0.1;    % Tangensiyel hız sıfır kabul eşiği [m/s]

% --- Çözüm Aralığı ve Seçenekler ---
tspan = [0 1e4];        % Başlangıç–bitiş zamanı [s]
options = odeset( ...
    'Events', @(t,Y) phase1Events(t,Y,h_safe,mu_Moon,Rm,vtheta_thresh), ...
    'RelTol',1e-6, ...
    'AbsTol',1e-8);

% --- ODE’yi Çalıştır ---
[t1, Y1, te, Ye, ie] = ode45( ...
    @(t,Y) phase1Dynamics(t,Y,mu_Moon,Rm,h_safe,T_max,Isp,g0,vtheta_thresh), ...
    tspan, Y0, options);
