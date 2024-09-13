function comp = apply_simplified_propulsion_model(comp, t)

if t < 40
comp.forces.Thrust = force(comp.attitude(:,3)*4e3, comp.engine.nozzle.exit.position);
else
comp.forces.Thrust = force([0;0;0]               , comp.engine.nozzle.exit.position);
end