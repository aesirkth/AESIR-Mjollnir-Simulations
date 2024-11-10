function rocket = mjollnir()

rocket                  = struct();
rocket.name             = "Mjöllnir";
rocket.dont_record      = ["", ""];
rocket.models           = {@equations_of_motion, ...
                           @propulsion_model,    ...
                           @aerodynamics_model,  ...
                           @gravity_model,       ...
                           @equations_of_motion};


rocket.derivative = containers.Map();



%% Enviroment & physical constants

rocket.enviroment                      = struct();
rocket.enviroment.position             = [0.25;0.25;-0.2];
rocket.enviroment.g                    = 9.81;
rocket.enviroment.temperature          = 282;

rocket.enviroment.dont_record          = ["",""];
rocket.enviroment.dont_record(end+1)   = "terrain";
rocket.enviroment.terrain              = initiate_terrain();


[rocket.enviroment.temperature_COESA, ~, rocket.enviroment.pressure, ~] = atmoscoesa(0);





%% Rigid-body model
rocket.rigid_body                        = struct();
rocket.rigid_body.center_of_mass         = [0;0;0.5];
rocket.rigid_body.moment_of_inertia      = eye(3)*(80*4.^2)*0.2;
rocket.rigid_body.moment_of_inertia(3,3) = (80*4.^2)*2;



rocket.forces                        = struct();
rocket.moments                       = struct();
rocket.attitude                      = eye(3);                                  rocket.derivative("attitude")         = zeros(3);
rocket.angular_momentum              = zeros(3,1);                              rocket.derivative("angular_momentum") = zeros(3,1);
rocket.rotation_rate                 = zeros(3,1);
rocket.position                      = [0;0;rocket.enviroment.terrain.z(0,0)];  rocket.derivative("position")         = zeros(3,1);
rocket.velocity                      = zeros(3,1);                              rocket.derivative("velocity")         = zeros(3,1);

rocket.mass                          = 80;

rocket.forces.null                   = force ([0;0;0], [0;0;0]);
rocket.moments.null                  = moment([0;0;0], [0;0;0]);




%% Mesh:
rocket.length_scale                             = 4;
rocket.mesh                                     = "Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl";






%% Aerodynamics-model
rocket.aerodynamics                              = struct();

rocket.aerodynamics                              = mesh2aerodynamics(rocket);
rocket.aerodynamics.wind_velocity                = [0;0;0];
rocket.aerodynamics.air_density                  = 1.2;
rocket.aerodynamics.pressure_coefficient         = [0.2;0.2;0.1];
rocket.aerodynamics.friction_coefficient         = ones(3,1)*0.01;
rocket.aerodynamics.position                     = rocket.aerodynamics.center_of_pressure;




rocket.engine                               = struct();
rocket.engine.burn_time                     = 20;
rocket.engine.thrust_force                  = 4e3;
rocket.engine.position                      = [0;0;-1.5];
rocket.engine.attitude                      = eye(3);
rocket.engine.nozzle                        = struct();
rocket.engine.nozzle.position               = [0;0;0];
rocket.engine.nozzle.attitude               = eye(3);