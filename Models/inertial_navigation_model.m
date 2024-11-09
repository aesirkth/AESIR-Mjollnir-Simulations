function rocket = inertial_navigation_model(rocket)


    
% Forces & moments
    
force_sum  = cellsum(cellfun(@(force)  rocket.forces .(force ).vec , ...
                                fieldnames(rocket.forces),  "UniformOutput",false));
moment_sum = (cellsum(cellfun(@(moment) rocket.moments.(moment).vec , ...
                                fieldnames(rocket.moments), "UniformOutput",false)) + ...
                      cellsum(cellfun(@(force)  cross(rocket.forces.(force).pos - rocket.rigid_body.center_of_mass, rocket.forces.(force).vec),   ...
                                fieldnames(rocket.forces),  "UniformOutput",false)));

    
rocket.guidance.measured_acceleration         = force_sum/rocket.mass;               % In rockets basis
rocket.guidance.measured_angular_acceleration = rocket.rigid_body.moment_of_inertia\(rocket.attitude')*moment_sum; % In rockets basis
rocket.guidance.measured_velocity             = rocket.velocity;
rocket.guidance.measured_position             = rocket.position;


end