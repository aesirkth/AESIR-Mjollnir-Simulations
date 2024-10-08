clc
clear
% clear global


%% Adding paths to sub-folders:
addpath('./Datasets');
addpath('./Simulation')
addpath('./Simulation/Methods')
addpath('./Assets');
addpath('./Methods');
addpath('./STLRead');
addpath('./UI');
addpath('./Data');
addpath('./Wrappers');
addpath('./projekt_tralljok')
addpath('./projekt_tralljok/Arduino')
if isfolder('../colorthemes/')
addpath('../colorthemes/'); 
end


%% Python-setup:

mypath = pwd(); 
mypath = split(mypath, "\"); 
mypath = mypath{1}+"\"+mypath{2}+"\"+mypath{3}; % Oooga booga



disp("Loading CoolProp into MATLAB:")
%try
pyenv('Version', mypath+'\miniconda3\envs\matlab_python_enviroment\python.exe');
py.importlib.import_module("CoolProp");
test = py.CoolProp.CoolProp.PropsSI('D', 'T', 200, 'Q', 0, 'NitrousOxide');
disp("test:"+string(test));
disp("Package loaded correctly.")
%catch python_error
%system("installer.bat&");
%error("Coolprop and/or Conda not installed. Installing...")
%end
%pause(1)







