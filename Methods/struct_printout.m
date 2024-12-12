function struct_printout(structure, only_structs)
if ~exist('only_structs', 'var'); only_structs = false; end

disp("struct with fields:")

struct_printout_internal(structure)




function struct_printout_internal(structure, stem)



children = fieldnames(structure);
num_characters = cellfun(@(child) strlength(child), children); max_characters = max(num_characters);

if ~exist("stem", "var"); stem = " "; end

for child_nr = 1:numel(children)
child = children{child_nr};

if child_nr == numel(children); if isequal(class(structure.(child)), 'struct'); branch_string = "╘"; else; branch_string = "└"; end; new_stem = stem + " " + string(repmat(' ', 1, max_characters-1));
else;                           if isequal(class(structure.(child)), 'struct'); branch_string = "╞"; else; branch_string = "├"; end; new_stem = stem + "│" + string(repmat(' ', 1, max_characters-1)); 
end

if isequal(class(structure.(child)), 'struct')
   

    disp(stem +branch_string +  string(repmat('═', 1, max_characters - num_characters(child_nr))) + "  "+ string(child))
    struct_printout_internal(structure.(child), new_stem)
elseif ~only_structs

    disp(stem +branch_string +  string(repmat('─', 1, max_characters - num_characters(child_nr))) + " "+ string(child)+":  ")

end


end

end
end