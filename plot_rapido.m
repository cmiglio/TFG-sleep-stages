% Script per calcular EOIs, diagrames T-F i plotejar.
warning off
%% Obrir senyals
close all
clear all
[dir_datos, dir_result] = config_function_example();

subject='V01.rec'; %.rec: dispositivo: deltamed , .edf: dispositivo:profusion
dispositivo='deltamed'; %deltamed
duracion=300; % Duración en segundos de la señal 
epoca=14; % Epoca: Epoca 1 sería de 0 a "duración" segundos, epoca 2 sería de duración a 2*duración, etc. 
[EDF]=abrir_edf([dir_datos filesep 'EDF' filesep subject]);
% Lee la epoca entrada
[senyals, EDF1] = leeredf_DEF(EDF,duracion,epoca,dispositivo);
senyals(:, 1:2) = []; % Remove EOG

Labels={'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'};

index_eliminar=[1 2 3 7 8 12 13 17 18 19]; % Índice de canales que no deseamos ver
a=1:19;
a(index_eliminar)=[];

fs=EDF1.SampleRate(1); %Frecuencia de muestreo de la señal EEG.

time=linspace(epoca*duracion,(epoca+1)*duracion,size(senyals,1)); % Vector de tiempo

%% Filtrar (tots els canals)

bp_filter = design_filter__9__16(fs);  % Señales filtradas de 9 a 16 Hz (frecuencia de spindleS)
senyals_filt=filtfilt(bp_filter.SOSMatrix,bp_filter.ScaleValues,senyals);

senyals_plot=senyals_filt;
senyals_plot_nofilt=senyals;

ev_inici=(find(time>4294,1,'First'));
ev_final=(find(time>4296,1,'First'));
win_2=1024;
vect=[4 5 6 9 10 11 14 15 16]; %ordenar les senyals
k=70;
figure
for i2 = 1:length(vect) %size(senyals_prom,2)
    senyal=detrend(senyals_plot(ev_inici-win_2:ev_final+win_2,vect(i2)),'constant');
    plot(time(ev_inici-win_2:ev_final+win_2),senyal-k*(i2-1),'Color',[0.5 0.5 0.5])       
    hold on
end
axis tight
xlabel('Time(s)')
ax=gca;
ax.YTick=linspace(k*(-i2+1),0,i2);
LabelOk=Labels(vect); %posar els labels amb el nou ordre
ax.YTickLabel=LabelOk(i2:-1:1);

figure
k=150;
for i2 = 1:length(vect) %size(senyals_prom,2)
    senyal=detrend(senyals_plot_nofilt(ev_inici-win_2:ev_final+win_2,vect(i2)),'constant');

    plot(time(ev_inici-win_2:ev_final+win_2),senyal-k*(i2-1),'Color',[0.5 0.5 0.5])       
    hold on
end
axis tight
xlabel('Time(s)')
ax=gca;
ax.YTick=linspace(k*(-i2+1),0,i2);
LabelOk=Labels(vect); %posar els labels amb el nou ordre
ax.YTickLabel=LabelOk(i2:-1:1);
