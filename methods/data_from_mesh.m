function comp = data_from_mesh(comp)
temp_fig = figure();
temp_ax = axes(temp_fig);
% temp_fig2 = figure();
% temp_ax2 = axes(temp_fig2);
% temp_fig3 = figure();
% temp_ax3 = axes(temp_fig3);

patch(temp_ax, comp.mesh, 'FaceColor',       [0 0 0], ...
                          'EdgeColor',       'none');
material('dull');
axis(temp_ax, "equal")
temp_ax.XColor = [1 1 1];
temp_ax.YColor = [1 1 1];
temp_ax.ZColor = [1 1 1];


% % Debug:
% 
% patch(temp_ax3, comp.mesh, 'FaceColor',       [0 0 0], ...
%                           'EdgeColor',       'none');
% material('dull');
% axis(temp_ax3, "equal")
% xlabel(temp_ax3, "X")
% ylabel(temp_ax3, "Y")
% zlabel(temp_ax3, "Z")

comp.moment_of_area = zeros(3,3,4); % Rows:    Faces
                                    % Columns: x/Degree of freedom
                                    % Pages:   Degree of area-moment
comp.length_scale = ones(3,1);


%% coordinate-transfer:
for face      = 1:3

if     face == 1; view(temp_ax, 90,0); drawnow; dimension2image_hash = ["NA"     "width" "height"];
elseif face == 2; view(temp_ax, 0,0 ); drawnow; dimension2image_hash = ["width" "NA"     "height"];
else;             view(temp_ax, 0,90); drawnow; dimension2image_hash = ["width" "height"  "NA"   ];
end

shadow = getframe(temp_ax);
shadow.cdata = flipud(shadow.cdata);
%imagesc(shadow.cdata); drawnow; pause(10)

% Warning! Busy logic up ahead.

height_projection = sum(~shadow.cdata(:,:,1), 2);
[max_pixel_height, ~] = find(height_projection, 1, 'last'  );
[min_pixel_height, ~] = find(height_projection, 1, 'first' );
width_projection = sum(~shadow.cdata(:,:,1), 1);
[~, max_pixel_width ] = find(width_projection,  1, 'last'  );
[~, min_pixel_width ] = find(width_projection,  1, 'first' );


for dimension = 1:3

if     dimension2image_hash(dimension) == "height"

[max_mesh_height] = max(comp.mesh.vertices(:,dimension), [],1 );
[min_mesh_height] = min(comp.mesh.vertices(:,dimension), [],1 );

pixel2height  = @(pixel )        (pixel  - min_pixel_height)*(max_mesh_height  - min_mesh_height )/(max_pixel_height - min_pixel_height) + min_mesh_height;
height2pixel  = @(height) round( (height - min_mesh_height )*(max_pixel_height - min_pixel_height)/(max_mesh_height  - min_mesh_height ) + min_pixel_height);
pixel_height  = pixel2height(2) - pixel2height(1);

elseif dimension2image_hash(dimension) == "width"

[max_mesh_width] = max(comp.mesh.vertices(:,dimension), [],1 );
[min_mesh_width] = min(comp.mesh.vertices(:,dimension), [],1 );

pixel2width   = @(pixel )        (pixel  - min_pixel_width )*(max_mesh_width   - min_mesh_width  )/(max_pixel_width  - min_pixel_width ) + min_mesh_width;
width2pixel   = @(width ) round( (width  - min_mesh_width  )*(max_pixel_width  - min_pixel_width )/(max_mesh_width   - min_mesh_width  ) + min_pixel_width);
pixel_width   = pixel2width (2) - pixel2width (1);
end

end


height2width  = @(height) pixel_width *height_projection(height2pixel(height))';
width2height  = @(width)  pixel_height*width_projection (width2pixel (width ));



for dimension = 1:3

if     dimension2image_hash(dimension) == "height"
height_vec = min_mesh_height:pixel_height:max_mesh_height;
comp.area(face) = pixel_height*sum( height2width(height_vec), "all");
comp.moment_of_area(face, dimension, 1) = pixel_height*sum( height2width(height_vec).*((height_vec - comp.center_of_mass(dimension))   ), "all");
comp.moment_of_area(face, dimension, 2) = pixel_height*sum( height2width(height_vec).*((height_vec - comp.center_of_mass(dimension)).^2), "all");
comp.moment_of_area(face, dimension, 3) = pixel_height*sum( height2width(height_vec).*((height_vec - comp.center_of_mass(dimension)).^3), "all");
comp.moment_of_area(face, dimension, 4) = pixel_height*sum( height2width(height_vec).*((height_vec - comp.center_of_mass(dimension)).^4), "all");
comp.length_scale(dimension) = (max_mesh_height - min_mesh_height)/2;
elseif dimension2image_hash(dimension) == "width"
width_vec = min_mesh_width:pixel_width:max_mesh_width;
comp.area(face) = pixel_width*sum( width2height(width_vec), "all");
comp.moment_of_area(face, dimension, 1) = pixel_width*sum( width2height(width_vec ).*((width_vec - comp.center_of_mass(dimension))    ), "all");
comp.moment_of_area(face, dimension, 2) = pixel_width*sum( width2height(width_vec ).*((width_vec - comp.center_of_mass(dimension)) .^2), "all");
comp.moment_of_area(face, dimension, 3) = pixel_width*sum( width2height(width_vec ).*((width_vec - comp.center_of_mass(dimension)) .^3), "all");
comp.moment_of_area(face, dimension, 4) = pixel_width*sum( width2height(width_vec ).*((width_vec - comp.center_of_mass(dimension)) .^4), "all");
comp.length_scale(dimension) = (max_mesh_width - min_mesh_width)/2;
end









% % Debug:
% 
% if dimension2image_hash(dimension)     == "height"
% plot(temp_ax2, height2width(height_vec), height_vec); 
% pixel_height = pixel_height
% elseif dimension2image_hash(dimension) == "width"
% plot(temp_ax2, width_vec, width2height(width_vec));
% pixel_width = pixel_width
% end
% temp_ax2.NextPlot = "add";
% scatter(temp_ax2, comp.center_of_mass(dimension), 1);
% temp_ax.NextPlot = "replacechildren";
% face
% dimension
% dimension2image_hash(dimension)
% axis equal
% drawnow; pause(10)


end

end




% comp.area = [sum(comp.moment_of_area(1,[2 3]))*0.5;
%              sum(comp.moment_of_area(2,[1 3]))*0.5;
%              sum(comp.moment_of_area(3,[1 2]))*0.5];
% 
% 
comp.center_of_pressure = [0.5*(comp.moment_of_area(2,1,1)/comp.area(2) + comp.moment_of_area(3,1,1)/comp.area(3));
                           0.5*(comp.moment_of_area(1,2,1)/comp.area(1) + comp.moment_of_area(3,2,1)/comp.area(3));
                           0.5*(comp.moment_of_area(1,3,1)/comp.area(1) + comp.moment_of_area(2,3,1)/comp.area(2))];




close(temp_fig);






end