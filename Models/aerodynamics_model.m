function rocket = aerodynamics_model(rocket)
% This model doesn't use the center-of-pressure, it instead relies on the first, second
% third and fourth moments of area of the rockets broadsides to calculate the moment induced upon the rocket
% due to the relative wind.

if rocket.position(3) < 0; rocket.position(3) = 0; end % fix atmocoesa warning

[~,~,~, rocket.enviroment.air_density] = atmoscoesa(rocket.position(3));


rocket.aerodynamics.relative_velocity                 = rocket.aerodynamics.wind_velocity - rocket.velocity;
relative_velocity_rocket_basis                        = (rocket.attitude')*rocket.aerodynamics.relative_velocity;



parallel_velocity_magnitude     = sqrt(norm(rocket.aerodynamics.relative_velocity)^2 - relative_velocity_rocket_basis*norm(rocket.aerodynamics.relative_velocity)); % Source: I made it the hell up.



%% Forces:

lift_force = rocket.attitude*(rocket.aerodynamics.pressure_coefficient.*(rocket.aerodynamics.surface_area.*sign(relative_velocity_rocket_basis).*(relative_velocity_rocket_basis.^2))*rocket.enviroment.air_density);
drag_force = normalize(rocket.aerodynamics.relative_velocity)*sum(rocket.aerodynamics.friction_coefficient.*rocket.aerodynamics.surface_area.*parallel_velocity_magnitude.^2)*rocket.enviroment.air_density;

rocket.forces.DragForce = force(drag_force, rocket.center_of_mass);
rocket.forces.LiftForce = force(lift_force, rocket.center_of_mass);




%% Moments:
rocket.rotation_rate_rocket_basis   = (rocket.attitude')*rocket.rotation_rate;

linear_velocity_components = zeros(3,3,4);
linear_rotation_components = zeros(3,3,4);

% rotation_tensor_sign = [ 0 -1  1;
%                         -1  0 -1;
%                          1 -1  0];

rotation_rate_tensor = [ 0                                     -rocket.rotation_rate_rocket_basis(3),  rocket.rotation_rate_rocket_basis(2);
                         rocket.rotation_rate_rocket_basis(3)   0                                     -rocket.rotation_rate_rocket_basis(1);
                        -rocket.rotation_rate_rocket_basis(2)   rocket.rotation_rate_rocket_basis(1)   0                                    ];

% https://en.wikipedia.org/wiki/Angular_velocity#Tensor

linear_rotation_components(:,:,1) = rotation_rate_tensor.^0;
linear_rotation_components(:,:,2) = rotation_rate_tensor.^1;
linear_rotation_components(:,:,3) = rotation_rate_tensor.^2;
linear_rotation_components(:,:,4) = rotation_rate_tensor.^3;


relative_velocity_tensor = [0                                   relative_velocity_rocket_basis(1)   relative_velocity_rocket_basis(1);
                            relative_velocity_rocket_basis(2)   0                                   relative_velocity_rocket_basis(2);
                            relative_velocity_rocket_basis(3)   relative_velocity_rocket_basis(3)   0                                   ];


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


scaling_factor = 1./(abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*rocket.aerodynamics.length_scale').*linear_rotation_components(:,:,2)) + 1);




lift_moment_tensor = sum(linear_rotation_components.*linear_velocity_components.*linear_coefficients.*rocket.aerodynamics.moment_of_area.*scaling_factor, 3);

lift_moment_vector = [lift_moment_tensor(3,2) + lift_moment_tensor(2,3);
                      lift_moment_tensor(3,1) + lift_moment_tensor(1,3);
                      lift_moment_tensor(1,2) + lift_moment_tensor(2,1)];



rocket.moments.LiftMoment = moment(rocket.attitude*lift_moment_vector, rocket.center_of_mass);





end