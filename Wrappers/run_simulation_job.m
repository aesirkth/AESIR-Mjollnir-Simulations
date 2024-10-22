function [job, sim] = run_simulation_job(job)
setup;

if  job.save && isfile(job.name) && ~job.overwrite; load(job.name); end


if ~exist("sim", "var")
    sim                    = struct();
    sim.rocket             = job.rocket;
    job.simulated          = false;
    job.post_processed     = false;
    if job.save; save(job.name, "sim", "job"); end
    
end
  

    if job.simulated == false
        %% Initialization.

        tic
        
        %% Solve differential equations.

        evalin  ("base", "loading_message = 'Simulating "+ job.name +":';");
        evalin  ("base", "loading_bar = waitbar(0, loading_message);");
        assignin("base", "loading_bar_end_time", job.t_max);
        sim.initial_state_vector = rocket2state_vector(sim.rocket, zeros(31,1));
        
        % Solve ODE initial value problem.
        t_range = [0, job.t_max];

        if job.quick; sim.solution = ode45( @(t,state_vector) system_equations(t,state_vector,sim.rocket), t_range,  sim.initial_state_vector);
        else;         sim.solution = ode23t(@(t,state_vector) system_equations(t,state_vector,sim.rocket), t_range,  sim.initial_state_vector);
        end
        
        
        sim.simulation_time = toc;
        job.simulated = true;
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        if job.save; save(job.name, "sim", "job"); end
        
    end
    
    
    
    
    if job.post_processed == false
        %% Post-processing:
        
        if job.save; load(job.name); end          
   
            evalin(  "base", "loading_message = 'Post-processing "+ job.name +":';");
            evalin(  "base", "loading_bar = waitbar(0, loading_message);");
            assignin("base", "loading_bar_end_time", job.t_max);
    
    
        sim.t             = sim.solution.x(  1:4:end);
        sim.state_vectors = sim.solution.y(:,1:4:end);
    
    
        [sim.rocket_historian, sim.rocket] = create_historian(sim.rocket,numel(sim.t));
       
        tic
        
        for time_index = 1:numel(sim.t)
        
        sim.rocket_historian = record_history(sim.rocket, ...
                                              sim.state_vectors(:,time_index), ...
                                              sim.t(time_index), ...
                                              time_index,...
                                              sim.rocket_historian);
        end
    
        sim.post_processing_time = toc;
        job.post_processed = true;
        sim.job = job;
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        if job.save; save(job.name, "sim", "job"); end
        
        
        
        
    
    end
    
job.is_done = true;
    
