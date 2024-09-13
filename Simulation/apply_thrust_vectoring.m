function [comp, state_vector_derivative] = apply_thrust_vectoring(comp, state_vector_derivative, t)
 

%if 5 < t 
%comp.guidance.desired_direction = roty(-45)*[0;0;1];
%end

% Euler-angles, ewww
theta_asin_argument_x = -dot(comp.guidance.desired_direction, comp.attitude(:,2));
theta_asin_argument_y =  dot(comp.guidance.desired_direction, comp.attitude(:,1));


comp.guidance.theta_x = asin(theta_asin_argument_x*(-1 < theta_asin_argument_x && theta_asin_argument_x < 1) + ...
                             1*(1  <= theta_asin_argument_x) + ...
                            -1*(theta_asin_argument_x <= -1));
comp.guidance.theta_y = asin(theta_asin_argument_y*(-1 < theta_asin_argument_y && theta_asin_argument_y < 1) + ...
                             1*(1  <= theta_asin_argument_y) + ...
                            -1*(theta_asin_argument_y <= -1));



omega = (comp.attitude')*comp.rotation_rate;

comp.guidance.omega_x = omega(1);
comp.guidance.omega_y = omega(2);

P_gain_x = - (comp.guidance.D_gain^2)/(4*comp.moment_of_inertia(1,1));
P_gain_y = - (comp.guidance.D_gain^2)/(4*comp.moment_of_inertia(2,2));


comp.guidance.desired_moment_x = P_gain_x*comp.guidance.theta_x - comp.guidance.I_gain*comp.guidance.integrated_theta(1) + comp.guidance.D_gain*comp.guidance.omega_x;
comp.guidance.desired_moment_y = P_gain_y*comp.guidance.theta_y - comp.guidance.I_gain*comp.guidance.integrated_theta(2) + comp.guidance.D_gain*comp.guidance.omega_y;

comp.guidance.desired_moment = [comp.guidance.desired_moment_x;
                                comp.guidance.desired_moment_y;
                                0];


%  Note, in the precense of memory, this will be calculated differently as the guidance-
%  computer will keep track of the previously applied thrust-vectoring moment
modelled_moment = comp.moment_of_inertia*comp.guidance.measured_angular_acceleration; 

comp.guidance.thrust_moment = comp.guidance.desired_moment - modelled_moment;

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

alpha = asin( alpha_asin_argument*(-1 < alpha_asin_argument && alpha_asin_argument < 1) + ...
              1                  *(1                   <= alpha_asin_argument) + ...
             -1                  *(alpha_asin_argument <= -1                 ));

alpha =       alpha    *(-alpha_lim < alpha && alpha < alpha_lim) + ...
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
