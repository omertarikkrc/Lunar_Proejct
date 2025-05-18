function dY = phase1_dynamics(t, Y)
    % Phase-1 dynamics: Öncelikli tangensiyel fren, gerekirse güvenli irtifa için
    % kısa radyal destek thrust’u
    global G mu_moon T_const m_dry Rm h1_safe ve

    % --- Durum vektörü parçaları
    x_s   = Y(5);    y_s   = Y(6);
    vx    = Y(7);    vy    = Y(8);
    m_sat = Y(9);

    % --- Konum ve hız vektörleri
    r_vec = [x_s; y_s];
    v_vec = [vx; vy];

    % --- Ölçümler
    r      = norm(r_vec);
    r_unit = r_vec / r;                   % radyal birim
    t_unit = [-r_unit(2); r_unit(1)];     % tangensiyel birim
    v_t    = dot(v_vec, t_unit);          % tangensiyel hız bileşeni
    h      = r - Rm;                      % mevcut irtifa

    % --- Yerçekimi ivmesi
    a_grav = -G * mu_moon / r^3 * r_vec;

    % --- Thrust kontrolü
    if v_t > 0 && m_sat > m_dry
        % 1) Tangensiyel fren
        a_thrust = -(T_const/m_sat) * t_unit;
        dm       = -T_const / ve;
    elseif h < h1_safe && m_sat > m_dry
        % 2) Güvenli irtifa altındaysa kısa radyal destek
        a_thrust =  (T_const/m_sat) * r_unit;
        dm       = -T_const / ve;
    else
        % 3) Thrust kapalı
        a_thrust = [0;0];
        dm       = 0;
    end

    % --- Diferansiyel denklem çıktısı
    dY = zeros(9,1);
    % Ay sabit; Y(1:4) türevleri sıfır
    dY(1:4) = 0;
    % Uzay aracının konum türevleri = hız
    dY(5) = vx;
    dY(6) = vy;
    % Uzay aracının ivme bileşenleri = yerçekimi + thrust
    dY(7) = a_grav(1) + a_thrust(1);
    dY(8) = a_grav(2) + a_thrust(2);
    % Kütle akışı
    dY(9) = dm;
end
