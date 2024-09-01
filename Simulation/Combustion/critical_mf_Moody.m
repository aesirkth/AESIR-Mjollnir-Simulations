function [mf_with_crit] = critical_mf_Moody(comp)
    %CRITICAL_MF_DYER Summary of this function goes here
    %   Detailed explanation goes here

    % Unpack fields of moody-struct into workspace
    variables = fieldnames(comp.N2O.moody);
    for i = 1:numel(variables); eval(variables{i}+"= comp.N2O.moody."+variables{i}+";"); end

    
    %% Ingoing parameters:
    
    Ai = comp.engine.injectors.total_area; % total injector area
    

    h1 = py.CoolProp.CoolProp.PropsSI('H', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   % Enthalpie massic (J/kg)
    s1 = py.CoolProp.CoolProp.PropsSI('S', 'P', round(comp.P_tank, 2), 'T|liquid', round(comp.T_tank, 2), 'NitrousOxide');   % Entropy massic (J/K*kg)
    
    %h1 = h1_fun(comp.P_tank, comp.T_tank);
    %s1 = s1_fun(comp.P_tank, comp.T_tank);
    h2 = comp.N2O.pressure_massic_entropy2massic_enthalpy(          comp.N2O.moody.pressure, ...
                                                          ones(size(comp.N2O.moody.pressure))*s1);
    
    hf    = massic_enthalpy_liquid;
    h_fg  = massic_enthalpy_combined;
    rho_l = density_liquid;
    rho_v = density_vapor;


    %% Equations:

     x2 = (h2 - hf) ./ h_fg; 
     mf = (h2 <= h1) .* comp.Cd .* Ai .* k ./ (x2 + k .* (1 - x2) .* rho_v ./ rho_l) .* ...
                        rho_v .* sqrt(2 .* (h1 - h2) ./ (x2 .* (k.^2 - 1) + 1));

    
     
   [mf_crit, index] = max(mf);
    mf_with_crit = mf;
    mf_with_crit(1:index) = mf_crit;
    P_cc_crit = pressure(index);
    

    


end

