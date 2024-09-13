function name = filename_availability(name)
if isfile(name)

        index = 1;
        name = strrep(name, ".", "("+string(index)+")"+".");
        while isfile(name) 
        name = strrep(name, "("+string(index)+")"+".", "("+string(index+1)+")"+"."); 
        index = index+1;
        end
end


end