function P_ex = exhaust_pressure(comp)
% Compute the exhaust pressure (see Sutton, 2017, p. 49).


gamma = comp.engine.gamma_combustion_products;
P_cc = comp.engine.combustion_chamber.pressure;

if P_cc == comp.enviroment.pressure
    P_ex = comp.enviroment.pressure;
else
    mach = comp.engine.nozzle.exit.mach;
    P_ex = P_cc * (1 + (gamma - 1) * mach^2 / 2)^(gamma / (1 - gamma));
end
end

