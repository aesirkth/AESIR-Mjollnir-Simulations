function v_e = exhaust_speed(comp)
% Compute exhaust speed using de Laval nozzle formula (see Sutton, 2017, p. 52 or https://en.wikipedia.org/wiki/De_Laval_nozzle).


R = comp.R;
M = comp.molecular_weight_combustion_products;
gamma = comp.gamma_combustion_products;
P_cc = comp.engine.combustion_chamber.pressure;

v_e = sqrt((comp.T_cc * R / M) * 2 * gamma / (gamma - 1) * (1 - (comp.P_ex / P_cc)^((gamma - 1) / gamma)));
end
