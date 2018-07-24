% CONFIG FUNCTION: Change the paths as needed to match your local machine		
%                  Call this function at the beginning of all scripts		
function [data_path, results_path] = config_function_example()		

    % Where data are stored		
    data_path = '..\BBDD'; % carpeta donde están guardadas las señales
    
    % another option: do it manually
    % data_path = uigetdir('', 'Pick the database directory');
    		
    % Where results must be saved		
    results_path = [pwd filesep 'results'];		
    		
    % Where calculation functions are stored		
    addpath('Functions')		
end