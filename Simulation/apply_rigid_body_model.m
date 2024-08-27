function [comp, state_vector_derivatives] = apply_rigid_body_model(comp, state_vector_derivatives)
% Computing the derivative of the state-vector based on the component
% parameters. The state-vector derivative and the state vector are then
% used by the ODE-solver to iterate the system.



% Forces & moments

force_sum  = cellsum(cellfun(@(force)  comp.forces .(force ).vec ,                                                                    fieldnames(comp.forces),  "UniformOutput",false));
moment_sum = cellsum(cellfun(@(moment) comp.moments.(moment).vec ,                                                                    fieldnames(comp.moments), "UniformOutput",false)) + ...
             cellsum(cellfun(@(force)  cross(comp.attitude*(comp.forces.(force).pos - comp.center_of_mass), comp.forces.(force).vec), fieldnames(comp.forces),  "UniformOutput",false));



% Stepping velocity

state_vector_derivatives(1:3) = comp.velocity;
state_vector_derivatives(4:6) = force_sum/comp.mass;


% Stepping angular shit
comp.rotation_rate = (comp.attitude*comp.moment_of_inertia*(comp.attitude'))\comp.angular_momentum; 

rotation_rate_tensor = [ 0                     -comp.rotation_rate(3)  comp.rotation_rate(2);
                        comp.rotation_rate(3)  0                      -comp.rotation_rate(1);
                       -comp.rotation_rate(2)  comp.rotation_rate(1)   0];

attitude_derivative = rotation_rate_tensor*comp.attitude;


state_vector_derivatives(7:9)   = moment_sum;
state_vector_derivatives(10:18) = reshape(attitude_derivative, 9,1);


end