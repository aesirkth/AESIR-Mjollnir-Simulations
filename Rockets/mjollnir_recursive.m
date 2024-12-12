function rocket = mjollnir_recursive()

    rocket                  = txt2struct('.\Assets\Mjollnir\Mjollnir.txt')
    rocket.name             = "Mjollnir";
    rocket.dont_record      = ["", ""];
    rocket.models           = {@equations_of_motion_recursive, ...
                               @simple_tank_model,   ...
                               @propulsion_model_recursive,    ...
                               @aerodynamics_model_recursive,  ...
                               @gravity_model_recursive,       ...
                               @equations_of_motion_recursive};
    
    
    rocket.derivative = containers.Map();
    
    
    
    %% Enviroment & physical constants
    
    rocket.enviroment                      = struct();
    rocket.enviroment.position             = [0;0;0];
    rocket.enviroment.g                    = 9.81;
    rocket.enviroment.temperature          = 282;
    rocket.enviroment.wind_velocity        = [0;0;0];
    
    rocket.enviroment.dont_record          = ["",""];
    rocket.enviroment.dont_record(end+1)   = "terrain";
    rocket.enviroment.terrain              = initiate_terrain();
    
    
    [rocket.enviroment.temperature_COESA, ~, rocket.enviroment.pressure, ~] = atmoscoesa(0);
    
    
    
    
    
    %% Rigid-body model
    rocket.rigid_body                        = body();
    rocket.rigid_body.center_of_mass         = [-1.165;0.439;1412.385]*1e-3 + [0;0;2];
    rocket.rigid_body.mass                   = 22.7;
    rocket.rigid_body.moment_of_inertia      = [ 6.166e10, -3.076e5,  -2.659e6;
                                                -3.076e5,   6.166e10, -2.382e6;
                                                -2.659e6,  -2.382e6,   2.067e8]*1e-9;
    
    
    
    
    rocket.forces                        = struct();
    rocket.moments                       = struct();
    rocket.attitude                      = eye(3);                                  rocket.derivative("attitude")         = zeros(3);
    rocket.angular_momentum              = zeros(3,1);                              rocket.derivative("angular_momentum") = zeros(3,1);
    rocket.rotation_rate                 = zeros(3,1);
    rocket.position                      = [0;0;rocket.enviroment.terrain.z(0,0)];  rocket.derivative("position")         = zeros(3,1);
    rocket.velocity                      = zeros(3,1);                              rocket.derivative("velocity")         = zeros(3,1);
    
    
    rocket.forces.null                   = force ([0;0;0], [0;0;0]);
    rocket.moments.null                  = moment([0;0;0], [0;0;0]);
    
    
    
    
    
    %% Aerodynamics-model
    
    rocket                                           = mesh2aerodynamics_recursive(rocket)
    
    %rocket.aerodynamics.center_of_pressure           = [0;0;4];
    
    
    
    rocket.engine.burn_time                     = 15;
    rocket.engine.thrust_force                  = 4e3;
    rocket.engine.fuel_grain                    = struct();
    rocket.engine.fuel_grain.mass               = 3;
    rocket.engine.fuel_grain.position           = [0;0;0.3];
    
    
    rocket.payload          = body();
    rocket.payload.position = [0;0;10];
    rocket.payload.mass     = 25;
    
    
    rocket.recovery_system            = body();
    rocket.recovery_system.shute      = struct();
    rocket.recovery_system.shute.mass = 0.75+0.791+0.275;
    rocket.recovery_system.position   = [0;0;3.2];
    
    rocket.tank = body();
    rocket.tank.position    = [0;0;2];
    rocket.tank.liquid      = struct();
    rocket.tank.liquid.mass = 27.0; rocket.derivative("tank.liquid.mass") = 0;
    