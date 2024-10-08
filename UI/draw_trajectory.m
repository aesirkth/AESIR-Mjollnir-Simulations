function draw_trajectory(ax, historian, comp, index)



bounds_x = [min(historian.position(1,1:index)), max(historian.position(1,1:index))]; x_span = bounds_x(2) - bounds_x(1); x_mean = (bounds_x(2) + bounds_x(1))*0.5;
bounds_y = [min(historian.position(2,1:index)), max(historian.position(2,1:index))]; y_span = bounds_y(2) - bounds_y(1); y_mean = (bounds_y(2) + bounds_y(1))*0.5;
bounds_z = [min(historian.position(3,1:index)), max(historian.position(3,1:index))]; z_span = bounds_z(2) - bounds_z(1); z_mean = (bounds_z(2) + bounds_z(1))*0.5;

max_span = max([x_span, y_span, z_span])*2;

bounds_x = x_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_y = y_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_z = z_mean + [-0.8,1.2]*(max_span+10)*0.5;

[x_grid, y_grid] = meshgrid(linspace(bounds_x(1),bounds_x(2),50), linspace(bounds_y(1),bounds_y(2),50));

z_grid = comp.enviroment.terrain.z(x_grid', y_grid')';

initial_plotstate = ax.NextPlot;

scatter3(ax, historian.position(1,end), historian.position(2,end), historian.position(3,end), "^");
ax.NextPlot = "add";
plot3(ax, historian.position(1,1:index), historian.position(2,1:index), historian.position(3,1:index), "--", "LineWidth",1.5)
if comp.guidance.is_activate
plot3    (ax, historian.guidance.closest_point(1,:    ), historian.guidance.closest_point(2,:    ), historian.guidance.closest_point(3,:    ));
scatter3 (ax, historian.guidance.closest_point(1,index), historian.guidance.closest_point(2,index), historian.guidance.closest_point(3,index));
scatter3 (ax, historian.guidance.aim_point    (1,index), historian.guidance.aim_point    (2,index), historian.guidance.aim_point    (3,index));
text     (ax, historian.guidance.closest_point(1,index), historian.guidance.closest_point(2,index), historian.guidance.closest_point(3,index), "closest point");
text     (ax, historian.guidance.aim_point    (1,index), historian.guidance.aim_point    (2,index), historian.guidance.aim_point    (3,index), "Aim");


end
mesh(ax, x_grid, y_grid, z_grid);
ax.DataAspectRatio    = [1 1 1];
ax.XLim = bounds_x;
ax.YLim = bounds_y;
ax.ZLim = bounds_z;
ax.XGrid = "on";
ax.YGrid = "on";
ax.ZGrid = "on";
ax.GridAlpha = 0.6;
ax.NextPlot = initial_plotstate;

end