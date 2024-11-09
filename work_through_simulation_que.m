%clc; clear; setup; p = gcp('nocreate'); if isempty(p); p=parpool(8); end

load("simulation_jobs.mat", "simulation_jobs");
disp("working through que...")

try
for job_index = 1:numel(simulation_jobs)
if ~isfield(simulation_jobs{job_index}, "is_done")
[~, simulation_jobs{job_index}] = run_simulation(simulation_jobs{job_index}.rocket, simulation_jobs{job_index});   
elseif ~simulation_jobs{job_index}.is_done
[~, simulation_jobs{job_index}] = run_simulation(simulation_jobs{job_index}.rocket, simulation_jobs{job_index});   
end
end


disp("job-que empty")
delete simulation_jobs.mat

catch err
disp("___________________");
disp(err.message);
arrayfun(@(stack) disp(stack.name+", Line: "+string(stack.line)), err.stack);
disp("___________________");
disp("Interrupted. Saving progress...")
save("simulation_jobs.mat", "simulation_jobs")
disp("Done.")
end
