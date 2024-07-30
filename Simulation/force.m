function fc = force(force_vec, force_position)
if exist("force_position", "var") == false
force_position = [0;0;0];
end
fc = struct();
fc.vec = force_vec;
fc.pos = force_position;

end