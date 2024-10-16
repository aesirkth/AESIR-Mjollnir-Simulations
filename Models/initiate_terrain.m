function terrain = initiate_terrain()

terrain = struct();

z = imread("greyscale3.png");
xlim = 20000; 
ylim = 20000;

terrain.z_data = double(z(:,:,1))*10; 
terrain.z_data = terrain.z_data(:, 1:height(z)); 
terrain.z_data = terrain.z_data(1:width(z), :);
terrain.z_data = terrain.z_data -1000; 

[x,y] = ndgrid(linspace(-xlim,xlim,width(z)), linspace(-ylim,ylim,height(z)));


terrain.interpolator = griddedInterpolant(x,y,terrain.z_data,'makima');

terrain.z = @(x,y) smoothdata2(terrain.interpolator(x,y).*(-xlim*0.9 < x & x < xlim*0.9).*(-ylim*0.9 < x & x < ylim*0.9),'gaussian',9) ...
                                                        .*(-xlim*0.9 < x & x < xlim*0.9).*(-ylim*0.9 < x & x < ylim*0.9);


