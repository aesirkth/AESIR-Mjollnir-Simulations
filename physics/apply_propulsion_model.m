function [comp,state_vector_derivative] = apply_propulsion_model(comp, state_vector_derivative)


   
    if comp.y < 0
        comp.y = 0;  % Fix atmoscoesa warnings.
    end
    
    A_t = pi * comp.r_throat.^2;                  % Compute the throat area (m^2).
    v_rocket = sqrt(dxdt^2 + dydt^2);        % Compute total velocity.
    
    % Get the temperature (K), speed of sound (m/s), pressure (Pa), and density (kg/m^3) at height y.
    [T_ext_COESA, speed_of_sound, P_ext, rho_ext] = atmoscoesa(y);
    T_ext = T_ext_COESA - comp.dT_ext;
    
    m_wall = comp.rho_alu * pi * comp.L_tank * (comp.D_ext_tank^2 - comp.D_int_tank^2) / 4;     % Compute the mass of the tank wall (density * pi * length * (external_r^2 - internal_r^2)).
    c_wall = comp.alu_thermal_capacity; 
    gamma = comp.gamma_combustion_products;
    Mw = comp.molecular_weight_combustion_products;
    R = comp.R; 
    
    m_fuel = comp.rho_fuel * pi * comp.L_fuel * (comp.D_cc_int^2 / 4 - comp.r_cc^2);     % Compute the fuel mass (density * pi * length * (fuel_r^2 - cc_r^2)).
    
    T_tank = tank_temperature(comp.U_tank_total, comp.m_ox);      % Compute the tank temperature.
    x_vap = x_vapor(comp.U_tank_total, comp.m_ox, T_tank);        % Compute the massic vapor ratio.
    rho_liq = fnval(comp.RhoL_T_N2O_spline, T_tank);              % Density for liquid N2O (kg/m^3).
    rho_vap = fnval(comp.RhoG_T_N2O_spline, T_tank);              % Density for vapor N2O (kg/m^3).
    
    remaining_ox = (1 - x_vap) * comp.m_ox / (rho_liq * comp.V_tank) * 100;      % Compute the remaining percentage of liquid oxidizer volume in the tank, recall that volume = mass / density.
    
    P_N2O = fnval(comp.Psat_N2O_spline, T_tank) * 10^6;                          % Get saturation pressure of N2O at this tank temperature.
    P_tank = P_N2O;                                                              % Key assumption (I think): Tank pressure is at the point of N2O saturation.
     
    mf_ox = mass_flow_oxidizer(T_tank, P_tank, comp.P_cc);   % Compute oxidizer mass flow.
    A_port = pi * comp.r_cc^2;                               % Compute port area.
    G_o = mf_ox / A_port;                                    % Compute oxidizer mass velocity (see Sutton, 2017, p. 602).
    mf_fuel = mass_flow_fuel(G_o, comp.r_cc);                % Compute fuel mass flow.
    OF = mf_ox / mf_fuel;                                    % Compute O/F ratio.
    mf_throat = mass_flow_throat(comp.P_cc, OF, A_t);        % Compute throat mass flow.
    
    [Qdot_w_t, comp.h_liq, comp.h_gas] = heat_flux_wall_tank(P_N2O, x_vap, comp.T_tank_wall, T_tank);  % Compute thermal heat flux from the tank wall to the interior.
    [Qdot_ext_w, comp.h_air_ext] = heat_flux_ext_wall(v_rocket, T_ext, P_ext, comp.T_tank_wall);  % Compute thermal heat flux from the exterior to the tank wall.
    
    h_outlet = py.CoolProp.CoolProp.PropsSI('H', 'P', P_tank, 'T|liquid', T_tank, 'NitrousOxide');  % Get mass specific enthalpy of N2O.
    
    V_cc = pi * (comp.D_cc_int^2 / 4 * comp.L_cc - (comp.D_cc_int^2 / 4 - comp.r_cc^2) * comp.L_fuel);    % Compute volume of the combustion chamber (total_volume - fuel_volume).
    
    c_star = interp1q(comp.OF_set, comp.c_star_set, OF);                            % Get the characteristic velocity of paraffin with N2O at the current O/F ratio.
    RTcc_Mw = gamma * (2 / (gamma + 1))^((gamma + 1) / (gamma - 1)) * c_star^2;     % Compute the ratio R * T_cc / Mw (see Sutton, 2017, p. 63).
    T_cc = RTcc_Mw * Mw / R;                                                        % Compute the combustion chamber temperature.
    
    % Equations for the tank model.
    dmtotaldt = -mf_ox;
    dUtotaldt = -mf_ox * h_outlet + Qdot_w_t;
    dTwalldt = (Qdot_ext_w - Qdot_w_t) / (m_wall * c_wall);
    drdt = comp.a * (G_o)^comp.n;
    dcomp.P_ccdt = (mf_fuel + mf_ox - mf_throat) * RTcc_Mw / V_cc;
    
    
    % Compute exhaust quantities.
    M_ex = exhaust_Mach(A_t);
    P_ex = exhaust_pressure(comp.P_cc, P_ext, M_ex);
    v_ex = exhaust_speed(T_cc, P_ex, comp.P_cc);
    
    if remaining_ox <= 0
        % Tank is empty (thrust and oxidizer mass are set to zero).
        comp.m_tot = m_fuel + comp.dry_mass;     % Compute total mass.
        [d2xdt2, d2ydt2] = eq_of_motion(0, 0, m_fuel, y, dxdt, dydt, speed_of_sound, rho_ext);
        if comp.y <= 0
            % The rocket has landed/crashed.
            comp.dxdt = 0;
            comp.dydt = 0;
            d2xdt2 = 0;
            d2ydt2 = 0;
        end
        state_vector_derivative(19:32) = [0; 0; 0; 0; 0; 0; dxdt; dydt; d2xdt2; d2ydt2; 0; 0; 0; 0];
    else
        F = comp.combustion_efficiency * thrust(mf_throat, v_ex, P_ext, P_ex);   % Compute thrust.
        comp.m_tot = comp.m_ox + m_fuel + comp.dry_mass;      % Compute total mass.
        [d2xdt2, d2ydt2] = eq_of_motion(F, comp.m_ox, m_fuel, y, dxdt, dydt, speed_of_sound, rho_ext);
        
        state_vector_derivative(19:32) = [dmtotaldt; dUtotaldt; dTwalldt; drdt; comp.dr_thdt; dcomp.P_ccdt; dxdt; dydt; d2xdt2; d2ydt2; 0; 0; 0; 0];


    end
