function rocket = trallgok()

    rocket                 = struct();
    rocket.name            = "Trallgök";
    rocket.dont_record     = ["", ""];
    rocket.models          = {@propulsion_model, @aerodynamics_model, @gravity_model, @inertial_navigation_model, @thrust_vectoring_model};
    rocket.state_variables = {};
    

    
    %% Enviroment & physical constants
    
    rocket.enviroment                      = struct();
    rocket.enviroment.position             = [0.25;0.25;-0.2];
    rocket.enviroment.g                    = 9.81;
    rocket.enviroment.temperature          = 282;
    
    rocket.enviroment.dont_record          = ["",""];
    rocket.enviroment.dont_record(end+1)   = "terrain";
    rocket.enviroment.terrain              = initiate_terrain();
    
    
    
    %% Rigid-body model
    rocket.position                      = [100;0;rocket.enviroment.terrain.z(100,0)]; rocket.state_variables{end+1} = "position";
    rocket.velocity                      = zeros(3,1);                                 rocket.state_variables{end+1} = "velocity";
    rocket.angular_momentum              = zeros(3,1);                                 rocket.state_variables{end+1} = "angular_momentum";
    rocket.attitude                      = eye(3);                                     rocket.state_variables{end+1} = "attitude";
    rocket.forces                        = struct();
    rocket.moments                       = struct();
    rocket.mass                          = 80; 
    rocket.center_of_mass                = [0;0;-0.8];
    rocket.rotation_rate                 = zeros(3,1);
    rocket.moment_of_inertia             = eye(3)*(80*4.^2)*0.2;
    rocket.moment_of_inertia(3,3)        = (80*4.^2)*0.2;
    
    
    rocket.forces.null                   = force ([0;0;0], [0;0;0]);
    rocket.moments.null                  = moment([0;0;0], [0;0;0]);
    
    
    
    
    %% Mesh:
    rocket.length_scale                             = 4;
    rocket.mesh                                     ="/Assets/rocket_mockup.stl";

    
    
    
    
    
    %% Aerodynamics-model
    rocket.aerodynamics                              = struct();
    
    rocket.aerodynamics                              = mesh2aerodynamics(rocket);
    rocket.aerodynamics.wind_velocity                = [0;0;0];
    rocket.aerodynamics.air_density                  = 1.2;
    rocket.aerodynamics.pressure_coefficient         = [0.2;0.2;0.1];
    rocket.aerodynamics.friction_coefficient         = ones(3,1)*0.01;
    rocket.aerodynamics.position                     = rocket.aerodynamics.center_of_pressure;
    
    

    
    %% Guidance
    rocket.guidance                            = struct();
    rocket.guidance.is_activate                = true; %% The below is not used unless true.
    rocket.guidance.update_desired_direction   = true;
    rocket.guidance.D_gain                     = 1e4;
    rocket.guidance.P_gain_offset              = 0.7e0;
    rocket.guidance.dieoff                     = 300;

    rocket.guidance.P_error                    = zeros(2,1); rocket.state_variables{end+1} = "guidance.P_error";
    rocket.guidance.D_error                    = zeros(2,1); rocket.state_variables{end+1} = "guidance.D_error";

    %    rocket.guidance.D_gain                     = 1e4;
%    rocket.guidance.P_gain_offset              = 0.5e1;
%    rocket.guidance.I_gain                     = 1e9;
%    rocket.guidance.I_sensitivity_region       = pi/50;% https://www.desmos.com/calculator/dmsb0mwpgu
%    rocket.guidance.I_dieoff                   = 300;
%rocket.guidance.D_gain                     = 1e7;
%rocket.guidance.P_gain_offset              = 9e-2;
%rocket.guidance.I_gain                     = 0e2;
%rocket.guidance.I_sensitivity_region       = pi/30;% 
% rocket.guidance.integrated_theta           = [0;0]; rocket.state_variables{end+1} = "guidance.integrated_theta";

    rocket.guidance.control_athority           = 25;
    rocket.guidance.desired_direction          = roty(45)*[0;0;1];

            x = 2:2:1000;
    rocket.guidance.trajectory                 = points2trajectory([x;0*x;500*sqrt(x)] + rocket.position.*[0;0;1]);
    rocket.guidance.aimpoint_angle             = 4;
    rocket.guidance.closest_point              = zeros(3,1);
    rocket.guidance.aim_point                  = zeros(3,1);
    rocket.guidance.closest_index              = 1;
    rocket.guidance.aim_index                  = 1;
    rocket.guidance.aim_finder_steps           = 1;
    rocket.guidance.closest_point_finder_steps = 1;





    rocket.engine = struct();
    rocket.engine.burn_time = 30;
    rocket.engine.position  = [0;0;-1.5];
    rocket.engine.attitude  = eye(3);
    rocket.engine.nozzle    = struct();
    rocket.engine.nozzle.position = [0;0;0];
    rocket.engine.nozzle.attitude = eye(3);
    




    
                       