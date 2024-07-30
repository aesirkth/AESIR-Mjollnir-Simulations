function mf_ox = mass_flow_oxidizer(comp)
    %MASS_FLOW_FUEL calculates the mass flow of the fuel
    
    if strcmp(evalin("base", "model"), 'Dyer')
        [P_cc_range, mf_crit] = critical_mf_Dyer(comp);
    else
        % Use Moody by default.
        [P_cc_range, mf_crit] = critical_mf_Moody(comp);
    end
    
    mf_ox = interp1(P_cc_range, mf_crit, comp.P_cc);
end

