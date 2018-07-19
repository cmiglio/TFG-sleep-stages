function [EoI_f,EoI_fg] = filtre_duracio(EoI,fs,epoca,duracion)
j = 1;
    for i = 1:length(EoI)
        if abs(EoI(i,1)-EoI(i,2))>=(0.5*fs)&&abs(EoI(i,1)-EoI(i,2))<=(2*fs)
            EoI_f(j,1) = EoI(i,1);
            EoI_f(j,2) = EoI(i,2);
            j = j+1;
        end
    end
% Per obtenir la mostra "global" s'ha de sumar per (epoca*duracion)*fs+1
EoI_fg = EoI_f+(epoca*duracion)*fs+1;
end

