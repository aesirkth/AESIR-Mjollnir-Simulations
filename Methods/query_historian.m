function instance = query_historian(instance, historian, t, t_range)
if ~exist("t_range", "var"); t_range = historian.t; end % All internal calls/recursions include t_range, way to bypass all substructs having their own t-instance.

parameter_names = fieldnames(historian);
    
        for index = 1:numel(parameter_names)
        parameter = parameter_names{index};
        if isequal(class(instance.(parameter)), 'double')
        
        instance.(parameter) = reshape(...
                                       makima(...
                                              t_range, ...        
                                              historian.(parameter), ...
                                              t ...
                                              ), ...
                                       height(instance.(parameter)),...
                                       []);
        
        elseif isequal(class(instance.(parameter)), 'struct')
        if      isfield(instance, 'dont_record') == 0
        instance.(parameter) = query_historian(instance.(parameter), historian.(parameter), t, t_range);
        elseif sum(matches(instance.dont_record, parameter)) == 0
        instance.(parameter) = query_historian(instance.(parameter), historian.(parameter), t, t_range);
        end
        end
    
        end
    
    end
    