function historian = record_history(rocket, historian, history_index)




parameter_names = fieldnames(historian);

for parameter_index = 1:numel(parameter_names)
parameter = parameter_names{parameter_index};

if isequal(class(rocket.(parameter)), 'double')

historian.(parameter)(:,history_index) = reshape(rocket.(parameter), ...
                                         numel  (rocket.(parameter)), ...
                                         1);

elseif isequal(class(rocket.(parameter)), 'struct')

if     isfield(rocket, 'dont_record') == 0;                historian.(parameter) = record_history(rocket.(parameter), historian.(parameter), history_index);
elseif sum(matches(rocket.dont_record, parameter)) == 0;   historian.(parameter) = record_history(rocket.(parameter), historian.(parameter), history_index);

else
disp(parameter)
end

end

end



   










