function rocket = tralljok()

    rocket = struct();
    rocket.name = "Tralljök";
    rocket.dont_record = ["", ""];
    
    rocket.static        = false; % True if simulation should be for a static fire, otherwise it is done for flight.
    rocket.full_duration = true;  % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
    
    load("Models/Methods/N2O.mat", "N2O")
    
    rocket.N2O                      = N2O;
    
    rocket.dont_record(end+1)       = "N2O";
    
    
    %% Enviroment & physical constants
    
    rocket.enviroment                      = struct();
    rocket.enviroment.position             = [0.25;0.25;-0.2];
    rocket.enviroment.g                    = 9.81;
    rocket.enviroment.temperature          = 282;
    
    rocket.enviroment.dont_record          = ["",""];
    rocket.enviroment.dont_record(end+1)   = "terrain";
    rocket.enviroment.terrain              = initiate_terrain();
    
    rocket.enviroment.R                    = 8.314;                       % Universal gas constant (J/K/mol).
    
    rocket.enviroment.stephan_cst          = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
    rocket.enviroment.eber_parameter       = 0.89;                        % Eber parameter for vertex angle between 20-50 degrees.
    rocket.enviroment.Molecular_weight_air = 28.9647e-3;                  % Molecular weight of air (kg/mol).
    rocket.enviroment.r_air                = rocket.enviroment.R / rocket.enviroment.Molecular_weight_air;
    
    
    
    [rocket.enviroment.temperature_COESA, ~, rocket.enviroment.pressure, ~] = atmoscoesa(0);
     rocket.enviroment.dT_ext = rocket.enviroment.temperature_COESA - rocket.enviroment.temperature;  % Difference between the COESA temperature and the actual temperature (K).
    
    
    
    
    
    %% Rigid-body model
    rocket.forces                        = struct();
    rocket.moments                       = struct();
    rocket.mass                          = 0;                       % dependant
    rocket.attitude                      = eye(3);
    rocket.center_of_mass                = [0;0;0.5];
    rocket.angular_momentum              = zeros(3,1);
    rocket.rotation_rate                 = zeros(3,1);
    rocket.position                      = [0;0;rocket.enviroment.terrain.z(0,0)];
    rocket.velocity                      = zeros(3,1);
    rocket.moment_of_inertia             = eye(3)*(80*4.^2)*0.2;
    rocket.moment_of_inertia(3,3)        = (80*4.^2)*2;
    
    
    rocket.forces.null                   = force ([0;0;0], [0;0;0]);
    rocket.moments.null                  = moment([0;0;0], [0;0;0]);
    
    
    
    
    %% Mesh:
    %rocket.mesh                                     = stlread("./assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
    rocket.mesh                                     = stlread("./Assets/rocket_mockup.stl");
    rocket.dont_record(1)                           = "mesh";
    rocket.mesh.vertices                            = 4*rocket.mesh.vertices/max(rocket.mesh.vertices, [], "all");
    rocket.mesh.vertices                            = rocket.mesh.vertices -   ...
                                                        0.5*[max(rocket.mesh.vertices(:,1))+min(rocket.mesh.vertices(:,1));
                                                             max(rocket.mesh.vertices(:,2))+min(rocket.mesh.vertices(:,2));
                                                             max(rocket.mesh.vertices(:,3))+min(rocket.mesh.vertices(:,3))]';
    rocket.mesh.vertices(:,3) = rocket.mesh.vertices(:,3)+0.4;
    
    
    
    
    
    %% Aerodynamics-model
    rocket.aerodynamics                              = struct();
    
    rocket.aerodynamics                              = mesh2aerodynamics(rocket);
    rocket.aerodynamics.wind_velocity                = [0;0;0];
    rocket.aerodynamics.air_density                  = 1.2;
    rocket.aerodynamics.pressure_coefficient         = [0.2;0.2;0.1];
    rocket.aerodynamics.friction_coefficient         = ones(3,1)*0.01;
    rocket.aerodynamics.position                     = rocket.aerodynamics.center_of_pressure;
    
    
    
    %% Shute
    rocket.shute                               = struct();
    rocket.shute.position                      = [0;0;2];
    rocket.shute.mass                          = 10;
    
    
    %% Payload
    rocket.payload                             = struct();
    rocket.payload.position                    = [0;0;1.7];
    rocket.payload.mass                        = 2;
    
    
    %% Electronics
    rocket.electronics                         = struct();
    rocket.electronics.position                = [0;0;1.5];
    rocket.electronics.mass                    = 2.3;
    
    
    %% Guidance
    rocket.guidance                            = struct();
    rocket.guidance.is_activate                = true; %% The below is not used unless true.
    rocket.guidance.update_desired_direction   = true;
    rocket.guidance.D_gain                     = 1e4;
    rocket.guidance.I_gain                     = 1e3;
    
    rocket.guidance.control_athority           = 45;
    rocket.guidance.desired_direction          = roty(45)*[0;0;1];
    rocket.guidance.integrated_theta           = [0;0];
            x = 2:2:1000;
    rocket.guidance.trajectory                 = points2trajectory([x;0*x;500*sqrt(x)] + rocket.position);
    rocket.guidance.aimpoint_angle             = 5;
    rocket.guidance.closest_point              = zeros(3,1);
    rocket.guidance.aim_point                  = zeros(3,1);
    rocket.guidance.closest_index              = 1;
    rocket.guidance.aim_index                  = 1;
    rocket.guidance.aim_finder_steps           = 1;
    rocket.guidance.closest_point_finder_steps = 1;
    
    %% Body-tube
    rocket.body_tube                           = struct();
    rocket.body_tube.position                  = [0.07;0.07;1.4];
    rocket.body_tube.mass                      = 7;
    
    
    %% Kasrtullen
    rocket.kastrullen                          = struct();
    rocket.kastrullen.position                 = [0;0;-1.5];
    rocket.kastrullen.length                   = 35e-2;      % Length of Kastrullen.
    
    
    
    %% Tank
    
    rocket.tank                         = struct();
    rocket.tank.position                = [0;0;-0.5];
    rocket.tank.filling_ratio           = 0.95;      % Tank filling ratio.
    
    rocket.tank.vapor                   = struct();
    rocket.tank.vapor.position          = [0;0;0.5];
    
    % Liquid
    rocket.tank.liquid                  = struct();
    rocket.tank.liquid.position         = [0;0;-0.8];
    rocket.tank.liquid.temperature      = 285;  % Initial tank temperature (K).
    
    % Tank-wall
    rocket.tank.wall                    = struct();
    rocket.tank.wall.position           = [0.07;0.07;0.4];
    rocket.tank.wall.  temperature      = 285;  % Assume that initial tank wall temperature is equal to the initial internal temperature (K).
    
    %rocket.tank.exterior_wall = struct();
    
    
    rocket.tank.wall.aluminium_thermal_conductivity = 236;        % Wm-1K-1 at 0 degree celcius.
    rocket.tank.wall.rho_alu                        = 2700;       % Density aluminium (kg/m^3).
    rocket.tank.wall.alu_thermal_capacity           = 897;        % J/K/kg
    rocket.tank.wall.aluminium_emissivity_painted   = 0.8;        % Emissivity of painted tank.
    rocket.tank.wall.aluminium_emissivity           = 0.3;        % Emissivity of plain aluminium.
    rocket.tank.wall.aluminium_absorbitivity        = 0.4;        % Absorptivity of plain aluminium.
    
    
    
    rocket.tank.liquid.heat_flux = 0;    % Thermal heat flux of the liquid    (dependant, computed in simulation). 
    rocket.tank.vapor .heat_flux = 0;    % Thermal heat flux of the vapor     (dependant, computed in simulation). 
    rocket.tank.wall  .heat_flux = 0;    % Thermal heat flux of the tank-wall (dependant, computed in simulation). 
    
    rocket.tank.oxidizer_mass      = 24.5;
    rocket.tank.pressure         = 0;    % Pressure (dependant, computed in simulation). 
    
    % Tank geometry.    
    
    if rocket.full_duration
        rocket.tank.diameter = 16e-2;    % Tank external diameter for full-duration burn (m).
        rocket.tank.length   = 1.83;     % Tank length for full-duration burn (m).
    else
        rocket.tank.diameter = 10e-2;    % Tank external diameter for short-duration burn (m).
        rocket.tank.length   = 0.73;     % Tank length for short-duration burn (m).
    end
    
    rocket.tank.thickness = 3.5e-3;      % Tank thickness (m).
    rocket.tank.volume    = rocket.tank.length*pi*(rocket.tank.diameter*0.5 - rocket.tank.thickness)^2; % Tank-volume (m^3).
    rocket.tank.wall.mass          = rocket.tank.wall.rho_alu* ...
                                       rocket.tank.length* ...
                                     ((rocket.tank.diameter*0.5)^2 - (rocket.tank.diameter*0.5 - rocket.tank.thickness)^2)*pi;
    rocket.tank.internal_area      = (rocket.tank.diameter-2*rocket.tank.thickness)*pi*rocket.tank.length;
    
    
    
    rocket.tank.liquid.mass = rocket.tank.filling_ratio       * rocket.tank.volume *  rocket.N2O.temperature2density_liquid(rocket.tank.liquid.temperature);               % The liquid mass is the liquid volume in the tank times the liquid density (kg).
    rocket.tank.vapor.mass = (1 - rocket.tank.filling_ratio)  * rocket.tank.volume *  rocket.N2O.temperature2density_vapor (rocket.tank.liquid.temperature);               % The liquid mass is the remaining volume in the tank times the vapor density (kg).
    
    rocket.tank.oxidizer_mass        = rocket.tank.liquid.mass + rocket.tank.vapor.mass;                                         % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
    rocket.tank.internal_energy      = rocket.tank.liquid.mass * rocket.N2O.temperature2specific_internal_energy_liquid(rocket.tank.liquid.temperature) ...
                                      + rocket.tank.vapor .mass * rocket.N2O.temperature2specific_internal_energy_vapor (rocket.tank.liquid.temperature);         % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).
    
    rocket.tank.Cd = 0.85;                                    % Discharge coefficient.
    rocket.tank.remaining_ox = 100;  
    rocket.tank.model = "moody";  % Moody or dyer.
    
    
    evalin("base", "temperature_initial_estimate = 285;")
    
    
    
    
    
    
    
    %% Engine
    
    rocket.engine                  = struct();
    rocket.engine.position         = [0;0;-2];
    rocket.engine.mass             = 24.504;     % Total engine mass (kg)
    rocket.engine.active_burn_flag = 0;
    
    c_star                          = readtable("Datasets/characteristic_velocity.csv");
    rocket.engine.OF_set           = c_star.OF;                                % OF ratio range.
    rocket.engine.c_star_set       = c_star.c_star;                        % Characteristic velocity c_star.
    
    
    %% Injectors:
    rocket.engine.injectors                  = struct();
    rocket.engine.injectors.position         = [0;0;-1.7];
    rocket.engine.injectors.number_of        = 80;                                                                            % Number of injectors holes.
    rocket.engine.injectors.radius           = 1.2e-3 / 2;                                                                    % injectors radius (m).
    rocket.engine.injectors.diameter         = 2*rocket.engine.injectors.radius;                                             % injectors diameter (m).
    rocket.engine.injectors.total_area       = rocket.engine.injectors.number_of*pi*(rocket.engine.injectors.radius)^2;     % injectors total area for ALL the injectorss (m).
    rocket.engine.injectors.plate_thickness  = 15e-3;                                                                         % injectors plate thickness (m).
    rocket.engine.injectors.plate_radius     = 30e-3;                                                                         % plate radius(?) (m)
    rocket.engine.injectors.mass             = 0.271;                                                                         % total injector mass (kg)
    rocket.engine.injectors.e                = 0.013;                                                                         % (???) (m)
    
    
    
    
    %% Fuel-grain properties.
    rocket.engine.fuel_grain                 = struct();
    rocket.engine.fuel_grain.position        = [0;0;-2.1];
    rocket.engine.fuel_grain.mass            = 3.1;                             % (kg)
    rocket.engine.fuel_grain.length          = 33e-2;                           % Fuel length (m).
    rocket.engine.fuel_grain.density         = 900;                             % Density of fuel (kg/m^3).
    rocket.engine.fuel_grain.radius          = 5e-2 / 2;                        % Fuel port diameter at ignition.
    
    rocket.engine.fuel_grain.mass_margin     = 1.2;                              % Mass of fuel that is for margin (kg).
    rocket.engine.fuel_grain.radius_margin   = sqrt(rocket.engine.fuel_grain.radius^2 ...
                                                   - rocket.engine.fuel_grain.mass_margin / ...
                                                    (rocket.engine.fuel_grain.density * ...
                                                     rocket.engine.fuel_grain.length * pi));
    
    rocket.engine.fuel_grain.a               = 20e-5;                           % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
    rocket.engine.fuel_grain.n               = 0.55;                            % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
    rocket.engine.fuel_grain.dr_thdt         = 0.35e-2;                         % Constant approximation of regression rate (m/s).
    
    
    
    
    
    
    
    
    %% Combustion-chamber
    
    rocket.engine.combustion_chamber                       = struct();
    rocket.engine.combustion_chamber.position              = [0.07;0.07;-1.9];
    rocket.engine.combustion_chamber.pressure              = 2500000; % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
    rocket.engine.combustion_chamber.temperature           = 285;     % Initial combustion chamber temperature.
    rocket.engine.combustion_chamber.thickness             = 4e-3;                                                             % Combustion chamber thickness (m).
    rocket.engine.combustion_chamber.external_diameter     = 15.2e-2;                                                  % Combustion chamber external diameter (m).
    rocket.engine.combustion_chamber.internal_diameter     = rocket.engine.combustion_chamber.external_diameter ...
                                                           -2*rocket.engine.combustion_chamber.thickness;             % Combustion chamber interanl diameter (m)*.
    
    rocket.engine.combustion_chamber.internal_radius       = rocket.engine.combustion_chamber.internal_diameter*0.5;
    rocket.engine.combustion_chamber.external_radius       = rocket.engine.combustion_chamber.external_diameter*0.5;
    rocket.engine.combustion_chamber.length                = 505.8e-3;                                                % Combustion chamber total casing (pre_cc + cc).
    rocket.engine.combustion_chamber.temperature           = 3700;                                                    % Combustion temperature (K).
    rocket.engine.combustion_chamber.combustion_efficiency = 0.9;
    %rocket.engine.combustion_chamber.radius             = rocket.engine.fuel_grain.radius;                        % The initial radius of the combustion chamber is equal to the initial radius of the fuel port (m).
    
    rocket.engine.combustion_chamber.SinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
                Sin_amp = rocket.engine.combustion_chamber.SinusShapeAmplitude; 
                R = rocket.engine.fuel_grain.radius;
                dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);      % Combustion diameter taking into account sinus shape.
    rocket.engine.combustion_chamber.InitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.
    
    
    
    
    %% Pre-combustion-chamber properties.
    
    rocket.engine.pre_combustion_chamber                  = struct();
    rocket.engine.pre_combustion_chamber.position         = [0;0;-1.8];
    rocket.engine.pre_combustion_chamber.length           = 75e-3;                                                   % Pre-combustion chamber length.
    rocket.engine.pre_combustion_chamber.mass             = 0.5;                                                     % Pre-combustion chamber mass.
    
    rocket.engine.combustion_chamber.temperature          = 280;                                                     % Combustion chamber temperature (K).
    
    
    
    %% Nozzle properties.
    
    rocket.engine.nozzle                  = struct();
    rocket.engine.nozzle.position         = [0;0;-2.3];
    
    rocket.engine.nozzle.throat           = struct();
    
    rocket.engine.nozzle.throat.diameter  = 38.4e-3;
    rocket.engine.nozzle.throat.position  = [0;0;-2.25];
    
    Ae_At                              = 4.75;
    
    rocket.engine.nozzle.exit             = struct();
    rocket.engine.nozzle.exit.diameter    = sqrt(Ae_At) * rocket.engine.nozzle.throat.diameter;
    rocket.engine.nozzle.exit.area        = pi * (rocket.engine.nozzle.exit.diameter)^2 / 4;         % Nozzle exit area (m^2).
    rocket.engine.nozzle.exit.position    = [0;0;-2.35];
    
    rocket.engine.nozzle.beta             = 80;                                                                                                                                       % Nozzle inlet angle (in °).
    rocket.engine.nozzle.alpha            = 10;                            % Nozzle exit angle (in °).
    rocket.engine.nozzle.length           = 154.55e-3;                         % Nozzle length (m).
    rocket.engine.nozzle.throat.radius    = rocket.engine.nozzle.throat.diameter / 2;      
    
    
    
    
    
    %% Combustion properties.
    rocket.engine.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
    rocket.engine.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).
    
    
    rocket.engine.fuel_grain.radius_init  = rocket.engine.fuel_grain.radius;
                                                % The initial radius of the nozzle throat is half of the throat diameter.    
    
    
    
    
    
    
    
    
    rocket.tank.Cd_inlet = 0.85;
    rocket.tank.Cd_outlet = 0.95;
    
    
    
    rocket.dry_mass = rocket.shute      .mass + ...
                       rocket.electronics.mass + ...
                       rocket.body_tube  .mass + ...
                       rocket.payload    .mass + ...
                       rocket.engine     .mass;
    
    
    rocket.mass = rocket.dry_mass + rocket.tank.oxidizer_mass+ rocket.engine.fuel_grain.mass;