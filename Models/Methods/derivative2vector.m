function derivative_vector = derivative2vector(derivative)


derivative_vector = cell2mat(cellfun(@(value) reshape(value, numel(value), 1), derivative.values, "UniformOutput", false)');


end