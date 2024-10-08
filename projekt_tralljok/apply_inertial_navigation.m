function comp = apply_inertial_navigation(comp)

variables = fieldnames(comp);
for i = 1:numel(variables); eval(variables{i}+"= comp."+variables{i}+";"); end
    
    
    
% Forces & moments
    
force_sum  = cellsum(cellfun(@(force)  forces .(force ).vec ,                                                     fieldnames(forces),  "UniformOutput",false));
moment_sum = cellsum(cellfun(@(moment) moments.(moment).vec ,                                                     fieldnames(moments), "UniformOutput",false)) + ...
             cellsum(cellfun(@(force)  cross(attitude*(forces.(force).pos - center_of_mass), forces.(force).vec), fieldnames(forces),  "UniformOutput",false));
    
    
comp.guidance.measured_acceleration         = (comp.attitude')*force_sum/comp.mass;               % In components basis
comp.guidance.measured_angular_acceleration = comp.moment_of_inertia\(comp.attitude')*moment_sum; % In components basis
comp.guidance.measured_velocity             = comp.velocity;
comp.guidance.measured_position             = comp.position;


end