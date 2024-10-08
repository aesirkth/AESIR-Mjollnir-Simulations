function comp = component()
% Properties center_of_mass and moment_of_inertia are described in terms of
% component-centric coordinates. Properties attitude, position, velocity,
% forces, moments, angular_momentum are described in global coordinates. 
% Attitude is a matrix with the component-centric vectors as it's columns, 
% can be used as a base-change matrix from component-centric coordinates to 
% global coordinates: [x' y' z'].


%% Component-centric coordinates
comp = struct();
comp.is_collideable = true;
comp.mass = 1;
comp.center_of_mass     = zeros(3,1);
comp.center_of_pressure = zeros(3,1);
%comp.relative_position = zeros(3,1);
comp.moment_of_inertia  = eye(3);


%% Global coordinates
comp.attitude             = eye(3); % [x';y';z'] -> [x;y;z]
comp.dimensions           = [1;1;1];
comp.angular_momentum     = zeros(3,1);
comp.rotation_rate        = zeros(3,1);
comp.position             = zeros(3,1);
comp.velocity             = zeros(3,1);
comp.forces               = dictionary(" ",  force([0;0;0], [0;0;0]));
comp.moments              = dictionary(" ", moment([0;0;0], [0;0;0]));
comp.area                 = ones(3,1);
comp.pressure_coefficient = eye(3)*0.2;
%comp.pressure_coefficient = @pressure_coefficient_1;
comp.friction_coefficient = ones(3,1)*0.2;
comp.relative_velocity   = zeros(3,1);

comp.is_colliding  = false;
end