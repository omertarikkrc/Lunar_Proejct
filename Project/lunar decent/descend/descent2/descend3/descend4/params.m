% params.m
% Ay yüzeyine iniş simülasyonu için sabit ve parametre tanımları

global G R_moon M_moon mu_moon ...
       R_earth M_earth mu_earth ...
       h0 v_max m_dry Isp g0

% Evrensel çekim sabiti
G       = 6.6742867e-11;        % [m^3/(kg·s^2)]

% Ay parametreleri
R_moon  = 1.7374000e6;         % Ay yarıçapı [m]
M_moon  = 7.3457576e22;        % Ay kütlesi [kg]
mu_moon = G * M_moon;          % Ay yerçekimi parametresi [m^3/s^2]

% (Gerekirse) Dünya parametreleri
R_earth = 6.3781366e6;         % Dünya yarıçapı [m]
M_earth = 5.9721426e24;        % Dünya kütlesi [kg]
mu_earth = G * M_earth;        % Dünya yerçekimi parametresi [m^3/s^2]

% Başlangıç yörünge irtifası
h0      = 260e3;               % [m]

% İniş koşulu
v_max   = 3;                   % Maksimum iniş hızı [m/s]

% Araç kütleleri ve itki
m_dry   = 1000;                % Kuru kütle [kg]
Isp     = 311;                 % İtkinin özgül darbesi [s]  (örnek değer; sen uygun Isp’yi gir)
g0      = 9.80665;             % Standart yerçekimi ivmesi [m/s^2]
