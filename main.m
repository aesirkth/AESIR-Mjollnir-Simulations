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
run_simulation = true;                          % True if the simulation should be run, if false it will load the most recent simulation.
process_data = false;                           % TODO: it would be nice to integrate this more properly into the main.
data_name = "Datasets/HT-2/ht21_large.mat";

plot_data     = false;                          % True if the data should be plot together with the simulations.
save_plots    = true;                           % True if the resulting plots should be saved.
debug_plot    = false;

%% Simulation settings:
quick         = false;                          % True if quick simulation should be done. Less accurate, but useful for tuning.
static        = true;                           % True if simulation should be for a static fire, otherwise it is done for flight.
full_duration = false;                          % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
model         = 'Moody';                        % Mass flow model, one of {'Moody', 'Dyer'}. Uses Moody by default.





%% Run or load simulation.
if run_simulation
    %% Initialization.
    
    disp("---------------------------------")
    disp("Intitialization...") 
    disp("---------------------------------")
    disp(" ")
    
    initiate_mjolnir; % <---- [Go here to change mjolnir's parameters]
    pre_processing
    
  
    %% Set simulation time.
    t0      = 0;                  % Initial time of ignition.
    t_max   = 0.1;                % Final time.
    t_range = [t0 t_max];         % Integration interval.
    
    tic

    %% Solve differential equations.
    disp("---------------------------------")
    disp("Solving differential equations...") 
    disp("---------------------------------")
    disp(" ")
    
    % tol = odeset('RelTol',1e-5,'AbsTol',1e-6);

     initial_state_vector = comp2state_vector(mjolnir, zeros(28,1));
    
    % Solve ODE initial value problem.

    if quick; [t, state] = ode45( @(t,state_vector) system_equations(t,state_vector,mjolnir), t_range,  initial_state_vector);
    else;     [t, state] = ode23t(@(t,state_vector) system_equations(t,state_vector,mjolnir), t_range,  initial_state_vector);
    end
    
    state = state';

    disp(" ")
    disp("---------------------------------")
    disp("Done.") 
    disp("---------------------------------")
    disp(" ")
    
    toc

end

% %% Plotting:
% my_ui = ui;
% my_ui.TSlider.Limits = t_range;
% 
% if isfolder('../colorthemes/'); aesir_purple(); end
% light(my_ui.ax)
% annotation(my_ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);
% az = 45;
% index = 1; drawnow
% 
% while ui_running
% update_ui
% end
