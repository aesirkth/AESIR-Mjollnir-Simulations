try index = evalin("base", "historian_index_finder;"); catch; index = 1; end

while historian.t(index+1) < t; index = index+1; end 
while historian.t(index  ) > t; index = index-1; end 
    
assignin("base", "historian_index_finder", index);