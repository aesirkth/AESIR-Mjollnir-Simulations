function rocket       = state_vector2rocket(state_vector, rocket)


    

vector_index    = 1;

for state_variable_index = 1:numel(rocket.state_variables)
state_variable                                     = rocket.state_variables{state_variable_index};
variable_address                                   = num2cell(split(state_variable, "."));
if isequal(class(variable_address{1}), "cell"); variable_address = cellfun(@(entry) entry{1}, variable_address, "UniformOutput", false); end
variable                                           = getfield(rocket, variable_address{:});
num_el                                             = numel(variable);
rocket                                             = setfield(rocket, variable_address{:}, reshape(state_vector(vector_index:vector_index+num_el-1), size(variable) ) );
vector_index                                       = vector_index + num_el;
end

end