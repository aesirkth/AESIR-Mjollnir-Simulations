function historian2csv(filename, historian)

txt = "";

write_branch("", historian);


    function write_branch(trace, branch)
        for property = fieldnames(branch)
            if     isequal(class(branch.(property)), "double"); 1
            elseif isequal(class(branch.(property)), "struct"); write_branch(trace+"."+property, branch.(property));
            end
        end


    end

end