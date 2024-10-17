function [historian, rocket] = create_historian(rocket,t)


% Run single timestep to let system equations assign all the dependant
% parameters we want to extract later.
test_state = rocket2state_vector(rocket, zeros(28,1));
[~,rocket] = system_equations(0, test_state, rocket);

[historian, rocket] = create_historian_internal(rocket, t);

    function [historian, rocket] = create_historian_internal(rocket, t)
    
    historian = struct();
    parameter_names = fieldnames(rocket);
    
        for index = 1:numel(parameter_names)
            parameter = parameter_names{index};
            if isequal(class(rocket.(parameter)), 'double') && isequal(parameter, "null") == false
            historian.(parameter) = zeros(numel(rocket.(parameter)), numel(t));
            
            elseif isequal(class(rocket.(parameter)), 'struct')
            if isfield(rocket, 'dont_record') == 0
            historian.(parameter) = create_historian_internal(rocket.(parameter), t);
            elseif sum(matches(rocket.dont_record, parameter)) == 0
            historian.(parameter) = create_historian_internal(rocket.(parameter), t);
            end

            end
        end
    end
end