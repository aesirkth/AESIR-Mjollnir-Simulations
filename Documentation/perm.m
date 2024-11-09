function s=perm(a)

I = speye(length(a));
s = det(I(:,a));