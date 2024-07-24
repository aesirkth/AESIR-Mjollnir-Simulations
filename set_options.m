
%% Manual settings.


comp.Cd = 0.85;                  % Discharge coefficient.
comp.a = 20e-5;                  % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
comp.n = 0.55;                   % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
comp.dr_thdt = 0.35e-2;           % Constant approximation of regression rate (m/s).

%% Vehicle parameters.
comp.n_inj = 80;                 % Number of injector holes.

%% Environment parameters.
% TODO: Retrieve from data?
comp.P_cc_init = 2500000;        % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
comp.T_tank_init = 285;          % Initial tank temperature (K).
comp.T_ext = 282;                % External (environment) temperature (K).

[T_ext_COESA, ~, P_atm, ~] = atmoscoesa(0);
comp.dT_ext = T_ext_COESA - comp.T_ext;     % Difference between the COESA temperature and the actual temperature (K).
comp.P_atm = P_atm;                         % Atmospheric pressure (Pa).

%% Other settings (TODO: give good name).
comp.filling_ratio = 0.95;      % Tank filling ratio.
comp.launch_angle = 87;         % Launch angle (°).

comp.drag_coefficient = 0.5;     
comp.combustion_efficiency = 0.9;

%% Physical constants.
comp.g = 9.81;                                  % Gravitational constant (m/s^2).
comp.R = 8.314;                                 % Universal gas constant (J/K/mol).

comp.stephan_cst = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
comp.eber_parameter = 0.89;                     % Eber parameter for vertex angle between 20-50 degrees.
comp.Molecular_weight_air = 28.9647e-3;         % Molecular weight of air (kg/mol).
comp.r_air = comp.R / comp.Molecular_weight_air;

%% Requirements.
comp.design_altitude = 14000;          % Designed altitude to reach (m).
comp.required_altitude = 12000;        % Mission requirements (m).

%% Mass.
comp.parachute_mass = 10;
comp.electronics_mass = 2.3;
comp.bodyTube_mass = 7;
comp.payload_mass = 2;

comp.propulsionSystem = 24.504;

comp.dry_mass = comp.parachute_mass + comp.electronics_mass + comp.bodyTube_mass + comp.payload_mass + comp.propulsionSystem;

comp.m_ox_init = 24.5;          % Oxidizer mass (kg).
comp.m_fuel_init = 3.1;         % Fuel mass (kg).
comp.rho_ox = 785;              % Oxidizer density (kg/m^3).

%% Tank geometry.    
if full_duration
    comp.D_ext_tank = 16e-2;    % Tank external diameter for full-duration burn (m).
    comp.L_tank = 1.83;         % Tank length for full-duration burn (m).
else
    comp.D_ext_tank = 10e-2;    % Tank external diameter for short-duration burn (m).
    comp.L_tank = 0.73;         % Tank length for short-duration burn (m).
end

comp.e_tank = 3.5e-3;                                                   % Tank thickness.
comp.D_int_tank = comp.D_ext_tank - 2 * comp.e_tank;    %9.42e-2;       % Tank internal diameter (m).
comp.V_tank = pi * (comp.D_int_tank)^2 / 4 * comp.L_tank;   %33.1e-3;   % Tank volume (m^3) (present in Tank_Temperature_finder_fct).
comp.surface = pi * (comp.D_ext_tank)^2 / 4;                            % Rocket surface.

%% Kastrullen.
comp.L_kastrullen = 35e-2;  % Length of Kastrullen.

%% Injector geometry.             
comp.r_inj = 1.2e-3 / 2;        % Injector radius (m).
comp.L_inj = 15e-3;             % Injector plate thickness (m).

comp.r_inj_plate = 30e-3;       % m
comp.mass_inj = 0.271;          % kg
comp.e_inj = 0.013;             % m

%% Combustion chamber geometry.
comp.D_cc_ext = 15.2e-2;                        % Combustion chamber external diameter (m).
comp.e_cc = 4e-3;
comp.D_cc_int = comp.D_cc_ext-2 * comp.e_cc;    % Combustion chamber interanl diameter (m)*.
comp.L_cc_casing = 609.69e-3;                   % Combustion chamber total casing (pre_cc + cc).
comp.L_pcc = 75e-3;                             % Pre-combustion chamber length.
comp.mass_pcc = 0.5;                            % Pre-combustion chamber mass.
comp.L_cc = 505.8e-3;                           % Combustion chamber total length(m).
comp.T_cc = 3650;                               % Combustion chamber temperature (K).

%% Ox properties.
comp.Molecular_weight_ox = 44.013e-3;           % Molecular weight N2O (kg/mol).
% comp.r_ox = comp.R/comp.Molecular_weight_ox;
comp.gamma_ox = 1.31;                           % Adiabatic index coefficient N2O.
comp.visc_nox = 2.98e-5;                        % Pa.s
comp.calorific_capacity_nox = 2269.5;           % J/kg
comp.thermal_conductivity_nox = 103e-3;         % W/m.K
 
%% Fuel properties.
comp.L_fuel = 33e-2;            % Fuel length (m).
comp.fuel_mass_init = 3.1;      % Initial fuel mass (kg).
comp.rho_fuel = 900;            % Density of fuel (kg/m^3).
comp.r_fuel_init = 5e-2 / 2;    % Fuel port diameter at ignition.
% comp.r_fuel_init = sqrt(comp.D_cc_int^2/4-comp.fuel_mass_init/(comp.rho_fuel*comp.L_fuel*pi));

comp.fuel_margin_mass = 1.2;    % Mass of fuel that is for margin (kg).
comp.fuel_margin_radius = sqrt(comp.D_cc_int^2 / 4 - comp.fuel_margin_mass / (comp.rho_fuel * comp.L_fuel * pi));

comp.CombustionChamberSinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
Sin_amp = comp.CombustionChamberSinusShapeAmplitude; 
R = comp.r_fuel_init;
dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);   % Combustion diameter taking into account sinus shape.
comp.CombustionChamberInitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.

%% Air properties sea level at 0°.   
comp.rho_air_SL = 1.292;                    % Air density (kg/m^3).
comp.visc_dyn_air_SL = 1.729e-5;            % Air dynamic viscosity (kg/m.s).
comp.cp_air_SL = 1006;                      % Specific heat of air (J/kg.K).
comp.air_thermal_conductivity = 0.02364;    % Thermal conductivity air (W/m.K).

%% Combustion properties.
comp.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
comp.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).
comp.T_cc = 3700;                                       % Combustion temperature (K).

%% Nozzle properties.
comp.D_throat = 38.4e-3;
% comp.A_throat_init = pi*(comp.D_throat)^2/4;  % Nozzle throat area (m^2).
Ae_At = 4.75;
comp.D_exit = sqrt(Ae_At) * comp.D_throat;
comp.A_exit = pi * (comp.D_exit)^2 / 4;         % Nozzle exit area (m^2).

comp.beta_nozzle = 80;                          % Nozzle inlet angle (in °).
comp.alpha_nozzle = 10;                         % Nozzle exit angle (in °).
comp.L_nozzle = 154.55e-3;                      % Nozzle length (m).

%% Tank properties.
comp.aluminium_thermal_conductivity = 236;      % Wm-1K-1 at 0 degree celcius.
comp.rho_alu = 2700;                            % Density aluminium (kg/m^3).
comp.alu_thermal_capacity = 897;                % J/K/kg
comp.aluminium_emissivity_painted = 0.8;        % Emissivity of painted tank.
comp.aluminium_emissivity = 0.3;                % Emissivity of plain aluminium.
comp.aluminium_absorbitivity = 0.4;             % Absorptivity of plain aluminium.

%% Set up the import options.
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
N2O = readtable("Datasets/nitrous-oxide_LVsaturation.csv", import_options_N2O);
c_star = readtable("Datasets/characteristic_velocity.csv");

%% Clear temporary variables.
clear import_options_N2O

%% Spline fitting.
Temperature_set = N2O.TemperatureK;         % Get temperature range.
N2O_Psat_set = N2O.Pressurebar;             % Get saturation pressure for the temperatures above.
N2O_Rhol_set = N2O.Liquiddensitykgm;        % Get liquid density for the temperatures above.
N2O_Rhog_set = N2O.Gasdensitykgm;           % Get gas density for the temperatures above.
N2O_Ul_set = N2O.LiquidIntEnergy;           % Get liquid internal energy for the temperatures above.
N2O_Ug_set = N2O.VaporIntEnergy;            % Get gas internal energy for the temperatures above.

% Put all variables in a map under the shorthand names.
names = {'T', 'Psat', 'Rhol', 'Rhog', 'Ul', 'Ug'};
vars = [Temperature_set, N2O_Psat_set, N2O_Rhol_set, N2O_Rhog_set, N2O_Ul_set, N2O_Ug_set];
N2O_vars = containers.Map;
for i = 1:length(names)
    N2O_vars(string(names(i))) = vars(:, i);
end

% Specify the x and y variables that are required, and a name for each pair.
xs = {'T', 'T', 'T', 'T', 'T', 'Psat', 'Psat', 'Psat'};
ys = {'Psat', 'Rhol', 'Rhog', 'Ul', 'Ug', 'Rhog', 'Ul', 'Ug'};
names = {'Psat', 'RhoL_T', 'RhoG_T', 'UL_T', 'UG_T', 'RhoG_P', 'UL_P', 'UG_P'};

% Fit a spline to each (x, y) pair.
for i = 1:length(names)
    x = N2O_vars(string(xs(i)));
    y = N2O_vars(string(ys(i)));
    name = string(names(i)) + '_N2O_spline';
    spln = csaps(x, y);                         % Fit a cubic smoothing spline to the data.
    comp.(name) = fnxtr(spln, 2);               % Extrapolate with a quadratic polynomial to avoid wonkiness at the boundaries.
end

% Plots for debugging.
if debug_plot
    rows = ceil(sqrt(length(names)));
    tiledlayout(rows, rows)
    for i = 1:length(names)
        x = N2O_vars(string(xs(i)));
        y = N2O_vars(string(ys(i)));
        name = string(names(i)) + '_N2O_spline';
        nexttile
        hold on
        xlim([0.99 * min(x) 1.01 * max(x)])
        scatter(x, y, '.')
        fnplt(comp.(name))
        hold off
    end
end

% Delete temporary variables.
clear debug_plot i name names N2O_vars spln vars x xs y ys;

comp.OF_set = c_star.OF;                                % OF ratio range.
comp.c_star_set = c_star.c_star;                        % Characteristic velocity c_star.
% comp.C_Star_polynom=polyfit(OF_set,C_star_set,5);     % Interpolation degree 3.

%% Storage tank geometry.

% TODO: Make sure that this data is only used for the tank filling
%       simulation and remove/move it.

comp.D_ext_storage = 230e-3;                                        % Storage tank external diameter (m).
comp.V_storage = 50e-3;                                             % Storage tank volume (m^3).
comp.D_int_storage = comp.D_ext_storage - 2 * comp.e_tank;
comp.L_storage = comp.V_storage / (pi * (comp.D_int_storage)^2 / 4);

%% Filling properties.

% TODO: Make sure that this data is only used for the tank filling
%       simulation and remove/move it.

comp.d_filling_inlet = 4.7e-3;      %2.5e-3;    % m 
comp.d_filling_outlet = 0.9e-3;                 % m

comp.S_inlet = pi * (comp.d_filling_inlet)^2 / 4;
comp.S_outlet = pi * (comp.d_filling_outlet)^2 / 4;

comp.P_storage_tank_init = fnval(comp.Psat_N2O_spline, comp.T_ext) * 10^6;
comp.cd_inlet = 0.85;
comp.cd_outlet = 0.95;
% comp.r_ox = py.CoolProp.CoolProp.PropsSI('P','T',comp.T_ext,'Q', 1,'NitrousOxide') / py.CoolProp.CoolProp.PropsSI('D','T',comp.T_ext,'Q', 1,'NitrousOxide') / comp.T_ext;
% comp.r_ox = 180.7175;
