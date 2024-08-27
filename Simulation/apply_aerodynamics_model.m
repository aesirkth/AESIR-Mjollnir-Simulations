function comp = apply_aerodynamics_model(comp)
% This model doesn't use the center-of-pressure, it instead relies on the first, second
% third and fourth moments of area of the rockets broadsides to calculate the moment induced upon the rocket
% due to the relative wind.

if comp.position(3) < 0; comp.position(3) = 0; end % fix atmocoesa warning

[~,~,~,comp.air_density]             = atmoscoesa(comp.position(3));

comp.relative_velocity               = comp.wind_velocity - comp.velocity;
comp.relative_velocity_comp_basis    = (comp.attitude')*comp.relative_velocity;



parallel_velocity_magnitude          = sqrt(norm(comp.relative_velocity)^2 - comp.relative_velocity_comp_basis*norm(comp.relative_velocity)); % Source: I made it the hell up.



%% Forces:

lift_force = comp.attitude*(comp.pressure_coefficient.*(comp.area.*sign(comp.relative_velocity_comp_basis).*(comp.relative_velocity_comp_basis.^2))*comp.air_density);
drag_force = normalize(comp.relative_velocity)*sum(comp.friction_coefficient.*comp.area.*parallel_velocity_magnitude.^2)*comp.air_density;

comp.forces.DragForce = force(drag_force, comp.center_of_mass);
comp.forces.LiftForce = force(lift_force, comp.center_of_mass);




%% Moments:
rotation_rate_comp_basis   = (comp.attitude')*comp.rotation_rate;

linear_velocity_components = zeros(3,3,4);
linear_rotation_components = zeros(3,3,4);

% rotation_tensor_sign = [ 0 -1  1;
%                         -1  0 -1;
%                          1 -1  0];

rotation_rate_tensor = [ 0                           -rotation_rate_comp_basis(3),  rotation_rate_comp_basis(2);
                        rotation_rate_comp_basis(3)   0                            -rotation_rate_comp_basis(1);
                       -rotation_rate_comp_basis(2)   rotation_rate_comp_basis(1)   0                          ];

% https://en.wikipedia.org/wiki/Angular_velocity#Tensor

linear_rotation_components(:,:,1) = rotation_rate_tensor.^0;
linear_rotation_components(:,:,2) = rotation_rate_tensor.^1;
linear_rotation_components(:,:,3) = rotation_rate_tensor.^2;
linear_rotation_components(:,:,4) = rotation_rate_tensor.^3;


relative_velocity_tensor = [0                                      comp.relative_velocity_comp_basis(1)   comp.relative_velocity_comp_basis(1);
                            comp.relative_velocity_comp_basis(2)   0                                      comp.relative_velocity_comp_basis(2);
                            comp.relative_velocity_comp_basis(3)   comp.relative_velocity_comp_basis(3)   0                                   ];


linear_velocity_components(:,:,1) =  relative_velocity_tensor.^3;
linear_velocity_components(:,:,2) =  relative_velocity_tensor.^2;
linear_velocity_components(:,:,3) =  relative_velocity_tensor.^1;
linear_velocity_components(:,:,4) =  relative_velocity_tensor.^0;

force_cross_tensor  = [ 0 -1  1;
                        1  0 -1;
                       -1  1  0];

linear_coefficients        =    zeros(3,3,4);
linear_coefficients(:,:,1) =    force_cross_tensor;
linear_coefficients(:,:,2) = -3*force_cross_tensor;
linear_coefficients(:,:,3) =  3*force_cross_tensor;
linear_coefficients(:,:,4) = -1*force_cross_tensor;


scaling_factor = 1./(abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*comp.length_scale').*linear_rotation_components(:,:,2)) + ...
                   ((abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*comp.length_scale').*linear_rotation_components(:,:,2))) == 0)*1000 );




lift_moment_tensor = sum(linear_rotation_components.*linear_velocity_components.*linear_coefficients.*comp.moment_of_area.*scaling_factor, 3);

lift_moment_vector = [lift_moment_tensor(3,2) + lift_moment_tensor(2,3);
                      lift_moment_tensor(3,1) + lift_moment_tensor(1,3);
                      lift_moment_tensor(1,2) + lift_moment_tensor(2,1)];



comp.moments.LiftMoment = moment(comp.attitude*lift_moment_vector, comp.center_of_mass);








end