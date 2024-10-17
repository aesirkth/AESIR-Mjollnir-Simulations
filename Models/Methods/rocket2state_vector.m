function state_vector = rocket2state_vector(rocket, state_vector)


state_vector(1:3)   =  rocket.position;
state_vector(4:6)   =  rocket.velocity;
state_vector(7:9)   =  rocket.angular_momentum;
state_vector(10:18) =  reshape(rocket.attitude, 9,1);
state_vector(19:29) = [rocket.tank.oxidizer_mass;                                                % The oxidizer mass.
                       rocket.tank.internal_energy;                                             % The total energy inside the tank.
                       rocket.tank.wall.temperature;                                              % The tank wall temperature.
                       rocket.engine.fuel_grain.radius;                                                % The radius of the combustion chamber.
                       rocket.engine.nozzle.throat.radius;                                            % The throat radius.
                       rocket.engine.combustion_chamber.pressure;                  % The pressure in the combustion chamber.
                       rocket.mass;
                       rocket.tank.liquid.heat_flux;
                       rocket.tank.vapor.heat_flux;
                       rocket.tank.wall.heat_flux;
                       rocket.engine.active_burn_flag];
state_vector(30:31) =  rocket.guidance.integrated_theta;




end