function boolean = is_checked(node, tree)

node_key = generate_node_path(node);


node_keys = cell(1,numel(tree.CheckedNodes));
for i = 1:numel(tree.CheckedNodes)   
node_keys{i} = generate_node_path(tree.CheckedNodes(i));
end


boolean = is_in(node_key, node_keys);


    function boolean = is_in(a,A)
    if numel(A) > 0
    boolean =  sum(cellfun(@(A)isequal(a,A), A)) > 0;
    else
    boolean = 0;
    end
    end



    function node_path = generate_node_path(node)
    node_path = "";
    root = node;
    while isequal(class(root), 'matlab.ui.container.CheckBoxTree') == false
    node_path = root.Text+"."+node_path;
    root = root.Parent;
    end
    end


end