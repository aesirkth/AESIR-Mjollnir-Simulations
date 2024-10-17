clc; clear; setup;



disp("Creating new jobs...")
base_render_job                 = struct();

base_render_job.play_on_startup = true;
base_render_job.close_on_finish = true;
base_render_job.record_video    = true;
base_render_job.overwrite       = false;
base_render_job.is_done         = false;
base_render_job.sim_name        = ""; %% Placeholder

try 
load("render_jobs.mat", "render_jobs");
job_index   = numel(render_jobs);
catch
render_jobs = {}; 
job_index   = 1;
end

sim_directory = uigetdir("Data", "Choose simulation-directory");
if contains(sim_directory, "sims")
vid_directory = strrep(sim_directory, "sims", "videos");
else
vid_directory = sim_directory + "/videos";
end
if ~isfolder(vid_directory); mkdir(vid_directory); end

copyfile("que_rendering_jobs.m", filename_availability(vid_directory+"/source.m")); % For traceability



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


save("render_jobs.mat", "render_jobs");

disp("Done.")
