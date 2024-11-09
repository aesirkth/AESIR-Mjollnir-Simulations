function [tank, state_variables] = sindri_tank(N2O, full_duration)

%% Tank

tank                         = struct();
tank.position                = [0;0;-0.5];
tank.filling_ratio           = 0.95;      % Tank filling ratio.

tank.vapor                   = struct();
tank.vapor.position          = [0;0;0.5];

% Liquid
tank.liquid                  = struct();
tank.liquid.position         = [0;0;-0.8];
tank.liquid.temperature      = 285;  % Initial tank temperature (K).

% Tank-wall
tank.wall                    = struct();
tank.wall.position           = [0.07;0.07;0.4];
tank.wall.  temperature      = 285;  % Assume that initial tank wall temperature is equal to the initial internal temperature (K).

%tank.exterior_wall = struct();


tank.wall.aluminium_thermal_conductivity = 236;        % Wm-1K-1 at 0 degree celcius.
tank.wall.rho_alu                        = 2700;       % Density aluminium (kg/m^3).
tank.wall.alu_thermal_capacity           = 897;        % J/K/kg
tank.wall.aluminium_emissivity_painted   = 0.8;        % Emissivity of painted tank.
tank.wall.aluminium_emissivity           = 0.3;        % Emissivity of plain aluminium.
tank.wall.aluminium_absorbitivity        = 0.4;        % Absorptivity of plain aluminium.



tank.liquid.heat_flux = 0;    % Thermal heat flux of the liquid    (dependant, computed in simulation). 
tank.vapor .heat_flux = 0;    % Thermal heat flux of the vapor     (dependant, computed in simulation). 
tank.wall  .heat_flux = 0;    % Thermal heat flux of the tank-wall (dependant, computed in simulation). 

tank.oxidizer_mass      = 24.5;
tank.pressure         = 0;    % Pressure (dependant, computed in simulation). 

% Tank geometry.    
if ~exist("full_duration", "var"); full_duration = true; end

if full_duration
    tank.diameter = 16e-2;    % Tank external diameter for full-duration burn (m).
    tank.length   = 1.83;     % Tank length for full-duration burn (m).
else
    tank.diameter = 10e-2;    % Tank external diameter for short-duration burn (m).
    tank.length   = 0.73;     % Tank length for short-duration burn (m).
end

tank.thickness = 3.5e-3;      % Tank thickness (m).
tank.volume    = tank.length*pi*(tank.diameter*0.5 - tank.thickness)^2; % Tank-volume (m^3).
tank.wall.mass          = tank.wall.rho_alu* ...
                                   tank.length* ...
                                 ((tank.diameter*0.5)^2 - (tank.diameter*0.5 - tank.thickness)^2)*pi;
tank.internal_area      = (tank.diameter-2*tank.thickness)*pi*tank.length;



tank.liquid.mass = tank.filling_ratio       * tank.volume *  N2O.temperature2density_liquid(tank.liquid.temperature);               % The liquid mass is the liquid volume in the tank times the liquid density (kg).
tank.vapor.mass = (1 - tank.filling_ratio)  * tank.volume *  N2O.temperature2density_vapor (tank.liquid.temperature);               % The liquid mass is the remaining volume in the tank times the vapor density (kg).

tank.oxidizer_mass        = tank.liquid.mass + tank.vapor.mass;                                         % The initial mass of the oxidizer in the tank is the sum of liquid and vapor mass (kg).
tank.internal_energy      = tank.liquid.mass * N2O.temperature2specific_internal_energy_liquid(tank.liquid.temperature) ...
                                  + tank.vapor .mass * N2O.temperature2specific_internal_energy_vapor (tank.liquid.temperature);         % The initial energy in the tank is the sum of liquid and vapor mass times energy (J).

tank.Cd = 0.85;                                    % Discharge coefficient.
tank.remaining_ox = 100;  
tank.model = "moody";  % Moody or dyer.

tank.Cd_inlet = 0.85;
tank.Cd_outlet = 0.95;




evalin("base", "temperature_initial_estimate = 285;")

state_variables = {"oxidizer_mass", ...
                   "internal_energy", ...
                   "wall.temperature", ...
                   "liquid.heat_flux", ...
                   "vapor.heat_flux", ...
                   "wall.heat_flux"};
                   
end