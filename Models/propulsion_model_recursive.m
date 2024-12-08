function rocket = propulsion_model_recursive(rocket)


if rocket.t < rocket.engine.burn_time; rocket.engine.nozzle.forces.Thrust = force([0;0;1]*4e3, [0;0;0]);
else;                                  rocket.engine.nozzle.forces.Thrust = force([0;0;0],     [0;0;0]);
end