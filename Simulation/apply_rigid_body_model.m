function [comp, state_vector_derivatives] = apply_rigid_body_model(comp, state_vector_derivatives)
% Computing the derivative of the state-vector based on the component
% parameters. The state-vector derivative and the state vector are then
% used by the ODE-solver to iterate the system.

 % Unpack fields of rigid_body-struct into workspace
variables = fieldnames(comp.rigid_body);
for i = 1:numel(variables); eval(variables{i}+"= comp.rigid_body."+variables{i}+";"); end



% Forces & moments

force_sum  = cellsum(cellfun(@(force)  forces .(force ).vec ,                                                     fieldnames(forces),  "UniformOutput",false));
moment_sum = cellsum(cellfun(@(moment) moments.(moment).vec ,                                                     fieldnames(moments), "UniformOutput",false)) + ...
             cellsum(cellfun(@(force)  cross(attitude*(forces.(force).pos - center_of_mass), forces.(force).vec), fieldnames(forces),  "UniformOutput",false));



% Stepping velocity

state_vector_derivatives(1:3) = velocity;
state_vector_derivatives(4:6) = force_sum/mass;


% Stepping angular shit
rotation_rate = (attitude*moment_of_inertia*(attitude'))\angular_momentum; 

rotation_rate_tensor = [ 0                     -rotation_rate(3)  rotation_rate(2);
                        rotation_rate(3)  0                      -rotation_rate(1);
                       -rotation_rate(2)  rotation_rate(1)   0];

attitude_derivative = rotation_rate_tensor*attitude;


state_vector_derivatives(7:9)   = moment_sum;
state_vector_derivatives(10:18) = reshape(attitude_derivative, 9,1);


end