function [rocket] = gravity_model(rocket)


rocket.forces.Gravity = force(rocket.enviroment.g*...
                                       rocket.mass*[0;0;-1], ...
                                       rocket.center_of_mass);




end