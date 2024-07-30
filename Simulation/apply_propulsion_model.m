function [comp,state_vector_derivative] = apply_propulsion_model(comp, state_vector_derivative)
% This model is based on the following literature: https://arc.aiaa.org/doi/10.2514/6.2013-4045

   
    if comp.position(3) < 0; comp.position(3) = 0; end % Fix atmoscoesa warnings.end
    
    comp.A_t = pi * comp.r_throat.^2;                  % Compute the throat area (m^2).
    comp.v_rocket = sqrt(comp.dxdt^2 + comp.dydt^2);   % Compute total velocity.
    
    % Get the temperature (K), speed comp.OF sound (m/s), pressure (Pa), and density (kg/m^3) at height y.
    [comp.T_ext_COESA, comp.speed_of_sound, comp.P_ext, comp.rho_ext] = atmoscoesa(comp.y);
    comp.T_ext = comp.T_ext_COESA - comp.dT_ext;
    
    m_wall = comp.rho_alu * pi * comp.L_tank * (comp.D_ext_tank^2 - comp.D_int_tank^2) / 4;     % Compute the mass of the tank wall (density * pi * length * (external_r^2 - internal_r^2)).
    c_wall = comp.alu_thermal_capacity; 
    gamma = comp.gamma_combustion_products;
    Mw = comp.molecular_weight_combustion_products;
    
    comp.m_fuel = comp.rho_fuel * pi * comp.L_fuel * (comp.D_cc_int^2 / 4 - comp.r_cc^2);  % Compute the fuel mass (density * pi * length * (fuel_r^2 - cc_r^2)).
    
    comp.T_tank = tank_temperature(comp);                                             % Compute the tank temperature.
    comp.x_vap =  x_vapor(comp.U_tank_total, comp.m_ox, comp.T_tank);                 % Compute the massic vapor ratio.
    rho_liq = fnval(comp.RhoL_T_N2O_spline, comp.T_tank);                             % Density for liquid N2O (kg/m^3).
    rho_vap = fnval(comp.RhoG_T_N2O_spline, comp.T_tank);                             % Density for vapor N2O (kg/m^3).
    
    remaining_ox = (1 - comp.x_vap) * comp.m_ox / (rho_liq * comp.V_tank) * 100;      % Compute the remaining percentage of liquid oxidizer volume in the tank, recall that volume = mass / density.
    
    comp.P_N2O = fnval(comp.Psat_N2O_spline, comp.T_tank) * 10^6;                     % Get saturation pressure of N2O at this tank temperature.
    comp.P_tank = comp.P_N2O;                                                         % Key assumption (I think): Tank pressure is at the point comp.OF N2O saturation.

    mf_ox          = mass_flow_oxidizer(comp);                                        % Compute oxidizer mass flow.
    A_port = pi * comp.r_cc^2;                                                        % Compute port area.
    comp.G_o = mf_ox / A_port;                                                        % Compute oxidizer mass velocity (see Sutton, 2017, p. 602).
    mf_fuel        = mass_flow_fuel    (comp);                                        % Compute fuel mass flow.
    comp.OF = mf_ox / mf_fuel;                                                        % Compute O/F ratio.
    comp.mf_throat = mass_flow_throat  (comp);                                        % Compute throat mass flow.
    
    [Qdot_w_t, comp.h_liq, comp.h_gas] = heat_flux_wall_tank(comp);              % Compute thermal heat flux from the tank wall to the interior.
    [Qdot_ext_w , comp.h_air_ext]      = heat_flux_ext_wall(comp);  % Compute thermal heat flux from the exterior to the tank wall.
    
    h_outlet = py.CoolProp.CoolProp.PropsSI('H', 'P', comp.P_tank, 'T|liquid', comp.T_tank, 'NitrousOxide');  % Get mass specific enthalpy comp.OF N2O.
    
    V_cc = pi * (comp.D_cc_int^2 / 4 * comp.L_cc - (comp.D_cc_int^2 / 4 - comp.r_cc^2) * comp.L_fuel);    % Compute volume of the combustion chamber (total_volume - fuel_volume).
    
    c_star = interp1q(comp.OF_set, comp.c_star_set, comp.OF);                              % Get the characteristic velocity of paraffin with N2O at the current O/F ratio.
    RTcc_Mw = gamma * (2 / (gamma + 1))^((gamma + 1) / (gamma - 1)) * c_star^2;       % Compute the ratio comp.R * comp.T_cc / Mw (see Sutton, 2017, p. 63).
    comp.T_cc = RTcc_Mw * Mw / comp.R;                                                          % Compute the combustion chamber temperature.
    
    % Equations for the tank model.
    dmtotaldt = -mf_ox;
    dUtotaldt = -mf_ox * h_outlet + Qdot_w_t;
    dTwalldt  = (Qdot_ext_w - Qdot_w_t) / (m_wall * c_wall);
    drdt      = comp.a * (comp.G_o)^comp.n;
    dP_ccdt   = (mf_fuel + mf_ox - comp.mf_throat) * RTcc_Mw / V_cc;
    
    
    % Compute exhaust quantities.
    comp.M_ex = exhaust_Mach    (comp);
    comp.P_ex = exhaust_pressure(comp);
    comp.v_ex = exhaust_speed   (comp);
    
    if remaining_ox <= 0
        % Tank is empty (thrust and oxidizer mass are set to zero).
        F = 0;
        comp.mass    = comp.m_fuel + comp.dry_mass;     % Compute total mass.
        state_vector_derivative(19:28) = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0];
    else
        F = comp.combustion_efficiency * thrust(comp);   % Compute thrust.
        comp.mass = comp.m_ox + comp.m_fuel + comp.dry_mass;      % Compute total mass.
        state_vector_derivative(19:28) = [dmtotaldt; dUtotaldt; dTwalldt; drdt; comp.dr_thdt; dP_ccdt; 0; 0; 0; 0];


    end


    comp.forces("thrust") = force(F*[0;0;1],[0;0;-0.9]);