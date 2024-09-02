function m_dot_fuel = mass_flow_fuel(comp)
    % Calculate fuel mass flow (see Sutton, 2017, p. 606).
    
    rho_fuel = comp.engine.fuel_grain.density;
    L = comp.engine.fuel_grain.length;
    r_dot = comp.engine.fuel_grain.a*(comp.tank.G_o.^comp.engine.fuel_grain.n);
    
    Sin_amp = comp.engine.combustion_chamber.SinusShapeAmplitude;
    C8 = comp.engine.combustion_chamber.InitialPerimeter;
    Rinit=comp.engine.fuel_grain.radius_init;
    coeff = 1+(C8/(2*pi*Rinit) - 1)*exp(sqrt(6/Sin_amp)*(Rinit-comp.engine.combustion_chamber.radius)*2/Rinit);
    
    m_dot_fuel = rho_fuel*2*pi*comp.engine.combustion_chamber.radius*r_dot*L*coeff;
end

