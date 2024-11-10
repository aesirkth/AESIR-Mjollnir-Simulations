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


%% Applying the rockets own models
for i = 1:numel(rocket.models)
apply_model = rocket.models{i};
rocket      = apply_model(rocket);
end

 state_vector_derivative = derivative2vector(rocket.derivative);

end