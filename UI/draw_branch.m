function draw_branch(ax, tree, parent, historian, t, index)
ColorMap = evalin("base", "ColorMap");

%index-finder:
if ~exist("index", "var"); historian_index_finder; end


for parameter_index = 1:numel(parent.Children)

parameter = parent.Children(parameter_index).Text;

if    isequal(class(historian.(parameter)), 'double') ...
   && is_checked(parent.Children(parameter_index), tree)
plot   (ax, historian.t(1:index  ), historian.(parameter)(1,1:index  ),                                               'Color',           ColorMap(1,:), 'LineWidth', 2);
plot   (ax, historian.t(index:end), historian.(parameter)(1,index:end),                                               'Color',           ColorMap(1,:), 'LineWidth', 1, 'LineStyle','--');
scatter(ax, historian.t(index    ), historian.(parameter)(1,index    ),                                               'MarkerEdgeColor', ColorMap(1,:));
text   (ax, historian.t(index    ), historian.(parameter)(1,index    ), strrep(parent.Text+" "+parameter, "_", " "),  'Color',           ColorMap(1,:), 'VerticalAlignment', 'top');
elseif isequal(class(historian.(parameter)), 'struct')

draw_branch(ax, tree, parent.Children(parameter_index), historian.(parameter),t, index);

end

end

end