function comp = historian2comp(comp, historian, history_index)

parameter_names = fieldnames(historian);

    for index = 1:numel(parameter_names)
    parameter = parameter_names{index};
    if isequal(class(comp.(parameter)), 'double')
    comp.(parameter) = reshape(historian.(parameter)(:,history_index), ...
                               size(comp.(parameter)));
    
    elseif isequal(class(comp.(parameter)), 'struct')
    if isfield(comp, 'dont_record') == 0
    comp.(parameter) = historian2comp(comp.(parameter), historian.(parameter), history_index);
    elseif sum(matches(comp.dont_record, parameter)) == 0
    comp.(parameter) = historian2comp(comp.(parameter), historian.(parameter), history_index);
    end
    end

    end

end
