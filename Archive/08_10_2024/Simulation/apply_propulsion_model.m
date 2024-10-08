function [comp,state_vector_derivative] = apply_propulsion_model(comp, state_vector_derivative)
% This model is based on the following literature: https://arc.aiaa.org/doi/10.2514/6.2013-4045

if comp.position(3) < 0; comp.position(3) = 0; end % Fix atmoscoesa warnings

comp.engine.fuel_grain.mass            = comp.engine.fuel_grain.density * pi * comp.engine.fuel_grain.length * (comp.engine.combustion_chamber.internal_diameter^2 / 4 - comp.engine.fuel_grain.radius^2);  % Compute the fuel mass (density * pi * length * (fuel_r^2 - cc_r^2)).
comp.mass   = comp.tank.oxidizer_mass + comp.engine.fuel_grain.mass + comp.dry_mass;                                 % Compute total mass.

if comp.engine.active_burn_flag == 0
    
    comp.engine.nozzle.throat.area = pi * comp.engine.nozzle.throat.radius.^2;                  % Compute the throat area (m^2).    
    % Get the temperature (K), speed of sound (m/s), pressure (Pa), and density (kg/m^3) at height y.
    [comp.enviroment.temperature_COESA, comp.aerodynamics.speed_of_sound, comp.enviroment.pressure, comp.enviroment.air_density] = atmoscoesa(comp.position(3));
    comp.enviroment.temperature = comp.enviroment.temperature_COESA - comp.enviroment.dT_ext;
    
    %m_wall = comp.rho_alu * pi * comp.tank.length * (comp.tank.diameter^2 - (comp.tank.diameter - comp.tank.thickness*2)^2) / 4;     % Compute the mass of the tank wall (density * pi * length * (external_r^2 - internal_r^2)).
    m_wall = comp.tank.wall.mass;
    c_wall = comp.tank.wall.alu_thermal_capacity; 
    gamma  = comp.engine.gamma_combustion_products;
    Mw     = comp.engine.gamma_combustion_products;
    
    
    
    comp.tank.liquid.temperature = tank_temperature(comp);                                              % Compute the tank temperature.
    comp.tank.x_vap  = x_vapor(comp.tank.internal_energy, comp.tank.oxidizer_mass, comp.tank.liquid.temperature, comp);            % Compute the massic vapor ratio.
    rho_liq     = comp.N2O.temperature2density_liquid(comp.tank.liquid.temperature);
%    rho_val     = comp.N2O.temperature2density_vapor (comp.tank.liquid.temperature);

    comp.tank.remaining_ox = (1 - comp.tank.x_vap) * comp.tank.oxidizer_mass / (rho_liq * comp.tank.volume) * 100;  % Compute the remaining percentage of liquid oxidizer volume in the tank, recall that volume = mass / density.
    
    comp.tank.pressure = fnval(comp.N2O.temperature2saturation_pressure, comp.tank.liquid.temperature)* 10^6;   % Get saturation pressure of N2O at this tank temperature.

    mf_ox                        = mass_flow_oxidizer(comp);                                         % Compute oxidizer mass flow.
    A_port                       = pi * comp.engine.fuel_grain.radius^2;                                                         % Compute port area.
    comp.tank.G_o                = mf_ox / A_port;                                                         % Compute oxidizer mass velocity (see Sutton, 2017, p. 602).
    mf_fuel                      = mass_flow_fuel    (comp);                                         % Compute fuel mass flow.
    comp.engine.OF               = mf_ox / mf_fuel;                                                         % Compute O/F ratio.
    comp.engine.nozzle.mass_flow = mass_flow_throat  (comp);                                         % Compute throat mass flow.
    
    [Qdot_w_t, comp.tank.liquid.heat_flux, comp.tank.vapor.heat_flux] = heat_flux_wall_tank(comp);                    % Compute thermal heat flux from the tank wall to the interior.
    [Qdot_ext_w , comp.tank.wall.heat_flux]      = heat_flux_ext_wall (comp);                    % Compute thermal heat flux from the exterior to the tank wall.
    
    h_outlet = py.CoolProp.CoolProp.PropsSI('H', 'P', comp.tank.pressure, 'T|liquid', comp.tank.liquid.temperature, 'NitrousOxide');  % Get mass specific enthalpy of N2O.
    
    V_cc = pi * (comp.engine.combustion_chamber.internal_diameter^2 / 4 * comp.engine.combustion_chamber.length - (comp.engine.combustion_chamber.internal_diameter^2 / 4 - comp.engine.fuel_grain.radius^2) * comp.engine.fuel_grain.length);    % Compute volume of the combustion chamber (total_volume - fuel_volume).
    
    c_star = interp1q(comp.engine.OF_set, comp.engine.c_star_set, comp.engine.OF);                              % Get the characteristic velocity of paraffin with N2O at the current O/F ratio.
    RTcc_Mw = gamma * (2 / (gamma + 1))^((gamma + 1) / (gamma - 1)) * c_star^2;       % Compute the ratio comp.R * comp.engine.combustion_chamber.temperature / Mw (see Sutton, 2017, p. 63).
    comp.engine.combustion_chamber.temperature = RTcc_Mw * Mw / comp.enviroment.R;                                                          % Compute the combustion chamber temperature.
    
    % Equations for the tank model.
    dmtotaldt = -mf_ox;
    dUtotaldt = -mf_ox * h_outlet + Qdot_w_t;
    dTwalldt  = (Qdot_ext_w - Qdot_w_t) / (m_wall * c_wall);
    drdt      = comp.engine.fuel_grain.a * (comp.tank.G_o)^comp.engine.fuel_grain.n;
    dP_ccdt   = (mf_fuel + mf_ox - comp.engine.nozzle.mass_flow) * RTcc_Mw / V_cc;
    
    
    % Compute exhaust quantities.
    comp.engine.nozzle.exit.mach     = exhaust_Mach    (comp);
    comp.engine.nozzle.exit.pressure = exhaust_pressure(comp);
    comp.engine.nozzle.exit.velocity = exhaust_speed   (comp);
    
        
    F = comp.engine.combustion_chamber.combustion_efficiency * thrust(comp);   % Compute thrust.
    comp.forces.Thrust = force(F*comp.attitude*[0;0;1],comp.engine.nozzle.position);

    state_vector_derivative(19:29) = [dmtotaldt; dUtotaldt; dTwalldt; drdt; comp.engine.fuel_grain.dr_thdt; dP_ccdt; 0; 0; 0; 0; 0];
    if comp.tank.remaining_ox <= 0;state_vector_derivative(29) = 1;end  % Check for burn-completion


    
else

    comp.forces.Thrust = force([0;0;0],comp.engine.nozzle.position);

    state_vector_derivative(19:29) = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1];


end

