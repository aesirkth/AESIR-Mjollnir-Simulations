function mjolnir = initiate_mjolnir()
terrain = evalin("base", "terrain");

mjolnir = struct();
mjolnir.dont_record = ["", ""];



mjolnir.tank         = struct();
mjolnir.engine       = struct();
mjolnir.engine.mass  = 24.504;     % Total engine mass (kg)



mjolnir.engine.nozzle             = struct();

mjolnir.tank.tank_wall           = struct();
mjolnir.tank.liquid              = struct();
mjolnir.tank.vapor               = struct();

mjolnir.N2O                      = initiate_N2O;

mjolnir.dont_record(end+1)       = "N2O";


%% Rigid-body model
mjolnir.rigid_body                               = struct();

mjolnir.rigid_body.forces                        = struct();
mjolnir.rigid_body.moments                       = struct();
mjolnir.rigid_body.g                             = 9.81;
mjolnir.rigid_body.mass                          = 0;                       % dependant
mjolnir.rigid_body.attitude                      = rotx(5)*eye(3);
mjolnir.rigid_body.center_of_mass                = [0;0;0.5];
mjolnir.rigid_body.angular_momentum              = zeros(3,1);
mjolnir.rigid_body.rotation_rate                 = zeros(3,1);
mjolnir.rigid_body.position                      = [0;0;terrain.z(0,0)];
mjolnir.rigid_body.velocity                      = zeros(3,1);
mjolnir.rigid_body.moment_of_inertia             = eye(3)*(80*4.^2)*0.2;
mjolnir.rigid_body.moment_of_inertia(3,3)        = (80*4.^2)*2;


mjolnir.rigid_body.forces.null                   = force ([0;0;0], [0;0;0]);
mjolnir.rigid_body.moments.null                  = moment([0;0;0], [0;0;0]);




%% Mesh:
mjolnir.mesh                                     = stlread("./assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
mjolnir.dont_record(1)                           = "mesh";
mjolnir.mesh.vertices                            = mjolnir.mesh.vertices*0.05;
mjolnir.mesh.vertices                            = mjolnir.mesh.vertices -   ...
                                                    0.5*[max(mjolnir.mesh.vertices(:,1))+min(mjolnir.mesh.vertices(:,1));
                                                         max(mjolnir.mesh.vertices(:,2))+min(mjolnir.mesh.vertices(:,2));
                                                         max(mjolnir.mesh.vertices(:,3))+min(mjolnir.mesh.vertices(:,3))]';






%% Aerodynamics-model
mjolnir.aerodynamics                              = struct();

mjolnir.aerodynamics                              = mesh2aerodynamics(mjolnir);
mjolnir.aerodynamics.wind_velocity                = [0;0;0];
mjolnir.aerodynamics.air_density                  = 1.2;
mjolnir.aerodynamics.pressure_coefficient         = [0.2;0.2;0.1];
mjolnir.aerodynamics.friction_coefficient         = ones(3,1)*0.01;














mjolnir.Cd = 0.85;                  % Discharge coefficient.
mjolnir.a = 20e-5;                  % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
mjolnir.n = 0.55;                   % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
mjolnir.dr_thdt = 0.35e-2;          % Constant approximation of regression rate (m/s).



%% Injectors:
mjolnir.engine.injectors                 = struct();

mjolnir.engine.injectors.number_of       = 80;                                                                            % Number of injectors holes.
mjolnir.engine.injectors.radius          = 1.2e-3 / 2;                                                                    % injectors radius (m).
mjolnir.engine.injectors.diameter        = 2*mjolnir.engine.injectors.radius;                                             % injectors diameter (m).
mjolnir.engine.injectors.total_area      = mjolnir.engine.injectors.number_of*pi*(mjolnir.engine.injectors.radius)^2;     % injectors total area for ALL the injectorss (m).
mjolnir.engine.injectors.plate_thickness = 15e-3;                                                                         % injectors plate thickness (m).
mjolnir.engine.injectors.plate_radius    = 30e-3;                                                                         % plate radius(?) (m)
mjolnir.engine.injectors.mass            = 0.271;                                                                         % total injector mass (kg)
mjolnir.engine.injectors.e               = 0.013;                                                                         % (???) (m)


%% Shute
mjolnir.shute              = struct();
mjolnir.shute.mass         = 10;


%% Payload
mjolnir.payload            = struct();
mjolnir.payload.mass       = 2;


%% Electronics
mjolnir.electronics        = struct();
mjolnir.electronics.mass   = 2.3;


%% Body-tube
mjolnir.body_tube          = struct();
mjolnir.body_tube.mass     = 7;


mjolnir.dry_mass = mjolnir.shute      .mass + ...
                   mjolnir.electronics.mass + ...
                   mjolnir.body_tube  .mass + ...
                   mjolnir.payload    .mass + ...
                   mjolnir.engine     .mass;



%% Combustion-chamber
mjolnir.engine.combustion_chamber = struct();

mjolnir.engine.combustion_chamber.pressure     = 2500000; % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
mjolnir.engine.combustion_chamber.temperature  = 285;     % Initial combustion chamber temperature.



%% Environment parameters.
% TODO: Retrieve from data?
mjolnir.T_tank = 285;               % Initial tank temperature (K).
mjolnir.T_wall = 285;               % Assume that initial tank wall temperature is equal to the initial internal temperature (K).
mjolnir.T_ext = 282;                % External (environment) temperature (K).

evalin("base", "T_tank_initial_estimate = 285;")

[T_ext_COESA, ~, P_atm, ~] = atmoscoesa(0);
mjolnir.dT_ext = T_ext_COESA - mjolnir.T_ext;  % Difference between the COESA temperature and the actual temperature (K).
mjolnir.P_atm = P_atm;                         % Atmospheric pressure (Pa).

%% Other settings (TODO: give good name).
mjolnir.active_burn_flag = 0;
mjolnir.filling_ratio = 0.95;      % Tank filling ratio.
mjolnir.launch_angle = 87;         % Launch angle (°).

mjolnir.drag_coefficient = 0.5;     
mjolnir.combustion_efficiency = 0.9;

%% Physical constants.
mjolnir.R = 8.314;                                 % Universal gas constant (J/K/mol).

mjolnir.stephan_cst = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
mjolnir.eber_parameter = 0.89;                     % Eber parameter for vertex angle between 20-50 degrees.
mjolnir.Molecular_weight_air = 28.9647e-3;         % Molecular weight of air (kg/mol).
mjolnir.r_air = mjolnir.R / mjolnir.Molecular_weight_air;

%% Requirements.
mjolnir.design_altitude = 14000;          % Designed altitude to reach (m).
mjolnir.required_altitude = 12000;        % Mission requirements (m).




mjolnir.m_ox = 24.5;           % Oxidizer mass (kg).
mjolnir.m_fuel = 3.1;          % Fuel mass (kg).
mjolnir.rho_ox = 785;               % Oxidizer density (kg/m^3).

mjolnir.mass = mjolnir.dry_mass + mjolnir.m_ox + mjolnir.m_fuel;

mjolnir.h_liq     = 0;              % Thermal heat flux from the tank wall to the interior (dependant, computed in simulation). 
mjolnir.h_gas     = 0;              % Thermal heat flux from the tank wall to the interior (dependant, computed in simulation). 
mjolnir.h_air_ext = 0;              % Thermal heat flux from the exterior to the tank wall (dependant, computed in simulation).

mjolnir.P_tank    = 0;              % Tank temperature (dependant, mjolniruted in simulation).

%% Tank geometry.    
if evalin("base", "full_duration")
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


%% Combustion chamber geometry.
mjolnir.D_cc_ext = 15.2e-2;                              % Combustion chamber external diameter (m).
mjolnir.e_cc = 4e-3;
mjolnir.D_cc_int = mjolnir.D_cc_ext-2 * mjolnir.e_cc;    % Combustion chamber interanl diameter (m)*.
mjolnir.L_cc_casing = 609.69e-3;                         % Combustion chamber total casing (pre_cc + cc).
mjolnir.L_pcc = 75e-3;                                   % Pre-combustion chamber length.
mjolnir.mass_pcc = 0.5;                                  % Pre-combustion chamber mass.
mjolnir.L_cc = 505.8e-3;                                 % Combustion chamber total length(m).
mjolnir.T_cc = 280;                                     % Combustion chamber temperature (K).

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







mjolnir.m_liq = mjolnir.filling_ratio       * mjolnir.V_tank *  mjolnir.N2O.temperature2density_liquid(mjolnir.T_tank);               % The liquid mass is the liquid volume in the tank times the liquid density (kg).
mjolnir.m_vap = (1 - mjolnir.filling_ratio) * mjolnir.V_tank *  mjolnir.N2O.temperature2density_vapor (mjolnir.T_tank);               % The liquid mass is the remaining volume in the tank times the vapor density (kg).

mjolnir.m_ox         = mjolnir.m_liq + mjolnir.m_vap;                                         % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
mjolnir.U_total      = mjolnir.m_liq * mjolnir.N2O.temperature2specific_internal_energy_liquid(mjolnir.T_tank) ...
                     + mjolnir.m_vap * mjolnir.N2O.temperature2specific_internal_energy_vapor(mjolnir.T_tank);         % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).
mjolnir.r_cc         = mjolnir.r_fuel;                                                        % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).
mjolnir.r_fuel_init  = mjolnir.r_fuel;
mjolnir.r_throat     = mjolnir.D_throat / 2;                                                  % The initial radius of the nozzle throat is half of the throat diameter.
mjolnir.remaining_ox = 100;      















c_star  = readtable("Datasets/characteristic_velocity.csv");

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

mjolnir.P_storage_tank = fnval(mjolnir.N2O.temperature2saturation_pressure, mjolnir.T_ext) * 10^6;
mjolnir.cd_inlet = 0.85;
mjolnir.cd_outlet = 0.95;
% mjolnir.r_ox = py.CoolProp.CoolProp.PropsSI('P','T',mjolnir.T_ext,'Q', 1,'NitrousOxide') / py.CoolProp.CoolProp.PropsSI('D','T',mjolnir.T_ext,'Q', 1,'NitrousOxide') / mjolnir.T_ext;
% mjolnir.r_ox = 180.7175;


%mjolnir = system_equations(0, zeros(29,1), mjolnir);