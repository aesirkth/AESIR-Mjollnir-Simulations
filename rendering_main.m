clc; clear; setup;

try
load("render_jobs.mat");
disp("Working through existing rendering que...")
render_job_que(render_jobs);
disp("Done.")
catch
end
disp("Creating new rendering jobs...")

base_render_job                 = struct();
base_render_job.play_on_startup = true;
base_render_job.close_on_finish = true;
base_render_job.record_video    = true;
base_render_job.overwrite       = false;
base_render_job.is_done         = false;
base_render_job.sim_name        = ""; %% Placeholder


render_jobs = {}; job_index = 1;


sim_directory = "Data/tvc_unstable_gains_trajectory/sims/";
vid_directory = strrep(sim_directory, "sims", "videos");
if ~isfolder(vid_directory); mkdir(vid_directory); end

files = struct2cell(dir(sim_directory)); files = files(1,:);



for file = files
if contains(file{1}, ".mat") && ~contains(file{1}, ".mp4")
file{1}
render_jobs{job_index} = base_render_job;
render_jobs{job_index}.sim_name = sim_directory+file{1};
render_jobs{job_index}.video_name = vid_directory + strrep(file{1}, ".mat", ".mp4");
job_index = job_index +1;
end
end

save("render_jobs.mat", "render_jobs")
disp("Done.")
disp("Woring through new rendering jobs...")
render_job_que(render_jobs)
disp("Done.")

