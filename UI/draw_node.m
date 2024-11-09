function draw_node(tree, ax, name, historian)
ColorMap = evalin("base", "ColorMap");
%index-finder:
if ~exist("index", "var"); historian_index_finder; end
% Get parent
for index = 1:numel(tree.Children); if strcmp(tree.Children(index).Text, name); parent = tree.Children(index); end; end
t_list = historian.t;
draw_node_internal(parent, ax, historian, index)



function draw_node_internal(parent, ax, historian, index)



for parameter_index = 1:numel(parent.Children)

parameter = parent.Children(parameter_index).Text;

if    isequal(class(historian.(parameter)), 'double') ...
   && is_checked(parent.Children(parameter_index), tree)
plot   (ax, t_list(1:index  ), historian.(parameter)(1,1:index  ),                                               'Color',           ColorMap(1,:), 'LineWidth', 2);
plot   (ax, t_list(index:end), historian.(parameter)(1,index:end),                                               'Color',           ColorMap(1,:), 'LineWidth', 1, 'LineStyle','--');
scatter(ax, t_list(index    ), historian.(parameter)(1,index    ),                                               'MarkerEdgeColor', ColorMap(1,:));
text   (ax, t_list(index    ), historian.(parameter)(1,index    ), strrep(parent.Text+" "+parameter, "_", " "),  'Color',           ColorMap(1,:), 'VerticalAlignment', 'top');
elseif isequal(class(historian.(parameter)), 'struct')

draw_node_internal(parent.Children(parameter_index), ax, historian.(parameter), index);

end

end

end
end