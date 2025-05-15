function b0 = initial_conditions(theta, deltaV, G, mE, mM, D_EM, r_park_E)
% initial_conditions:
% Verilen açıda (theta) Dünya park yörüngesinden kaçış manevrası uygulanmış
% bir uzay aracının başlangıç durum vektörünü oluşturur.
%
% INPUTS:
%   theta      : Dünya çevresinde açısal konum [radyan]
%   deltaV     : Tangensiyel impulsif manevra büyüklüğü [m/s]
%   G          : Evrensel çekim sabiti [m^3/kg/s^2]
%   mE, mM     : Dünya ve Ay kütleleri [kg]
%   D_EM       : Dünya–Ay mesafesi [m]
%   r_park_E   : Dünya park yörüngesi yarıçapı (RE + h) [m]
%
% OUTPUT:
%   b0         : [1x18] boyutunda başlangıç durum vektörü

% Dünya ve Ay’ın ortak kütle merkezi etrafındaki konumları
r_E = -mM / (mE + mM) * D_EM;
r_M =  mE / (mE + mM) * D_EM;

% Açısal hız (çembersel yörünge varsayımı)
w = sqrt(G * (mE + mM) / D_EM^3);

% Dünya ve Ay konum & hız (2D düzlem, z=0)
pos_E = [r_E, 0];
vel_E = [0,  w * r_E];
pos_M = [r_M, 0];
vel_M = [0,  w * r_M];

% Dünya merkezli uzay aracı konumu (theta açısında)
x_s = r_park_E * cos(theta);
y_s = r_park_E * sin(theta);

% Toplam hız (teğet + impulsif delta-V aynı yönlü)
v_total = sqrt(G * mE / r_park_E) + deltaV;
vx_s = -v_total * sin(theta);
vy_s =  v_total * cos(theta);

% Uzay aracı konumu ve hızı, ortak merkez referansında
pos_s = pos_E + [x_s, y_s];
vel_s = vel_E + [vx_s, vy_s];

% 3 cisim için: [x y z vx vy vz] x 3
b0 = [pos_E 0 vel_E 0 pos_M 0 vel_M 0 pos_s 0 vel_s 0];

end
