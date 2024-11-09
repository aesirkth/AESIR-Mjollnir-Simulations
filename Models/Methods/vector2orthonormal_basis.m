function mat = vector2orthonormal_basis(vector, offset)

if ~exist("offset", "var"); offset = rand(3,1) + vector; end
r3 = vector/norm(vector); % Should be normal, but just in case
r2 = cross(r3, offset);
r2 = r2/norm(r2);
r1 = cross(r2, r3);
r1 = r1/norm(r1);

mat = [r1,r2,r3];


end