function derivative = make_derivative(rocket)




vector_index    = 1; derivative = containers.Map();

for state_variable_index = 1:numel(rocket.state_variables)
state_variable                                     = rocket.state_variables{state_variable_index};
variable_address                                   = num2cell(split(state_variable, "."));
if isequal(class(variable_address{1}), "cell"); variable_address = cellfun(@(entry) entry{1}, variable_address, "UniformOutput", false); end
variable                                           = getfield(rocket, variable_address{:});
num_el                                             = numel(variable);
derivative(state_variable)                         = zeros(numel(variable), 1);
vector_index                                       = vector_index + num_el;
end

end