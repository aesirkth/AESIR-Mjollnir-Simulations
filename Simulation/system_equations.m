function [state_vector_derivative, comp] = system_equations(~, state_vector, comp)

%% Un-packing and pre-allocating:
comp          = state_vector2comp(comp, state_vector); % Unpacking the state-vector
comp.attitude = orthonormalize(comp.attitude);         % Orthonormalizing the components basis after the ode-solver has messed with it

state_vector_derivative = zeros(size(state_vector));

[comp, state_vector_derivative] = apply_propulsion_model(comp, state_vector_derivative);
 comp                           = apply_aerodynamics    (comp);
[comp, state_vector_derivative] = apply_rigid_body_model(comp, state_vector_derivative);
the oe