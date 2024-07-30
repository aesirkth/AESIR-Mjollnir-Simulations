
    mjolnir.rho_liq = py.CoolProp.CoolProp.PropsSI('D', 'T', mjolnir.T_tank, 'Q', 0, 'NitrousOxide');        % Density for liquid N2O (kg/m^3).
    mjolnir.rho_vap = py.CoolProp.CoolProp.PropsSI('D', 'T', mjolnir.T_tank, 'Q', 1, 'NitrousOxide');        % Density for vapor  N2O (kg/m^3).
    mjolnir.u_liq   = py.CoolProp.CoolProp.PropsSI('U', 'T', mjolnir.T_tank, 'Q', 0, 'NitrousOxide');        % Specific internal energy for liquid N2O (J/kg).
    mjolnir.u_vap   = py.CoolProp.CoolProp.PropsSI('U', 'T', mjolnir.T_tank, 'Q', 1, 'NitrousOxide');        % Specific internal energy for vapor N2O (J/kg).
    
    mjolnir.m_liq = mjolnir.filling_ratio * mjolnir.V_tank * mjolnir.rho_liq;                     % The liquid mass is the liquid volume in the tank times the liquid density (kg).
    mjolnir.m_vap = (1 - mjolnir.filling_ratio) * mjolnir.V_tank * mjolnir.rho_vap;               % The liquid mass is the remaining volume in the tank times the vapor density (kg).
    
    mjolnir.m_ox         = mjolnir.m_liq + mjolnir.m_vap;                                         % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
    mjolnir.U_total      = mjolnir.m_liq * mjolnir.u_liq + mjolnir.m_vap * mjolnir.u_vap;         % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).
    mjolnir.r_cc         = mjolnir.r_fuel;                                                        % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).
    mjolnir.r_fuel_init  = mjolnir.r_fuel;
    mjolnir.r_throat     = mjolnir.D_throat / 2;                                                  % The initial radius of the nozzle throat is half of the throat diameter.
    mjolnir.remaining_ox = 100;                                                                   % Percentage of remaining oxidizer.