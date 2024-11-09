function rocket = propulsion_model(rocket)

if rocket.t < rocket.engine.burn_time; rocket.forces.Thrust = force(rocket.engine.attitude*rocket.engine.nozzle.attitude*[0;0;1]*4e3, ...
                                                                    rocket.engine.position + rocket.engine.attitude*rocket.engine.nozzle.position);
else;                                  rocket.forces.Thrust = force(rocket.engine.attitude*rocket.engine.nozzle.attitude*[0;0;1]*0  , ...
                                                                    rocket.engine.position + rocket.engine.attitude*rocket.engine.nozzle.position);
end