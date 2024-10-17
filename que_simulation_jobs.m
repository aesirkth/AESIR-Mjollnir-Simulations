clc; clear; setup;



disp("Creating new jobs...")
base_simulation_job = struct();

%% User settings.
base_simulation_job.quick                  = false;                                    % True if quick simulation should be done. Less accurate, but useful for tuning.

directory = "Data/tralljok" + string(datetime("today")) + "/sims/";
if ~isfolder(directory); mkdir(directory); end

base_simulation_job.name                   = directory + "sim.mat";
base_simulation_job.overwrite              = true;
base_simulation_job.save                   = true;
base_simulation_job.is_done                = false;



base_simulation_job.rocket                = tralljok;


base_simulation_job.t_max                  = 80;                                      % Final time.


copyfile("que_simulation_jobs.m", filename_availability(directory+"/source.m")); % For traceability


try 
load("simulation_jobs.mat", "simulation_jobs");
job_index   = numel(simulation_jobs);
catch
simulation_jobs = {}; 
job_index   = 1;
end



for I_gain = 10.^(1:1:7)
    for D_gain = 10.^(1:1:7)
        job = base_simulation_job;
        job.rocket.guidance.I_gain = I_gain;
        job.rocket.guidance.D_gain = D_gain;

        
        job.name = strrep(job.name, ".mat", "("+string(job_index)+").mat");
  

        
        simulation_jobs{job_index} =  job;
        job_index = job_index+1
    end
end

save("simulation_jobs.mat", "simulation_jobs");

disp("Done.")
