function push_sim2ui(sim, render_job, ui)

%% Skip-feature:
try index = evalin("base", "indexstamp"); catch; assignin("base", "indexstamp", 1); index = 1; end


while sim.t(index) < ui.TSlider.Value && sim.t(index +1) < ui.TSlider.Value;index = index+1;end
while sim.t(index) > ui.TSlider.Value && sim.t(index +1) > ui.TSlider.Value;index = index-1;end


if isequal(ui.Switch.Value,'⏵︎') && index < numel(sim.t)
index = index+1;
ui.TSlider.Value = sim.t(index);
assignin("base", "indexstamp", index);

rocket = historian2comp(sim.rocket, sim.rocket_historian, index);


draw_component     (ui.ax,  rocket, 0.001);
draw_node_positions(ui.ax3, ui.rocketNode, ui.Tree, rocket);
draw_trajectory    (ui.ax2, sim.rocket_historian, rocket, index);

%az = az+0.1;
az = 5;
ui.ax .View = [az, 5];
ui.ax3.View = [az, 5];
ui.ax2.View = [az, 5];


if sim.t(index) < 60
ui.TLabel.Text = "T+"+string(sim.t(index))+" s";
else
ui.TLabel.Text = "T+"+string(floor(sim.t(index)/60))+" m, " + string(mod(sim.t(index), 60)) + " s";
end

ui.VelocityLabel.Text = "Velocity: "+string(norm(rocket.velocity)) +" m/s";


plot(ui.ax4, 0,0);
ui.ax4.NextPlot = "add";
draw_branch(ui.ax4, ui.Tree, ui.rocketNode, sim.rocket_historian, sim.t, index);

ui.ax4.NextPlot = "replacechildren";

drawnow

if render_job.record_video; writeVideo(render_job.vidobj, getframe(ui.UIFigure)); end
if render_job.close_on_finish && index == numel(sim.t);   close   (ui.UIFigure);  end

else
pause(0.5)

end


