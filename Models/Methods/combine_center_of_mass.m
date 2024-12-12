function [my_center_of_mass, my_mass] = combine_center_of_mass(parent, parent_base, origin_to_parent)

    if ~exist("parent_base",      "var");      parent_base  = eye(3);        end
    if ~exist("origin_to_parent", "var");  origin_to_parent = zeros(3,1);    end

    if isfield(parent, "mass");           parent_mass           = parent.mass;           else; parent_mass           = 0;          end
    if isfield(parent, "center_of_mass"); parent_center_of_mass = parent.center_of_mass; else; parent_center_of_mass = zeros(3,1); end    
    %if isfield(parent, "position");       parent_position       = parent.position;       else; parent_position       = zeros(3,1); end
    if isfield(parent, "attitude");       parent_attitude       = parent.attitude;       else; parent_attitude       = eye(3);     end



    my_mass           = parent_mass;
    my_center_of_mass = origin_to_parent + parent_base*parent_center_of_mass;



    children = fieldnames(parent);   
    child_base = parent_attitude*parent_base;
    for child_index = 1:numel(children)
        child = children{child_index};

        if isequal(class(parent.(child)), 'struct')
            if isfield(parent.(child), "position"); origin_to_child = origin_to_parent + parent_base*parent.(child).position; else; origin_to_child = origin_to_parent; end
            [new_center_of_mass, new_mass] = combine_center_of_mass(parent.(child), child_base, origin_to_child);

            my_center_of_mass = (my_center_of_mass*my_mass + new_center_of_mass*new_mass )/(my_mass + new_mass + ((my_mass + new_mass) == 0));
                      my_mass =                    my_mass +                    new_mass;

        end
    end
    

        



end