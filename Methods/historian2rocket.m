function rocket = historian2rocket(rocket, historian, history_index)

parameter_names = fieldnames(historian);

    for index = 1:numel(parameter_names)
    parameter = parameter_names{index};
    if isequal(class(rocket.(parameter)), 'double')
    rocket.(parameter) = reshape(historian.(parameter)(:,history_index), ...
                               size(rocket.(parameter)));
    
    elseif isequal(class(rocket.(parameter)), 'struct')
    if isfield(rocket, 'dont_record') == 0
    rocket.(parameter) = historian2rocket(rocket.(parameter), historian.(parameter), history_index);
    elseif sum(matches(rocket.dont_record, parameter)) == 0
    rocket.(parameter) = historian2rocket(rocket.(parameter), historian.(parameter), history_index);
    end
    end

    end

end
