function [historian, instance] = create_historian(instance,history_length)


% Run single timestep to let system equations assign all the dependant
% parameters we want to extract later.
test_state = rocket2state_vector(instance);
[~,instance] = system_equations(0, test_state, instance);

[historian, instance] = create_historian_internal(instance, history_length);


    function [historian, instance] = create_historian_internal(instance, history_length)
    
    historian = struct();
    parameter_names = fieldnames(instance);
    
        for index = 1:numel(parameter_names)
            parameter = parameter_names{index};
            if isequal(class(instance.(parameter)), 'double') && isequal(parameter, "null") == false
            historian.(parameter) = zeros(numel(instance.(parameter)), history_length);
            
            elseif isequal(class(instance.(parameter)), 'struct')
            if ~isfield(instance, 'dont_record')
            historian.(parameter) = create_historian_internal(instance.(parameter), history_length);
            elseif sum(matches(instance.dont_record, parameter)) == 0
            historian.(parameter) = create_historian_internal(instance.(parameter), history_length);
            end

            end
        end
    end
end