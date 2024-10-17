function rocket = state_vector2rocket(rocket, state_vector)
% Re-integrates the extracted state-vector into the rocketonent. Done in order
% to make the information more easily accessible for us meat-rocketuters when
% writing simulation steps and functions.

rocket.position                            =          state_vector(1:3);
rocket.velocity                            =          state_vector(4:6);
rocket.angular_momentum                    =          state_vector(7:9);
rocket.attitude                            =  reshape(state_vector(10:18), 3,3);
rocket.tank.oxidizer_mass                  =          state_vector(19);           % The oxidizer mass.
rocket.tank.internal_energy                =          state_vector(20);           % The total energy inside the tank.
rocket.tank.wall.temperature               =          state_vector(21);           % The tank wall temperature.
rocket.engine.fuel_grain.radius            =          state_vector(22);           % The radius of the combustion chamber.
rocket.engine.nozzle.throat.radius         =          state_vector(23);           % The throat radius.
rocket.engine.combustion_chamber.pressure  =          state_vector(24);           % The pressure in the combustion chamber.
rocket.mass                                =          state_vector(25);
rocket.tank.liquid.heat_flux               =          state_vector(26);
rocket.tank.vapor.heat_flux                =          state_vector(27);
rocket.tank.wall.heat_flux                 =          state_vector(28);
rocket.engine.active_burn_flag             = ceil(mod(state_vector(29), 1));
rocket.guidance.integrated_theta           =          state_vector(30:31);

end