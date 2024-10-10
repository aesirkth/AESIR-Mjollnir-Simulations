set(groot, 'defaultAxesTickLabelInterpreter','latex'); set(groot, 'defaultLegendInterpreter','latex');
addpath('../../animation_toolbox/');addpath('../../colorthemes/');addpath('../STLRead/');
fig = figure;
ax = axes(fig); dark_mode2; plot3(ax, 0,0,0); view(0,0);ax.DataAspectRatio = [1,1,1]; 
annotation(fig, "rectangle","EdgeColor", [1,1,1]*0.13, "Position", [0.25 0.1 0.5 0.8]);
ax.XLim = [-50,50];ax.YLim = [-10,10];ax.ZLim = [-50,50]; axis off
light(ax);
mesh = stlread("../Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
mesh.vertices = (mesh.vertices - [0 0 (max(mesh.vertices(3,:)) + min(mesh.vertices(3,:)))*0.5] - [0 0 10])*(roty(90)');

%% b-fun
tempfig = figure();
tempax = axes(tempfig); tempax.Color = [0 0 0];
patch(tempax, mesh, ...
                              'FaceColor',       [1 1 1], ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 1, ...
                              'FaceAlpha',       1)

img = getframe(tempax); img = double(img.cdata(30:end-30,30:end-30,1)); img = floor(img); img = img ~= 0;
close(tempfig)
p1 = max(img.*(1:width(img)), [], "all"); p2 = min(img.*(1:width(img))+ (img==0)*1000000, [], "all");
b_discrete = sum(img, 1)*(max(mesh.vertices(:,3)) - min(mesh.vertices(:,3)))/(max(sum(img, 1), [], "all"));
r2p = @(r) (r-max(mesh.vertices(:,1))).*(p1-p2)./(max(mesh.vertices(:,1), [], "all") - min(mesh.vertices(:,1), [], "all"))+p1;
b= @(r) interp1(1:width(b_discrete), b_discrete, r2p(r), "linear");


%% animation setup

r  = -50:0.2:50; r_text = -15; y_text = -10;
y  = -ones(size(r))*2;
f  = @(r,v,w) 0.005*sign(v - w.*r).*b(r).*(v - w.*r).^2;
f2 = @(r,v,w) 0.005*((v-w*r).^3).*b(r)./abs(v-w*25);


rocket = animation(@(c)patch(ax, mesh, ...
                              'FaceColor',       ColorMap(70,:), ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 0.1, ...
                              'FaceAlpha',       0.1), {0},{0});

r_ax = animation(@(c)quiver3(ax, 0,-5,0, 60,0,0, "LineWidth", 1.5, "Color", [1 1 1]), {0},{0});
b_ax = animation(@(c)quiver3(ax, 0,-5,0, 0,0,40, "LineWidth", 1.5, "Color", [1 1 1]), {0},{0});



integrand_line1 = animation(@(c) plot3(r, y, f(r,c{1}, c{2}), "LineWidth", 1.2, "Color", [1,0.5,0]), {0,1}, {10,0} );
integrand_line2 = animation(@(c) plot3(r, y, f(r,c{1}, c{2}), "LineWidth", 1.2, "Color", [1,0.5,0]), {10,0}, {5,1} );
integrand_line3 = animation(@(c) plot3(r, y, f(r,c{1}, c{2}), "LineWidth", 1.2, "Color", [1,0.5,0]), {5,1}, {-5,1} );
integrand_line4 = animation(@(c) plot3(r, y, f(r,c{1}, c{2}), "LineWidth", 1.2, "Color", [1,0.5,0]), {-5,1}, {-5,-1} );
integrand_line5 = animation(@(c) plot3(r, y, f(r,c{1}, c{2}), "LineWidth", 1.2, "Color", [1,0.5,0]), {-5,-1}, {0,1} );

omega_text1 = animation(@(c) text(25,-10,30, "$ \omega = "+string(c{2})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {0,1}, {10,0} );
omega_text2 = animation(@(c) text(25,-10,30, "$ \omega = "+string(c{2})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {10,0}, {5,1} );
omega_text3 = animation(@(c) text(25,-10,30, "$ \omega = "+string(c{2})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {5,1}, {-5,1} );
omega_text4 = animation(@(c) text(25,-10,30, "$ \omega = "+string(c{2})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {-5,1}, {-5,-1});
omega_text5 = animation(@(c) text(25,-10,30, "$ \omega = "+string(c{2})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {-5,-1}, {0,1} );

v_text1 = animation(@(c) text(25,-10,25, "$ v_0 = "+string(c{1})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {0,1}, {10,0} );
v_text2 = animation(@(c) text(25,-10,25, "$ v_0 = "+string(c{1})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {10,0}, {5,1} );
v_text3 = animation(@(c) text(25,-10,25, "$ v_0 = "+string(c{1})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {5,1}, {-5,1} );
v_text4 = animation(@(c) text(25,-10,25, "$ v_0 = "+string(c{1})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {-5,1}, {-5,-1});
v_text5 = animation(@(c) text(25,-10,25, "$ v_0 = "+string(c{1})+" $", "Color", [1,0.5,0], "Interpreter", "latex"),  {-5,-1}, {0,1} );

text1 = animation(@(c) text(r_text, y_text, f(r_text,c{1}, c{2}) + 5,"$(v_0 - \omega r)^2 \cdot sign(v_0 - \omega r) b(r) $", "Interpreter", "latex", "Color", [1,0.5,0]), {0,1}, {10,0} );
text2 = animation(@(c) text(r_text, y_text, f(r_text,c{1}, c{2}) + 5,"$(v_0 - \omega r)^2 \cdot sign(v_0 - \omega r) b(r) $", "Interpreter", "latex", "Color", [1,0.5,0]), {10,0}, {5,1} );
text3 = animation(@(c) text(r_text, y_text, f(r_text,c{1}, c{2}) + 5,"$(v_0 - \omega r)^2 \cdot sign(v_0 - \omega r) b(r) $", "Interpreter", "latex", "Color", [1,0.5,0]), {5,1}, {-5,1} );
text4 = animation(@(c) text(r_text, y_text, f(r_text,c{1}, c{2}) + 5,"$(v_0 - \omega r)^2 \cdot sign(v_0 - \omega r) b(r) $", "Interpreter", "latex", "Color", [1,0.5,0]), {-5,1}, {-5,-1} );
text5 = animation(@(c) text(r_text, y_text, f(r_text,c{1}, c{2}) + 5,"$(v_0 - \omega r)^2 \cdot sign(v_0 - \omega r) b(r) $", "Interpreter", "latex", "Color", [1,0.5,0]), {-5,-1}, {0,1} );
delete integrand.gif
saver =  save_to_gif(ax, "integrand.gif");

animate({rocket, r_ax, b_ax, integrand_line1, text1, omega_text1, v_text1, saver}, 1:2:100)
animate({rocket, r_ax, b_ax, integrand_line2, text2, omega_text2, v_text2, saver}, 1:2:100)
animate({rocket, r_ax, b_ax, integrand_line3, text3, omega_text3, v_text3, saver}, 1:2:100)
animate({rocket, r_ax, b_ax, integrand_line4, text4, omega_text4, v_text4, saver}, 1:2:100)
animate({rocket, r_ax, b_ax, integrand_line5, text5, omega_text5, v_text5, saver}, 1:2:100)
animate({rocket, r_ax, b_ax, integrand_line5, text5, omega_text5, v_text5, saver}, 100*ones(1,50));

