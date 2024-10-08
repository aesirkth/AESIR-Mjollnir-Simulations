function [d2xdt2, d2ydt2] = eq_of_motion(comp)


    %EQOFMOTION Summarcomp.y of this function goes here
    %   Detailed explanation goes here
    
    
    v=sqrt(comp.dxdt.^2+ comp.dydt.^2);
    m = comp.dry_mass+comp.m_ox+comp.m_fuel;
    angle = comp.launch_angle;
    Cd = drag_coefficient_model(v, comp.speed_of_sound);
    frontal_area = comp.surface;
    
    D= Cd .* 0.5 .* comp.rho_ext .* v.^2 .* frontal_area;
    
    g=gravity_model(comp.y);
    
    
    if evalin("base", "static") %static fire
        d2xdt2 = 0;
        d2ydt2 = 0;
    else %flight condition
        if v<10 || comp.y<0
            Dx = 0;
            Dy = 0;
            comp.Fx = comp.F.*cosd(angle);
            comp.Fy = comp.F.*sind(angle);
        else
            Dx = D.*comp.dxdt./v;
            Dy = D.*comp.dydt./v;
            comp.Fx = comp.F.*comp.dxdt./v;
            comp.Fy = comp.F.*comp.dydt./v;
        end
    
        d2xdt2=(comp.Fx-Dx)./m;
        d2ydt2=-g+(comp.Fcomp.y-Dy)./m;
        
        %     disp("Drag (N) : "+D)
        %     disp("Dx : "+Dx)
        %     disp("Dcomp.y : "+Dcomp.y)  
        %     disp("Thrust (N) : "+comp.F)
        %     disp("a_x (g) : "+d2xdt2./g)
        %     disp("a_comp.y (g) : "+d2comp.ydt2./g)  
    end
end
