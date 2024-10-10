set(groot, 'defaultAxesTickLabelInterpreter','latex'); set(groot, 'defaultLegendInterpreter','latex');
addpath('../../animation_toolbox/');addpath('../../colorthemes/');addpath('../STLRead/');
fig = figure;
ax = axes(fig); dark_mode2; plot3(ax, 0,0,0); view(0,0);ax.DataAspectRatio = [1,1,1]; 
annotation(fig, "rectangle","EdgeColor", [1,1,1]*0.13, "Position", [0.22 0.05 0.56 0.9]);
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

%%

r  = -50:0.2:50; r_text = -15; y_text = -10;
y  = -ones(size(r))*2;
f  = @(r,v,w) 0.005*sign(v - w.*r).*b(r).*(v - w.*r).^2;
f2 = @(r,v,w) 0.005*((v-w*r).^3).*b(r)./abs(v-w*25);
a  = @(r,k) 10^(-1.5*k)*3*b(r).*r.^k;
%%

for k = 0:4
if mod(k,2)==1; C = [1,0,0]; else C = [0,1,1]; end

quiver3(ax, 0,-5,0, 60,0,0, "LineWidth", 1.5, "Color", [1 1 1]); ax.NextPlot = "add";
quiver3(ax, 0,-5,0, 0,0,40, "LineWidth", 1.5, "Color", [1 1 1]);


patch(ax, mesh, ...
                              'FaceColor',       ColorMap(70,:), ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 0.3, ...
                              'FaceAlpha',       0.3);


plot3(ax, r,y,10.^(-1.5*k).*10*r.^k, "LineWidth", 1, "Color", [1,0.1,0.1], "LineStyle", "--");
plot3(ax, r,y,a(r,k), "LineWidth", 1.5, "Color", [1,0.1,0.1]); 
fill3(ax, [-50:0.1:0,0], [zeros(size(-50:0.1:0)),0], [a(-50:0.1:0, k),0], C, "FaceAlpha", 0.5);
fill3(ax,  [0,0:0.1:54], [0,zeros(size(0:0.1:54))],  [0,a(0:0.1:54,  k)], [0,1,1], "FaceAlpha", 0.5);
text(ax, 20, 0, a(20,k)+15, "$b(r) \cdot r^"+string(k)+"$", "Interpreter", "latex", "Color", [1,0,0]);
text(ax, 35, 0, a(35,k)+20, "$r^"+string(k)+"$", "Interpreter", "latex", "Color", [1,0,0]);
text(ax, 15, 0, a(15,k)-10, "$A_{"+string(k)+"} = \int_{R} b(r) \cdot r^"+string(k)+" \partial r$", "Interpreter", "latex", "Color", [0,1,1]);
view(0,0)

ax.NextPlot = "replacechildren";
drawnow
delete("area_moment"+string(k)+".png");
exportgraphics(ax, "area_moment"+string(k)+".png", "BackgroundColor", get(ax, "Color"));

pause(2)
end