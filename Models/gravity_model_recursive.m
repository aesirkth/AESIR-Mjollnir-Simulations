function [rocket] = gravity_model_recursive(rocket)


    rocket.forces.Gravity = force((rocket.attitude')*rocket.enviroment.g*rocket.mass_absolute*[0;0;-1], ...
                                  (rocket.attitude')*rocket.center_of_mass_absolute);
    
    
    
    
    end