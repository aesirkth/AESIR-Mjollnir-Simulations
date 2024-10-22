function rocket = mjollnir()

rocket = struct();
rocket.name = "Mjöllnir";
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
rocket.length_scale                             = 4;
rocket.mesh                                     = "Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl";
rocket.length_scale                             = 4;






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
rocket.guidance.is_activate                = false; %% The below is not used unless true.
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




rocket.tank   = sindri_tank  (rocket.N2O);
rocket.engine = sindri_engine();





rocket.dry_mass = rocket.shute      .mass + ...
                   rocket.electronics.mass + ...
                   rocket.body_tube  .mass + ...
                   rocket.payload    .mass + ...
                   rocket.engine     .mass;


rocket.mass = rocket.dry_mass + rocket.tank.oxidizer_mass+ rocket.engine.fuel_grain.mass;