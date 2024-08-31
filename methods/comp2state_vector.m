function state_vector = comp2state_vector(comp, state_vector)


state_vector(1:3)   =  comp.rigid_body.position;
state_vector(4:6)   =  comp.rigid_body.velocity;
state_vector(7:9)   =  comp.rigid_body.angular_momentum;
state_vector(10:18) =  reshape(comp.rigid_body.attitude, 9,1);
state_vector(19:29) = [comp.m_ox;                  % The oxidizer mass.
                       comp.U_total;               % The total energy inside the tank.
                       comp.T_wall;                % The tank wall temperature.
                       comp.r_cc;                  % The radius of the combustion chamber.
                       comp.r_throat;              % The throat radius.
                       comp.P_cc;                  % The pressure in the combustion chamber.
                       comp.rigid_body.mass;
                       comp.h_liq;
                       comp.h_gas;
                       comp.h_air_ext;
                       comp.active_burn_flag];




end