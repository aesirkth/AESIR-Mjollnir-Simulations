function [state_vector_derivative, rocket] = system_equations(t, state_vector, rocket)
% Ordinary differential equation governing the thrust, propulsion,
% tank-parameters and equations of motion of the rocket.




%% Updating loading-bar:
if randi(40) == 1
loading_bar = evalin("base", "loading_bar");
waitbar(t/evalin("base", "loading_bar_end_time"), loading_bar,evalin("base", "loading_message")+"    "+string(t)+"s  /  "+string(evalin("base", "loading_bar_end_time")) +"s");
end


rocket          = state_vector2rocket(rocket, state_vector); % Unpacking the state-vector
rocket.attitude = orthonormalize   (rocket.attitude);

state_vector_derivative = zeros(size(state_vector));


%% Applying the different models:


%[rocket, state_vector_derivative] = apply_propulsion_model           (rocket, state_vector_derivative); % <---- [Original Aesir propulsion model]
 rocket                           = apply_propulsion_model           (rocket, t);
 rocket                           = apply_aerodynamics_model         (rocket);                          % <---- [Added by Spiggen 2024]
 rocket                           = apply_gravity_model              (rocket);                          % <---- [Added by Spiggen 2024]
 %% No more additional forces, as inertial-navigation emulator needs force-information
if rocket.guidance.is_activate
 rocket                           = apply_inertial_navigation        (rocket);                          % <---- [Added by Spiggen 2024]
[rocket, state_vector_derivative] = apply_thrust_vectoring           (rocket, state_vector_derivative, t); % <---- [Added by Spiggen 2024]
end
%% Final step
[rocket, state_vector_derivative] = apply_rigid_body_model           (rocket, state_vector_derivative); % <---- [Added by Spiggen 2024]

end