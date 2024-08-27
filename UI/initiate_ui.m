my_ui = ui;
my_ui.UIFigure.Name = "Mjölnir flight sim";
my_ui.TSlider.Limits = [t0,t_max];
grid(my_ui.ax4, "on");

parameters = fieldnames(mjolnir_historian);

for index = 1:numel(parameters)

parameter = parameters{index};
if height(mjolnir_historian.(parameter)) == 1 && isequal(class(mjolnir_historian.(parameter)), 'double')
if sum( mjolnir_historian.(parameter) ~= mjolnir_historian.(parameter)(1) ) ~= 0
uitreenode(my_ui.Tree, "Text", parameter);
end
end
end


if isfolder('../colorthemes/'); aesir_purple(); end
light(my_ui.ax)
annotation(my_ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);
az = 5;
index = 1; drawnow

pause(1)
my_ui.UIFigure.WindowState = "maximized";

mjolnir = historian2comp(mjolnir, mjolnir_historian, 1);

draw_component(my_ui.ax, mjolnir, 0.003);
draw_component(my_ui.ax3, mjolnir, 0.003);
draw_trajectory(my_ui.ax2, mjolnir_historian.position(:,1:index), terrain);

my_ui.ax .View = [az, 5];
my_ui.ax3.View = [az, 5];
my_ui.ax2.View = [az, 5];