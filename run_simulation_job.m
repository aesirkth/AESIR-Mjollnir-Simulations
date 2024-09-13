function sim = run_simulation_job(job)

    sim         = struct(); % Don't want to save, and then load and thus overwrite, job-options 
    sim.mjolnir = job.mjolnir;
    sim.name    = job.save_name;
    sim.job     = job;

    if isfile(job.load_name); load(job.load_name); end

    if job.run_simulation
        %% Initialization.
    
        if isfile(job.save_name); warning("File name already exists, file will be overwritten upon simulation completion."); end

        tic
        
        %% Solve differential equations.

        evalin("base", "loading_message = 'Simulating "+ job.save_name +":';");
        evalin("base", "loading_bar = waitbar(0, loading_message);");
        assignin("base", "loading_bar_end_time", job.t_max);
        sim.initial_state_vector = comp2state_vector(job.mjolnir, zeros(31,1));
        
        % Solve ODE initial value problem.
        t_range = [0, job.t_max];

        if job.quick; sim.solution = ode45( @(t,state_vector) system_equations(t,state_vector,sim.mjolnir), t_range,  sim.initial_state_vector);
        else;         sim.solution = ode23t(@(t,state_vector) system_equations(t,state_vector,sim.mjolnir), t_range,  sim.initial_state_vector);
        end
        
        
        sim.simulation_time = toc;
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        save(job.save_name, "sim")
        
    end
    
    
    
    
    if job.process_data
        %% Post-processing:
        
        load(job.load_name)
        
        if isfile(job.save_name); warning("File name already exists, file will be overwritten upon simulation completion."); end
    
            evalin("base", "loading_message = 'Post-processing "+ job.save_name +":';");
            evalin("base", "loading_bar = waitbar(0, loading_message);");
            assignin("base", "loading_bar_end_time", job.t_max);
    
    
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
        evalin("base","close(loading_bar)");
        evalin("base", "clear loading_bar_end_time, loading_message");
        save(job.save_name, "sim")
        
        
        
        
    
    end
    
    
    

end