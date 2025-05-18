function dY = SystemsOfEquations(t, Y)
    global G m T_const Isp g0 ve Rm

    % --- Kütleler
    m_moon = m(1);
    m_dry  = m(2);
    m_sat  = Y(9);   % Uzay aracının anlık kütlesi

    % --- Pozisyon ve hızlar
    x_m = Y(1);  y_m = Y(2);
    vx_m = Y(3); vy_m = Y(4);

    x_s = Y(5);  y_s = Y(6);
    vx_s = Y(7); vy_s = Y(8);

    pos_m = [x_m; y_m];
    pos_s = [x_s; y_s];
    vel_s = [vx_s; vy_s];

    % --- Ay merkezli vektörler
    r_vec = pos_s - pos_m;
    v_vec = vel_s - [vx_m; vy_m];   % Ay'a göre hız
    r = norm(r_vec);

    % --- Birim vektörler
    r_unit = r_vec / r;
    t_unit = [-r_unit(2); r_unit(1)];  % teğetsel yön

    % --- Teğetsiyel hız bileşeni
    v_t = dot(v_vec, t_unit);

    % --- Yerçekimi ivmesi
    a_grav = -G * m_moon / r^3 * r_vec;

    % --- THRUST UYGULAMASI (Sadece pozitif teğetsiyeli frenle, 0’da kes)
    if v_t > 0 && m_sat > m_dry
        thrust_dir = -t_unit;                % fren yönü
        a_thrust  = (T_const / m_sat) * thrust_dir;
        dm        = -T_const / ve;           % kütle azalması
    else
        a_thrust = [0; 0];
        dm       = 0;
    end

    % --- Ay sabit varsayılıyor
    a_m = [0; 0];

    % --- Diferansiyel denklem çıktısı
    dY = zeros(9,1);
    dY(1) = vx_m;
    dY(2) = vy_m;
    dY(3) = a_m(1);
    dY(4) = a_m(2);

    dY(5) = vx_s;
    dY(6) = vy_s;
    dY(7) = a_grav(1) + a_thrust(1);
    dY(8) = a_grav(2) + a_thrust(2);
    dY(9) = dm;
end
