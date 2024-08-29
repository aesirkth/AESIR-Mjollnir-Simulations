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
setup; clc

%% User settings.
update_N2O             = false;                 % True if the calculations for N2O should be re-run.
run_simulation         = true;                  % True if the simulation should be run, if false it will load the most recent simulation.
process_data           = true;                  % TODO: it would be nice to integrate this more properly into the main.
plot_data              = false;                   % True if the data should be plot together with the simulations.
data_name              = "Datasets/test7.mat";


save_plots             = false;                  % True if the resulting plots should be saved.
debug_plot             = false;

%% Simulation settings:
quick                  = false;                 % True if quick simulation should be done. Less accurate, but useful for tuning.
static                 = false;                 % True if simulation should be for a static fire, otherwise it is done for flight.
full_duration          = true;                  % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
model                  = 'Moody';               % Mass flow model, one of {'Moody', 'Dyer'}. Uses Moody by default.










%% Run or load simulation.
if run_simulation
    %% Initialization.

    if isfile(data_name); warning("File name already exists, file will be overwritten upon simulation completion."); end

    initiate_terrain;
    mjolnir = initiate_mjolnir; % <---- [Go here to change mjolnir's parameters]
    %pre_processing
    


    %% Set simulation time.
    t0      = 0;                  % Initial time of ignition.
    t_max   = 80;                 % Final time.
    t_range = t0:0.01:t_max;         % Integration interval.
    
    tic
    
    %% Solve differential equations.

    % tol = odeset('RelTol',1e-5,'AbsTol',1e-6);
    opts = odeset("Refine",10);
    loading_message = "Simulating " + data_name + ":";
    loading_bar = waitbar(0, loading_message);
    initial_state_vector = comp2state_vector(mjolnir, zeros(28,1));
    
    % Solve ODE initial value problem.
    
    if quick; solution = ode45( @(t,state_vector) system_equations(t,state_vector,mjolnir), t_range,  initial_state_vector, opts);
    else;     solution = ode23t(@(t,state_vector) system_equations(t,state_vector,mjolnir), t_range,  initial_state_vector, opts);
    end
    
    
    simulation_time = toc;
    waitbar(1,loading_bar,  "Done! Elapsed simulation time: " +string(simulation_time)+" s");
    close(loading_bar);
    save(data_name)
    
end




if process_data
%% Post-processing:
    
    load(data_name)
    
    if isfile(data_name); warning("File name already exists, file will be overwritten upon simulation completion."); end

    loading_message = "Post-processing " + data_name + ":";
    loading_bar = waitbar(0, loading_message);


    t     = solution.x(  1:3:end);
    state = solution.y(:,1:3:end);



    [mjolnir_historian, mjolnir] = create_historian(mjolnir,t);
   
    tic
    
    for time_index = 1:numel(t)
    
    mjolnir_historian = record_history(mjolnir, ...
                                       state(:,time_index), ...
                                       t(time_index), ...
                                       time_index,...
                                       mjolnir_historian);
    end

    post_processing_time = toc;
    waitbar(1,loading_bar,  "Done! Elapsed post-processing time: " +string(post_processing_time)+" s");
    close(loading_bar)
    save(data_name)
    
    
    
    

end




if plot_data
    %% Plotting:
    
    load(data_name)
    initiate_terrain
    initiate_ui
    
    while ui_running
    update_ui
    end


end



%{
Test-data
Flight-instrument
%}