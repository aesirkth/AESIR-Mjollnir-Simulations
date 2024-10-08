function pressure_coefficients = pressure_coefficient_1(normalized_velocity_projection)

pressure_coefficients = 2*eye(3)*(2/pi).*abs(atan(1.7*normalized_velocity_projection)./(20*normalized_velocity_projection.^8 + 1));

end