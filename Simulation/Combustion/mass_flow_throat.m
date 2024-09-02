function m_dot_th = mass_flow_throat(comp)
%m_dot_th calculates the mass flow of that goes through the throat

c_star = interp1q(comp.engine.OF_set, comp.engine.c_star_set, comp.engine.OF);

m_dot_th = comp.engine.combustion_chamber.pressure*comp.engine.nozzle.throat.area/c_star;

end

