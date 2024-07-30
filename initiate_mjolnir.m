g                                   = 9.82;
wind_velocity                       = [0;0;0];
air_density                         = 1.2;

%% Manual settings.
mjolnir = struct();

mjolnir.center_of_pressure          = zeros(3,1);


%% Global coordinates
mjolnir.attitude                    = rotz(45)*roty(1);
mjolnir.dimensions                  = [1;1;1];
mjolnir.angular_momentum            = zeros(3,1);
mjolnir.rotation_rate               = zeros(3,1);
mjolnir.position                    = [0;0;10];
mjolnir.velocity                    = zeros(3,1);
mjolnir.forces                      = dictionary(" ",  force([0;0;0], [0;0;0]));
mjolnir.moments                     = dictionary(" ", moment([0;0;0], [0;0;0]));
mjolnir.area                        = ones(3,1);
mjolnir.pressure_coefficient        = eye(3)*0.2;

mjolnir.friction_coefficient        = ones(3,1)*0.2;
mjolnir.relative_velocity           = zeros(3,1);

mjolnir.mass                        = 200;
mjolnir.center_of_mass              = [0;0;0.5];

mjolnir.mesh                        = stlread("./assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
mjolnir.mesh.vertices               = mjolnir.mesh.vertices*0.05;
mjolnir.mesh.vertices               = mjolnir.mesh.vertices - 0.5*[max(mjolnir.mesh.vertices(:,1))+min(mjolnir.mesh.vertices(:,1));
                                                                       max(mjolnir.mesh.vertices(:,2))+min(mjolnir.mesh.vertices(:,2));
                                                                       max(mjolnir.mesh.vertices(:,3))+min(mjolnir.mesh.vertices(:,3))]';

mjolnir                             = data_from_mesh(mjolnir);
mjolnir.center_of_mass(1:2)         = mjolnir.center_of_pressure(1:2);
mjolnir                             = data_from_mesh(mjolnir);
mjolnir.moment_of_area(:,1:2,[1,3]) = 0;
mjolnir.moment_of_inertia           = eye(3)*(mjolnir.mass*mjolnir.length_scale(3).^2)/12;
mjolnir.moment_of_inertia(3,3)      = (mjolnir.mass*mjolnir.length_scale(1).^2)/2;




mjolnir.forces("gravity")           = force(g*mjolnir.mass*[0;0;-1], mjolnir.center_of_mass);




mjolnir.x = 0;                      % Position along x [m]
mjolnir.y = 0;                      % Position along y [m]
mjolnir.dxdt = 0;                   % Velocity along x [m/s]
mjolnir.dydt = 0;                   % Velocity along x [m/s]

mjolnir.Cd = 0.85;                  % Discharge coefficient.
mjolnir.a = 20e-5;                  % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
mjolnir.n = 0.55;                   % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
mjolnir.dr_thdt = 0.35e-2;          % Constant approximation of regression rate (m/s).

%% Vehicle parameters.
mjolnir.n_inj = 80;                 % Number of injector holes.

%% Environment parameters.
% TODO: Retrieve from data?
mjolnir.P_cc = 2500000;             % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
mjolnir.T_tank = 285;               % Initial tank temperature (K).
mjolnir.T_wall = 285;               % Assume that initial tank wall temperature is equal to the initial internal temperature (K).
mjolnir.T_ext = 282;                % External (environment) temperature (K).

[T_ext_COESA, ~, P_atm, ~] = atmoscoesa(0);
mjolnir.dT_ext = T_ext_COESA - mjolnir.T_ext;  % Difference between the COESA temperature and the actual temperature (K).
mjolnir.P_atm = P_atm;                         % Atmospheric pressure (Pa).

%% Other settings (TODO: give good name).
mjolnir.filling_ratio = 0.95;      % Tank filling ratio.
mjolnir.launch_angle = 87;         % Launch angle (°).

mjolnir.drag_coefficient = 0.5;     
mjolnir.combustion_efficiency = 0.9;

%% Physical constants.
mjolnir.g = 9.81;                                  % Gravitational constant (m/s^2).
mjolnir.R = 8.314;                                 % Universal gas constant (J/K/mol).

mjolnir.stephan_cst = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
mjolnir.eber_parameter = 0.89;                     % Eber parameter for vertex angle between 20-50 degrees.
mjolnir.Molecular_weight_air = 28.9647e-3;         % Molecular weight of air (kg/mol).
mjolnir.r_air = mjolnir.R / mjolnir.Molecular_weight_air;

%% Requirements.
mjolnir.design_altitude = 14000;          % Designed altitude to reach (m).
mjolnir.required_altitude = 12000;        % Mission requirements (m).

%% Mass.
mjolnir.parachute_mass = 10;
mjolnir.electronics_mass = 2.3;
mjolnir.bodyTube_mass = 7;
mjolnir.payload_mass = 2;

mjolnir.propulsionSystem = 24.504;

mjolnir.dry_mass = mjolnir.parachute_mass + mjolnir.electronics_mass + mjolnir.bodyTube_mass + mjolnir.payload_mass + mjolnir.propulsionSystem;

mjolnir.m_ox = 24.5;           % Oxidizer mass (kg).
mjolnir.m_fuel = 3.1;          % Fuel mass (kg).
mjolnir.rho_ox = 785;               % Oxidizer density (kg/m^3).

mjolnir.h_liq     = 0;              % Thermal heat flux from the tank wall to the interior (dependant, computed in simulation). 
mjolnir.h_gas     = 0;              % Thermal heat flux from the tank wall to the interior (dependant, computed in simulation). 
mjolnir.h_air_ext = 0;              % Thermal heat flux from the exterior to the tank wall (dependant, computed in simulation).

mjolnir.P_tank    = 0;              % Tank temperature (dependant, mjolniruted in simulation).

%% Tank geometry.    
if full_duration
    mjolnir.D_ext_tank = 16e-2;    % Tank external diameter for full-duration burn (m).
    mjolnir.L_tank = 1.83;         % Tank length for full-duration burn (m).
else
    mjolnir.D_ext_tank = 10e-2;    % Tank external diameter for short-duration burn (m).
    mjolnir.L_tank = 0.73;         % Tank length for short-duration burn (m).
end

mjolnir.e_tank = 3.5e-3;                                                         % Tank thickness.
mjolnir.D_int_tank = mjolnir.D_ext_tank - 2 * mjolnir.e_tank;    %9.42e-2;       % Tank internal diameter (m).
mjolnir.V_tank = pi * (mjolnir.D_int_tank)^2 / 4 * mjolnir.L_tank;   %33.1e-3;   % Tank volume (m^3) (present in Tank_Temperature_finder_fct).
mjolnir.surface = pi * (mjolnir.D_ext_tank)^2 / 4;                               % Rocket surface.

%% Kastrullen.
mjolnir.L_kastrullen = 35e-2;      % Length of Kastrullen.

%% Injector geometry.             
mjolnir.r_inj = 1.2e-3 / 2;        % Injector radius (m).
mjolnir.L_inj = 15e-3;             % Injector plate thickness (m).

mjolnir.r_inj_plate = 30e-3;       % m
mjolnir.mass_inj = 0.271;          % kg
mjolnir.e_inj = 0.013;             % m

%% Combustion chamber geometry.
mjolnir.D_cc_ext = 15.2e-2;                              % Combustion chamber external diameter (m).
mjolnir.e_cc = 4e-3;
mjolnir.D_cc_int = mjolnir.D_cc_ext-2 * mjolnir.e_cc;    % Combustion chamber interanl diameter (m)*.
mjolnir.L_cc_casing = 609.69e-3;                         % Combustion chamber total casing (pre_cc + cc).
mjolnir.L_pcc = 75e-3;                                   % Pre-combustion chamber length.
mjolnir.mass_pcc = 0.5;                                  % Pre-combustion chamber mass.
mjolnir.L_cc = 505.8e-3;                                 % Combustion chamber total length(m).
mjolnir.T_cc = 3650;                                     % Combustion chamber temperature (K).

%% Ox properties.
mjolnir.Molecular_weight_ox = 44.013e-3;           % Molecular weight N2O (kg/mol).
% mjolnir.r_ox = mjolnir.R/mjolnir.Molecular_weight_ox;
mjolnir.gamma_ox = 1.31;                           % Adiabatic index coefficient N2O.
mjolnir.visc_nox = 2.98e-5;                        % Pa.s
mjolnir.calorific_capacity_nox = 2269.5;           % J/kg
mjolnir.thermal_conductivity_nox = 103e-3;         % W/m.K
 
%% Fuel properties.
mjolnir.L_fuel = 33e-2;            % Fuel length (m).
mjolnir.fuel_mass = 3.1;      % Initial fuel mass (kg).
mjolnir.rho_fuel = 900;            % Density of fuel (kg/m^3).
mjolnir.r_fuel = 5e-2 / 2;    % Fuel port diameter at ignition.
% mjolnir.r_fuel = sqrt(mjolnir.D_cc_int^2/4-mjolnir.fuel_mass/(mjolnir.rho_fuel*mjolnir.L_fuel*pi));

mjolnir.fuel_margin_mass = 1.2;    % Mass of fuel that is for margin (kg).
mjolnir.fuel_margin_radius = sqrt(mjolnir.D_cc_int^2 / 4 - mjolnir.fuel_margin_mass / (mjolnir.rho_fuel * mjolnir.L_fuel * pi));

mjolnir.CombustionChamberSinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
Sin_amp = mjolnir.CombustionChamberSinusShapeAmplitude; 
R = mjolnir.r_fuel;
dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);      % Combustion diameter taking into account sinus shape.
mjolnir.CombustionChamberInitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.

%% Air properties sea level at 0°.   
mjolnir.rho_air_SL = 1.292;                    % Air density (kg/m^3).
mjolnir.visc_dyn_air_SL = 1.729e-5;            % Air dynamic viscosity (kg/m.s).
mjolnir.cp_air_SL = 1006;                      % Specific heat of air (J/kg.K).
mjolnir.air_thermal_conductivity = 0.02364;    % Thermal conductivity air (W/m.K).

%% Combustion properties.
mjolnir.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
mjolnir.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).
mjolnir.T_cc = 3700;                                       % Combustion temperature (K).

%% Nozzle properties.
mjolnir.D_throat = 38.4e-3;
% mjolnir.A_throat = pi*(mjolnir.D_throat)^2/4;  % Nozzle throat area (m^2).
Ae_At = 4.75;
mjolnir.D_exit = sqrt(Ae_At) * mjolnir.D_throat;
mjolnir.A_exit = pi * (mjolnir.D_exit)^2 / 4;         % Nozzle exit area (m^2).

mjolnir.beta_nozzle = 80;                             % Nozzle inlet angle (in °).
mjolnir.alpha_nozzle = 10;                            % Nozzle exit angle (in °).
mjolnir.L_nozzle = 154.55e-3;                         % Nozzle length (m).

%% Tank properties.
mjolnir.aluminium_thermal_conductivity = 236;        % Wm-1K-1 at 0 degree celcius.
mjolnir.rho_alu = 2700;                              % Density aluminium (kg/m^3).
mjolnir.alu_thermal_capacity = 897;                  % J/K/kg
mjolnir.aluminium_emissivity_painted = 0.8;          % Emissivity of painted tank.
mjolnir.aluminium_emissivity = 0.3;                  % Emissivity of plain aluminium.
mjolnir.aluminium_absorbitivity = 0.4;               % Absorptivity of plain aluminium.

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
    spln = csaps(x, y);                            % Fit a cubic smoothing spline to the data.
    mjolnir.(name) = fnxtr(spln, 2);               % Extrapolate with a quadratic polynomial to avoid wonkiness at the boundaries.
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
        fnplt(mjolnir.(name))
        hold off
    end
end

% Delete temporary variables.
clear debug_plot i name names N2O_vars spln vars x xs y ys;

mjolnir.OF_set = c_star.OF;                                % OF ratio range.
mjolnir.c_star_set = c_star.c_star;                        % Characteristic velocity c_star.
% mjolnir.C_Star_polynom=polyfit(OF_set,C_star_set,5);     % Interpolation degree 3.

%% Storage tank geometry.

% TODO: Make sure that this data is only used for the tank filling
%       simulation and remove/move it.

mjolnir.D_ext_storage = 230e-3;                                                    % Storage tank external diameter (m).
mjolnir.V_storage     = 50e-3;                                                     % Storage tank volume (m^3).
mjolnir.D_int_storage = mjolnir.D_ext_storage - 2 * mjolnir.e_tank;
mjolnir.L_storage     = mjolnir.V_storage / (pi * (mjolnir.D_int_storage)^2 / 4);

%% Filling properties.

% TODO: Make sure that this data is only used for the tank filling
%       simulation and remove/move it.

mjolnir.d_filling_inlet = 4.7e-3;      %2.5e-3;    % m 
mjolnir.d_filling_outlet = 0.9e-3;                 % m

mjolnir.S_inlet = pi * (mjolnir.d_filling_inlet)^2 / 4;
mjolnir.S_outlet = pi * (mjolnir.d_filling_outlet)^2 / 4;

mjolnir.P_storage_tank = fnval(mjolnir.Psat_N2O_spline, mjolnir.T_ext) * 10^6;
mjolnir.cd_inlet = 0.85;
mjolnir.cd_outlet = 0.95;
% mjolnir.r_ox = py.CoolProp.CoolProp.PropsSI('P','T',mjolnir.T_ext,'Q', 1,'NitrousOxide') / py.CoolProp.CoolProp.PropsSI('D','T',mjolnir.T_ext,'Q', 1,'NitrousOxide') / mjolnir.T_ext;
% mjolnir.r_ox = 180.7175;
