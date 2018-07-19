function [time,fs,EDF,senyals] = obrir_senyals( subject,dispositivo,duracion,epoca,dir_datos,dir_result )

[EDF] = abrir_edf([dir_datos filesep subject]);
% Lee la epoca entrada
[senyals, EDF1] = leeredf_DEF(EDF,duracion,epoca,dispositivo);

fs = EDF1.SampleRate(1); %Frequencia de mostreig del senyal EEG 

time = linspace(epoca*duracion,(epoca+1)*duracion,size(senyals,1));

end

