function varname = filename2varname(filename)

filename = strrep(filename, ".m", "");
filename = strrep(filename, " ", "");
filename = strrep(filename, "/", "");
filename = strrep(filename, "\", "");
filename = strrep(filename, ".", "");
filename = strrep(filename, "(", "");
filename = strrep(filename, ")", "");
varname = filename;
end