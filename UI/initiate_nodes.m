%function new_node = initiate_nodes(ui, historian, name)
function new_node = initiate_nodes(tree, name, historian)

new_node = uitreenode(tree, "Text", name);
initiate_nodes_internal(new_node, historian)  


function initiate_nodes_internal(parent, historian)


    parameters = fieldnames(historian);
    
    for index = 1:numel(parameters)
    
    parameter = parameters{index};
    if height(historian.(parameter)) == 1 && isequal(class(historian.(parameter)), 'double')
    
        if sum( historian.(parameter) ~= historian.(parameter)(1) ) ~= 0
        uitreenode(parent, "Text", parameter);
        end
    
    elseif isequal(class(historian.(parameter)), 'struct')
        new_node = uitreenode(parent, "Text", parameter);
        initiate_nodes_internal(new_node, historian.(parameter))
    end
    
    end
    
    
end
end