function comp = apply_aerodynamics_model(comp)
% This model doesn't use the center-of-pressure, it instead relies on the first, second
% third and fourth moments of area of the rockets broadsides to calculate the moment induced upon the rocket
% due to the relative wind.

if comp.position(3) < 0; comp.position(3) = 0; end % fix atmocoesa warning

[comp.enviroment.temperature_COESA, comp.aerodynamics.speed_of_sound, comp.enviroment.pressure, comp.enviroment.air_density] = atmoscoesa(comp.position(3));
 comp.enviroment.temperature = comp.enviroment.temperature_COESA - comp.enviroment.dT_ext;


% Unpack fields of aerodynamics-struct and the rigid_body into workspace
variables = fieldnames(comp.aerodynamics);
for i = 1:numel(variables); eval(variables{i}+"= comp.aerodynamics."+variables{i}+";"); end
variables = fieldnames(comp);
for i = 1:numel(variables); eval(variables{i}+"= comp."  +variables{i}+";"); end


rotation_rate = (attitude*moment_of_inertia*(attitude'))\angular_momentum;


relative_velocity               = wind_velocity - velocity;
relative_velocity_comp_basis    = (attitude')*relative_velocity;



parallel_velocity_magnitude          = sqrt(norm(relative_velocity)^2 - relative_velocity_comp_basis*norm(relative_velocity)); % Source: I made it the hell up.



%% Forces:

lift_force = attitude*(pressure_coefficient.*(surface_area.*sign(relative_velocity_comp_basis).*(relative_velocity_comp_basis.^2))*air_density);
drag_force = normalize(relative_velocity)*sum(friction_coefficient.*surface_area.*parallel_velocity_magnitude.^2)*air_density;

comp.forces.DragForce = force(drag_force, center_of_mass);
comp.forces.LiftForce = force(lift_force, center_of_mass);




%% Moments:
rotation_rate_comp_basis   = (attitude')*rotation_rate;

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


relative_velocity_tensor = [0                                      relative_velocity_comp_basis(1)   relative_velocity_comp_basis(1);
                            relative_velocity_comp_basis(2)   0                                      relative_velocity_comp_basis(2);
                            relative_velocity_comp_basis(3)   relative_velocity_comp_basis(3)   0                                   ];


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


scaling_factor = 1./(abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*length_scale').*linear_rotation_components(:,:,2)) + ...
                   ((abs(linear_velocity_components(:,:,3)) + abs(([1;1;1]*length_scale').*linear_rotation_components(:,:,2))) == 0)*1000 );




lift_moment_tensor = sum(linear_rotation_components.*linear_velocity_components.*linear_coefficients.*moment_of_area.*scaling_factor, 3);

lift_moment_vector = [lift_moment_tensor(3,2) + lift_moment_tensor(2,3);
                      lift_moment_tensor(3,1) + lift_moment_tensor(1,3);
                      lift_moment_tensor(1,2) + lift_moment_tensor(2,1)];



comp.moments.LiftMoment = moment(attitude*lift_moment_vector, center_of_mass);

% comp.enviroment.air_temperature     = air_temperature;
% comp.enviroment.air_pressure        = air_pressure;
% comp.enviroment.air_density         = air_density;
comp.aerodynamics.relative_velocity = relative_velocity;
comp.rotation_rate                  = rotation_rate;




end