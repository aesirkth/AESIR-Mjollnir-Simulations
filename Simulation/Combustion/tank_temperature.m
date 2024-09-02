function T_tank = tank_temperature(comp)
%TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank


try
T_tank_initial_estimate = evalin("base", "T_tank_initial_estimate");
catch
T_tank_initial_estimate = comp.tank.liquid.temperature;
assignin("base", "T_tank_initial_estimate", comp.tank.liquid.temperature)
end


T_tank = fzero(@Tank_Temperature_finder_fct, T_tank_initial_estimate);


assignin("base", "T_tank_initial_estimate", T_tank)


function F_tank = Tank_Temperature_finder_fct(T)
%TANK_TEMPERATURE_FINDER Function is the function that temperature must
%verify
%To find the tank temperature, the model will try to find T such that
%Tank_Temperature_finder_fct(Utot,mtot,T)=0 (Utot is fixed at each step)

    
    % rho_liq = interp1(comp.N2O_density_spline.T,...
    %                   comp.N2O_density_spline.rho_liq,...
    %                   T);
    % 
    % rho_vap = interp1(comp.N2O_density_spline.T,...
    %                   comp.N2O_density_spline.rho_vap,...
    %                   T);

    rho_liq = comp.N2O.temperature2density_liquid(T);
    rho_vap = comp.N2O.temperature2density_vapor(T);

    x = x_vapor(comp.tank.internal_energy, comp.tank.oxidizer_mass, T, comp);
    %x = 0.5;

    F_tank = comp.tank.volume - comp.tank.oxidizer_mass.*((1-x)./rho_liq + x./rho_vap);


end
end