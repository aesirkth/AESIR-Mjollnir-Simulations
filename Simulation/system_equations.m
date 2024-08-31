function [state_vector_derivative, comp] = system_equations(t, state_vector, comp)
% Ordinary differential equation governing the thrust, propulsion,
% tank-parameters and equations of motion of the rocket.



%% Un-packing and pre-allocating:
%if comp.burning; waitbar(t/evalin("base", "t_max"), "Simuating:"+string(t)+"s  /  "+string(evalin("base", "t_max")) +"s");end
%% Updating loading-bar:
if randi(40) == 1
loading_bar = evalin("base", "loading_bar");
waitbar(t/evalin("base", "t_max"), loading_bar,evalin("base", "loading_message")+"    "+string(t)+"s  /  "+string(evalin("base", "t_max")) +"s");
end


comp                    = state_vector2comp(comp, state_vector); % Unpacking the state-vector
state_vector_derivative = zeros(size(state_vector));


%% Applying the different models:


[comp, state_vector_derivative] = apply_propulsion_model  (comp, state_vector_derivative); % <---- [Original Aesir propulsion model]
 comp                           = apply_aerodynamics_model(comp);                          % <---- [Added by Spiggen 2024]
 comp                           = apply_gravity_model     (comp);                          % <---- [Added by Spiggen 2024]
[comp, state_vector_derivative] = apply_rigid_body_model  (comp, state_vector_derivative); % <---- [Added by Spiggen 2024]

end