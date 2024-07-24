function state_vector = comp2state_vector(state_vector, comp)

state_vector(19:24) = [comp.m_ox_init; 
                       comp.U_total_init; 
                       comp.opts.T_wall_init; 
                       comp.r_cc_init; 
                       comp.r_throat_init; 
                       comp.opts.P_cc_init];





end