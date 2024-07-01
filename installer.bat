ECHO OFF
echo %0
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o miniconda.exe
start /wait "" miniconda.exe
del miniconda.exe
call C:\Users\%USERNAME%\miniconda3/Scripts/activate.bat C:\Users\%USERNAME%\miniconda3
call conda create --name matlab_python_enviroment python=3.11
call conda install --name matlab_python_enviroment conda-forge::coolprop
Pause