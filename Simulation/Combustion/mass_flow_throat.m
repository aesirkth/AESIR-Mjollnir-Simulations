function m_dot_th = mass_flow_throat(comp)
%m_dot_th calculates the mass flow of that goes through the throat

c_star = interp1q(comp.OF_set, comp.c_star_set, comp.OF);

m_dot_th = comp.engine.combustion_chamber.pressure*comp.A_t/c_star;

end

