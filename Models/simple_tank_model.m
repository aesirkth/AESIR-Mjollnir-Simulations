function rocket = simple_tank_model(rocket)

rocket.derivative("tank.liquid.mass") = -(rocket.tank.liquid.mass > 0)*27.0/rocket.engine.burn_time;


end