function outstruct = txt2struct(filename)

path_elements = split(filename, '\'); path = strrep(filename, path_elements(end), ''); name = strrep(path_elements(end), '.txt','');

outstruct = body();
file_cell = readcell(filename, "Delimiter", ',');
read_head = 1;
max_head  = height(file_cell);

while read_head <= max_head
pattern = string(file_cell{read_head,1});
if contains(pattern, string(name))

address = split(file_cell{read_head, 1}, '.');
is_body_address = address; is_body_address{end} = 'is_body';
if      contains(pattern, "position");  outstruct = setfield(outstruct, address{2:end}, cell2mat(file_cell(read_head+1:read_head+3,1))); outstruct = setfield(outstruct, is_body_address{2:end}, true); read_head = read_head+4;
elseif  contains(pattern, "attitude");  outstruct = setfield(outstruct, address{2:end}, cell2mat(file_cell(read_head+1:read_head+3,:))); outstruct = setfield(outstruct, is_body_address{2:end}, true); read_head = read_head+4;
elseif  contains(pattern, "mesh"    );  outstruct = setfield(outstruct, address{2:end}, path+string(file_cell{read_head+1,1}));          outstruct = setfield(outstruct, is_body_address{2:end}, true); read_head = read_head+2;
else;                                                                                                                                    read_head = read_head+1;
end

else; read_head = read_head+1;
end

end