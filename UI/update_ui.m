

%% Skip-feature:
while t(index) < my_ui.TSlider.Value && t(index +1) < my_ui.TSlider.Value;index = index+1;end
while t(index) > my_ui.TSlider.Value && t(index +1) > my_ui.TSlider.Value;index = index-1;end


if isequal(my_ui.Switch.Value,'⏵︎') && index < numel(t)-1
index = index+1;
my_ui.TSlider.Value = t(index);


mjolnir = historian2comp(mjolnir, mjolnir_historian, index);


draw_component(my_ui.ax,  mjolnir, 0.003);
%draw_component(my_ui.ax3, mjolnir, 0.003);
draw_node_positions(my_ui.ax3, my_ui.mjolnirNode, my_ui.Tree, mjolnir);
draw_trajectory(my_ui.ax2, mjolnir_historian.rigid_body.position(:,1:index), terrain);

az = az+0.1;
my_ui.ax .View = [az, 5];
my_ui.ax3.View = [az, 5];
my_ui.ax2.View = [az, 5];


if t(index) < 60
my_ui.TLabel.Text = "T+"+string(t(index))+" s";
else
my_ui.TLabel.Text = "T+"+string(floor(t(index)/60))+" m, " + string(mod(t(index), 60)) + " s";
end

my_ui.VelocityLabel.Text = "Velocity: "+string(norm(mjolnir.rigid_body.velocity)) +" m/s";


plot(my_ui.ax4, 0,0);
my_ui.ax4.NextPlot = "add";
draw_branch(my_ui.ax4, my_ui.Tree, my_ui.mjolnirNode, mjolnir_historian, t, index);

my_ui.ax4.NextPlot = "replacechildren";

else
pause(0.5)

end
drawnow

