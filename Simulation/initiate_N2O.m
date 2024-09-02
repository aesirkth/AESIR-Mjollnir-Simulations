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

density_liquid                                  = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 0, 'NitrousOxide'), temperature_range);        % Density for liquid N2O (kg/m^3).
density_vapor                                   = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 1, 'NitrousOxide'), temperature_range);        % Density for vapor  N2O (kg/m^3).
specific_internal_energy_liquid                 = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide'), temperature_range);        % Specific internal energy for liquid N2O (J/kg).
specific_internal_energy_vapor                  = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 1, 'NitrousOxide'), temperature_range);        % Specific internal energy for vapor N2O (J/kg).


N2O.temperature2density_liquid                  = @(T) interp1(temperature_range, density_liquid,                  T);
N2O.temperature2density_vapor                   = @(T) interp1(temperature_range, density_vapor,                   T);
N2O.temperature2specific_internal_energy_liquid = @(T) interp1(temperature_range, specific_internal_energy_liquid, T);
N2O.temperature2specific_internal_energy_vapor  = @(T) interp1(temperature_range, specific_internal_energy_vapor,  T);




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




%% Importing stuff


% Set up the import options.
import_options_N2O = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter.
import_options_N2O.DataLines = [8, 602];
import_options_N2O.Delimiter = ";";

% Specify column names and types.
import_options_N2O.VariableNames = ["TemperatureK", "Pressurebar", "Liquiddensitykgm", "Gasdensitykgm", "LiquidIntEnergy", "VaporIntEnergy", "LiquidEnthalpy", "VaporEnthalpy"];
import_options_N2O.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
import_options_N2O.ExtraColumnsRule = "ignore";
import_options_N2O.EmptyLineRule = "read";

% Import the data.
N2O_import     = readtable("Datasets/nitrous-oxide_LVsaturation.csv", import_options_N2O);

% Spline fitting.
temperatures              = N2O_import.TemperatureK;         % Get temperature range.
saturation_pressures      = N2O_import.Pressurebar;          % Get saturation pressure for the temperatures above.
%densities_liquid          = N2O_import.Liquiddensitykgm;     % Get liquid density for the temperatures above.
densities_vapor           = N2O_import.Gasdensitykgm;        % Get gas density for the temperatures above.
internal_energies_liquid  = N2O_import.LiquidIntEnergy;      % Get liquid internal energy for the temperatures above.
internal_energies_vapor   = N2O_import.VaporIntEnergy;       % Get gas internal energy for the temperatures above.


N2O.temperature2saturation_pressure            = fnxtr(csaps(temperatures,         saturation_pressures     ), 2);
N2O.temperature2internal_energy_liquid         = fnxtr(csaps(temperatures,         internal_energies_liquid ), 2);
N2O.temperature2internal_energy_vapor          = fnxtr(csaps(temperatures,         internal_energies_vapor  ), 2);
N2O.saturation_pressure2density_vapor          = fnxtr(csaps(saturation_pressures, densities_vapor          ), 2);
N2O.saturation_pressure2internal_energy_liquid = fnxtr(csaps(saturation_pressures, internal_energies_liquid ), 2);
N2O.saturation_pressure2internal_energy_vapor  = fnxtr(csaps(saturation_pressures, internal_energies_vapor  ), 2);



N2O.Molecular_weight = 44.013e-3;           % Molecular weight N2O (kg/mol).
N2O.gamma = 1.31;                           % Adiabatic index coefficient N2O.
N2O.viscosity = 2.98e-5;                        % Pa.s
N2O.calorific_capacity = 2269.5;           % J/kg
N2O.thermal_conductivity = 103e-3;         % W/m.K




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


density_liquid           = py.CoolProp.CoolProp.PropsSI('D', 'P', pressure, 'Q', 0, 'NitrousOxide');   %Density of Oxidizer (kg/m^3)
density_vapor            = py.CoolProp.CoolProp.PropsSI('D', 'P', pressure, 'Q', 1, 'NitrousOxide');   %Density of Oxidizer (kg/m^3)

massic_enthalpy_liquid   = py.CoolProp.CoolProp.PropsSI('H', 'P', pressure, 'Q', 0, 'NitrousOxide');   %Enthalpie massic (J/kg)
massic_enthalpy_vapor    = py.CoolProp.CoolProp.PropsSI('H', 'P', pressure, 'Q', 1, 'NitrousOxide');   %Enthalpie massic (J/kg)
massic_enthalpy_combined = massic_enthalpy_vapor - massic_enthalpy_liquid;

k = (density_liquid / density_vapor)^(1/3);

end



end