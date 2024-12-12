function varname = filename2varname(filename)

filename = strrep(filename, ".m", "");
filename = strrep(filename, " ", "");
filename = strrep(filename, "/", "");
filename = strrep(filename, "\", "");
filename = strrep(filename, ".", "");
filename = strrep(filename, "(", "");
filename = strrep(filename, ")", "");
filename = strrep(filename, ":", "");
filename = strrep(filename, "-", "");


filename = char(filename);
if numel(filename) > 60; filename = filename(end-60:end); end
filename = string(filename);
varname = filename;
end