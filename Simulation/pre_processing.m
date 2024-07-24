
    comp.rho_liq = py.CoolProp.CoolProp.PropsSI('D', 'T', comp.T_tank_init, 'Q', 0, 'NitrousOxide');        % Density for liquid N2O (kg/m^3).
    comp.rho_vap = py.CoolProp.CoolProp.PropsSI('D', 'T', comp.T_tank_init, 'Q', 1, 'NitrousOxide');        % Density for vapor  N2O (kg/m^3).
    comp.u_liq   = py.CoolProp.CoolProp.PropsSI('U', 'T', comp.T_tank_init, 'Q', 0, 'NitrousOxide');        % Specific internal energy for liquid N2O (J/kg).
    comp.u_vap   = py.CoolProp.CoolProp.PropsSI('U', 'T', comp.T_tank_init, 'Q', 1, 'NitrousOxide');        % Specific internal energy for vapor N2O (J/kg).
    
    comp.m_liq = comp.fill_ratio * comp.V_tank * comp.rho_liq;                     % The liquid mass is the liquid volume in the tank times the liquid density (kg).
    comp.m_vap = (1 - comp.fill_ratio) * comp.V_tank * comp.rho_vap;               % The liquid mass is the remaining volume in the tank times the vapor density (kg).
    
    comp.m_ox_init     = comp.m_liq + comp.m_vap;                                  % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
    comp.U_total_init  = comp.m_liq * comp.u_liq + comp.m_vap * comp.u_vap;        % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).
    comp.r_cc_init     = comp.r_fuel_init;                                         % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).
    comp.r_throat_init = comp.D_throat / 2;                                        % The initial radius of the nozzle throat is half of the throat diameter.
