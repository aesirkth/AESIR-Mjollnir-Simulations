function draw_trajectory(ax, positions)

initial_plotstate = ax.NextPlot;

scatter3(ax, positions(1,end), positions(2,end), positions(3,end), "^");
ax.NextPlot = "add";
plot3(ax, positions(1,:), positions(2,:), positions(3,:), "--")
ax.DataAspectRatio = [1 1 1];
ax.PlotBoxAspectRatio = [1 1 1];
ax.XGrid = "on";
ax.YGrid = "on";
ax.ZGrid = "on";

ax.NextPlot = initial_plotstate;

end