function render_job = push_sim2ui(sim, render_job, ui)

%% Skip-feature:
try previous_t = evalin("base", "previous_time"); catch; previous_t = ui.TSlider.Value; end
assignin("base", "previous_time", ui.TSlider.Value);


if isequal(ui.Switch.Value,'⏵︎') && ui.TSlider.Value < ui.TSlider.Limits(2)
ui.TSlider.Value = ui.TSlider.Value + 1/60;
end




if ui.TSlider.Value ~= previous_t

rocket = historian2instance(sim.rocket, sim.rocket_historian, ui.TSlider.Value);


draw_component     (ui.ax,  rocket, 0.001);
draw_node_positions(ui.ax3, ui.rocketNode, ui.Tree, rocket);
draw_trajectory    (ui.ax2, sim.rocket_historian, rocket, ui.TSlider.Value);

%az = az+0.1;
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


plot(ui.ax4, 0,0);
ui.ax4.NextPlot = "add";
draw_branch(ui.ax4, ui.Tree, ui.rocketNode, sim.rocket_historian, ui.TSlider.Value);

ui.ax4.NextPlot = "replacechildren";

drawnow





if render_job.record_video
writeVideo(render_job.vidobj, getframe(ui.UIFigure)); 
end
if render_job.record_gif
img = getframe(ui.UIFigure); img = frame2im(img); [img,cmap] = rgb2ind(img, 256);    
imwrite(img, cmap, render_job.gif_name, "gif", WriteMode="append", DelayTime=1/render_job.framerate); 
end

if render_job.close_on_finish &&  ui.TSlider.Value == ui.TSlider.Limits(2);   close(ui.UIFigure); render_job.rendering = false;  end


end
