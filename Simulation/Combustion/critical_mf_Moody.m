function [mf_with_crit] = critical_mf_Moody(comp)
    %CRITICAL_MF_DYER Summary of this function goes here
    %   Detailed explanation goes here


    D_inj = 2 * comp.r_inj;             %Injector diameter
    n_inj = comp.n_inj;               %Number of injector holes
    Ai = n_inj * pi * D_inj^2 / 4;
    

    h1 = py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/kg)
    s1 = py.CoolProp.CoolProp.PropsSI('S', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/K.kg)


    mf = arrayfun(@(P_cc, hf, h_fg, rho2_v, rho2_l, k) ...
                    compute_mass_flow ...
                   (P_cc, hf, h_fg, rho2_v, rho2_l, k, comp.Cd, Ai, h1, s1), ...
                    comp.moody_spline.P_cc, ...
                    comp.moody_spline.hf, ...
                    comp.moody_spline.h_fg, ...
                    comp.moody_spline.rho2_v, ...
                    comp.moody_spline.rho2_l, ...
                    comp.moody_spline.k);


    [mf_crit, index] = max(mf);
    mf_with_crit = mf;
    mf_with_crit(1:index) = mf_crit;
    P_cc_crit = comp.moody_spline.P_cc(index);
    

    


end


function mf = compute_mass_flow(P_cc, hf, h_fg, rho2_v, rho2_l, k, Cd, Ai, h1, s1)


        h2 = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'S', s1, 'NitrousOxide');   %Enthalpie massic (J/kg)
        
        x2 = (h2 - hf) / h_fg;

        mf = (h2 <= h1) * Cd * Ai * k / (x2 + k * (1 - x2) * rho2_v / rho2_l) * rho2_v * sqrt(2 * (h1 - h2) / (x2 * (k^2 - 1) + 1));



end