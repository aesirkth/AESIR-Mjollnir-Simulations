function struct2txt(filename, historian, times)

if exist("times", "var"); historian = query_historian(historian, historian, times); end


write_branches("rocket", historian);


    function write_branches(trace, branches)
        branch_names = fieldnames(branches);
        for branch_index = 1:numel(branch_names)
            branch_name = branch_names{branch_index};
            if     isequal(class(branches.(branch_name)), "double"); writematrix(trace+"."+branch_name, filename, "delimiter", ",", 'WriteMode','append'); writematrix(branches.(branch_name),filename, "delimiter", ",", 'WriteMode','append');
            elseif isequal(class(branches.(branch_name)), "struct"); writematrix(trace+"."+branch_name, filename, "delimiter", ",", 'WriteMode','append'); write_branches(trace+"."+branch_name, branches.(branch_name));
            end
        end


    end

end