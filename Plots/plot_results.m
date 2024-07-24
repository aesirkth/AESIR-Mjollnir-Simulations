%% Plots combustion, flight, and thrust plots.

disp("---------------------------------")
disp("Plotting...") 
disp("---------------------------------")
disp(" ")

close all
flight_plot    (mjolnir, simulation);
thrust_plot    (mjolnir, simulation);
combustion_plot(mjolnir, simulation);

% sensor_plot;

% figure(4)
% Isp = Tr./(opts.g.*mf_throat);
% plot(OF, Isp)
% xlabel("OF")
% ylabel("Isp (s)")
