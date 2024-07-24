position_list(:, list_index) = my_rocket.position;


draw_component(my_ui.ax, my_rocket, 0.003)
my_ui.ax.NextPlot = "add";
az = az+0.3;
my_ui.ax.View = [az, 45];
xlim(my_ui.ax, my_rocket.position(1) + [-3 3])
ylim(my_ui.ax, my_rocket.position(2) + [-3 3])
zlim(my_ui.ax, my_rocket.position(3) + [-3 3])
my_ui.ax.DataAspectRatio = [1 1 1];
my_ui.ax.XGrid = "on";
my_ui.ax.YGrid = "on";
my_ui.ax.ZGrid = "on";
my_ui.ax.NextPlot = "replacechildren";


plot3(my_ui.ax2, position_list(1,1:list_index), ...
                 position_list(2,1:list_index), ...
                 position_list(3,1:list_index), "LineStyle","--", "LineWidth",1.1);
my_ui.ax2.NextPlot = "add";
scatter3(my_ui.ax2, my_rocket.position(1), my_rocket.position(2), my_rocket.position(3), "^");
my_ui.ax2.View = [az, 45];
my_ui.ax2.DataAspectRatio = [1 1 1];
my_ui.ax2.PlotBoxAspectRatio = [1 1 1];
my_ui.ax2.XGrid = "on";
my_ui.ax2.YGrid = "on";
my_ui.ax2.ZGrid = "on";
my_ui.ax2.NextPlot = "replacechildren";


% %my_ui.AirspeedIndicator.Airspeed = norm(my_rocket.velocity);
% my_ui.AirspeedIndicator.Value = norm(my_rocket.velocity);
% my_ui.Altimeter.Altitude = my_rocket.position(3);
% my_ui.ArtificialHorizon.Roll  = (360/2*pi)*acos(norm(cross(my_rocket.attitude(:,1),[0;0.999;0])));
% my_ui.ArtificialHorizon.Pitch = (360/2*pi)*asin(norm(cross(my_rocket.attitude(:,2),[0;0;0.999])));
% %my_ui.ArtificialHorizon.Yaw   = (360/2*pi)*asin(norm(cross(my_rocket.attitude(:,3),[0.999;0;0])));
% my_ui.ClimbIndicator.Value = my_rocket.velocity(3);
drawnow