function draw_sim(ui, sim, dt)
ui.TSlider.Limits = [0,max(sim.rocket_historian.t)];


%% Skip-feature:
try previous_t = evalin("base", "previous_time"); catch; previous_t = ui.TSlider.Value; end
assignin("base", "previous_time", ui.TSlider.Value);


if isequal(ui.Switch.Value,'⏵︎') && ui.TSlider.Value < ui.TSlider.Limits(2)
ui.TSlider.Value = ui.TSlider.Value + dt;
end




if ui.TSlider.Value ~= previous_t

rocket = query_historian(sim.initial_rocket, sim.rocket_historian, ui.TSlider.Value);



if     isequal(ui.TabGroup.SelectedTab.Title, "Flight") 

draw_rocket        (ui.ax,  rocket);
draw_trajectory    (ui.ax2, sim.rocket_historian, rocket, ui.TSlider.Value);
az = 5;
ui.ax .View = [az, 5];
ui.ax3.View = [az, 5];
ui.ax2.View = [az, 5];
if ui.TSlider.Value < 60
    ui.TLabel.Text = "T+"+string(ui.TSlider.Value)+" s";
else
    ui.TLabel.Text = "T+"+string(floor(ui.TSlider.Value/60))+" m, " + string(mod(ui.TSlider.Value, 60)) + " s";
end
    
ui.VelocityLabel.Text = "Velocity: "+string(norm(rocket.velocity)) +" m/s";

    
elseif isequal(ui.TabGroup.SelectedTab.Title, "Plots") 

plot(ui.ax4, 0,0);
ui.ax4.NextPlot = "add";
draw_node          (ui.Tree, ui.ax4, sim.initial_rocket.name, sim.rocket_historian, ui.TSlider.Value);
draw_node_positions(ui.ax3, ui.rocketNode, ui.Tree, rocket);
ui.ax4.NextPlot = "replacechildren";

end



drawnow

end
