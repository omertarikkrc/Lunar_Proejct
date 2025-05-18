function dY = descent_dynamics(t, Y)
    global mu_moon Isp g0 ve T_const m_dry

    x = Y(1);   y = Y(2);
    vx = Y(3);  vy = Y(4);
    m = Y(5);

    r_vec = [x; y];
    v_vec = [vx; vy];

    r = norm(r_vec);
    a_grav = -mu_moon / r^3 * r_vec;

    % --- THRUST YÖNÜ: her zaman hızın tersi yönüne (frenleme)
    if norm(v_vec) > 0
        thrust_dir = -v_vec / norm(v_vec);
    else
        thrust_dir = [0; 0];
    end

    % --- THRUST VE KÜTLE AZALMASI
    if m > m_dry
        mdot = T_const / ve;
        thrust_acc = T_const / m * thrust_dir;
        dm = -mdot;
    else
        thrust_acc = [0; 0];
        dm = 0;
    end

    a_total = a_grav + thrust_acc;

    % --- ÇIKTI
    dY = zeros(5,1);
    dY(1) = vx;
    dY(2) = vy;
    dY(3) = a_total(1);
    dY(4) = a_total(2);
    dY(5) = dm;
end
