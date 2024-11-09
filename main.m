setup;

my_rocket = mjollnir;

job = struct(); job.save = true; job.name = "Data/test/sims/sim.mat";

disp("Simulating...")
sim = run_simulation(my_rocket, job);
disp("Done.")


disp("Rendering...")
render_job = render_simulation(sim);
disp("Done.")
