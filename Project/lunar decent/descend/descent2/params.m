%% Part 2: Ay Yüzeyine İniş ve Geri Yörüngeye Çıkış
clear; clc; close all;
global G
G = 6.67430e-11;            % Evrensel çekim sabiti [m^3/kg/s^2]

%% Ay Parametreleri
Rm        = 1.7374e6;       % Ay yarıçapı [m]
mu_Moon   = 4.9028e12;      % Ay'un kütle çekim parametresi [m^3/s^2]

%% Başlangıç Yörünge Koşulları
h_park    = 260e3;          % Park yörünge irtifası [m]
r0        = Rm + h_park;    % Başlangıç yarıçap [m]
theta0    = 0;              % Başlangıç açısı [rad]
vtheta0   = sqrt(mu_Moon/r0); % Dairesel yörünge hızı [m/s]
vr0       = 0;              % Başlangıç radyal hız [m/s]

%% Kütle ve İtki Parametreleri
m_dry     = 1000;           % Kuru kütle [kg]
m_fuel    = 4000;           % Yakıt kütlesi [kg]
m0        = m_dry + m_fuel; % Toplam başlangıç kütlesi [kg]
Isp       = 311;            % Özgül itki [s]
g0        = 9.80665;        % Yerçekimi ivmesi [m/s^2]
T_max     = 5000;           % Maksimum thrust [N]

%% Faz Geçiş Eşikleri (Parametrik)
h_safe      = 10e3;   % Minimum güvenli irtifa [m]
v_soft_max  = 3;      % Maksimum iniş hızı [m/s]

%% Başlangıç Durum Vektörü
% Y = [r; theta; vr; vtheta; m]
Y0 = [r0; theta0; vr0; vtheta0; m0];
