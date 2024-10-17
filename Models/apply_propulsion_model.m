function rocket = apply_propulsion_model(rocket, t)

if t < 10
rocket.forces.Thrust = force(rocket.attitude(:,3)*4e3, rocket.engine.nozzle.exit.position);
else
rocket.forces.Thrust = force([0;0;0]               , rocket.engine.nozzle.exit.position);
end