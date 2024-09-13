function comp = state_vector2comp(comp, state_vector)
% Re-integrates the extracted state-vector into the component. Done in order
% to make the information more easily accessible for us meat-computers when
% writing simulation steps and functions.

comp.position                            =          state_vector(1:3);
comp.velocity                            =          state_vector(4:6);
comp.angular_momentum                    =          state_vector(7:9);
comp.attitude                            =  reshape(state_vector(10:18), 3,3);
comp.tank.oxidizer_mass                  =          state_vector(19);           % The oxidizer mass.
comp.tank.internal_energy                =          state_vector(20);           % The total energy inside the tank.
comp.tank.wall.temperature               =          state_vector(21);           % The tank wall temperature.
comp.engine.fuel_grain.radius            =          state_vector(22);           % The radius of the combustion chamber.
comp.engine.nozzle.throat.radius         =          state_vector(23);           % The throat radius.
comp.engine.combustion_chamber.pressure  =          state_vector(24);           % The pressure in the combustion chamber.
comp.mass                                =          state_vector(25);
comp.tank.liquid.heat_flux               =          state_vector(26);
comp.tank.vapor.heat_flux                =          state_vector(27);
comp.tank.wall.heat_flux                 =          state_vector(28);
comp.engine.active_burn_flag             = ceil(mod(state_vector(29), 1));
comp.guidance.integrated_theta           =          state_vector(30:31);

end