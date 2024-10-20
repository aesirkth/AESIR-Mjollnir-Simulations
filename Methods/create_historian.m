function [historian, instance] = create_historian(instance,t)


% Run single timestep to let system equations assign all the dependant
% parameters we want to extract later.
test_state = instance2state_vector(instance, zeros(28,1));
[~,instance] = system_equations(0, test_state, instance);

[historian, instance] = create_historian_internal(instance, t);
historian.t = t;

    function [historian, instance] = create_historian_internal(instance, t)
    
    historian = struct();
    parameter_names = fieldnames(instance);
    
        for index = 1:numel(parameter_names)
            parameter = parameter_names{index};
            if isequal(class(instance.(parameter)), 'double') && isequal(parameter, "null") == false
            historian.(parameter) = zeros(numel(instance.(parameter)), numel(t));
            
            elseif isequal(class(instance.(parameter)), 'struct')
            if isfield(instance, 'dont_record') == 0
            historian.(parameter) = create_historian_internal(instance.(parameter), t);
            elseif sum(matches(instance.dont_record, parameter)) == 0
            historian.(parameter) = create_historian_internal(instance.(parameter), t);
            end

            end
        end
    end
end