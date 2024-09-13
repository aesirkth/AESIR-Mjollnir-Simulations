function mjolnir = initiate_mjolnir()

mjolnir = struct();
mjolnir.dont_record = ["", ""];

mjolnir.static        = false; % True if simulation should be for a static fire, otherwise it is done for flight.
mjolnir.full_duration = true;  % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.


mjolnir.N2O                      = initiate_N2O;

mjolnir.dont_record(end+1)       = "N2O";


%% Enviroment & physical constants

mjolnir.enviroment                      = struct();
mjolnir.enviroment.dont_record          = ["",""];
mjolnir.enviroment.position             = [0.25;0.25;-0.2];
mjolnir.enviroment.g                    = 9.81;
mjolnir.enviroment.temperature          = 282;

mjolnir.enviroment.dont_record(end+1)   = "terrain";
mjolnir.enviroment.terrain              = initiate_terrain();

mjolnir.enviroment.R                    = 8.314;                       % Universal gas constant (J/K/mol).

mjolnir.enviroment.stephan_cst          = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
mjolnir.enviroment.eber_parameter       = 0.89;                        % Eber parameter for vertex angle between 20-50 degrees.
mjolnir.enviroment.Molecular_weight_air = 28.9647e-3;                  % Molecular weight of air (kg/mol).
mjolnir.enviroment.r_air                = mjolnir.enviroment.R / mjolnir.enviroment.Molecular_weight_air;



[mjolnir.enviroment.temperature_COESA, ~, mjolnir.enviroment.pressure, ~] = atmoscoesa(0);
 mjolnir.enviroment.dT_ext = mjolnir.enviroment.temperature_COESA - mjolnir.enviroment.temperature;  % Difference between the COESA temperature and the actual temperature (K).





%% Rigid-body model
mjolnir.forces                        = struct();
mjolnir.moments                       = struct();
mjolnir.mass                          = 0;                       % dependant
mjolnir.attitude                      = eye(3);
mjolnir.center_of_mass                = [0;0;0.5];
mjolnir.angular_momentum              = zeros(3,1);
mjolnir.rotation_rate                 = zeros(3,1);
mjolnir.position                      = [0;0;mjolnir.enviroment.terrain.z(0,0)];
mjolnir.velocity                      = zeros(3,1);
mjolnir.moment_of_inertia             = eye(3)*(80*4.^2)*0.2;
mjolnir.moment_of_inertia(3,3)        = (80*4.^2)*2;


mjolnir.forces.null                   = force ([0;0;0], [0;0;0]);
mjolnir.moments.null                  = moment([0;0;0], [0;0;0]);




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
mjolnir.aerodynamics.position                     = mjolnir.aerodynamics.center_of_pressure;



%% Shute
mjolnir.shute                         = struct();
mjolnir.shute.position                = [0;0;2];
mjolnir.shute.mass                    = 10;


%% Payload
mjolnir.payload                       = struct();
mjolnir.payload.position              = [0;0;1.7];
mjolnir.payload.mass                  = 2;


%% Electronics
mjolnir.electronics                   = struct();
mjolnir.electronics.position          = [0;0;1.5];
mjolnir.electronics.mass              = 2.3;


%% Guidance
mjolnir.guidance                      = struct();
mjolnir.guidance.D_gain               = 10000;
mjolnir.guidance.I_gain               = 100000;

mjolnir.guidance.control_athority     = 45;
mjolnir.guidance.desired_direction    = roty(45)*[0;0;1];
mjolnir.guidance.integrated_theta     = [0;0];

%% Body-tube
mjolnir.body_tube                     = struct();
mjolnir.body_tube.position            = [0.07;0.07;1.4];
mjolnir.body_tube.mass                = 7;


%% Kasrtullen
mjolnir.kastrullen                    = struct();
mjolnir.kastrullen.position           = [0;0;-1.5];
mjolnir.kastrullen.length             = 35e-2;      % Length of Kastrullen.



%% Tank

mjolnir.tank                         = struct();
mjolnir.tank.position                = [0;0;-0.5];
mjolnir.tank.filling_ratio           = 0.95;      % Tank filling ratio.

mjolnir.tank.vapor                   = struct();
mjolnir.tank.vapor.position          = [0;0;0.5];

% Liquid
mjolnir.tank.liquid                  = struct();
mjolnir.tank.liquid.position         = [0;0;-0.8];
mjolnir.tank.liquid.temperature      = 285;  % Initial tank temperature (K).

% Tank-wall
mjolnir.tank.wall                    = struct();
mjolnir.tank.wall.position           = [0.07;0.07;0.4];
mjolnir.tank.wall.  temperature      = 285;  % Assume that initial tank wall temperature is equal to the initial internal temperature (K).

%mjolnir.tank.exterior_wall = struct();


mjolnir.tank.wall.aluminium_thermal_conductivity = 236;        % Wm-1K-1 at 0 degree celcius.
mjolnir.tank.wall.rho_alu                        = 2700;       % Density aluminium (kg/m^3).
mjolnir.tank.wall.alu_thermal_capacity           = 897;        % J/K/kg
mjolnir.tank.wall.aluminium_emissivity_painted   = 0.8;        % Emissivity of painted tank.
mjolnir.tank.wall.aluminium_emissivity           = 0.3;        % Emissivity of plain aluminium.
mjolnir.tank.wall.aluminium_absorbitivity        = 0.4;        % Absorptivity of plain aluminium.



mjolnir.tank.liquid.heat_flux = 0;    % Thermal heat flux of the liquid    (dependant, computed in simulation). 
mjolnir.tank.vapor .heat_flux = 0;    % Thermal heat flux of the vapor     (dependant, computed in simulation). 
mjolnir.tank.wall  .heat_flux = 0;    % Thermal heat flux of the tank-wall (dependant, computed in simulation). 

mjolnir.tank.oxidizer_mass      = 24.5;
mjolnir.tank.pressure         = 0;    % Pressure (dependant, computed in simulation). 

% Tank geometry.    

if mjolnir.full_duration
    mjolnir.tank.diameter = 16e-2;    % Tank external diameter for full-duration burn (m).
    mjolnir.tank.length   = 1.83;     % Tank length for full-duration burn (m).
else
    mjolnir.tank.diameter = 10e-2;    % Tank external diameter for short-duration burn (m).
    mjolnir.tank.length   = 0.73;     % Tank length for short-duration burn (m).
end

mjolnir.tank.thickness = 3.5e-3;      % Tank thickness (m).
mjolnir.tank.volume    = mjolnir.tank.length*pi*(mjolnir.tank.diameter*0.5 - mjolnir.tank.thickness)^2; % Tank-volume (m^3).
mjolnir.tank.wall.mass          = mjolnir.tank.wall.rho_alu* ...
                                   mjolnir.tank.length* ...
                                 ((mjolnir.tank.diameter*0.5)^2 - (mjolnir.tank.diameter*0.5 - mjolnir.tank.thickness)^2)*pi;
mjolnir.tank.internal_area      = (mjolnir.tank.diameter-2*mjolnir.tank.thickness)*pi*mjolnir.tank.length;



mjolnir.tank.liquid.mass = mjolnir.tank.filling_ratio       * mjolnir.tank.volume *  mjolnir.N2O.temperature2density_liquid(mjolnir.tank.liquid.temperature);               % The liquid mass is the liquid volume in the tank times the liquid density (kg).
mjolnir.tank.vapor.mass = (1 - mjolnir.tank.filling_ratio)  * mjolnir.tank.volume *  mjolnir.N2O.temperature2density_vapor (mjolnir.tank.liquid.temperature);               % The liquid mass is the remaining volume in the tank times the vapor density (kg).

mjolnir.tank.oxidizer_mass        = mjolnir.tank.liquid.mass + mjolnir.tank.vapor.mass;                                         % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
mjolnir.tank.internal_energy      = mjolnir.tank.liquid.mass * mjolnir.N2O.temperature2specific_internal_energy_liquid(mjolnir.tank.liquid.temperature) ...
                                  + mjolnir.tank.vapor .mass * mjolnir.N2O.temperature2specific_internal_energy_vapor (mjolnir.tank.liquid.temperature);         % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).

mjolnir.tank.Cd = 0.85;                                    % Discharge coefficient.
mjolnir.tank.remaining_ox = 100;  
mjolnir.tank.model = "moody";  % Moody or dyer.


evalin("base", "temperature_initial_estimate = 285;")







%% Engine

mjolnir.engine                  = struct();
mjolnir.engine.position         = [0;0;-2];
mjolnir.engine.mass             = 24.504;     % Total engine mass (kg)
mjolnir.engine.active_burn_flag = 0;

c_star                          = readtable("Datasets/characteristic_velocity.csv");
mjolnir.engine.OF_set           = c_star.OF;                                % OF ratio range.
mjolnir.engine.c_star_set       = c_star.c_star;                        % Characteristic velocity c_star.


%% Injectors:
mjolnir.engine.injectors                  = struct();
mjolnir.engine.injectors.position         = [0;0;-1.7];
mjolnir.engine.injectors.number_of        = 80;                                                                            % Number of injectors holes.
mjolnir.engine.injectors.radius           = 1.2e-3 / 2;                                                                    % injectors radius (m).
mjolnir.engine.injectors.diameter         = 2*mjolnir.engine.injectors.radius;                                             % injectors diameter (m).
mjolnir.engine.injectors.total_area       = mjolnir.engine.injectors.number_of*pi*(mjolnir.engine.injectors.radius)^2;     % injectors total area for ALL the injectorss (m).
mjolnir.engine.injectors.plate_thickness  = 15e-3;                                                                         % injectors plate thickness (m).
mjolnir.engine.injectors.plate_radius     = 30e-3;                                                                         % plate radius(?) (m)
mjolnir.engine.injectors.mass             = 0.271;                                                                         % total injector mass (kg)
mjolnir.engine.injectors.e                = 0.013;                                                                         % (???) (m)




%% Fuel-grain properties.
mjolnir.engine.fuel_grain                 = struct();
mjolnir.engine.fuel_grain.position        = [0;0;-2.1];
mjolnir.engine.fuel_grain.mass            = 3.1;                             % (kg)
mjolnir.engine.fuel_grain.length          = 33e-2;                           % Fuel length (m).
mjolnir.engine.fuel_grain.density         = 900;                             % Density of fuel (kg/m^3).
mjolnir.engine.fuel_grain.radius          = 5e-2 / 2;                        % Fuel port diameter at ignition.

mjolnir.engine.fuel_grain.mass_margin     = 1.2;                              % Mass of fuel that is for margin (kg).
mjolnir.engine.fuel_grain.radius_margin   = sqrt(mjolnir.engine.fuel_grain.radius^2 ...
                                               - mjolnir.engine.fuel_grain.mass_margin / ...
                                                (mjolnir.engine.fuel_grain.density * ...
                                                 mjolnir.engine.fuel_grain.length * pi));

mjolnir.engine.fuel_grain.a               = 20e-5;                           % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
mjolnir.engine.fuel_grain.n               = 0.55;                            % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
mjolnir.engine.fuel_grain.dr_thdt         = 0.35e-2;                         % Constant approximation of regression rate (m/s).








%% Combustion-chamber

mjolnir.engine.combustion_chamber                       = struct();
mjolnir.engine.combustion_chamber.position              = [0.07;0.07;-1.9];
mjolnir.engine.combustion_chamber.pressure              = 2500000; % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
mjolnir.engine.combustion_chamber.temperature           = 285;     % Initial combustion chamber temperature.
mjolnir.engine.combustion_chamber.thickness             = 4e-3;                                                             % Combustion chamber thickness (m).
mjolnir.engine.combustion_chamber.external_diameter     = 15.2e-2;                                                  % Combustion chamber external diameter (m).
mjolnir.engine.combustion_chamber.internal_diameter     = mjolnir.engine.combustion_chamber.external_diameter ...
                                                       -2*mjolnir.engine.combustion_chamber.thickness;             % Combustion chamber interanl diameter (m)*.

mjolnir.engine.combustion_chamber.internal_radius       = mjolnir.engine.combustion_chamber.internal_diameter*0.5;
mjolnir.engine.combustion_chamber.external_radius       = mjolnir.engine.combustion_chamber.external_diameter*0.5;
mjolnir.engine.combustion_chamber.length                = 505.8e-3;                                                % Combustion chamber total casing (pre_cc + cc).
mjolnir.engine.combustion_chamber.temperature           = 3700;                                                    % Combustion temperature (K).
mjolnir.engine.combustion_chamber.combustion_efficiency = 0.9;
%mjolnir.engine.combustion_chamber.radius             = mjolnir.engine.fuel_grain.radius;                        % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).

mjolnir.engine.combustion_chamber.SinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
            Sin_amp = mjolnir.engine.combustion_chamber.SinusShapeAmplitude; 
            R = mjolnir.engine.fuel_grain.radius;
            dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);      % Combustion diameter taking into account sinus shape.
mjolnir.engine.combustion_chamber.InitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.




%% Pre-combustion-chamber properties.

mjolnir.engine.pre_combustion_chamber                  = struct();
mjolnir.engine.pre_combustion_chamber.position         = [0;0;-1.8];
mjolnir.engine.pre_combustion_chamber.length           = 75e-3;                                                   % Pre-combustion chamber length.
mjolnir.engine.pre_combustion_chamber.mass             = 0.5;                                                     % Pre-combustion chamber mass.

mjolnir.engine.combustion_chamber.temperature          = 280;                                                     % Combustion chamber temperature (K).



%% Nozzle properties.

mjolnir.engine.nozzle                  = struct();
mjolnir.engine.nozzle.position         = [0;0;-2.3];

mjolnir.engine.nozzle.throat           = struct();

mjolnir.engine.nozzle.throat.diameter  = 38.4e-3;
mjolnir.engine.nozzle.throat.position  = [0;0;-2.25];

Ae_At                              = 4.75;

mjolnir.engine.nozzle.exit             = struct();
mjolnir.engine.nozzle.exit.diameter    = sqrt(Ae_At) * mjolnir.engine.nozzle.throat.diameter;
mjolnir.engine.nozzle.exit.area        = pi * (mjolnir.engine.nozzle.exit.diameter)^2 / 4;         % Nozzle exit area (m^2).
mjolnir.engine.nozzle.exit.position    = [0;0;-2.35];

mjolnir.engine.nozzle.beta             = 80;                                                                                                                                       % Nozzle inlet angle (in °).
mjolnir.engine.nozzle.alpha            = 10;                            % Nozzle exit angle (in °).
mjolnir.engine.nozzle.length           = 154.55e-3;                         % Nozzle length (m).
mjolnir.engine.nozzle.throat.radius    = mjolnir.engine.nozzle.throat.diameter / 2;      





%% Combustion properties.
mjolnir.engine.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
mjolnir.engine.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).


mjolnir.engine.fuel_grain.radius_init  = mjolnir.engine.fuel_grain.radius;
                                            % The initial radius of the nozzle throat is half of the throat diameter.    








mjolnir.tank.Cd_inlet = 0.85;
mjolnir.tank.Cd_outlet = 0.95;



mjolnir.dry_mass = mjolnir.shute      .mass + ...
                   mjolnir.electronics.mass + ...
                   mjolnir.body_tube  .mass + ...
                   mjolnir.payload    .mass + ...
                   mjolnir.engine     .mass;


mjolnir.mass = mjolnir.dry_mass + mjolnir.tank.oxidizer_mass+ mjolnir.engine.fuel_grain.mass;