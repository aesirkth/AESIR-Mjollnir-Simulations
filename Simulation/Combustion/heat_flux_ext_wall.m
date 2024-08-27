function [Qdot_ext_w,hcc] = heat_flux_ext_wall(comp)
    %This function return the flux going from the external to the wall.

    %Geometric parameters:
    D_ext = comp.D_ext_tank;
    L = comp.L_tank;
    S = pi*D_ext*L;
    e = comp.e_tank;
    K = comp.eber_parameter;
    
    %Thermal and physical parameters
    k_alu = comp.aluminium_thermal_conductivity;
    Beta_air = 1/comp.T_ext;             %thermic dilatation coefficient for a perfect gas
    
    
    %thermophysical properties of the air must be evaluated at Tfilm = (Text + Twall) / 2
    visc_dyn_air = py.CoolProp.CoolProp.PropsSI('V','P',comp.P_ext,'T', (comp.T_ext+comp.T_wall)/2,'Air'); %Dynamic viscosity
    cp_air = py.CoolProp.CoolProp.PropsSI('C','P',comp.P_ext,'T', (comp.T_ext+comp.T_wall)/2,'Air'); %Cp of air
    k_air = py.CoolProp.CoolProp.PropsSI('L','P',comp.P_ext,'T', (comp.T_ext+comp.T_wall)/2,'Air'); %Conductivity of air
    rho_air = py.CoolProp.CoolProp.PropsSI('D','P',comp.P_ext,'T', (comp.T_ext+comp.T_wall)/2,'Air'); %density of air
    
    
    if evalin("base", "static") || norm(comp.velocity) ==0
        %Natural Convection
        DeltaT=comp.T_ext-comp.T_wall;
        G_r = rho_air^2*comp.g*L^3*Beta_air*abs(DeltaT)/(visc_dyn_air^2);
        
        Nu = 0.5*G_r^(1/4);
        hcc = Nu*k_alu/L;
    
        %so...
        h = 1/(1/hcc+0.5*e/k_alu);
        Qdot_ext_w = h*S*DeltaT;
    
    else
        %Flight mode: taking into account turbulent, compressible and supersonic
        %flow (also friction)
        
        Re=norm(comp.velocity)*L*rho_air/visc_dyn_air;
        Vertex_angle=20*pi/180;%20 degrees
        hcc=(0.0071 + 0.0154*sqrt(Vertex_angle))*k_air*Re^(0.8)/L; %Eber formula for supersonic compressible flow
        
        T_st=comp.T_ext+norm(comp.velocity)^2/(2*cp_air);%stagnation temperature
        T_boundary = comp.T_ext + K*(T_st-comp.T_ext);%temperature inside the boudary layer taking into account friction
        
        %comp.T_wall_ext=fzero(@(T_unknown) Wall_ext_temp_finder(T_unknown), [0 1000]);
        h = 1/(1/hcc+0.5*e/k_alu);%global resistance
        DeltaT=T_boundary-comp.T_wall;
        Qdot_ext_w = h*S*DeltaT;
        
    %     disp("h : "+h)
    %     disp("T_boundary (K) : "+T_boundary)
    %     disp("comp.T_ext (K) : "+comp.T_ext)
    %     disp("comp.T_wall (K) : "+comp.T_wall)
    %     disp("Speed (m/s) : "+comp.v_rocket)
    end


    function [output] = Wall_ext_temp_finder(T_unknown)
    %EXTERNAL WALL TEMPERATURE FINDER by getting the zero of this function
    %http://dark.dk/documents/technical_notes/simplified%20aerodynamic%20heating%20of%20rockets.pdf
    
    sigma = comp.stephan_cst;
    epsilon = comp.aluminium_emissivity;
    
    
    output = h - (sigma*epsilon*T_unknown^4)/(T_boundary-comp.T_excomp.T_wall);
end

end
    