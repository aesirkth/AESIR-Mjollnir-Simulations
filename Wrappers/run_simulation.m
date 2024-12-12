function [sim,job] = run_simulation(rocket, job)
%% run_simulation(rocket, (job) )
%
% Parameter             : Class                 : Default                   :   Description             
%___________________________________________________________________________________________________________________
% job                   : struct                : N/A                       :   specify how the job should be run
% job.name              : string                : "Data/test/sims/sim.mat"  :   filename to which the job progress should be saved
% job.save              : boolean               : false                     :   whether progress should be saved to a .m file
% job.load              : boolean               : false                     :   whether progress should be loaded from previous sim if file is available
% job.is_done           : boolean               : false                     :   usually false, true if job is complete. Will not run of false.
% job.ode_solver        : @ode45, @ode23t, ...  : @ode45                    :   which solver should be used for the simulation   
% job.t_max             : float                 : 80                        :   simulation end time   
%
% [NOTE!] Latest sim auto-saves to "./Data/latest_sim.mat". You have no choise in the matter, as it's no fun to run a 
% 10h+ sim and realize after the fact that you didn't turn saving on, loosing you all your work. The latest_sim file is over-
% written every time a simulation is run, it just allows you to save your sim post mortem.


setup;

if ~exist  ("job", "var");       job              = struct();                   end
if ~isfield (job, "save");       job.save         = true;                       end
if ~isfield (job, "load");       job.load         = false;                      end
if ~isfield (job, "is_done");    job.is_done      = false;                      end
if ~isfield (job, "t_max");      job.t_max        = 80;                         end   
if ~isfield (job, "ode_solver"); job.ode_solver   = @ode45;                     end
if ~isfield (job, "name");       job.name         = "Data/test/sims/sim.mat";   end



if  job.load && isfile(job.name);  load(job.name); end


if ~exist("sim", "var")


    sim = struct();
    

    %% Simulation:

    tic

    evalin  ("base", "loading_message = 'Simulating "+ job.name +":';");
    evalin  ("base", "loading_bar = waitbar(0, loading_message);");
    assignin("base", "loading_bar_end_time", job.t_max);
    disp    ("Simulating/Simulating...")
    
    initial_state_vector    = rocket2state_vector(rocket);
    [~, sim.initial_rocket] = system_equations   (0, initial_state_vector, rocket); % [NOTE!] Due to recursion-structure, the rocket gotten out of ODE is not meant to be fed back into the ODE.
    % Solve ODE initial value problem.
    t_range = [0, job.t_max];
    
    sim.solution   = job.ode_solver( @(t,state_vector) system_equations(t,state_vector,rocket), t_range,  initial_state_vector);
    sim.ode_solver = job.ode_solver;

    sim.simulation_time = toc;
    job.simulated = true;
    evalin("base","close(loading_bar)");
    evalin("base", "clear loading_bar_end_time, loading_message");
    disp    ("Simulating/Done.")






    %% Post-processing:
        
    evalin  ("base", "loading_message = 'Post-processing "+ job.name +":';");
    evalin  ("base", "loading_bar = waitbar(0, loading_message);");
    assignin("base", "loading_bar_end_time", job.t_max);
    disp    ("Simulating/Post-processing...")



    [sim.rocket_historian, rocket] = create_historian(rocket,numel(sim.solution.x));

    tic

    for index = 1:numel(sim.solution.x)

    [~, rocket]          = system_equations(sim.solution.x(:,index), sim.solution.y(:,index), rocket);
    sim.rocket_historian = record_history(rocket, sim.rocket_historian, index);
    end

    sim.post_processing_time = toc;
    sim.job = job;
    evalin("base","close(loading_bar)");
    evalin("base", "clear loading_bar_end_time, loading_message");
    disp  ("Simulating/Done.")

                 save(genpath("./Data/latest_sim.mat"), "sim", "job");
    if job.save; save(genpath(job.name),                "sim", "job"); end



end
    
job.is_done = true;
    
