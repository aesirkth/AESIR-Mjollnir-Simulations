function [comp] = apply_gravity_model(comp)


comp.rigid_body.forces.Gravity = force(comp.rigid_body.g*...
                                       comp.rigid_body.mass*[0;0;-1], ...
                                       comp.rigid_body.center_of_mass);




end