function [rocket] = gravity_model(rocket)


rocket.forces.Gravity = force((rocket.attitude')*rocket.enviroment.g*...
                                       rocket.mass*[0;0;-1], ...
                                       rocket.rigid_body.center_of_mass);




end