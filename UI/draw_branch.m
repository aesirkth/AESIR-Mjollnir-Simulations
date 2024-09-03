function draw_branch(ax, tree, parent, historian, t, index)
ColorMap = evalin("base", "ColorMap");


for parameter_index = 1:numel(parent.Children)

parameter = parent.Children(parameter_index).Text;

if    isequal(class(historian.(parameter)), 'double') ...
   && is_checked(parent.Children(parameter_index), tree)
plot   (ax, t(1:index  ), historian.(parameter)(1,1:index  ),                               'Color',           ColorMap(1,:), 'LineWidth', 2);
plot   (ax, t(index:end), historian.(parameter)(1,index:end),                               'Color',           ColorMap(1,:), 'LineWidth', 1, 'LineStyle','--');
scatter(ax, t(index    ), historian.(parameter)(1,index    ),                               'MarkerEdgeColor', ColorMap(1,:));
text   (ax, t(index    ), historian.(parameter)(1,index    ), strrep(parameter, "_", " "),  'Color',           ColorMap(1,:), 'VerticalAlignment', 'top');
elseif isequal(class(historian.(parameter)), 'struct')

draw_branch(ax, tree, parent.Children(parameter_index), historian.(parameter),t, index);

end

end

end