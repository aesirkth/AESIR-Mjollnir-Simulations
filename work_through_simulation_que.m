clc; clear; setup;

load("simulation_jobs.mat", "simulation_jobs");
disp("working through que...")

for job_index = 1:numel(simulation_jobs)
if ~simulation_jobs{job_index}.is_done

run_simulation_job(simulation_jobs{job_index});    
simulation_jobs{job_index}.is_done = true;
save("simulation_jobs.mat", "simulation_jobs")

end
end

disp("job-que empty")
delete simulation_jobs.mat