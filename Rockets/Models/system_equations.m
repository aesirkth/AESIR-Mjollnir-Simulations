function [state_vector_derivative, rocket] = system_equations(t, state_vector, rocket)
% Ordinary differential equation governing the thrust, propulsion,
% tank-parameters and equations of motion of the rocket.




%% Updating loading-bar:
if randi(40) == 1
loading_bar = evalin("base", "loading_bar");
waitbar(t/evalin("base", "loading_bar_end_time"), loading_bar,evalin("base", "loading_message")+"    "+string(t)+"s  /  "+string(evalin("base", "loading_bar_end_time")) +"s");
end

% Setup
rocket.t              = t;
rocket                = state_vector2rocket (state_vector, rocket); % Unpacking the state-vector
rocket.attitude       = orthonormalize      (rocket.attitude);
rocket.derivative     = make_derivative     (rocket);
rocket                = equations_of_motion (rocket); % <---- [Added by Spiggen 2024]

%% Applying the rockets own models
for i = 1:numel(rocket.models)
apply_model = rocket.models{i};
rocket      = apply_model(rocket);
end

%% Final step
 rocket                           = equations_of_motion       (rocket); % <---- [Added by Spiggen 2024]

 state_vector_derivative = derivative2vector(rocket.derivative, rocket.state_variables);

end