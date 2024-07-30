function [state_vector_derivative, comp] = system_equations(t, state_vector, comp)
% Ordinary differential equation governing the thrust, propulsion,
% tank-parameters and equations of motion of the rocket.

disp("T+"+string(t)+"s")

%% Un-packing and pre-allocating:
comp          = state_vector2comp(comp, state_vector); % Unpacking the state-vector
comp.attitude = orthonormalize(comp.attitude);         % Orthonormalizing the components basis after the ode-solver has messed with it

state_vector_derivative = zeros(size(state_vector));

%% Applying the different models:
[comp, state_vector_derivative] = apply_propulsion_model  (comp, state_vector_derivative); % <---- [Original Aesir propulsion model]
 comp                           = apply_aerodynamics_model(comp);                          % <---- [Added by Spiggen 2024]
[comp, state_vector_derivative] = apply_rigid_body_model  (comp, state_vector_derivative); % <---- [Added by Spiggen 2024]

end