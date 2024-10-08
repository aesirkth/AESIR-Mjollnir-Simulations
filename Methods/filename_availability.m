function name = filename_availability(name, index)

path_elements = split(name, "/");
filepath      = strrep(name, path_elements(end), "");

if ~isfolder(filepath); mkdir(filepath); end

if exist("index", "var")

name = split(name, ".");
name_filetype = name(2);
name = split(name(1), "(");
name = name(1) + "." + name_filetype; 
name = strrep(name, ".", "("+string(index)+").");

if isfile(name); delete(name); end

else

if isfile(name)
name = split(name, ".");
name_filetype = name(2);
name = split(name(1), "(");
name = name(1) + "." + name_filetype; 

        index = 1;
        name  = strrep(name, ".", "("+string(index)+")"+".");
        while   isfile(name) 
        name  = strrep(name, "("+string(index)+")"+".", "("+string(index+1)+")"+"."); 
        index = index+1;
        end
end
end

end