function [comp, state_vector_derivative] = apply_thrust_vectoring(comp, state_vector_derivative, t)
 
%% Finding desired heading based on trajectory
if comp.guidance.update_desired_direction
    
trajectory_distance = @(point) norm(comp.position - comp.guidance.trajectory(point) );

try     comp.guidance.closest_index = evalin("base", "closest_index_guess");
catch;  comp.guidance.closest_index = 100;
end

stepsize = 1;
comp.guidance.closest_point_finder_steps = 0;
%% Find minima
while true

comp.guidance.closest_point_finder_steps = comp.guidance.closest_point_finder_steps + 1;

trajectory_distance_current = trajectory_distance(comp.guidance.closest_index);
trajectory_distance_fwd     = trajectory_distance(comp.guidance.closest_index + stepsize);
trajectory_distance_bwd     = trajectory_distance(comp.guidance.closest_index - stepsize);


if     trajectory_distance_current < trajectory_distance_fwd && ...
       trajectory_distance_current < trajectory_distance_bwd;           stepsize      = stepsize*0.5;

elseif trajectory_distance_current < trajectory_distance_fwd && ...
       trajectory_distance_current > trajectory_distance_bwd;           comp.guidance.closest_index = comp.guidance.closest_index - stepsize;

elseif trajectory_distance_current > trajectory_distance_fwd && ...
       trajectory_distance_current < trajectory_distance_bwd;           comp.guidance.closest_index = comp.guidance.closest_index + stepsize;

else;                                                                   comp.guidance.closest_index = comp.guidance.closest_index - stepsize;
end


if  stepsize < 0.001 || trajectory_distance_current == 0; break; end

end


comp.guidance.closest_point = comp.guidance.trajectory(comp.guidance.closest_index);

assignin("base", "closest_index_guess", comp.guidance.closest_index)
aim_distance = (trajectory_distance_current+10) / sind(comp.guidance.aimpoint_angle);

try     comp.guidance.aim_index = evalin("base", "aim_index_guess");
catch;  comp.guidance.aim_index = comp.guidance.closest_index;
end

stepsize = 1;
comp.guidance.aim_finder_steps = 0;
increment = false;
at_local_optima = false;

while true

comp.guidance.aim_finder_steps = comp.guidance.aim_finder_steps + 1;

aim_distance_current = trajectory_distance(comp.guidance.aim_index);
aim_distance_fwd     = trajectory_distance(comp.guidance.aim_index + stepsize);
aim_distance_bwd     = trajectory_distance(comp.guidance.aim_index - stepsize);

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
                   comp.guidance.aim_index > comp.guidance.closest_index;

too_coarse = (abs(aim_distance_current - aim_distance) < abs(aim_distance_fwd - aim_distance) && ...
              abs(aim_distance_current - aim_distance) < abs(aim_distance_bwd - aim_distance) );

if           too_coarse; stepsize                = stepsize*0.25;
elseif  at_local_optima; stepsize                = stepsize*0.5;
elseif        increment; comp.guidance.aim_index = comp.guidance.aim_index + stepsize;
elseif       ~increment; comp.guidance.aim_index = comp.guidance.aim_index - stepsize;
end


if stepsize < 0.001 && ~too_coarse; break; end

end





assignin("base", "aim_index_guess", comp.guidance.aim_index)




comp.guidance.aim_point = comp.guidance.trajectory(comp.guidance.aim_index);

comp.guidance.desired_direction = comp.guidance.aim_point - comp.guidance.measured_position;
comp.guidance.desired_direction = comp.guidance.desired_direction/norm(comp.guidance.desired_direction);

%desired_direction = comp.guidance.desired_direction

end



%% Thrust-vectoring:

%if 5 < t 
%comp.guidance.desired_direction = roty(-45)*[0;0;1];
%end

% Euler-angles, ewww
theta_asin_argument_x = -dot(comp.guidance.desired_direction, comp.attitude(:,2));
theta_asin_argument_y =  dot(comp.guidance.desired_direction, comp.attitude(:,1));


comp.guidance.theta_x = asin(theta_asin_argument_x*(-1                    <  theta_asin_argument_x && ...
                                                    theta_asin_argument_x <   1                   ) + ...
                                                 1*( 1                    <= theta_asin_argument_x) + ...
                                                -1*(theta_asin_argument_x <= -1                   ));
comp.guidance.theta_y = asin(theta_asin_argument_y*(-1                    <  theta_asin_argument_y  && ...
                                                    theta_asin_argument_y <   1                   ) + ...
                                                 1*( 1                    <= theta_asin_argument_y) + ...
                                                -1*(theta_asin_argument_y <= -1                   ));



omega = (comp.attitude')*comp.rotation_rate;

comp.guidance.omega_x = omega(1);
comp.guidance.omega_y = omega(2);

P_gain_x = - (comp.guidance.D_gain^2)/(4*comp.moment_of_inertia(1,1));
P_gain_y = - (comp.guidance.D_gain^2)/(4*comp.moment_of_inertia(2,2));

%% Main PID-controller
comp.guidance.desired_moment_x = P_gain_x*comp.guidance.theta_x - comp.guidance.I_gain*comp.guidance.integrated_theta(1) + comp.guidance.D_gain*comp.guidance.omega_x;
comp.guidance.desired_moment_y = P_gain_y*comp.guidance.theta_y - comp.guidance.I_gain*comp.guidance.integrated_theta(2) + comp.guidance.D_gain*comp.guidance.omega_y;

comp.guidance.desired_moment = [comp.guidance.desired_moment_x;
                                comp.guidance.desired_moment_y;
                                0];


%  Note, in the precense of memory, this will be calculated differently as the guidance-
%  computer will keep track of the previously applied thrust-vectoring moment
modelled_moment = comp.moment_of_inertia*comp.guidance.measured_angular_acceleration; 

comp.guidance.thrust_moment = (comp.guidance.desired_moment - modelled_moment).*[1;1;1];

thrust_moment_direction =       comp.guidance.thrust_moment/ ...
                           norm(comp.guidance.thrust_moment);

if 0 < norm(comp.forces.Thrust.vec) 

moment_arm            = (comp.engine.nozzle.exit.position - comp.center_of_mass);
moment_arm_direction  = moment_arm/norm(moment_arm);
moment_arm_complement =      cross(moment_arm_direction, thrust_moment_direction)/ ...
                        norm(cross(moment_arm_direction, thrust_moment_direction));


alpha_asin_argument = dot(comp.guidance.thrust_moment, thrust_moment_direction) / ...
                      ( norm(moment_arm)* norm(comp.forces.Thrust.vec));

alpha_lim = comp.guidance.control_athority*2*pi/360;

alpha = asin( alpha_asin_argument*(-1                  <  alpha_asin_argument && ...
                                   alpha_asin_argument <   1                 ) + ...
              1                  *( 1                  <= alpha_asin_argument) + ...
             -1                  *(alpha_asin_argument <= -1                 ));

alpha =       alpha    *(-alpha_lim <   alpha && ...
                          alpha     <   alpha_lim) + ...
              alpha_lim*( alpha_lim <=  alpha    ) + ...
             -alpha_lim*( alpha     <= -alpha_lim);

comp.guidance.alpha = alpha*360/(2*pi);

thrust_force_direction = moment_arm_complement*sin(alpha) + ...
                         moment_arm_direction *cos(alpha)*(-1);
                         

comp.forces.Thrust = force(comp.attitude*thrust_force_direction*norm(comp.forces.Thrust.vec), ...
                           comp.engine.nozzle.exit.position);



else

comp.forces.Thrust = force([0;0;0], ...
                           comp.engine.nozzle.exit.position);


end


state_vector_derivative(30:31) = [comp.guidance.theta_x;comp.guidance.theta_y];
