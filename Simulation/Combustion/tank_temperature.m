function T_tank = tank_temperature(comp)
%TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank

                                     %fplot(@Tank_Temperature_finder_fct,  [183, 309.51]); drawnow
% V_tank = comp.V_tank
% m_ox = comp.m_ox
% U_tank_total = comp.U_tank_total


T_tank = fzero(@Tank_Temperature_finder_fct, [183, 309.51]);

function F_tank = Tank_Temperature_finder_fct(T)
%TANK_TEMPERATURE_FINDER Function is the function that temperature must
%verify
%To find the tank temperature, the model will try to find T such that
%Tank_Temperature_finder_fct(Utot,mtot,T)=0 (Utot is fixed at each step)

    
    %Coolprop liquid density (kg/m^3)
    rho_liq = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 0,'NitrousOxide');
    
    %Coolprop vapor density (kg/m^3)
    rho_vap = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 1,'NitrousOxide');
    
    x=x_vapor(comp.U_tank_total,comp.m_ox,T);
    
    F_tank = comp.V_tank - comp.m_ox.*((1-x)./rho_liq+x./rho_vap);


end
end