function [ui, render_job] = configure_sim2ui(sim, render_job, ui)



if ~exist("ui",  "var"); ui  = rocket_app(); end



ui.UIFigure.Name  = "Flight sim";
ui.TSlider.Limits = [0,max(sim.rocket_historian.t)];
grid(ui.ax4, "on");


create_branch(ui.rocketNode, sim.rocket_historian)


if isfolder('../colorthemes/'); dark_mode2(); end
light(ui.ax)
annotation(ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);

index = 1; drawnow

pause(1)
ui.UIFigure.WindowState = "maximized";

rocket = historian2instance(sim.rocket, sim.rocket_historian, 0);


draw_component     (ui.ax, rocket, 0.003);
draw_node_positions(ui.ax3, ui.rocketNode, ui.Tree, rocket);
draw_trajectory    (ui.ax2, sim.rocket_historian, rocket, index);

az = 10;
ui.ax .View = [az, 5];
ui.ax3.View = [az, 5];
ui.ax2.View = [az, 5];

ui.Switch.Value = '⏵︎';




end











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
