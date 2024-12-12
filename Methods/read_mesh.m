function mesh = read_mesh(rocket);
    mesh = stlread(rocket.mesh);
    mesh.vertices = rocket.length_scale*mesh.vertices/max(mesh.vertices, [], "all");
    mesh.vertices  = mesh.vertices -   ...
                      0.5*[max(mesh.vertices(:,1))+min(mesh.vertices(:,1));
                           max(mesh.vertices(:,2))+min(mesh.vertices(:,2));
                           max(mesh.vertices(:,3))+min(mesh.vertices(:,3))]';