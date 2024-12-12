setup;

my_rocket = mjollnir_recursive;


disp("Simulating...")
job = struct(); job.t_max = 100;
sim = run_simulation(my_rocket);
disp("Done.")
%sim.rocket_historian.position(:,:) = 0;



delete(".\Data\recursive_test.txt")
struct2txt(".\Data\recursive_test.txt", sim.rocket_historian, 0:1/30:100);


render_simulation_recursive(sim)
%disp("Rendering...")
%render_job = render_simulation(sim);
%disp("Done.")
