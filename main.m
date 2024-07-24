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
setup;

%% User settings.
run_simulation = true;       % True if the simulation should be run, if false it will load the most recent simulation.
process_data = false;        % TODO: it would be nice to integrate this more properly into the main.
data_name = "Datasets/HT-2/ht21_large.mat";

plot_data = false;           % True if the data should be plot together with the simulations.
save_plots = true;           % True if the resulting plots should be saved.
debug_plot = false;

%% Simulation settings:
quick = false;               % True if quick simulation should be done. Less accurate, but useful for tuning.
static = true;               % True if simulation should be for a static fire, otherwise it is done for flight.
full_duration = false;       % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
model = 'Moody';             % Mass flow model, one of {'Moody', 'Dyer'}. Uses Moody by default.





%% Run or load simulations.
if run_simulation
    %% Run simulations.
    initiate_mjolnir;
    simulate(mjonlir);
end
simulation = load("simulation_results.mat");

%% Data processing.
if process_data
    disp("")          %% TODO: data processing.
else
    data = load(data_name); 
    data = data.data;
end

%% Plot the simulation results.
plot_results;
