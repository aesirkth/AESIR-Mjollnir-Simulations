function terrain = initiate_terrain()

terrain = struct();

z = imread("greyscale3.png");
xlim = 20000; 
ylim = 20000;

terrain.z_data = double(z(:,:,1))*10; z = z(:, 1:height(z)); z = z(1:width(z), :);
%z = z - mean(z);
[x,y] = ndgrid(linspace(-xlim,xlim,width(z)), linspace(-ylim,ylim,height(z)));


terrain.interpolator = griddedInterpolant(x,y,terrain.z_data,'makima');

terrain.z = @(x,y) smoothdata2(terrain.interpolator(x,y),'gaussian',9).*(-xlim < x & x < xlim).*(-ylim < x & x < ylim);


