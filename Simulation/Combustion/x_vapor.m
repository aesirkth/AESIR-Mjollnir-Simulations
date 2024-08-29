function x_vapor = x_vapor(U_tot, m_tot, T, comp)
    % Compute the massic vapor ratio at each time step.

    u_liq = comp.N2O.temperature2specific_internal_energy_liquid(T);
    u_vap = comp.N2O.temperature2specific_internal_energy_vapor(T);

    % Note that the following equation equals one if and only if the specific internal energy of whatever is in the tank equals the
    % specific internal energy for vapor N2O, and zero if it equals that for liquid.
    x_vapor = ((U_tot ./ m_tot) - u_liq) ./ (u_vap - u_liq);  
end
