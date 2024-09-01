function mf_ox = mass_flow_oxidizer(comp)
    %MASS_FLOW_FUEL calculates the mass flow of the fuel
    
    if strcmp(evalin("base", "model"), 'Dyer')
        [mf_crit] = critical_mf_Dyer(comp);
    else
        % Use Moody by default.
        [mf_crit] = critical_mf_Moody(comp);
    end
    
    mf_ox = interp1(comp.N2O.moody.pressure, mf_crit, comp.engine.combustion_chamber.pressure);
end

