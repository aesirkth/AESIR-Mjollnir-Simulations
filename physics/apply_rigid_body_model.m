function [comp, state_vector_derivatives] = apply_rigid_body_model(comp, state_vector_derivatives)
% Computing the derivative of the state-vector based on the component
% parameters. The state-vector derivative and the state vector are then
% used by the ODE-solver to iterate the system.


% Forces & moments

force_sum  = cellsum(cellfun(@(force)  force.vec ,                                                          values(comp.forces , "cell"), "UniformOutput",false));
moment_sum = cellsum(cellfun(@(moment) moment.vec ,                                                         values(comp.moments, "cell"), "UniformOutput",false)) + ...
             cellsum(cellfun(@(force)  cross(comp.attitude*(force.pos - comp.center_of_mass), force.vec),   values(comp.forces,  "cell"), "UniformOutput",false));



% Stepping velocity

state_vector_derivatives(1:3) = comp.velocity;
state_vector_derivatives(4:6) = force_sum/comp.mass;


% Stepping angular shit
comp.rotation_rate = (comp.attitude*comp.moment_of_inertia*(comp.attitude'))\comp.angular_momentum; 


state_vector_derivatives(7:9)   = moment_sum;
% state_vector_derivatives(10:21) = attitude_quaternion_derivatives(rot_vector2rot_quaternion(rotation_rate), ...
%                                                                   attitude2attitude_quaternions(comp.attitude));
state_vector_derivatives(10:18) = reshape(attitude_derivative(comp), 9,1);
end