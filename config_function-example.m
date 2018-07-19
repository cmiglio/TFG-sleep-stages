% CONFIG FUNCTION: Change the paths as needed to match your local machine		
%                  Call this function at the beginning of all scripts		
function [data_path, results_path] = config_function()		

    % Where data are stored		
    data_path = 'C:\Users\cmigliorelli\Google Drive\BIOART-cm\Gemma'; % carpeta donde están guardadas las señales		
    		
    % Where results must be saved		
    results_path = [pwd filesep 'results'];		
    		
    % Where calculation functions are stored		
    addpath('Functions')		
end