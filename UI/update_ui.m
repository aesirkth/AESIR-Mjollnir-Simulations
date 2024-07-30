

%% Skip-feature:
while t(index) < my_ui.TSlider.Value && t(index +1) < my_ui.TSlider.Value;index = index+1;end
while t(index) > my_ui.TSlider.Value && t(index +1) > my_ui.TSlider.Value;index = index-1;end


if isequal(my_ui.Switch.Value,'⏵︎') && index < numel(t)-1
index = index+1;
my_ui.TSlider.Value = t(index);

az = az+0.3;
my_ui.ax .View = [az, 45];
my_ui.ax2.View = [az, 45];


[~,mjolnir] = system_equations(t(index),state(:,index), mjolnir); % Calculating dependant data from the state-vector


draw_component(my_ui.ax, mjolnir, 0.003);
draw_trajectory(my_ui.ax2, state(1:3,1:index));

if t(index) < 60
my_ui.TLabel.Text = "T+"+string(t(index))+" s";
else
my_ui.TLabel.Text = "T+"+string(floor(t(index)/60))+" m, " + string(mod(t(index), 60)) + " s";
end

my_ui.VelocityLabel.Text = "Velocity: "+string(norm(mjolnir.velocity)) +" m/s";


else
pause(0.5)

end
drawnow