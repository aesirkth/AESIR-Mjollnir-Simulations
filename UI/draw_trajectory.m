function draw_trajectory(ax, positions, terrain)



bounds_x = [min(positions(1,:)), max(positions(1,:))]; x_span = bounds_x(2) - bounds_x(1); x_mean = (bounds_x(2) + bounds_x(1))*0.5;
bounds_y = [min(positions(2,:)), max(positions(2,:))]; y_span = bounds_y(2) - bounds_y(1); y_mean = (bounds_y(2) + bounds_y(1))*0.5;
bounds_z = [min(positions(3,:)), max(positions(3,:))]; z_span = bounds_z(2) - bounds_z(1); z_mean = (bounds_z(2) + bounds_z(1))*0.5;

max_span = max([x_span, y_span, z_span])*2;

bounds_x = x_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_y = y_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_z = z_mean + [-0.8  ,1.2  ]*(max_span+10)*0.5;

[x_grid, y_grid] = meshgrid(linspace(bounds_x(1),bounds_x(2),50), linspace(bounds_y(1),bounds_y(2),50));

z_grid = arrayfun(@(x,y)terrain.z(x,y), x_grid, y_grid);

initial_plotstate = ax.NextPlot;

scatter3(ax, positions(1,end), positions(2,end), positions(3,end), "^");
ax.NextPlot = "add";
plot3(ax, positions(1,:), positions(2,:), positions(3,:), "--", "LineWidth",1.5)
mesh(ax, x_grid, y_grid, z_grid);%, "EdgeColor","none","FaceColor",[0.2,0.5,0.2]);
%light(ax);
ax.DataAspectRatio    = [1 1 1];
%ax.PlotBoxAspectRatio = [1 1 1];
ax.XLim = bounds_x;
ax.YLim = bounds_y;
ax.ZLim = bounds_z;
ax.XGrid = "on";
ax.YGrid = "on";
ax.ZGrid = "on";
ax.GridAlpha = 0.6;
ax.NextPlot = initial_plotstate;

end