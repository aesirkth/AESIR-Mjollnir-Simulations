function mat = orthonormalize(mat)
% Normalizes and orthogonalizes the attitude.


mat(:,1) =  mat(:,1)/norm(mat(:,1));
mat(:,2) =  -cross(mat(:,1), mat(:,3));
mat(:,2) =  mat(:,2)/norm(mat(:,2));
mat(:,3) =  cross(mat(:,1), mat(:,2));
mat(:,3) =  mat(:,3)/norm(mat(:,3));



end