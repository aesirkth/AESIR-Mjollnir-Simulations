clc; clear; setup;



disp("Creating new job...")
job = struct();

%% User settings.
job.quick                  = false;                                    % True if quick simulation should be done. Less accurate, but useful for tuning.

directory = "Data/test";
if ~isfolder(directory+"/sims/"); mkdir(directory+"/sims/"); end

job.name                   = directory +"/sims/"+ "sim.mat";
job.overwrite              = true;
job.save                   = true;
job.is_done                = false;
job.mjolnir                = initiate_mjolnir;
job.t_max                  = 80;                                      % Final time.


disp("Done.")


%%

disp("Simulating...")
[job, sim] = run_simulation_job(job);
disp("Done.")

%%

render_job                 = struct();

render_job.play_on_startup = true;
render_job.close_on_finish = true;
render_job.record_video    = false;
render_job.overwrite       = true;
render_job.is_done         = false;

if ~isfolder(directory+"/videos/"); mkdir(directory+"/videos/"); end
render_job.video_name      = strrep(strrep(job.name, "/sims/", "/videos/"), ".mat", ".mp4"); 

%%

disp("Rendering...")
render_job = run_rendering_job(render_job, sim);
disp("Done.")





