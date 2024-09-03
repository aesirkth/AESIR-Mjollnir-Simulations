function draw_node_positions(ax, parent_node, tree, comp)

ColorMap = evalin("base", "ColorMap");


plot3(ax, 0,0,0);
patch(ax, comp.mesh, 'FaceColor',       ColorMap(70,:), ...
                     'EdgeColor',       'none',        ...
                     'FaceLighting',    'gouraud',     ...
                     'AmbientStrength', 0.1, ...
                     'FaceAlpha',       0.1);

ax.NextPlot = "add";
l = light(ax);
l.Color = [1 1 1];
lighting(ax, "flat")
axis(ax, "tight")
ax.DataAspectRatio = [1 1 1];

draw_node_positions_internal(ax, parent_node, comp);

ax.NextPlot = "replacechildren";


view(ax, 0, 0);


function draw_node_positions_internal(ax, parent_node, parent_struct)

for parameter_index = 1:numel(parent_node.Children)
    
    parameter = parent_node.Children(parameter_index).Text;
    
    if    isequal(class(parent_struct.(parameter)), 'struct') ...
       && is_checked(parent_node.Children(parameter_index), tree)  ...
       && isequal(parameter, "forces" ) == false ...
       && isequal(parameter, "moments") == false
    
    if isfield(parent_struct.(parameter), "ui_node_position"); node_position = parent_struct.(parameter).ui_node_position;
    else;                                                      node_position = comp.rigid_body.center_of_mass;
    end
    
    scatter3(ax, node_position(1), ...
                 node_position(2), ...
                 node_position(3), "filled", "MarkerFaceColor",ColorMap(1,:));
    text    (ax, node_position(1)+0.1, ...
                 node_position(2)+0.1, ...
                 node_position(3), strrep(parameter, "_", " "), "Color",ColorMap(1,:));
    
    draw_node_positions_internal(ax, parent_node.Children(parameter_index), parent_struct.(parameter));
    
    end

end

end

end


