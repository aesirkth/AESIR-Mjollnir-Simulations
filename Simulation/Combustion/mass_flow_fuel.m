function m_dot_fuel = mass_flow_fuel(comp)
    % Calculate fuel mass flow (see Sutton, 2017, p. 606).
    
    rho_fuel = comp.rho_fuel;
    L = comp.L_fuel;
    r_dot = comp.a*(comp.G_o.^comp.n);
    
    Sin_amp = comp.CombustionChamberSinusShapeAmplitude;
    C8 = comp.CombustionChamberInitialPerimeter;
    Rinit=comp.r_fuel_init;
    coeff = 1+(C8/(2*pi*Rinit) - 1)*exp(sqrt(6/Sin_amp)*(Rinit-comp.r_cc)*2/Rinit);
    
    m_dot_fuel = rho_fuel*2*pi*comp.r_cc*r_dot*L*coeff;
end

