function ui = configure_sim2ui(sim, job, ui)

if ~exist("ui", "var"); ui = mjolnir_app(); end

if job.record_video
    job.video_name = split(job.data_name, "(");
    job.video_name = split(job.video_name(1), ".");
    job.video_name = job.video_name(1)+".mp4";
    job.vidobj     = VideoWriter(job.video_name, "MPEG-4");
    open(job.vidobj)
end

ui.UIFigure.Name  = "Mjölnir flight sim";
ui.TSlider.Limits = [0,sim.job.t_max];
grid(ui.ax4, "on");


create_branch(ui.mjolnirNode, sim.mjolnir_historian)


if isfolder('../colorthemes/'); aesir_purple(); end
light(ui.ax)
annotation(ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);

index = 1; drawnow

pause(1)
ui.UIFigure.WindowState = "maximized";

mjolnir = historian2comp(sim.mjolnir, sim.mjolnir_historian, 1);


draw_component     (ui.ax, mjolnir, 0.003);
draw_node_positions(ui.ax3, ui.mjolnirNode, ui.Tree, mjolnir);
draw_trajectory    (ui.ax2, sim.mjolnir_historian, mjolnir, index);

az = 10;
ui.ax .View = [az, 5];
ui.ax3.View = [az, 5];
ui.ax2.View = [az, 5];






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
