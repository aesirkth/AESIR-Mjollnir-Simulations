function simulate(comp)
    tic
  
    %% Set combustion parameters.
    t0 = 0;                     % Initial time of ignition.
    comp.t_burn = 80;           % Final time.
    tf = comp.t_burn + t0;      % Time when propelant is completely burned.
    t_range = [t0 tf];          % Integration interval.
    
    %% Initialization.
    
    disp("---------------------------------")
    disp("Intitialization...") 
    disp("---------------------------------")
    disp(" ")
    
    pre_processing

    %% Solve differential equations.
    disp("---------------------------------")
    disp("Solving differential equations...") 
    disp("---------------------------------")
    disp(" ")
    
    % Initialization.
    % tol = odeset('RelTol',1e-5,'AbsTol',1e-6);
     initial_state_vector = zeros(28,1);
     initial_state_vector = comp2state_vector(comp, initial_state_vector);
    
    % Solve ODE initial value problem.
    comp.remaining_ox = 100;    % Percentage of remaining oxidizer.
    % ode_opts = odeset('RelTol', 1e-5, 'AbsTol', 1e-8);
    % ode_opts = odeset('MaxStep', 0.05);
    % [t, state] = ode23tb(@system_equations, t_range,  initial_state_vector, ode_opts);
    if evalin("base", "quick") == false
        [t, state] = ode23t(@system_equations, t_range,  initial_state_vector);
    else
        [t, state] = ode45(@system_equations, t_range,  initial_state_vector);
    end
    

    %% Post-compute recuperation of data.
    disp(" ")
    disp("---------------------------------")
    disp("Collecting results...") 
    disp("---------------------------------")
    disp(" ")



    post_processing
    
    toc
end
