clc; clear; setup;

load("render_jobs.mat", "render_jobs");
disp("working through que...")

for job_index = 1:numel(render_jobs)
if  ~render_jobs{job_index}.is_done

render_jobs{job_index} = run_rendering_job(render_jobs{job_index});

save("render_jobs.mat", "render_jobs")
    
end
end

disp("job-que empty")
delete render_jobs.mat