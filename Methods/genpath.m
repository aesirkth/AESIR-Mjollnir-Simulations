function filename = genpath(filename)

filepath = split(filename, "/");
subpath = "";
if isequal(filepath(1), "."); subpath = "."; filepath = filepath(2:end); end

for level = 1:numel(filepath)-1
subpath = subpath+"/"+filepath(level);
if ~isfolder(subpath) ;mkdir(subpath); end

end

end