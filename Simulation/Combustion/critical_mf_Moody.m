function [P_cc, mf_with_crit] = critical_mf_Moody(comp)
    %CRITICAL_MF_DYER Summary of this function goes here
    %   Detailed explanation goes here

    %     comp.Cd = comp.comp.Cd;                     %Discharge coefficient
    D_inj = 2 * comp.r_inj;             %Injector diameter
    n_inj = comp.n_inj;               %Number of injector holes
    Ai = n_inj * pi * D_inj^2 / 4;
    
    P_min = 8.78374e5;
    P_max = 7.245e6;
    
    h1 = py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/kg)
    %disp(h1)
    %disp(py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'T|gas', round(comp.T_tank, 2), 'NitrousOxide'))
    %disp(py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'T', round(comp.T_tank, 2), 'NitrousOxide'))
    %disp(py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'Q', 0, 'NitrousOxide'))
    %disp(py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'Q', 1, 'NitrousOxide'))
    %disp(' ')
    s1 = py.CoolProp.CoolProp.PropsSI('S', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/K.kg)
    % P_sacomp.T_tank = fnval(comp.Psat_NO2_spline,comp.T_tank)*10^6;
    
    %     disp("P_sat : "+P_sacomp.T_tank/10^5+" bars")
    Cd = comp.Cd;
    if gpuDeviceCount == 0
        P_cc = P_min:5e5:P_max;
        mf = zeros(1, length(P_cc));
        parfor i = 1:length(P_cc); mf(i) = compute_mass_flow(P_cc(i), Cd, Ai, h1, s1); end
    else
        P_cc = gpuArray(P_min:5e5:P_max);
        mf = arrayfun(@(P_cc) compute_mass_flow(P_cc, Cd, Ai, h1, s1), P_cc);
    end
    
    [mf_crit, index] = max(mf);
    mf_with_crit = mf;
    mf_with_crit(1:index) = mf_crit;
    P_cc_crit = P_cc(index);
    

    


end


function mf = compute_mass_flow(P_cc,Cd, Ai, h1, s1)

        rho2_l = py.CoolProp.CoolProp.PropsSI('D', 'P', P_cc, 'Q', 0, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
        rho2_v = py.CoolProp.CoolProp.PropsSI('D', 'P', P_cc, 'Q', 1, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
    
        hf = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'Q', 0, 'NitrousOxide');   %Enthalpie massic (J/kg)
        hg = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'Q', 1, 'NitrousOxide');   %Enthalpie massic (J/kg)
        h_fg = hg - hf;

        h2 = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc, 'S', s1, 'NitrousOxide');   %Enthalpie massic (J/kg)
        
        x2 = (h2 - hf) / h_fg;
        k = (rho2_l / rho2_v)^(1/3);
        
        if h2 <= h1
            mf = Cd * Ai * k / (x2 + k * (1 - x2) * rho2_v / rho2_l) * rho2_v * sqrt(2 * (h1 - h2) / (x2 * (k^2 - 1) + 1));
        else
            mf = 0;
        end



    end