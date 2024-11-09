function rocket = equations_of_motion(rocket)
% rocketuting the rocket.derivative of the state-vector based on the rocketonent
% parameters. The state-vector rocket.derivative and the state vector are then
% used by the ODE-solver to iterate the system.


% Forces & moments

force_sum  = cellsum(cellfun(@(force)  rocket.forces .(force ).vec ,                                                                          fieldnames(rocket.forces),  "UniformOutput",false));
moment_sum = cellsum(cellfun(@(moment) rocket.moments.(moment).vec ,                                                                          fieldnames(rocket.moments), "UniformOutput",false)) + ...
             cellsum(cellfun(@(force)  cross(rocket.attitude*(rocket.forces.(force).pos - rocket.center_of_mass), rocket.forces.(force).vec), fieldnames(rocket.forces),  "UniformOutput",false));



% Stepping velocity


rocket.derivative("position") = rocket.velocity;
rocket.derivative("velocity") = force_sum/rocket.mass;


% Stepping angular shit
rocket.rotation_rate = (rocket.attitude*rocket.moment_of_inertia*(rocket.attitude'))\rocket.angular_momentum; 

rotation_rate_tensor = [  0                       -rocket.rotation_rate(3)        rocket.rotation_rate(2);
                          rocket.rotation_rate(3)  0                             -rocket.rotation_rate(1);
                         -rocket.rotation_rate(2)  rocket.rotation_rate(1)        0               ];

attitude_rocket.derivative = rotation_rate_tensor*rocket.attitude;


rocket.derivative("angular_momentum")   = moment_sum;
rocket.derivative("attitude")           = attitude_rocket.derivative;

end