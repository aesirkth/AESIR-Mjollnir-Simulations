function ui = initiate_ui()



ui  = rocket_app();

%% Initial settings

ui.UIFigure.Name  = "Flight sim";
grid(ui.ax4, "on");





if isfolder('../colorthemes/'); dark_mode2(); end
light(ui.ax)
annotation(ui.UIFigure,'rectangle',[0 0 1 1],'Color',[1 1 1]);

drawnow

pause(1)
ui.UIFigure.WindowState = "maximized";


az = 10;
ui.ax .View = [az, 5];
ui.ax3.View = [az, 5];
ui.ax2.View = [az, 5];

ui.Switch.Value = '⏵︎';




end
