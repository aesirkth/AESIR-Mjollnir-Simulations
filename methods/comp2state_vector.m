function state_vector = comp2state_vector(comp, state_vector)


state_vector(1:3)   =  comp.position;
state_vector(4:6)   =  comp.velocity;
state_vector(7:9)   =  comp.angular_momentum;
state_vector(10:18) =  reshape(comp.attitude, 9,1);
state_vector(19:32) = [comp.m_ox_init;             % The oxidizer mass.
                       comp.U_total_init;          % The total energy inside the tank.
                       comp.opts.T_wall_init;      % The tank wall temperature.
                       comp.r_cc_init;             % The radius of the combustion chamber.
                       comp.r_throat_init;         % The throat radius.
                       comp.opts.P_cc_init;        % The pressure in the combustion chamber.
                       comp.x;                     % The position on the x-axis (m).
                       comp.y;                     % The position on the y-axis (m).
                       comp.dxdt;                  % The velocity along the x-axis (m/s).
                       comp.dydt;                  % The velocity along the y-axis (m/s).
                       comp.m_tot;
                       comp.h_liq;
                       comp.h_gas;
                       comp.h_air_ext];




end