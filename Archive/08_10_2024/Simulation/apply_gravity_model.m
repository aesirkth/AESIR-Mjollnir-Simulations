function [comp] = apply_gravity_model(comp)


comp.forces.Gravity = force(comp.enviroment.g*...
                                       comp.mass*[0;0;-1], ...
                                       comp.center_of_mass);




end