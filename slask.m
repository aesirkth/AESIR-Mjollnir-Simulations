setup

img = imread("greyscale3.png");
z = double(img(:,:,1));

[x,y] = ndgrid(linspace(-1000,1000,width(z)), linspace(-1000,1000,height(z)));

%x = x'; y = y'; z = z';

F = griddedInterpolant(x,y,z,'makima');

z = F(x,y);
z = smoothdata2(z,'gaussian',9);

[x2,y2] = ndgrid(-200:0.7:200, -200:0.7:200);

z2 = F(x2,y2);

z2 = smoothdata2(z2, 'gaussian', 9);

ax = axes();
surf(ax, x,y,z, "EdgeColor","none", "FaceColor", [0.2,0.5,0.2]);
light(ax);
ax.DataAspectRatio = [1 1 1];
figure();
ax2 = axes();
surf(ax2, x2,y2,z2, "EdgeColor","none", "FaceColor", [0.2,0.5,0.2]);
light(ax2);
ax2.DataAspectRatio = [1 1 1];