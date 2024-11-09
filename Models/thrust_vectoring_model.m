function rocket = thrust_vectoring_model(rocket)
 
%% Finding desired heading based on trajectory
if rocket.guidance.update_desired_direction
    
trajectory_distance = @(point) norm(rocket.position - rocket.guidance.trajectory(point) );

try     rocket.guidance.closest_index = evalin("base", "closest_index_guess");
catch;  rocket.guidance.closest_index = 100;
end

stepsize = 1;
rocket.guidance.closest_point_finder_steps = 0;
%% Find minima
while true

rocket.guidance.closest_point_finder_steps = rocket.guidance.closest_point_finder_steps + 1;

trajectory_distance_current = trajectory_distance(rocket.guidance.closest_index);
trajectory_distance_fwd     = trajectory_distance(rocket.guidance.closest_index + stepsize);
trajectory_distance_bwd     = trajectory_distance(rocket.guidance.closest_index - stepsize);


if     trajectory_distance_current < trajectory_distance_fwd && ...
       trajectory_distance_current < trajectory_distance_bwd;           stepsize      = stepsize*0.5;

elseif trajectory_distance_current < trajectory_distance_fwd && ...
       trajectory_distance_current > trajectory_distance_bwd;           rocket.guidance.closest_index = rocket.guidance.closest_index - stepsize;

elseif trajectory_distance_current > trajectory_distance_fwd && ...
       trajectory_distance_current < trajectory_distance_bwd;           rocket.guidance.closest_index = rocket.guidance.closest_index + stepsize;

else;                                                                   rocket.guidance.closest_index = rocket.guidance.closest_index - stepsize;
end


if  stepsize < 0.001 || trajectory_distance_current == 0; break; end

end


rocket.guidance.closest_point = rocket.guidance.trajectory(rocket.guidance.closest_index);

assignin("base", "closest_index_guess", rocket.guidance.closest_index)
aim_distance = (trajectory_distance_current+10) / sind(rocket.guidance.aimpoint_angle);

try     rocket.guidance.aim_index = evalin("base", "aim_index_guess");
catch;  rocket.guidance.aim_index = rocket.guidance.closest_index;
end

stepsize = 1;
rocket.guidance.aim_finder_steps = 0;


while true

rocket.guidance.aim_finder_steps = rocket.guidance.aim_finder_steps + 1;

aim_distance_current = trajectory_distance(rocket.guidance.aim_index);
aim_distance_fwd     = trajectory_distance(rocket.guidance.aim_index + stepsize);
aim_distance_bwd     = trajectory_distance(rocket.guidance.aim_index - stepsize);

%if t > 1.06
%    increment = increment
%    at_local_optima = at_local_optima

%aim_distance = aim_distance
%aim_distance_current = aim_distance_current
%aim_distance_fwd = aim_distance_fwd
%aim_distance_bwd = aim_distance_bwd    

%end



if      aim_distance_current < aim_distance && aim_distance_bwd < aim_distance_fwd; increment = true;
elseif  aim_distance_current > aim_distance && aim_distance_bwd < aim_distance_fwd; increment = false;
elseif  aim_distance_current < aim_distance && aim_distance_bwd > aim_distance_fwd; increment = true;
elseif  aim_distance_current > aim_distance && aim_distance_bwd > aim_distance_fwd; increment = true;
else;   break;
end

at_local_optima =(aim_distance_bwd < aim_distance && aim_distance < aim_distance_fwd) && ...
                   rocket.guidance.aim_index > rocket.guidance.closest_index;

too_coarse = (abs(aim_distance_current - aim_distance) < abs(aim_distance_fwd - aim_distance) && ...
              abs(aim_distance_current - aim_distance) < abs(aim_distance_bwd - aim_distance) );

if           too_coarse; stepsize                = stepsize*0.25;
elseif  at_local_optima; stepsize                = stepsize*0.5;
elseif        increment; rocket.guidance.aim_index = rocket.guidance.aim_index + stepsize;
elseif       ~increment; rocket.guidance.aim_index = rocket.guidance.aim_index - stepsize;
end


if stepsize < 0.001 && ~too_coarse; break; end

end





assignin("base", "aim_index_guess", rocket.guidance.aim_index)




rocket.guidance.aim_point = rocket.guidance.trajectory(rocket.guidance.aim_index);

rocket.guidance.desired_direction = rocket.guidance.aim_point - rocket.guidance.measured_position;
rocket.guidance.desired_direction = rocket.guidance.desired_direction/norm(rocket.guidance.desired_direction);

%desired_direction = rocket.guidance.desired_direction

end



%% Thrust-vectoring:

%if 5 < t 
%rocket.guidance.desired_direction = roty(-45)*[0;0;1];
%end

% Euler-angles, ewww yucky
theta_asin_argument_x = - dot(rocket.guidance.desired_direction, rocket.attitude(:,2));
theta_asin_argument_y =   dot(rocket.guidance.desired_direction, rocket.attitude(:,1));


rocket.guidance.theta_x = asin(theta_asin_argument_x*(-1                     <   theta_asin_argument_x  && ...
                                                       theta_asin_argument_x <   1                     ) + ...
                                                   1*( 1                     <=  theta_asin_argument_x ) + ...
                                                  -1*( theta_asin_argument_x <= -1                     ));
rocket.guidance.theta_y = asin(theta_asin_argument_y*(-1                     <   theta_asin_argument_y  && ...
                                                       theta_asin_argument_y <   1                     ) + ...
                                                   1*( 1                     <=  theta_asin_argument_y ) + ...
                                                  -1*( theta_asin_argument_y <= -1                     ));

rocket.guidance.theta = [rocket.guidance.theta_x; rocket.guidance.theta_y];

rocket.guidance.omega = (rocket.attitude')*rocket.rotation_rate; rocket.guidance.omega = rocket.guidance.omega(1:2);

rocket.guidance.omega_x = rocket.guidance.omega(1);
rocket.guidance.omega_y = rocket.guidance.omega(2);
%rocket.guidance.integraged_theta_x = rocket.guidance.integrated_theta(1);
%rocket.guidance.integraged_theta_y = rocket.guidance.integrated_theta(2);

P_gain = zeros(2,1);
P_gain(1) = rocket.guidance.P_gain_offset*(rocket.guidance.D_gain^2)/(4*rocket.moment_of_inertia(1,1));
P_gain(2) = rocket.guidance.P_gain_offset*(rocket.guidance.D_gain^2)/(4*rocket.moment_of_inertia(2,2));

%% Main PID-controller
%rocket.guidance.desired_moment_x = - P_gain_x*rocket.guidance.theta(1) + rocket.guidance.D_gain*rocket.guidance.omega(1) - rocket.guidance.I_gain*rocket.guidance.integrated_theta(1);
%rocket.guidance.desired_moment_y = - P_gain_y*rocket.guidance.theta(2) + rocket.guidance.D_gain*rocket.guidance.omega(2) - rocket.guidance.I_gain*rocket.guidance.integrated_theta(2);

rocket.guidance.desired_moment = zeros(3,1);
rocket.guidance.P_term = rocket.guidance.P_error.*(abs(rocket.guidance.P_error ) > abs(rocket.guidance.theta  )) + ...
                         rocket.guidance.theta  .*(abs(rocket.guidance.theta   ) > abs(rocket.guidance.P_error));
rocket.guidance.D_term = rocket.guidance.D_error.*(abs(rocket.guidance.D_error ) > abs(rocket.guidance.omega  )) + ...
                         rocket.guidance.theta  .*(abs(rocket.guidance.omega   ) > abs(rocket.guidance.D_error));

rocket.guidance.desired_moment(1) = -rocket.guidance.P_term(1)*P_gain(1)*rocket.guidance.P_gain_offset + rocket.guidance.D_gain*rocket.guidance.D_term(1);
rocket.guidance.desired_moment(2) = -rocket.guidance.P_term(2)*P_gain(2)*rocket.guidance.P_gain_offset + rocket.guidance.D_gain*rocket.guidance.D_term(2);


%  Note, in the precense of memory, this will be calculated differently as the guidance-
%  computer will keep track of the previously applied thrust-vectoring moment
modelled_moment = rocket.moment_of_inertia*rocket.guidance.measured_angular_acceleration; 

rocket.guidance.thrust_moment = (rocket.guidance.desired_moment - modelled_moment).*[1;1;1];

if norm(rocket.guidance.thrust_moment) ~= 0 && 0 < norm(rocket.forces.Thrust.vec) 

thrust_moment_direction =       rocket.guidance.thrust_moment/ ...
                           norm(rocket.guidance.thrust_moment);


moment_arm            = (rocket.engine.position+rocket.engine.attitude*rocket.engine.nozzle.position - rocket.center_of_mass);
moment_arm_direction  = moment_arm/norm(moment_arm);
moment_arm_complement =      cross(moment_arm_direction, thrust_moment_direction)/ ...
                        norm(cross(moment_arm_direction, thrust_moment_direction));


alpha_asin_argument = dot(rocket.guidance.thrust_moment, thrust_moment_direction) / ...
                      ( norm(moment_arm)* norm(rocket.forces.Thrust.vec));

alpha_lim = rocket.guidance.control_athority*2*pi/360;

alpha = asin( alpha_asin_argument*(-1                   <   alpha_asin_argument && ...
                                    alpha_asin_argument <   1                  ) + ...
              1                  *( 1                   <=  alpha_asin_argument) + ...
             -1                  *( alpha_asin_argument <= -1                  ));

alpha =       alpha    *(-alpha_lim <   alpha && ...
                          alpha     <   alpha_lim) + ...
              alpha_lim*( alpha_lim <=  alpha    ) + ...
             -alpha_lim*( alpha     <= -alpha_lim);

rocket.guidance.alpha = alpha*360/(2*pi);

nozzle_direction = moment_arm_complement*sin(alpha) + ...
                   moment_arm_direction *cos(alpha)*(-1);
                         

rocket.engine.nozzle.attitude = vector2orthonormal_basis(nozzle_direction, rocket.attitude(:,2));

else

rocket.engine.nozzle.attitude = eye(3);

end

rocket.forces.Thrust = force(rocket.attitude*rocket.engine.attitude*rocket.engine.nozzle.attitude*[0;0;1]*norm(rocket.forces.Thrust.vec), ...
                             rocket.engine.position + rocket.engine.attitude*rocket.engine.nozzle.position);

%I_sensitivity_weighting = @(theta) (2/sqrt(pi))*exp(-(theta/rocket.guidance.I_sensitivity_region).^2).*theta; % https://www.desmos.com/calculator/dmsb0mwpgu

%rocket.derivative("guidance.integrated_theta") = I_sensitivity_weighting([rocket.guidance.theta_x;rocket.guidance.theta_y]) - rocket.guidance.integrated_theta*rocket.guidance.I_dieoff;

rocket.derivative("guidance.P_error") = rocket.guidance.theta     *rocket.guidance.dieoff - rocket.guidance.P_error*rocket.guidance.dieoff;
rocket.derivative("guidance.D_error") = rocket.guidance.omega(1:2)*rocket.guidance.dieoff - rocket.guidance.D_error*rocket.guidance.dieoff;

rocket.guidance.P_error_x = rocket.guidance.P_error(1);
rocket.guidance.P_error_y = rocket.guidance.P_error(2);
rocket.guidance.D_error_x = rocket.guidance.D_error(1);
rocket.guidance.D_error_y = rocket.guidance.D_error(2);
