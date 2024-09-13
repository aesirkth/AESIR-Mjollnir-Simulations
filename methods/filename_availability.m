function name = filename_availability(name)
if isfile(name)
name = split(name, ")");
name_filetype = name(2);
name = split(name(1), "(");
name = name(1) + name_filetype; 

        index = 1;
        name = strrep(name, ".", "("+string(index)+")"+".");
        while isfile(name) 
        name = strrep(name, "("+string(index)+")"+".", "("+string(index+1)+")"+"."); 
        index = index+1;
        end
end


end