function [mat, rotation_basis] = vector2rotmat(vec)
% Takes a vector with a length theta and creates a rotation matrix that
% rotates theta radians around the vectors axis.

if norm(vec) ~= 0
% Gram-Schmidt orthogonalization:
rotation_basis = vec*ones(1,3) + [0 0 0;
                                  0 1 0;
                                  0 0 1];
rotation_basis = orthonormalize(rotation_basis);

mat = rotation_basis*rotx(norm(vec)*360/(2*pi))*(rotation_basis');

else
rotation_basis = eye(3);
mat            = eye(3);
end

