

%% Adding paths to sub-folders:
addpath('./Datasets');
addpath('./Rockets');
addpath('./Rockets/components/');
addpath('./Rockets/Models');
addpath('./Rockets/Models/Methods');
addpath('./Assets');
addpath('./Methods');
addpath('./STLRead');
addpath('./UI');
addpath('./UI/colorthemes')
addpath('./Data');
addpath('./Wrappers');



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

