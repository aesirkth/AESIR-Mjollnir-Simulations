function rocket = aerodynamics_model_recursive(rocket)
% This model doesn't use the center-of-pressure, it instead relies on the first, second
% third and fourth moments of area of the components broadsides to calculate the moment induced upon the component
% due to the relative wind.
    
if rocket.position(3) < 0; rocket.position(3) = 0; end % fix atmocoesa warning
    
[~,~,~, air_density] = atmoscoesa(rocket.position(3));
rocket.enviroment.air_density = air_density;


rocket = aerodynamics_model_internal(rocket);


    




function [component] = aerodynamics_model_internal(component)

    if isfield(component, 'is_body')
    if component.is_body

    children = fieldnames(component);

    for child_index = 1:numel(children)
    child = children{child_index};
    if isequal(class(component.(child)), 'struct'); component.(child) = aerodynamics_model_internal(component.(child)); end
    end



    if isfield(component, 'aerodynamics')

    component.aerodynamics.wind_velocity_absolute    = (component.attitude')*component.wind_velocity_absolute;
    

    parallel_velocity_magnitude     = sqrt(norm(component.wind_velocity_absolute)^2 - component.aerodynamics.wind_velocity_absolute*norm(component.wind_velocity_absolute)); % Source: I made it the hell up.
    
    
    
    %% Drag:
    
   
    drag_force = normalize(component.wind_velocity_absolute)*sum(component.aerodynamics.friction_coefficient.*component.aerodynamics.surface_area.*parallel_velocity_magnitude.^2)*air_density;
    
    component.forces.DragForce = force((component.attitude')*drag_force, [0;0;0]);
   
    
    
    
    
    %% Lift:
    component.rotation_rate_component_basis   = (component.attitude')*component.rotation_rate_absolute;
    
    linear_velocity_components = zeros(3,3,4);
    linear_rotation_components = zeros(3,3,4);
    
    % rotation_tensor_sign = [ 0 -1  1;
    %                         -1  0 -1;
    %                          1 -1  0];
    
    rotation_rate_tensor = [ 0                                           -component.rotation_rate_component_basis(3),  component.rotation_rate_component_basis(2);
                             component.rotation_rate_component_basis(3)   0                                           -component.rotation_rate_component_basis(1);
                            -component.rotation_rate_component_basis(2)   component.rotation_rate_component_basis(1)   0                                         ];
    
    % https://en.wikipedia.org/wiki/Angular_velocity#Tensor
    
    linear_rotation_components(:,:,1) = rotation_rate_tensor.^0;
    linear_rotation_components(:,:,2) = rotation_rate_tensor.^1;
    linear_rotation_components(:,:,3) = rotation_rate_tensor.^2;
    linear_rotation_components(:,:,4) = rotation_rate_tensor.^3;
    
    
    relative_velocity_tensor = [0                                                  component.aerodynamics.wind_velocity_absolute(1)   component.aerodynamics.wind_velocity_absolute(1);
                                component.aerodynamics.wind_velocity_absolute(2)   0                                                  component.aerodynamics.wind_velocity_absolute(2);
                                component.aerodynamics.wind_velocity_absolute(3)   component.aerodynamics.wind_velocity_absolute(3)   0                                      ];
    
    
    linear_velocity_components(:,:,1) =  relative_velocity_tensor.^3;
    linear_velocity_components(:,:,2) =  relative_velocity_tensor.^2;
    linear_velocity_components(:,:,3) =  relative_velocity_tensor.^1;
    linear_velocity_components(:,:,4) =  relative_velocity_tensor.^0;
    
    crossproduct_tensor  = [ 0 -1  1;
                             1  0 -1;
                            -1  1  0];
    

    
    


    linear_coefficients        =    ones(1,1,4);
    linear_coefficients(1,1,1) =   1;
    linear_coefficients(1,1,2) =  -3;
    linear_coefficients(1,1,3) =   3;
    linear_coefficients(1,1,4) =  -1;
    
    
    scaling_factor = 1./(abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*component.aerodynamics.length_scale').*linear_rotation_components(:,:,2)) + 10);
    
    
    
    
    lift_moment_tensor = sum(linear_rotation_components.*linear_velocity_components.*linear_coefficients.*component.aerodynamics.moment_of_area(:,:,2:5).*scaling_factor, 3).*crossproduct_tensor;
    lift_force_tensor  = sum(linear_rotation_components.*linear_velocity_components.*linear_coefficients.*component.aerodynamics.moment_of_area(:,:,1:4).*scaling_factor, 3);
    
    lift_moment_vector = [lift_moment_tensor(3,2) + lift_moment_tensor(2,3);
                          lift_moment_tensor(3,1) + lift_moment_tensor(1,3);
                          lift_moment_tensor(1,2) + lift_moment_tensor(2,1)];

    lift_force_vector  = lift_force_tensor * [1;1;1];
    
    
    
    component.moments.LiftMoment = moment(lift_moment_vector, [0;0;0]);
    component.forces.LiftForce   = force (lift_force_vector,  [0;0;0]);
    
    
    end
    
    
    end

    end
end
end