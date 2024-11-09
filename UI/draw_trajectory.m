function draw_trajectory(ax, historian, rocket, t)
ColorMap = evalin("base", "ColorMap");

%index-finder:
historian_index_finder;
t_query = linspace(0,t,200);
positions     = makima(historian.t, historian.position,          t_query);



bounds_x = [min(positions(1,1:end)), max(positions(1,1:end))]; x_span = bounds_x(2) - bounds_x(1); x_mean = (bounds_x(2) + bounds_x(1))*0.5;
bounds_y = [min(positions(2,1:end)), max(positions(2,1:end))]; y_span = bounds_y(2) - bounds_y(1); y_mean = (bounds_y(2) + bounds_y(1))*0.5;
bounds_z = [min(positions(3,1:end)), max(positions(3,1:end))]; z_span = bounds_z(2) - bounds_z(1); z_mean = (bounds_z(2) + bounds_z(1))*0.5;

max_span = max([x_span, y_span, z_span])*2;

bounds_x = x_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_y = y_mean + [-1  ,1  ]*(max_span+10)*0.5;
bounds_z = z_mean + [-0.8,1.2]*(max_span+10)*0.5;

[x_grid, y_grid] = meshgrid(linspace(bounds_x(1),bounds_x(2),50), linspace(bounds_y(1),bounds_y(2),50));

z_grid = rocket.enviroment.terrain.z(x_grid', y_grid')';

initial_plotstate = ax.NextPlot;

scatter3(ax, positions(1,end), positions(2,end), positions(3,end), "^", "Color", ColorMap(1,:));
ax.NextPlot = "add";
plot3(ax, positions(1,1:end), positions(2,1:end), positions(3,1:end), "--", "LineWidth",1.5, "Color", ColorMap(1,:))
mesh(ax, x_grid, y_grid, z_grid);

if isfield(rocket, "guidance")
    closest_point = makima(historian.t, historian.guidance.closest_point,  t);
    %closest_index = makima(historian.t, historian.guidance.closest_index,  t);
    aim_point     = makima(historian.t, historian.guidance.aim_point,      t);
    aim_index     = makima(historian.t, historian.guidance.aim_index,      t);
    trajectory    = cell2mat(arrayfun(@(i)rocket.guidance.trajectory(i), linspace(historian.guidance.closest_index(1), abs(aim_index*6), 800), "UniformOutput", false));
    
    plot3    (ax, trajectory   (1,:), trajectory   (2,:), trajectory   (3,:), "LineWidth", 1.5,  "Color", ColorMap(1,:));
    scatter3 (ax, closest_point(1  ), closest_point(2  ), closest_point(3  ),                    "Color", ColorMap(1,:));
    scatter3 (ax, aim_point    (1  ), aim_point    (2  ), aim_point    (3  ),                    "Color", ColorMap(1,:));
    text     (ax, closest_point(1  ), closest_point(2  ), closest_point(3  ), "closest point",   "Color", ColorMap(1,:));
    text     (ax, aim_point    (1  ), aim_point    (2  ), aim_point    (3  ), "Aim",             "Color", ColorMap(1,:));
    
    
end

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