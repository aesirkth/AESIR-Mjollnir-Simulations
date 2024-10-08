clc; clear; setup;

load("render_jobs.mat", "render_jobs");
disp("working through que...")

for job_index = 1:numel(render_jobs)
if  ~render_jobs{job_index}.is_done

run_rendering_job(render_jobs{job_index})
render_jobs{job_index}.is_done = true;
save("render_jobs.mat", "render_jobs")
    
end
end

disp("job-que empty")
delete render_jobs.mat