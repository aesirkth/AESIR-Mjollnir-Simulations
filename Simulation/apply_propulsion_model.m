function [comp,state_vector_derivative] = apply_propulsion_model(comp, state_vector_derivative)
% This model is based on the following literature: https://arc.aiaa.org/doi/10.2514/6.2013-4045

if comp.rigid_body.position(3) < 0; comp.rigid_body.position(3) = 0; end % Fix atmoscoesa warnings

comp.m_fuel            = comp.rho_fuel * pi * comp.L_fuel * (comp.D_cc_int^2 / 4 - comp.r_cc^2);  % Compute the fuel mass (density * pi * length * (fuel_r^2 - cc_r^2)).
comp.rigid_body.mass   = comp.m_ox + comp.m_fuel + comp.dry_mass;                                 % Compute total mass.

if comp.active_burn_flag == 0
    
    comp.A_t = pi * comp.r_throat.^2;                  % Compute the throat area (m^2).    
    % Get the temperature (K), speed of sound (m/s), pressure (Pa), and density (kg/m^3) at height y.
    [comp.T_ext_COESA, comp.speed_of_sound, comp.P_ext, comp.rho_ext] = atmoscoesa(comp.rigid_body.position(3));
    comp.T_ext = comp.T_ext_COESA - comp.dT_ext;
    
    m_wall = comp.rho_alu * pi * comp.L_tank * (comp.D_ext_tank^2 - comp.D_int_tank^2) / 4;     % Compute the mass of the tank wall (density * pi * length * (external_r^2 - internal_r^2)).
    c_wall = comp.alu_thermal_capacity; 
    gamma  = comp.gamma_combustion_products;
    Mw     = comp.molecular_weight_combustion_products;
    
    
    
    comp.T_tank = tank_temperature(comp);                                              % Compute the tank temperature.
    comp.x_vap  = x_vapor(comp.U_tank_total, comp.m_ox, comp.T_tank, comp);            % Compute the massic vapor ratio.
    rho_liq     = comp.N2O.temperature2density_liquid(comp.T_tank);
%    rho_val     = comp.N2O.temperature2density_vapor (comp.T_tank);

    comp.remaining_ox = (1 - comp.x_vap) * comp.m_ox / (rho_liq * comp.V_tank) * 100;  % Compute the remaining percentage of liquid oxidizer volume in the tank, recall that volume = mass / density.
    
    comp.P_tank = fnval(comp.N2O.temperature2saturation_pressure, comp.T_tank)* 10^6;   % Get saturation pressure of N2O at this tank temperature.

    mf_ox          = mass_flow_oxidizer(comp);                                         % Compute oxidizer mass flow.
    A_port = pi * comp.r_cc^2;                                                         % Compute port area.
    comp.G_o = mf_ox / A_port;                                                         % Compute oxidizer mass velocity (see Sutton, 2017, p. 602).
    mf_fuel        = mass_flow_fuel    (comp);                                         % Compute fuel mass flow.
    comp.OF = mf_ox / mf_fuel;                                                         % Compute O/F ratio.
    comp.mf_throat = mass_flow_throat  (comp);                                         % Compute throat mass flow.
    
    [Qdot_w_t, comp.h_liq, comp.h_gas] = heat_flux_wall_tank(comp);                    % Compute thermal heat flux from the tank wall to the interior.
    [Qdot_ext_w , comp.h_air_ext]      = heat_flux_ext_wall (comp);                    % Compute thermal heat flux from the exterior to the tank wall.
    
    h_outlet = py.CoolProp.CoolProp.PropsSI('H', 'P', comp.P_tank, 'T|liquid', comp.T_tank, 'NitrousOxide');  % Get mass specific enthalpy of N2O.
    
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
    
        
    F = comp.combustion_efficiency * thrust(comp);   % Compute thrust.
    comp.rigid_body.forces.Thrust = force(F*comp.rigid_body.attitude*[0;0;1],[0;0;-0.9]);

    state_vector_derivative(19:28) = [dmtotaldt; dUtotaldt; dTwalldt; drdt; comp.dr_thdt; dP_ccdt; 0; 0; 0; 0];
    if comp.remaining_ox <= 0;state_vector_derivative(29) = 1;end  % Check for burn-completion


    
else

    comp.rigid_body.forces.Thrust = force([0;0;0],[0;0;-0.9]);

    state_vector_derivative(19:29) = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1];


end

