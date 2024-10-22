clc; clear; setup;



disp("Creating new jobs...")
base_simulation_job = struct();

base_simulation_job.quick                  = true;                                    % True if quick simulation should be done. Less accurate, but useful for tuning.

directory = "Data/trallgok_ODE45_" + string(datetime("today")) + "/sims/";
if ~isfolder(directory); mkdir(directory); end

base_simulation_job.name                   = directory + "sim.mat";
base_simulation_job.overwrite              = true;
base_simulation_job.save                   = true;
base_simulation_job.is_done                = false;



base_simulation_job.rocket                = tralljok;


base_simulation_job.t_max                  = 80;                                      % Final time.



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
copyfile("simulation_jobs.mat",   filename_availability(directory+"/simulation_jobs.mat")); % For traceability
copyfile("que_simulation_jobs.m", filename_availability(directory+"/source.txt")); % For traceability

disp("Done.")
