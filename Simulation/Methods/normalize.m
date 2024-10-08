function outvec = normalize(vec)

if norm(vec) ~= 0
outvec = vec/norm(vec);
else; outvec = [0;0;0];
end


end