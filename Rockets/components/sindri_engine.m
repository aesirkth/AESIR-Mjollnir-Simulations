function [engine, state_variables] = sindri_engine()


%% Engine

engine                  = struct();



engine.position         = [0;0;-2];
engine.mass             = 24.504;     % Total engine mass (kg)
engine.active_burn_flag = 0;

c_star                          = readtable("Datasets/characteristic_velocity.csv");
engine.OF_set           = c_star.OF;                                % OF ratio range.
engine.c_star_set       = c_star.c_star;                        % Characteristic velocity c_star.


%% Injectors:
engine.injectors                  = struct();
engine.injectors.position         = [0;0;-1.7];
engine.injectors.number_of        = 80;                                                                            % Number of injectors holes.
engine.injectors.radius           = 1.2e-3 / 2;                                                                    % injectors radius (m).
engine.injectors.diameter         = 2*engine.injectors.radius;                                             % injectors diameter (m).
engine.injectors.total_area       = engine.injectors.number_of*pi*(engine.injectors.radius)^2;     % injectors total area for ALL the injectorss (m).
engine.injectors.plate_thickness  = 15e-3;                                                                         % injectors plate thickness (m).
engine.injectors.plate_radius     = 30e-3;                                                                         % plate radius(?) (m)
engine.injectors.mass             = 0.271;                                                                         % total injector mass (kg)
engine.injectors.e                = 0.013;                                                                         % (???) (m)




%% Fuel-grain properties.
engine.fuel_grain                 = struct();
engine.fuel_grain.position        = [0;0;-2.1];
engine.fuel_grain.mass            = 3.1;                             % (kg)
engine.fuel_grain.length          = 33e-2;                           % Fuel length (m).
engine.fuel_grain.density         = 900;                             % Density of fuel (kg/m^3).
engine.fuel_grain.radius          = 5e-2 / 2;                        % Fuel port diameter at ignition.

engine.fuel_grain.mass_margin     = 1.2;                              % Mass of fuel that is for margin (kg).
engine.fuel_grain.radius_margin   = sqrt(engine.fuel_grain.radius^2 ...
                                               - engine.fuel_grain.mass_margin / ...
                                                (engine.fuel_grain.density * ...
                                                 engine.fuel_grain.length * pi));

engine.fuel_grain.a               = 20e-5;                           % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
engine.fuel_grain.n               = 0.55;                            % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
engine.fuel_grain.dr_thdt         = 0.35e-2;                         % Constant approximation of regression rate (m/s).








%% Combustion-chamber

engine.combustion_chamber                       = struct();
engine.combustion_chamber.position              = [0.07;0.07;-1.9];
engine.combustion_chamber.pressure              = 2500000; % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
engine.combustion_chamber.temperature           = 285;     % Initial combustion chamber temperature.
engine.combustion_chamber.thickness             = 4e-3;                                                             % Combustion chamber thickness (m).
engine.combustion_chamber.external_diameter     = 15.2e-2;                                                  % Combustion chamber external diameter (m).
engine.combustion_chamber.internal_diameter     = engine.combustion_chamber.external_diameter ...
                                                       -2*engine.combustion_chamber.thickness;             % Combustion chamber interanl diameter (m)*.

engine.combustion_chamber.internal_radius       = engine.combustion_chamber.internal_diameter*0.5;
engine.combustion_chamber.external_radius       = engine.combustion_chamber.external_diameter*0.5;
engine.combustion_chamber.length                = 505.8e-3;                                                % Combustion chamber total casing (pre_cc + cc).
engine.combustion_chamber.temperature           = 3700;                                                    % Combustion temperature (K).
engine.combustion_chamber.combustion_efficiency = 0.9;
%engine.combustion_chamber.radius             = engine.fuel_grain.radius;                        % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).

engine.combustion_chamber.SinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
            Sin_amp = engine.combustion_chamber.SinusShapeAmplitude; 
            R = engine.fuel_grain.radius;
            dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);      % Combustion diameter taking into account sinus shape.
engine.combustion_chamber.InitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.




%% Pre-combustion-chamber properties.

engine.pre_combustion_chamber                  = struct();
engine.pre_combustion_chamber.position         = [0;0;-1.8];
engine.pre_combustion_chamber.length           = 75e-3;                                                   % Pre-combustion chamber length.
engine.pre_combustion_chamber.mass             = 0.5;                                                     % Pre-combustion chamber mass.

engine.combustion_chamber.temperature          = 280;                                                     % Combustion chamber temperature (K).



%% Nozzle properties.

engine.nozzle                  = struct();
engine.nozzle.position         = [0;0;-2.3];

engine.nozzle.throat           = struct();

engine.nozzle.throat.diameter  = 38.4e-3;
engine.nozzle.throat.position  = [0;0;-2.25];

Ae_At                              = 4.75;

engine.nozzle.exit             = struct();
engine.nozzle.exit.diameter    = sqrt(Ae_At) * engine.nozzle.throat.diameter;
engine.nozzle.exit.area        = pi * (engine.nozzle.exit.diameter)^2 / 4;         % Nozzle exit area (m^2).
engine.nozzle.exit.position    = [0;0;-2.35];

engine.nozzle.beta             = 80;                                                                                                                                       % Nozzle inlet angle (in °).
engine.nozzle.alpha            = 10;                            % Nozzle exit angle (in °).
engine.nozzle.length           = 154.55e-3;                         % Nozzle length (m).
engine.nozzle.throat.radius    = engine.nozzle.throat.diameter / 2;      





%% Combustion properties.
engine.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
engine.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).


engine.fuel_grain.radius_init  = engine.fuel_grain.radius;
                                            % The initial radius of the nozzle throat is half of the throat diameter.    




state_variables = {"fuel_grain.radius", ...
                   "nozzle.throat.radius", ...
                   "combustion_chamber.pressure", ...
                   "active_burn_flag"};