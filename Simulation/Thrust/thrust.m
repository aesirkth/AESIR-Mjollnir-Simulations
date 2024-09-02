function F = thrust(comp)
% Compute thrust (see Sutton, 2017, p. 33).


mf_throat = comp.engine.nozzle.mass_flow;
A_ex      = comp.engine.nozzle.exit.area;
v_ex      = comp.engine.nozzle.exit.velocity;
P_ex      = comp.engine.nozzle.exit.pressure;
P_atm     = comp.enviroment.pressure;


F = mf_throat * v_ex + ( P_ex - P_atm) * A_ex;
end

