function v_e = exhaust_speed(comp)
% Compute exhaust speed using de Laval nozzle formula (see Sutton, 2017, p. 52 or https://en.wikipedia.org/wiki/De_Laval_nozzle).


R       = comp.enviroment.R;
M       = comp.engine.gamma_combustion_products;
gamma   = comp.engine.gamma_combustion_products;
P_cc    = comp.engine.combustion_chamber.pressure;
t       = comp.engine.combustion_chamber.temperature;
P_ex    = comp.engine.nozzle.exit.pressure;

v_e = sqrt((t * R / M) * 2 * gamma / (gamma - 1) * (1 - (P_ex / P_cc)^((gamma - 1) / gamma)));
end
