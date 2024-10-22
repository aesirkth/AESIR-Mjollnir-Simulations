clc; clear; setup; parpool(8);

load("simulation_jobs.mat", "simulation_jobs");
disp("working through que...")

try
parfor job_index = 1:numel(simulation_jobs)
if ~simulation_jobs{job_index}.is_done
simulation_jobs{job_index} = run_simulation_job(simulation_jobs{job_index});   

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
