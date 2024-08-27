

%% Skip-feature:
while t(index) < my_ui.TSlider.Value && t(index +1) < my_ui.TSlider.Value;index = index+1;end
while t(index) > my_ui.TSlider.Value && t(index +1) > my_ui.TSlider.Value;index = index-1;end


if isequal(my_ui.Switch.Value,'⏵︎') && index < numel(t)-1
index = index+1;
my_ui.TSlider.Value = t(index);


mjolnir = historian2comp(mjolnir, mjolnir_historian, index);

% [~,mjolnir] = system_equations(t(index),state(:,index), mjolnir); % Calculating dependant data from the state-vector
%mjolnir = state_vector2comp(mjolnir, state(:,index));

draw_component(my_ui.ax,  mjolnir, 0.003);
draw_component(my_ui.ax3, mjolnir, 0.003);
draw_trajectory(my_ui.ax2, mjolnir_historian.position(:,1:index), terrain);

az = az+0.1;
my_ui.ax .View = [az, 5];
my_ui.ax3.View = [az, 5];
my_ui.ax2.View = [az, 5];


if t(index) < 60
my_ui.TLabel.Text = "T+"+string(t(index))+" s";
else
my_ui.TLabel.Text = "T+"+string(floor(t(index)/60))+" m, " + string(mod(t(index), 60)) + " s";
end

my_ui.VelocityLabel.Text = "Velocity: "+string(norm(mjolnir.velocity)) +" m/s";

plotted_parameters = cell(1,numel(my_ui.Tree.CheckedNodes));
plot(my_ui.ax4, 0,0);
my_ui.ax4.NextPlot = "add";
for parameter_index = 1:numel(my_ui.Tree.CheckedNodes)
parameter = my_ui.Tree.CheckedNodes(parameter_index).Text;
plotted_parameters{parameter_index} = parameter;

plot   (my_ui.ax4, t(1:index  ), mjolnir_historian.(parameter)(1,1:index  ),             'Color',           ColorMap(1,:), 'LineWidth', 2);
plot   (my_ui.ax4, t(index:end), mjolnir_historian.(parameter)(1,index:end),             'Color',           ColorMap(1,:), 'LineWidth', 1, 'LineStyle','--');
scatter(my_ui.ax4, t(index    ), mjolnir_historian.(parameter)(1,index    ),             'MarkerEdgeColor', ColorMap(1,:));
text   (my_ui.ax4, t(index    ), mjolnir_historian.(parameter)(1,index    ), parameter,  'Color',           ColorMap(1,:), 'VerticalAlignment', 'top');
end



my_ui.ax4.NextPlot = "replacechildren";

else
pause(0.5)

end
drawnow