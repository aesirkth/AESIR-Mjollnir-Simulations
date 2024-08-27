function T_tank = tank_temperature(comp)
%TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank


try
T_tank_initial_estimate = evalin("base", "T_tank_initial_estimate");
catch
T_tank_initial_estimate = comp.T_tank;
assignin("base", "T_tank_initial_estimate", comp.T_tank)
end


T_tank = fzero(@Tank_Temperature_finder_fct, T_tank_initial_estimate);


assignin("base", "T_tank_initial_estimate", T_tank)


function F_tank = Tank_Temperature_finder_fct(T)
%TANK_TEMPERATURE_FINDER Function is the function that temperature must
%verify
%To find the tank temperature, the model will try to find T such that
%Tank_Temperature_finder_fct(Utot,mtot,T)=0 (Utot is fixed at each step)

    
    %Coolprop liquid density (kg/m^3)
    rho_liq = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 0,'NitrousOxide');
    
    %Coolprop vapor density (kg/m^3)
    rho_vap = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 1,'NitrousOxide');

    x = x_vapor(comp.U_tank_total, comp.m_ox, T, comp);
    %x = 0.5;

    F_tank = comp.V_tank - comp.m_ox.*((1-x)./rho_liq + x./rho_vap);


end
end