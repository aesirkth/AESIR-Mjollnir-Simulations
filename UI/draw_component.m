function draw_component(ax,comp, scaler)
ColorMap = evalin("base", "ColorMap");

if exist("scaler", "var") == false
scaler = 0.1;
end

initial_plotstate = ax.NextPlot;

plot3(ax,0,0,0);
ax.NextPlot = "add";
draw_internal(comp);
if isfield(comp, "children")
cellfun(@draw_internal, comp.children )
end
ax.NextPlot = initial_plotstate;



function draw_internal(comp)

%% Mesh:
if isfield(comp, "mesh")
new_mesh = comp.mesh;
new_mesh.vertices = comp.mesh.vertices*(comp.attitude');
new_mesh.vertices = new_mesh.vertices + comp.position';

patch(ax, new_mesh, 'FaceColor',       [100 0 100]/255, ...
                    'EdgeColor',       'none',        ...
                    'FaceLighting',    'gouraud',     ...
                    'AmbientStrength', 0.7, ...
                    'FaceAlpha',       0.2);
camlight(ax, 70,45)
axis(ax, "tight")

end


%% Center of mass
scatter3(ax, comp.position(1) + comp.attitude(1,:)*comp.center_of_mass, ...
             comp.position(2) + comp.attitude(2,:)*comp.center_of_mass, ...
             comp.position(3) + comp.attitude(3,:)*comp.center_of_mass, ...
             comp.mass*scaler, "filled");


%% Moment of inertia

z_circle = comp.position +  ...
                           comp.attitude*(comp.center_of_mass + ...
                                                                [(comp.moment_of_inertia(3,3).^(0.2))*cos(linspace(0,2*pi,100))*scaler; ...
                                                                 (comp.moment_of_inertia(3,3).^(0.2))*sin(linspace(0,2*pi,100))*scaler; ...
                                                                 zeros(1,100)]*300);
y_circle =comp.position +  ...
                           comp.attitude*(comp.center_of_mass + ...
                                                                [(comp.moment_of_inertia(2,2).^(0.2))*cos(linspace(0,2*pi,100))*scaler; ...
                                                                 zeros(1,100); ...
                                                                 (comp.moment_of_inertia(2,2).^(0.2))*sin(linspace(0,2*pi,100))*scaler]*300);
x_circle = comp.position +  ...
                           comp.attitude*(comp.center_of_mass + ...
                                                                [zeros(1,100); ...
                                                                 (comp.moment_of_inertia(1,1).^(0.2))*cos(linspace(0,2*pi,100))*scaler; ...
                                                                 (comp.moment_of_inertia(1,1).^(0.2))*sin(linspace(0,2*pi,100))*scaler]*300);



plot3(ax, x_circle(1,:), x_circle(2,:), x_circle(3,:), "LineWidth",1.5, "Color",ColorMap(end-50,:));
plot3(ax, y_circle(1,:), y_circle(2,:), y_circle(3,:), "LineWidth",1.5, "Color",ColorMap(end-50,:));
plot3(ax, z_circle(1,:), z_circle(2,:), z_circle(3,:), "LineWidth",1.5, "Color",ColorMap(end-50,:));






% quiver3(ax, comp.position(1)*[1 1 1], ...
%             comp.position(2)*[1 1 1], ...
%             comp.position(3)*[1 1 1], ...
%             comp.attitude(1,:)*scaler, ...
%             comp.attitude(2,:)*scaler, ...
%             comp.attitude(3,:)*scaler, ...
%             "Color",ColorMap(end-100,:))

% quiver3(ax, comp.position(1), ...
%             comp.position(2), ...
%             comp.position(3), ...
%             comp.velocity(1)*scaler, ...
%             comp.velocity(2)*scaler, ...
%             comp.velocity(3)*scaler, ...
%             "Color",ColorMap(60,:))

%% Forces:
% cellfun(@(force) quiver3(ax, ...
%                          comp.position(1) +  comp.attitude(1,:)*force.pos, ...
%                          comp.position(2) +  comp.attitude(2,:)*force.pos, ...
%                          comp.position(3) +  comp.attitude(3,:)*force.pos, ...
%                          force.vec(1)*scaler, ...
%                          force.vec(2)*scaler, ...
%                          force.vec(3)*scaler, ...
%                          "Color", ColorMap(end,:), ...
%                          "LineWidth",1),...
%         values(comp.forces , "cell"))

cellfun(@(force) quiver3(ax, ...
                         comp.position(1) +  comp.attitude(1,:)*force.pos - force.vec(1)*scaler, ...
                         comp.position(2) +  comp.attitude(2,:)*force.pos - force.vec(2)*scaler, ...
                         comp.position(3) +  comp.attitude(3,:)*force.pos - force.vec(3)*scaler, ...
                         force.vec(1)*scaler, ...
                         force.vec(2)*scaler, ...
                         force.vec(3)*scaler, ...
                         "Color", ColorMap(end,:), ...
                         "LineWidth",1.5),...
        values(comp.forces , "cell"))

cellfun(@(force, str) text(ax, ...
                         comp.position(1) + comp.attitude(1,:)*force.pos -force.vec(1)*scaler*0.1, ...
                         comp.position(2) + comp.attitude(2,:)*force.pos -force.vec(2)*scaler*0.1, ...
                         comp.position(3) + comp.attitude(3,:)*force.pos -force.vec(3)*scaler*0.1, ...
                         str, ...
                         "Color", ColorMap(end,:), ...
                         "LineWidth", 1.5),...
        values(comp.forces , "cell"), ...
        keys(  comp.forces , "cell"))


%% Moments:
% cellfun(@(moment) quiver3(ax, ...
%                          comp.position(1) + comp.attitude(1,:)*moment.pos, ...
%                          comp.position(2) + comp.attitude(2,:)*moment.pos, ...
%                          comp.position(3) + comp.attitude(3,:)*moment.pos, ...
%                          moment.vec(1)*scaler*300, ...
%                          moment.vec(2)*scaler*300, ...
%                          moment.vec(3)*scaler*300, ...
%                          "Color", ColorMap(60,:)),...
%          values(comp.moments , "cell"))

cellfun(@(moment) quiver3(ax, ...
                         comp.position(1) + comp.attitude(1,:)*moment.pos - moment.vec(1)*scaler*300, ...
                         comp.position(2) + comp.attitude(2,:)*moment.pos - moment.vec(2)*scaler*300, ...
                         comp.position(3) + comp.attitude(3,:)*moment.pos - moment.vec(3)*scaler*300, ...
                         moment.vec(1)*scaler*300, ...
                         moment.vec(2)*scaler*300, ...
                         moment.vec(3)*scaler*300, ...
                         "Color", ColorMap(60,:), ...
                         "LineWidth", 1.5),...
         values(comp.moments , "cell"))

cellfun(@(moment, str) text(ax, ...
                         comp.position(1) + moment.pos(1)-moment.vec(1)*scaler*30, ...
                         comp.position(2) + moment.pos(2)-moment.vec(2)*scaler*30, ...
                         comp.position(3) + moment.pos(3)-moment.vec(3)*scaler*30, ...
                         str, ...
                         "Color", ColorMap(60,:), ...
                         "LineStyle","--"),...
        values(comp.moments , "cell"), ...
        keys(  comp.moments , "cell"))





%% Relative wind:
xvec = linspace(-3,3,4) + comp.position(1);
yvec = linspace(-3,3,4) + comp.position(2);
zvec = linspace(-3,3,4) + comp.position(3);
[X,Y,Z] = meshgrid(xvec, yvec, zvec);

quiver3(ax, X,Y,Z, comp.relative_velocity(1)*ones(size(X)), ...
                   comp.relative_velocity(2)*ones(size(Y)), ...
                   comp.relative_velocity(3)*ones(size(Z)), "off")


    end
end