%% This file is the main user interface.
%{
    Some notes on hyperparameter tuning:
    - Set the external temperature based on conditions during testing/launch.
    - To tune the tank pressure:
        - A higher T_tank_init tends to move the initial tank pressure up.
        - A higher Cd tends to result in a steeper slope.
    - To tune the combustion chamber pressure:
        - A higher Cd tends to move the initial combustion chamber pressure up.
        - A higher dr_thdt tends to result in a steeper slope.
    - To tune the fuel regression rate.
        - Tweak a and n.
        - This data has not been available yet, so beware that these parameters are not tuned.
%}

setup; clc; clear

job = struct();

%% User settings.
job.update_N2O             = false;                                    % True if the calculations for N2O should be re-run, normally false.
job.run_simulation         = true;                                     % True if the simulation should be run, if false it will load the most recent simulation.
job.process_data           = true;                                     % TODO: it would be nice to integrate this more properly into the main.
job.plot_data              = true;                                     % True if the data should be plot together with the simulations.
job.record_video           = false;
job.load_name              = "Datasets/test(2).mat";
job.save_name              = filename_availability(job.load_name);
job.quick                  = false;                                    % True if quick simulation should be done. Less accurate, but useful for tuning.



job.mjolnir = initiate_mjolnir;
job.t_max   = 120;                                                     % Final time.




sim         = run_simulation_job(job);


if job.plot_data
    %% Plotting:


    load(job.load_name)
    ui = configure_sim2ui(sim, job);
    index = 1;
    while exist("ui", "var")
    push_sim2ui(sim, job, ui);
    end
    if record_video; close(job.vidobj); end


end