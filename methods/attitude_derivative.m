function derivative = attitude_derivative(comp)

[~, rotation_basis] = vector2rotmat(comp.rotation_rate);
derivative = rotation_basis*rotx(90)*(rotation_basis')*comp.attitude*norm(comp.rotation_rate);


end