function state_vector = comp2state_vector(comp, state_vector)


state_vector(1:3)   =  comp.position;
state_vector(4:6)   =  comp.velocity;
state_vector(7:9)   =  comp.angular_momentum;
state_vector(10:18) =  reshape(comp.attitude, 9,1);
state_vector(19:29) = [comp.tank.oxidizer_mass;                                                % The oxidizer mass.
                       comp.tank.internal_energy;                                             % The total energy inside the tank.
                       comp.tank.wall.temperature;                                              % The tank wall temperature.
                       comp.engine.fuel_grain.radius;                                                % The radius of the combustion chamber.
                       comp.engine.nozzle.throat.radius;                                            % The throat radius.
                       comp.engine.combustion_chamber.pressure;                  % The pressure in the combustion chamber.
                       comp.mass;
                       comp.tank.liquid.heat_flux;
                       comp.tank.vapor.heat_flux;
                       comp.tank.wall.heat_flux;
                       comp.engine.active_burn_flag]
state_vector(30:31) = comp.guidance.integrated_theta;




end