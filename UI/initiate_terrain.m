terrain = struct();

z = imread("greyscale3.png");

z = double(z(:,:,1))*10; z = z(:, 1:height(z)); z = z(1:width(z), :);
%z = z - mean(z);
[x,y] = ndgrid(linspace(-20000,20000,width(z)), linspace(-20000,20000,height(z)));


terrain.interpolator = griddedInterpolant(x,y,z,'makima');

terrain.z = @(x,y) smoothdata2(terrain.interpolator(x,y),'gaussian',9);

clear x y z

