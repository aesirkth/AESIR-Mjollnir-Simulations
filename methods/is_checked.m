function boolean = is_checked(node, tree)

list = cell(1,numel(tree.CheckedNodes));
for i = 1:numel(tree.CheckedNodes)
list{i} = tree.CheckedNodes(i).Text;
end


boolean = is_in(node, list);


    function boolean = is_in(a,A)
    boolean = sum(strcmp(a,A)) > 0;

    end
end