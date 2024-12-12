setup;

my_rocket = mjollnir;


disp("Simulating...")
job = struct(); job.t_max = 100;
sim = run_simulation(my_rocket);
disp("Done.")


%delete(".\Data\recursive_test.txt")
%struct2txt(".\Data\recursive_test.txt", sim.rocket_historian, 0:1/30:100);


render_simulation(sim)
