function rocket = equations_of_motion_recursive(rocket)
    % computing the motion of the rocket.
    

    % Pre-recursion:
    rocket.attitude = orthonormalize(rocket.attitude);
    


    rocket.wind_velocity_absolute = rocket.enviroment.wind_velocity - rocket.velocity;
    
    rocket.rotation_rate = (rocket.attitude*rocket.rigid_body.moment_of_inertia*(rocket.attitude'))\rocket.angular_momentum; 
    
    rotation_rate_tensor = [  0                       -rocket.rotation_rate(3)        rocket.rotation_rate(2);
                              rocket.rotation_rate(3)  0                             -rocket.rotation_rate(1);
                             -rocket.rotation_rate(2)  rocket.rotation_rate(1)        0                      ];
    
    
    
    % Recursion:
    rocket = equations_of_motion_recursor(rocket);



    
    % Post-recursion:
    force_sum  = rocket.attitude*rocket.force_absolute.vec;
    moment_sum = rocket.attitude*(rocket.moment_absolute.vec) + cross(rocket.attitude*rocket.force_absolute.pos - rocket.center_of_mass_absolute, rocket.attitude*rocket.force_absolute.vec);
    

    rocket.derivative("position") = rocket.velocity;
    rocket.derivative("velocity") = force_sum/rocket.mass_absolute;
    
    
    attitude_derivative = rotation_rate_tensor*rocket.attitude;
    
    
    rocket.derivative("angular_momentum")   = moment_sum;
    rocket.derivative("attitude")           = attitude_derivative;
    
    










    function [component] = equations_of_motion_recursor(component)
        % Pre-recursion:

    if isfield(component, 'is_body')
    if component.is_body

        if ~isfield(component,         'center_of_mass'            ); component.center_of_mass              = zeros(3,1)                            ; end
        if ~isfield(component,         'mass'                      ); component.mass                        = 0                                     ; end
        if ~isfield(component,         'wind_velocity_absolute'    ); component.wind_velocity_absolute      = zeros(3,1)                            ; end
        if ~isfield(component,         'rotation_rate'             ); component.rotation_rate               = zeros(3,1)                            ; end       
        if ~isfield(component,         'rotation_rate_absolute'    ); component.rotation_rate_absolute      = component.rotation_rate               ; end        
        if ~isfield(component,         'forces'                    ); component.forces                      = struct('Null',force( [0;0;0],[0;0;0])); end
        if ~isfield(component,         'moments'                   ); component.moments                     = struct('Null',moment([0;0;0],[0;0;0])); end


        component.center_of_mass_absolute = component.center_of_mass;
        component.mass_absolute           = component.mass;
        component.force_absolute          = force (cellsum(cellfun( @(force)       component.forces .(force ).vec                                 , fieldnames(component.forces ), 'UniformOutput', false)), [0;0;0]);
        component.moment_absolute         = moment(cellsum(cellfun( @(moment)      component.moments.(moment).vec                                 , fieldnames(component.moments), 'UniformOutput', false)) + ...
                                                   cellsum(cellfun( @(force) cross(component.forces .(force ).pos, component.forces.(force ).vec) , fieldnames(component.forces ), 'UniformOutput', false)), [0;0;0]);




        % recursion:

        children = fieldnames(component);

        for child_index = 1:numel(children)
        
        child = children{child_index};
        if isequal(class(component.(child)), 'struct') && ...
                 (isequal(child, 'forces'         )+ ...
                  isequal(child, 'moments'        )+ ...
                  isequal(child, 'force_absolute' )+ ...
                  isequal(child, 'moment_absolute')) == 0
        if isfield(component.(child), 'is_body')
        if component.(child).is_body



        if ~isfield(component.(child), 'rotation_rate'             ); component.(child).rotation_rate       = zeros(3,1)                            ; end
        if ~isfield(component.(child), 'position'                  ); component.(child).position            = zeros(3,1)                            ; end
        if ~isfield(component.(child), 'attitude'                  ); component.(child).attitude            = eye(3)                                ; end
        if ~isfield(component.(child), 'forces'                    ); component.(child).forces              = struct('Null',force( [0;0;0],[0;0;0])); end
        if ~isfield(component.(child), 'moments'                   ); component.(child).moments             = struct('Null',moment([0;0;0],[0;0;0])); end
    
        %% Parent to child communication:
        % Going from parent to child, since the parent properties are in the grandparents basis,
        % and the properties under child are in the parents basis, it means that the base change needs to be from grandparent to parent,
        % i.e multiplication with the parents attitude-matrix inverse, ie component.attitude'
        
        component.(child).rotation_rate_absolute    = (component.attitude')*component.rotation_rate_absolute + component.(child).rotation_rate;
        component.(child).wind_velocity_absolute    = (component.attitude')*component.wind_velocity_absolute - cross((component.attitude')*component.rotation_rate_absolute, component.(child).position);




        component.(child) = equations_of_motion_recursor(component.(child));



        %% Child to parent communication:
        % Going from child to parent, since all the childs properties are in the parents basis, and need to be in grandparents basis,
        % the base change becomes the parents attitude-matrix, ie component.attitude

        component.center_of_mass_absolute = (component.center_of_mass_absolute*component.mass_absolute + component.attitude*component.(child).center_of_mass*component.(child).mass)/ ...
                                                                             ((component.mass_absolute +                                                     component.(child).mass) + ...
                                                                             ((component.mass_absolute +                                                     component.(child).mass) == 0)*10);

        component.mass_absolute           =                                    component.mass_absolute +                                                     component.(child).mass;

        component.force_absolute          = force( component.force_absolute .vec + component.(child).attitude*component.(child).force_absolute .vec, ...
                                                   [0;0;0]);
        component.moment_absolute         = moment(component.moment_absolute.vec + component.(child).attitude*component.(child).moment_absolute.vec + cross(component.(child).position, component.(child).attitude*component.(child).force_absolute.vec), ...
                                                   [0;0;0]);

        end
        end
        end
        end

    end
    end
    
    end
end