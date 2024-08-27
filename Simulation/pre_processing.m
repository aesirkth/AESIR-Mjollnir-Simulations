
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

    mjolnir.moody_spline = struct();
    
   [mjolnir.moody_spline.P_cc,   ...
    mjolnir.moody_spline.hf,     ...
    mjolnir.moody_spline.h_fg,   ...
    mjolnir.moody_spline.rho2_v, ...
    mjolnir.moody_spline.rho2_l, ...
    mjolnir.moody_spline.k] = arrayfun(@moody_spline, 8.78374e4:5e5:7.245e6);






function [P_cc, hf, h_fg, rho2_v, rho2_l, k] = moody_spline(P_cc)


        rho2_l = py.CoolProp.CoolProp.PropsSI('D', 'P', P_cc, 'Q', 0, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
        rho2_v = py.CoolProp.CoolProp.PropsSI('D', 'P', P_cc, 'Q', 1, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
    
        hf = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'Q', 0, 'NitrousOxide');   %Enthalpie massic (J/kg)
        hg = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'Q', 1, 'NitrousOxide');   %Enthalpie massic (J/kg)
        h_fg = hg - hf;

        k = (rho2_l / rho2_v)^(1/3);

        

end