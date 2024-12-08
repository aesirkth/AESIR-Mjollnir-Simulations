function draw_rocket_recursive(ax, rocket)
ColorMap = evalin("base", "ColorMap");
ax_initial_plotstate = ax.NextPlot;

plot3(ax, 0,0,0)
ax.NextPlot = "add";
draw_parent_recursor(rocket)
view(ax, [45, 10])
ax.DataAspectRatio = [1 1 1];
if isfield(rocket, 'center_of_mass_absolute')
ax.XLim = rocket.position(1) + rocket.center_of_mass_absolute(1) + [-4,4];
ax.YLim = rocket.position(2) + rocket.center_of_mass_absolute(2) + [-4,4];
ax.ZLim = rocket.position(3) + rocket.center_of_mass_absolute(3) + [-4,4];
else
ax.XLim = rocket.position(1)+[-4,4]*100;
ax.YLim = rocket.position(2)+[-4,4]*100;
ax.ZLim = rocket.position(3)+[-4,4]*100;
end

light(ax)
ax.NextPlot = ax_initial_plotstate;


function draw_parent_recursor(parent, world2origin, local2world, parent_name)
if ~exist('world2origin', 'var'); world2origin = [0;0;0]; end
if ~exist('local2world' , 'var'); local2world  = eye(3) ; end
if ~exist('parent_name' , 'var'); parent_name  = ""     ; end


    children = fieldnames(parent);

    for child_index = 1:numel(children)
    child = children{child_index};

    if isfield(parent, 'position'); parent_position = parent.position; else; parent_position = [0;0;0]; end
    if isfield(parent, 'attitude'); parent_attitude = parent.attitude; else; parent_attitude = eye(3) ; end

    %% RECURSION

    if isequal(class(parent.(child)), 'struct')
        draw_parent_recursor(parent.(child),  local2world*parent_position + world2origin, local2world*parent_attitude, child)
    end

    %% NODE

    vectorscatter(ax, world2origin, "Marker", ".", "MarkerEdgeColor", [1,1,1], "SizeData", 100);
    %vectortext   (ax, world2origin + rand(1,3), parent_name, "Color", [1,1,1], "FontSize", 5);


    %% MESH

    if isfield(parent, 'mesh')
    meshname = filename2varname(parent.mesh);
    try mesh_transformed = evalin('base', meshname); catch; mesh_transformed = stlread(parent.mesh); assignin("base", meshname, mesh_transformed); end
    
    mesh_transformed.vertices = mesh_transformed.vertices*(local2world') + world2origin';
    
    patch(ax, mesh_transformed, 'FaceColor',       ColorMap(70,:), ...
                                'EdgeColor',       'none',        ...
                                'FaceLighting',    'gouraud',     ...
                                'AmbientStrength', 0.6, ...
                                'FaceAlpha',       0.05);

    end


    %% FORCES
    if isfield(parent, "forces")
        cellfun( @(force) vectorquiver(ax, world2origin + local2world*(parent_position + parent_attitude* (parent.forces.(force).pos - parent.forces.(force).vec*1e-3)), ... 
                                                          local2world*                   parent_attitude*                              parent.forces.(force).vec*1e-3,  ...
                                           "Color", ColorMap(200,:),"LineWidth",1.5 ), ...
                 fieldnames(parent.forces) );


        %cellfun( @(force) vectortext(  ax, world2origin + local2world*(parent_position + parent_attitude* (parent.forces.(force).pos - parent.forces.(force).vec*1e-4)), ...
        %                                   parent_name+"  "+force, ... 
        %                                   "Color", ColorMap(200,:), "FontSize", 10 ), ...
        %         fieldnames(parent.forces) );
        
    end

    %% MOMENTS
    if isfield(parent, "moments")
        cellfun( @(moment) vectorquiver( ax, world2origin + local2world*(parent_position + parent_attitude* (parent.moments.(moment).pos - parent.moments.(moment).vec*1e-3)), ... 
                                                            local2world*                   parent_attitude*                                parent.moments.(moment).vec*1e-3,  ...
                                             "Color", ColorMap(150,:),"LineWidth",1.5 ), ...
                 fieldnames(parent.moments) );


        %cellfun( @(moment)  vectortext(  ax, world2origin + local2world*(parent_position + parent_attitude* (parent.moments.(moment).pos - parent.moments.(moment).vec*1e-6)), ...
        %                                     parent_name+"  "+moment, ... 
        %                                     "Color", ColorMap(150,:), "FontSize", 10 ), ...
        %         fieldnames(parent.moments) );
        
    end

    %% RELATIVE WIND
    if isfield(parent, "wind_velocity_absolute")
        vectorquiver(ax, world2origin + local2world* (parent_position -  parent.wind_velocity_absolute*1e-1) + [1;1;0]*0.5, ... 
                                        local2world*                     parent.wind_velocity_absolute*1e-1,  ...
                        "LineWidth", 1, "Color",ColorMap(80,:));

        %vectortext(ax, world2origin + local2world* ( -  parent.wind_velocity_absolute*1e-3)*0.5, ...
        %               parent_name + "  wind-velocity absolute", ...
        %               "Color", ColorMap(150,:),"LineWidth",1.5 );

    end


    %% CENTER OF MASS
    %if isfield(parent, "center_of_mass")
    %    vectorquiver(ax, world2origin + local2world* ( -  parent.wind_velocity_absolute), ... 
    %                     world2origin + local2world*      parent.wind_velocity_absolute,  ...
    %                    "AutoScale","on","LineWidth", 0.2, "Color",ColorMap(80,:));

    %    vectortext(ax, world2origin + local2world* ( -  parent.wind_velocity_absolute)*0.5, ...
    %                   parent_name + "  wind-velocity absolute", ...
    %                   "Color", ColorMap(150,:),"LineWidth",1.5 );

    




    end
    

end
end