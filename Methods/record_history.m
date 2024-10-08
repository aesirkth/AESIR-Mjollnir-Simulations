function historian = record_history(comp, state, t, history_index, historian)

[~,comp] = system_equations(t, state, comp);


historian = assign_parameters(comp, historian, history_index);

end





function historian = assign_parameters(comp, historian, history_index)
parameter_names = fieldnames(historian);

for parameter_index = 1:numel(parameter_names)
parameter = parameter_names{parameter_index};

if isequal(class(comp.(parameter)), 'double')

historian.(parameter)(:,history_index) = reshape(comp.(parameter), ...
                                         numel  (comp.(parameter)), ...
                                         1);

elseif isequal(class(comp.(parameter)), 'struct')
if isfield(comp, 'dont_record') == 0
historian.(parameter) = assign_parameters(comp.(parameter), historian.(parameter), history_index);
elseif sum(matches(comp.dont_record, parameter)) == 0
historian.(parameter) = assign_parameters(comp.(parameter), historian.(parameter), history_index);
else
disp(parameter)
end
end

end


end


   










