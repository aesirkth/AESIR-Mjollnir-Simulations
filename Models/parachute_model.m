function rocket = parachute_model(rocket)

if rocket.velocity(3)<-2 &&  rocket.position(3)>500

drag_magnitude                  =           0.5*rocket.enviroment.air_density*rocket.chute.drogue.area*norm(rocket.velocity)^2*rocket.chute.drogue.coefficient; %calulate drag using Cd and reference area assigned in my_rocket
drag_direction                  =           -normalize(rocket.velocity); %direction of the force is assumed to be equal to that of the rocket's velocity
drag                            =           drag_magnitude*drag_direction;
pos                             =           [0 0 4]'; %placeholder value
rocket.forces.chute_drag        =           force(rocket.attitude*drag, pos);

elseif rocket.velocity(3)<-2 &&  rocket.position(3)<500

drag_magnitude                  =           0.5*rocket.enviroment.air_density*rocket.chute.main.area*norm(rocket.velocity)^2*rocket.chute.main.coefficient;
drag_direction                  =           -normalize(rocket.velocity);
drag                            =           drag_magnitude*drag_direction;
pos                             =           [0 0 4]';
rocket.forces.chute_drag        =          force(rocket.attitude*drag, pos);

else

pos                              =           [0 0 4]';
rocket.forces.chute_drag         =           force(rocket.attitude*eye(3,1), pos);

end