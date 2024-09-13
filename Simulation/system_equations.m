function [state_vector_derivative, comp] = system_equations(t, state_vector, comp)
% Ordinary differential equation governing the thrust, propulsion,
% tank-parameters and equations of motion of the rocket.




%% Updating loading-bar:
if randi(40) == 1
loading_bar = evalin("base", "loading_bar");
waitbar(t/evalin("base", "loading_bar_end_time"), loading_bar,evalin("base", "loading_message")+"    "+string(t)+"s  /  "+string(evalin("base", "loading_bar_end_time")) +"s");
end


comp          = state_vector2comp(comp, state_vector); % Unpacking the state-vector
comp.attitude = orthonormalize   (comp.attitude);

state_vector_derivative = zeros(size(state_vector));


%% Applying the different models:


[comp, state_vector_derivative] = apply_propulsion_model           (comp, state_vector_derivative); % <---- [Original Aesir propulsion model]
% comp                           = apply_simplified_propulsion_model(comp, t);
 comp                           = apply_aerodynamics_model         (comp);                          % <---- [Added by Spiggen 2024]
 comp                           = apply_gravity_model              (comp);                          % <---- [Added by Spiggen 2024]
 %% No more additional forces, as inertial-navigation emulator needs force-information
 %comp                           = apply_inertial_navigation        (comp);                          % <---- [Added by Spiggen 2024]
%[comp, state_vector_derivative] = apply_thrust_vectoring           (comp, state_vector_derivative, t); % <---- [Added by Spiggen 2024]
%% Final step
[comp, state_vector_derivative] = apply_rigid_body_model           (comp, state_vector_derivative); % <---- [Added by Spiggen 2024]

end