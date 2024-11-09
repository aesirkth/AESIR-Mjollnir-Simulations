clc; clear; setup;



disp("Creating new jobs...")


directory = "Data/trallgok_ODE45_" + string(datetime("today")) + "/sims/";
if ~isfolder(directory); mkdir(directory); end

base_simulation_job         = struct();
base_simulation_job.name    = directory + "sim.mat";
base_simulation_job.rocket  = trallgok;


try 
load("simulation_jobs.mat", "simulation_jobs");
job_index   = numel(simulation_jobs);
catch
simulation_jobs = {}; 
job_index = 1;
end




for D_gain = 10.^(1:1:7)
    job                        = base_simulation_job;
    job.name                   = strrep(job.name, ".mat", "("+string(job_index)+").mat");
    job.rocket.guidance.D_gain = D_gain;


    simulation_jobs{job_index} =  job; job_index = job_index+1
end


save("simulation_jobs.mat", "simulation_jobs");
copyfile("simulation_jobs.mat",   filename_availability(directory+"/simulation_jobs.mat")); % For traceability
copyfile("que_simulation_jobs.m", filename_availability(directory+"/source.txt")); % For traceability

disp("Done.")
