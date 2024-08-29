function N2O = initiate_N2O

try 
update_N2O = evalin("base", "update_N2O");
catch
update_N2O = false;
end

if update_N2O

N2O = struct;

%% Density & specific internal energy as functions of temperature functions/interpolations:

temperature_range = 182.23:0.1:309.52;

density_liquid                  = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 0, 'NitrousOxide'), temperature_range);        % Density for liquid N2O (kg/m^3).
density_vapor                   = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 1, 'NitrousOxide'), temperature_range);        % Density for vapor  N2O (kg/m^3).
specific_internal_energy_liquid = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide'), temperature_range);        % Specific internal energy for liquid N2O (J/kg).
specific_internal_energy_vapor  = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 1, 'NitrousOxide'), temperature_range);        % Specific internal energy for vapor N2O (J/kg).


N2O.temperature2density_liquid                  = @(T) interp1(temperature_range, density_liquid,                  T);
N2O.temperature2density_vapor                   = @(T) interp1(temperature_range, density_vapor,                  T);
N2O.temperature2specific_internal_energy_liquid = @(T) interp1(temperature_range, specific_internal_energy_liquid, T);
N2O.temperature2specific_internal_energy_vapor  = @(T) interp1(temperature_range, specific_internal_energy_vapor, T);




%% Massic enthalpy as functions of pressure and massic entropy function/interpolation:

[pressure_meshg, massic_entropy_meshg] = meshgrid(8.78374e4:5e5:7.245e6, -22:10:2500);


massic_enthalpy_meshg = arrayfun( @(P, s) py.CoolProp.CoolProp.PropsSI('H', 'P', P, 'S', s, 'NitrousOxide'), pressure_meshg, massic_entropy_meshg );

N2O.pressure_massic_entropy2massic_enthalpy = @(P, s) interp2(pressure_meshg, massic_entropy_meshg, massic_enthalpy_meshg, P, s);




 N2O.moody = struct();

 N2O.moody.pressure = 8.78374e4:5e5:7.245e6;
[N2O.moody.massic_enthalpy_liquid, ...
 N2O.moody.massic_enthalpy_combined,   ...
 N2O.moody.density_vapor, ...
 N2O.moody.density_liquid, ...
 N2O.moody.k] = arrayfun(@moody, N2O.moody.pressure);




N2O.massic_vapor_ratio = struct;




save("Simulation\N2O.mat", "N2O")


else
load("Simulation\N2O.mat", "N2O")


end




function [massic_enthalpy_liquid,...
          massic_enthalpy_combined, ...
          density_vapor, ...
          density_liquid, ...
          k] ...
          = moody(pressure)


density_liquid = py.CoolProp.CoolProp.PropsSI('D', 'P', pressure, 'Q', 0, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
density_vapor  = py.CoolProp.CoolProp.PropsSI('D', 'P', pressure, 'Q', 1, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)

massic_enthalpy_liquid   = py.CoolProp.CoolProp.PropsSI('H', 'P', pressure, 'Q', 0, 'NitrousOxide');   %Enthalpie massic (J/kg)
massic_enthalpy_vapor    = py.CoolProp.CoolProp.PropsSI('H', 'P', pressure, 'Q', 1, 'NitrousOxide');   %Enthalpie massic (J/kg)
massic_enthalpy_combined = massic_enthalpy_vapor - massic_enthalpy_liquid;

k = (density_liquid / density_vapor)^(1/3);

end


end