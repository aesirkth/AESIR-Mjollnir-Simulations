function derivative_vector = derivative2vector(derivative, state_variables)



vector_index    = 1; derivative_vector = zeros(sum(cellfun(@numel, derivative.values)), 1); % right size but wrong order

for state_variable_index = 1:numel(state_variables)
state_variable                                        = state_variables{state_variable_index};
elements                                              = derivative(state_variable);
num_el                                                = numel(elements);
elements                                              = reshape(elements, num_el, 1);
derivative_vector(vector_index:vector_index+num_el-1) = elements;
vector_index                                          = vector_index + num_el;
end





end