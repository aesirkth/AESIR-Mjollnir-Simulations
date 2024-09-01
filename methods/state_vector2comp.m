function comp = state_vector2comp(comp, state_vector)
% Re-integrates the extracted state-vector into the component. Done in order
% to make the information more easily accessible for us meat-computers when
% writing simulation steps and functions.

comp.rigid_body.position                 =          state_vector(1:3);
comp.rigid_body.velocity                 =          state_vector(4:6);
comp.rigid_body.angular_momentum         =          state_vector(7:9);
comp.rigid_body.attitude                 =  reshape(state_vector(10:18), 3,3);
comp.m_ox                                =          state_vector(19);           % The oxidizer mass.
comp.U_tank_total                        =          state_vector(20);           % The total energy inside the tank.
comp.T_tank_wall                         =          state_vector(21);           % The tank wall temperature.
comp.r_cc                                =          state_vector(22);           % The radius of the combustion chamber.
comp.r_throat                            =          state_vector(23);           % The throat radius.
comp.engine.combustion_chamber.pressure  =          state_vector(24);           % The pressure in the combustion chamber.
comp.rigid_body.mass                     =          state_vector(25);
comp.h_liq                               =          state_vector(26);
comp.h_gas                               =          state_vector(27);
comp.h_air_ext                           =          state_vector(28);
comp.active_burn_flag                    = ceil(mod(state_vector(29), 1));

end