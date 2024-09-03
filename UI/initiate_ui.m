my_ui = ui2;
my_ui.UIFigure.Name = "Mjölnir flight sim";
my_ui.TSlider.Limits = [t0,t_max];
grid(my_ui.ax4, "on");


create_branch(my_ui.mjolnirNode, mjolnir_historian)


if isfolder('../colorthemes/'); aesir_purple(); end
light(my_ui.ax)
annotation(my_ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);
az = 5;
index = 1; drawnow

pause(1)
my_ui.UIFigure.WindowState = "maximized";

mjolnir = historian2comp(mjolnir, mjolnir_historian, 1);


draw_component(my_ui.ax, mjolnir, 0.003);
%draw_component(my_ui.ax3, mjolnir, 0.003);
draw_node_positions(my_ui.ax3, my_ui.mjolnirNode, my_ui.Tree, mjolnir);
draw_trajectory(my_ui.ax2, mjolnir_historian.rigid_body.position(:,1:index), terrain);

my_ui.ax .View = [az, 5];
my_ui.ax3.View = [az, 5];
my_ui.ax2.View = [az, 5];


















function create_branch(parent, historian)


parameters = fieldnames(historian);

for index = 1:numel(parameters)

parameter = parameters{index};
if height(historian.(parameter)) == 1 && isequal(class(historian.(parameter)), 'double')

    if sum( historian.(parameter) ~= historian.(parameter)(1) ) ~= 0
    uitreenode(parent, "Text", parameter);
    end

elseif isequal(class(historian.(parameter)), 'struct')
    new_branch = uitreenode(parent, "Text", parameter);
    create_branch(new_branch, historian.(parameter))
end

end


end