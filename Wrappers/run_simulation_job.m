function sim = run_simulation_job(job)


if job.save; load(job.name); end

if ~exist("sim", "var") || ~job.save
    sim                    = struct();
    sim.mjolnir            = job.mjolnir;
    sim.job                = job; 
    clear job
    sim.job.new_job        = false;
    sim.job.simulated      = false;
    sim.job.post_processed = false;
    if sim.job.save; save(sim.job.name, "sim"); end
    
end
  

    if sim.job.simulated == false
        %% Initialization.

        tic
        
        %% Solve differential equations.

        evalin  ("base", "loading_message = 'Simulating "+ sim.job.name +":';");
        evalin  ("base", "loading_bar = waitbar(0, loading_message);");
        assignin("base", "loading_bar_end_time", sim.job.t_max);
        sim.initial_state_vector = comp2state_vector(sim.mjolnir, zeros(31,1));
        
        % Solve ODE initial value problem.
        t_range = [0, sim.job.t_max];

        if sim.job.quick; sim.solution = ode45( @(t,state_vector) system_equations(t,state_vector,sim.mjolnir), t_range,  sim.initial_state_vector);
        else;             sim.solution = ode23t(@(t,state_vector) system_equations(t,state_vector,sim.mjolnir), t_range,  sim.initial_state_vector);
        end
        
        
        sim.simulation_time = toc;
        sim.job.simulated = true;
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        if sim.job.save; save(sim.job.name, "sim"); end
        
    end
    
    
    
    
    if sim.job.post_processed == false
        %% Post-processing:
        
        if sim.job.save; load(sim.job.name); end          
   
            evalin(  "base", "loading_message = 'Post-processing "+ sim.job.name +":';");
            evalin(  "base", "loading_bar = waitbar(0, loading_message);");
            assignin("base", "loading_bar_end_time", sim.job.t_max);
    
    
        sim.t             = sim.solution.x(  1:4:end);
        sim.state_vectors = sim.solution.y(:,1:4:end);
    
    
        [sim.mjolnir_historian, sim.mjolnir] = create_historian(sim.mjolnir,sim.t);
       
        tic
        
        for time_index = 1:numel(sim.t)
        
        sim.mjolnir_historian = record_history(sim.mjolnir, ...
                                               sim.state_vectors(:,time_index), ...
                                               sim.t(time_index), ...
                                               time_index,...
                                               sim.mjolnir_historian);
        end
    
        sim.post_processing_time = toc;
        sim.job.post_processed = true;
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        if sim.job.save; save(sim.job.name, "sim"); end
        
        
        
        
    
    end
    
    
    

end