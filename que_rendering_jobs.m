clc; clear; setup;


disp("Creating new jobs...")
base_render_job                 = struct();
base_render_job.close_on_finish = true;
base_render_job.play_on_startup = true;
base_render_job.record_video    = true;


try 
load("render_jobs.mat", "render_jobs");
job_index   = numel(render_jobs);
catch
render_jobs = {}; 
job_index   = 1;
end

sim_directory = "Data\trallgok_ODE45_24-Oct-2024\sims";%uigetdir("Data", "Choose simulation-directory");

if contains(sim_directory, "sims"); vid_directory = strrep(sim_directory, "sims", "videos"); gif_directory = strrep(sim_directory, "sims", "gifs");
else;                               vid_directory = sim_directory + "\videos";               gif_directory = sim_directory + "\gifs";
end



if ~isfolder(vid_directory) && base_render_job.record_video; mkdir(vid_directory); end
if ~isfolder(gif_directory) && base_render_job.record_gif;   mkdir(gif_directory); end


files = struct2cell(dir(sim_directory)); files = files(1,:);



for file = files
if contains(file{1}, ".mat") && ~contains(file{1}, ".mp4") && ~contains(file{1}, ".gif") 
file{1}
render_jobs{job_index} = base_render_job;
render_jobs{job_index}.sim_name = string(sim_directory)+"\"+string(file{1});
render_jobs{job_index}.video_name = vid_directory +"\"+ strrep(file{1}, ".mat", ".mp4");
render_jobs{job_index}.gif_name   = gif_directory +"\"+ strrep(file{1}, ".mat", ".gif");
job_index = job_index +1;
end
end


save("render_jobs.mat", "render_jobs");
if base_render_job.record_video
copyfile("que_rendering_jobs.m", filename_availability(vid_directory+"\source.txt")); % For traceability
copyfile("render_jobs.mat",      filename_availability(vid_directory+"\render_jobs.mat"));
end
if base_render_job.record_gif
copyfile("que_rendering_jobs.m", filename_availability(gif_directory+"\source.txt")); % For traceability
copyfile("render_jobs.mat",      filename_availability(gif_directory+"\render_jobs.mat"));
end

disp("Done.")
