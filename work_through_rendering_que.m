clc; clear; setup;

load("render_jobs.mat", "render_jobs");
disp("working through que...")

try
for job_index = 1:numel(render_jobs)
if ~isfield(render_jobs{job_index}, "is_done")
[~, render_jobs{job_index}] = render_simulation(render_jobs{job_index}.sim, render_jobs{job_index});   
elseif ~render_jobs{job_index}.is_done
[~, render_jobs{job_index}] = render_simulation(render_jobs{job_index}.sim, render_jobs{job_index});   
end
end


disp("job-que empty")
delete render_jobs.mat

catch err
disp("___________________");
disp(err.message);
arrayfun(@(stack) disp(stack.name+", Line: "+string(stack.line)), err.stack);
disp("___________________");
disp("Interrupted. Saving progress...")
save("render_jobs.mat", "render_jobs")
disp("Done.")
end
