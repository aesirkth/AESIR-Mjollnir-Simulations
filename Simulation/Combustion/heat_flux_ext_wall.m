function [Qdot_ext_w,hcc] = heat_flux_ext_wall(comp)
    %This function return the flux going from the external to the wall.

    %Geometric parameters:
    D_ext = comp.tank.diameter;
    L = comp.tank.length;
    S = pi*D_ext*L;
    e = comp.tank.thickness;
    K = comp.enviroment.eber_parameter;
    
    %Thermal and physical parameters
    k_alu = comp.tank.wall.aluminium_thermal_conductivity;
    Beta_air = 1/comp.enviroment.temperature;             %thermic dilatation coefficient for a perfect gas
    
    
    %thermophysical properties of the air must be evaluated at Tfilm = (Text + Twall) / 2
    visc_dyn_air = py.CoolProp.CoolProp.PropsSI('V','P',comp.enviroment.pressure,'T', (comp.enviroment.temperature+comp.tank.wall.temperature)/2,'Air'); %Dynamic viscosity
    cp_air       = py.CoolProp.CoolProp.PropsSI('C','P',comp.enviroment.pressure,'T', (comp.enviroment.temperature+comp.tank.wall.temperature)/2,'Air'); %Cp of air
    k_air        = py.CoolProp.CoolProp.PropsSI('L','P',comp.enviroment.pressure,'T', (comp.enviroment.temperature+comp.tank.wall.temperature)/2,'Air'); %Conductivity of air
    rho_air      = py.CoolProp.CoolProp.PropsSI('D','P',comp.enviroment.pressure,'T', (comp.enviroment.temperature+comp.tank.wall.temperature)/2,'Air'); %density of air
    
    
    if comp.static || norm(comp.velocity) ==0
        %Natural Convection
        DeltaT=comp.enviroment.temperature-comp.tank.wall.temperature;
        G_r = rho_air^2*comp.enviroment.g*L^3*Beta_air*abs(DeltaT)/(visc_dyn_air^2);
        
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
        
        T_st=comp.enviroment.temperature+norm(comp.velocity)^2/(2*cp_air);%stagnation temperature
        T_boundary = comp.enviroment.temperature + K*(T_st-comp.enviroment.temperature);%temperature inside the boudary layer taking into account friction
        
        %comp.tank.wall.temperature_ext=fzero(@(T_unknown) Wall_ext_temp_finder(T_unknown), [0 1000]);
        h = 1/(1/hcc+0.5*e/k_alu);%global resistance
        DeltaT=T_boundary-comp.tank.wall.temperature;
        Qdot_ext_w = h*S*DeltaT;
        
    %     disp("h : "+h)
    %     disp("T_boundary (K) : "+T_boundary)
    %     disp("comp.enviroment.temperature (K) : "+comp.enviroment.temperature)
    %     disp("comp.tank.wall.temperature (K) : "+comp.tank.wall.temperature)
    %     disp("Speed (m/s) : "+comp.v_rocket)
    end


    function [output] = Wall_ext_temp_finder(T_unknown)
    %EXTERNAL WALL TEMPERATURE FINDER by getting the zero of this function
    %http://dark.dk/documents/technical_notes/simplified%20aerodynamic%20heating%20of%20rockets.pdf
    
    sigma = comp.enviroment.stephan_cst;
    epsilon = comp.aluminium_emissivity;
    
    
    output = h - (sigma*epsilon*T_unknown^4)/(T_boundary-comp.T_excomp.tank.wall.temperature);
end

end
    