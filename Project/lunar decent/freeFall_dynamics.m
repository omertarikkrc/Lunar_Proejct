function dY = freeFall_dynamics(t, Y)
    global G m

    % Ay kütlesi
    m_moon = m(1);

    % Uzay aracı durumu
    x_s  = Y(5);  
    y_s  = Y(6);
    vx_s = Y(7);
    vy_s = Y(8);
    m_sat= Y(9);

    % Konum, hız, mesafe
    r_vec = [x_s; y_s];
    r     = norm(r_vec);

    % Yerçekimi ivmesi
    a_grav = -G * m_moon / r^3 * r_vec;

    % ÇIKTI vektörü [x_m';y_m';vx_m';vy_m'; x_s';y_s';vx_s';vy_s'; m']
    dY = zeros(9,1);
    % Ay sabit (dY(1:4)=0 zaten)
    dY(1:4) = 0;
    % Uzay aracının pozisyon türevleri = hızı
    dY(5) = vx_s;
    dY(6) = vy_s;
    % Uzay aracının hız türevleri = yalnızca yerçekimi
    dY(7) = a_grav(1);
    dY(8) = a_grav(2);
    % Kütle değişimi = 0 (thrust yok)
    dY(9) = 0;
end
