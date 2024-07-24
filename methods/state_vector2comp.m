function comp = state_vector2comp(comp, state_vector)

    comp.m_ox         = state_vector(19);        % The oxidizer mass.
    comp.U_tank_total = state_vector(20);        % The total energy inside the tank.
    comp.T_tank_wall  = state_vector(21);        % The tank wall temperature.
    comp.r_cc         = state_vector(22);        % The radius of the combustion chamber.
    comp.r_throat     = state_vector(23);        % The throat radius.
    comp.P_cc         = state_vector(24);        % The pressure in the combustion chamber.
    comp.x            = state_vector(25);        % The position on the x-axis (m).
    comp.y            = state_vector(26);        % The position on the y-axis (m).
    comp.dxdt         = state_vector(27);        % The velocity along the x-axis (m/s).
    comp.dydt         = state_vector(28);        % The velocity along the y-axis (m/s).
    comp.m_tot        = state_vector(29);
    comp.h_liq        = state_vector(30);
    comp.h_gas        = state_vector(31);
    comp.h_air_ext    = state_vector(32);

end