% descent_params.m

% Ay sabitleri
global G mu_moon Rm g0
G       = 6.67430e-11;
mu_moon = 4.9027692e12;
Rm      = 1.7374e6;
g0      = 9.80665;

% Roket sabitleri
global Isp ve T_const
Isp     = 311;
ve      = Isp*g0;
T_const = 12000;

% Faz geçiş eşikleri (parametrik)
global h1_safe h2_start h2_end h3_end v3_target
h1_safe   = 5e3;    % Phase-1 sonunda korumamız gereken min irtifa
h2_start  = 30e3;   % Phase-2 başlangıcı (yuk.), = Phase-1’in bitiş irtifası
h2_end    = 5e3;    % Phase-2 bitiş, Phase-3 baş. irtifası
h3_end    = 0;      % Yüzey
v3_target = 3;      % m/s
