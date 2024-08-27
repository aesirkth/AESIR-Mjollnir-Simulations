function [historian, comp] = create_historian(comp,t)


% Run single timestep to let system equations assign all the dependant
% parameters we want to extract later.
test_state = comp2state_vector(comp, zeros(28,1));
[~,comp] = system_equations(0, test_state, comp);

[historian, comp] = create_historian_internal(comp, t);

    function [historian, comp] = create_historian_internal(comp, t)
    
    historian = struct();
    parameter_names = fieldnames(comp);
    
        for index = 1:numel(parameter_names)
            parameter = parameter_names{index};
            if isequal(class(comp.(parameter)), 'double')
            historian.(parameter) = zeros(numel(comp.(parameter)), numel(t));
            
            elseif isequal(class(comp.(parameter)), 'struct')
            if isfield(comp, 'dont_record') == 0
            historian.(parameter) = create_historian_internal(comp.(parameter), t);
            elseif sum(matches(comp.dont_record, parameter)) == 0
            historian.(parameter) = create_historian_internal(comp.(parameter), t);
            end

            end
        end
    end
end