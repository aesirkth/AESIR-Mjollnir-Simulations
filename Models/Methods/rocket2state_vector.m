function state_vector = rocket2state_vector(rocket)




vector_index    = 1; state_vector = zeros(numel(rocket.state_variables)*6, 1);

for state_variable_index = 1:numel(rocket.state_variables)
state_variable                                     = rocket.state_variables{state_variable_index};
variable_address                                   = num2cell(split(state_variable, ".")); 
if isequal(class(variable_address{1}), "cell"); variable_address = cellfun(@(entry) entry{1}, variable_address, "UniformOutput", false); end
variable                                           = getfield(rocket, variable_address{:});
num_el                                             = numel(variable);
state_vector(vector_index:(vector_index+num_el-1)) = reshape(variable, num_el,1);
vector_index                                       = vector_index + num_el;
end

state_vector = state_vector(1:vector_index-1);
end