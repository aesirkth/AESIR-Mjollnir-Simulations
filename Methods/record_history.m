function historian = record_history(rocket, state, t, history_index, historian)

[~,rocket] = system_equations(t, state, rocket);


historian = assign_parameters(rocket, historian, history_index);

end





function historian = assign_parameters(rocket, historian, history_index)
parameter_names = fieldnames(historian);

for parameter_index = 1:numel(parameter_names)
parameter = parameter_names{parameter_index};

if isequal(class(rocket.(parameter)), 'double')

historian.(parameter)(:,history_index) = reshape(rocket.(parameter), ...
                                         numel  (rocket.(parameter)), ...
                                         1);

elseif isequal(class(rocket.(parameter)), 'struct')

if     isfield(rocket, 'dont_record') == 0;                historian.(parameter) = assign_parameters(rocket.(parameter), historian.(parameter), history_index);
elseif sum(matches(rocket.dont_record, parameter)) == 0;   historian.(parameter) = assign_parameters(rocket.(parameter), historian.(parameter), history_index);

else
disp(parameter)
end

end

end


end


   










