function [mass] = sum_masses(parent)

    if     isequal(class(parent), 'struct');  mass = sum(structfun(@sum_masses, parent));
    if     isfield(parent, "mass");           mass = mass + parent.mass;
    end
    
    else;                                     mass = 0;
    end

end