function F = thrust(comp)
% Compute thrust (see Sutton, 2017, p. 33).


A_ex = comp.A_exit;
F = comp.mf_throat * comp.v_ex + ( comp.P_ex - comp.P_ext) * A_ex;
end

