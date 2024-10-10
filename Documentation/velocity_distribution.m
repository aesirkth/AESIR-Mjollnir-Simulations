set(groot, 'defaultAxesTickLabelInterpreter','latex'); set(groot, 'defaultLegendInterpreter','latex');
addpath('../../animation_toolbox/');addpath('../../colorthemes/');addpath('../STLRead/');
fig = figure;
ax = axes(fig); dark_mode2; plot3(ax, 0,0,0); ax.DataAspectRatio = [1,1,1]; 
annotation(fig, "rectangle","EdgeColor", [1,1,1]*0.13, "Position", [0.25 0.1 0.5 0.8]);
ax.XLim = [-50,50];ax.YLim = [-10,10];ax.ZLim = [-50,50]; axis off
light(ax);
mesh = stlread("../Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
mesh.vertices = mesh.vertices - [0 0 (max(mesh.vertices(3,:)) + min(mesh.vertices(3,:)))*0.5] - [0 0 10];

amplitude = 45;
frequency = 4;

rocket   = animation(@(c)patch(ax, rotmesh(mesh, roty(amplitude*sin(c{1}))), ...
                              'FaceColor',       ColorMap(70,:), ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 0.1, ...
                              'FaceAlpha',       0.1), {0}, {frequency*2*pi});

rotwind_vector           =     animation(@(c) quivervec(ax,   (roty(amplitude*sin(c{1}))*[0;0;1]*(-40:4:40)+roty(amplitude*sin(c{1}))*[0.5;0;0]*cos(c{1})*(-40:4:40)), ...
                                                              (roty(amplitude*sin(c{1}))*[-0.4;0;0]*cos(c{1})*(-40:4:40)), ...
                                                              "off","LineWidth", 1.5,"Color", [0,1,1]) ,{0}, {frequency*2*pi});

rotwind_line              =     animation(@(c) plotvec(ax,     (roty(amplitude*sin(c{1}))*[0;0;1]*(-40:4:40)+roty(amplitude*sin(c{1}))*[0.5;0;0]*cos(c{1})*(-40:4:40)), ...
                                                               "LineWidth", 1.5,"Color", [0,1,1]) ,{0}, {frequency*2*pi});

rotwind_text              =      animation(@(c) textvec(ax,     (roty(amplitude*sin(c{1}))*[0;0;1]*30+roty(amplitude*sin(c{1}))*[0.5;0;0]*cos(c{1})*30) + [10;0;0], ...
                                                                "$-\vec{\omega}\;x\;\vec{r}$","Color", [0,1,1], "Interpreter", "latex"),{0}, {frequency*2*pi});



saver = save_to_gif(ax, "velocity_distribution.gif");
delete velocity_distribution.gif
animate({rocket, ...
        rotwind_vector, ...
        rotwind_line, ...
        rotwind_text, saver}, 1:0.5:100)





function mesh = rotmesh(mesh, mat)
mesh.vertices = mesh.vertices*(mat');

end

function quivervec(ax, orig, vec,varargin); quiver3(ax, orig(1,:), orig(2,:), orig(3,:), vec(1,:), vec(2,:), vec(3,:), varargin{:});
end

function plotvec(ax,vec,varargin); plot3(ax, vec(1,:), vec(2,:), vec(3,:), varargin{:});
end

function textvec(ax,vec,varargin); text(ax, vec(1,:), vec(2,:), vec(3,:), varargin{:});
end