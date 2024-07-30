function M_ex = exhaust_Mach(comp)
% Compute the exhaust Mach number.

M_ex_zero = fzero(@(M) exhaust_Mach_fct(M), 2);
M_ex = max(0, M_ex_zero);


function f = exhaust_Mach_fct(M_ex)
% Equality f(M_ex) = 0 that we use to find the Mach number (see Sutton, 2017, p. 60).


A_ex  = comp.A_exit;
gamma = comp.gamma_combustion_products;

f = 1 / M_ex * (2 / (gamma + 1) * (1 + (gamma - 1) * M_ex^2 / 2))^((gamma + 1) / (2 * (gamma - 1))) - A_ex / comp.A_t;
end

end