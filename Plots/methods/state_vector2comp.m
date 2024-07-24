function comp = state_vector2comp(state_vector, comp)

comp.m_ox_init        = state_vector(19);
comp.U_total_init     = state_vector(20);
comp.opts.T_wall_init = state_vector(21);
comp.r_cc_init        = state_vector(22);
comp.r_throat_init    = state_vector(23);
comp.opts.P_cc_init   = state_vector(24);



end