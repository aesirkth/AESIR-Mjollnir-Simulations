
% my_ui = ui;
% initiate_mjolnir

parameter_names = fieldnames(mjolnir);


for parameter_index = 1:numel(parameter_names)
parameter_name = parameter_names{parameter_index};

uilabel(my_ui.MjolnirparametersPanel, "Text",parameter_name+": ", "Position", [10,  100*parameter_index, 100,20])
uieditfield(my_ui.MjolnirparametersPanel, "numeric"             , "Position", [120, 100*parameter_index, 100,20])
drawnow
end

