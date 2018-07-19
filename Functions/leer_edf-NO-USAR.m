function [senyales, EDF] = leer_edf(EDF, duracion, epoca, dispositivo)

canales = 1 : EDF.NS;
EDF.channel = canales;
dur_epoca = 5;
x = dur_epoca*epoca;
if EDF.NRec < 0
    Ch_data = fread(EDF.FILE.FID, 'int16');
    R = sum(EDF.Dur*EDF.SampleRate);
    EDF.NRec = fix(length(Ch_data)./R);
    clear('Ch_data', 'R');
end
if x + duracion <= EDF.Dur*EDF.NRec
    Start = x/EDF.Dur;
    NoS = duracion/EDF.Dur;
    NoR = ceil((Start+NoS))-floor(Start);
    ini = floor(Start);
    offset = EDF.AS.bpb*ini;
    inicial = EDF.HeadLen+offset;
    ini = ini*EDF.Dur;
end
bi = [0; cumsum(EDF.SPR)];
bi = bi(canales);
count = zeros(length(canales), 1);
for i = 1 : NoR
    for k = 1 : length(canales)
        inicio = inicial + (EDF.AS.bpb*(i-1)) + (bi(k)*2);
        fseek(EDF.FILE.FID, inicio, -1);
        [tmp, cnt] = fread(EDF.FILE.FID, EDF.SPR(canales(k)), 'int16');
        if i == 1
            if ini == x
                if duracion >= EDF.Dur
                    S(count(k)+1 : count(k)+cnt, k) = tmp;
                    clear('tmp');
                    count(k) = count(k) + cnt;
                else
                    x2 = x + duracion;
                    dif = x2 - ini;
                    cnt = round(dif*EDF.SPR(canales(k))/EDF.Dur);
                    S(count(k)+1:count(k)+cnt,k)=tmp(1:round(dif*EDF.SPR(canales(k))/EDF.Dur));
                    clear('tmp');
                    count(k)=count(k)+cnt;
                end
            elseif ini < x
                if x + duracion < ini + EDF.Dur
                    dif1 = x - ini;
                    dif2 = x + duracion-ini;
                    cnt = round(dif2*EDF.SPR(canales(k))/EDF.Dur)-round(dif1*EDF.SPR(canales(k))/EDF.Dur);
                    S(count(k)+1 : count(k)+cnt, k) = tmp(round(dif1*EDF.SPR(canales(k))/EDF.Dur)+1:round(dif2*EDF.SPR(canales(k))/EDF.Dur));
                    clear('tmp');
                    count(k) = count(k) + cnt;
                else
                    dif = x - ini;
                    cnt = length(tmp)-round(dif*EDF.SPR(canales(k))/EDF.Dur);
                    S(count(k)+1:count(k)+cnt,k)=tmp(round(dif*EDF.SPR(canales(k))/EDF.Dur)+1:length(tmp));
                    clear('tmp');
                    count(k) = count(k) + cnt;
                end
            end
        elseif i == NoR &&  i~=1 
            ini2 = ini + EDF.Dur*(NoR-1);
            x2 = x + duracion;
            dif = x2 - ini2;
            cnt = round(dif*EDF.SPR(canales(k))/EDF.Dur);
            S(count(k)+1 : count(k)+cnt, k) = tmp(1:round(dif*EDF.SPR(canales(k))/EDF.Dur));
            clear('tmp');
            count(k) = count(k) + cnt;
        else
            S(count(k)+1 : count(k)+cnt, k) = tmp(1 : length(tmp));
            clear('tmp');
            count(k) = count(k) + cnt;
        end
    end
end

% CALIBRACION DE LAS SEÑALES
S = [ones(size(S,1),1) S]*EDF.Calib([1 canales+1],:);

if strcmp(dispositivo, 'deltamed')
    senyales(:,1)=S(:,24)-S(:,20);   % EOG izquierdo - A1
    senyales(:,2)=S(:,23)-S(:,20);   % EOG derecho - A1
    senyales(:,3)=S(:,9)-S(:,21);    % Fp1 - A2
    senyales(:,4)=S(:,1)-S(:,20);    % Fp2 - A1
    senyales(:,5)=S(:,14)-S(:,21);   % F7 - A2
    senyales(:,6)=S(:,10)-S(:,21);   % F3 - A2
    senyales(:,7)=S(:,17)-S(:,20);   % Fz - A1
    senyales(:,8)=S(:,2)-S(:,20);    % F4 - A1
    senyales(:,9)=S(:,6)-S(:,20);    % F8 - A1
    senyales(:,10)=S(:,15)-S(:,21);  % T3 - A2
    senyales(:,11)=S(:,11)-S(:,21);  % C3 - A2
    senyales(:,12)=S(:,18)-S(:,20);  % Cz - A1
    senyales(:,13)=S(:,3)-S(:,20);   % C4 - A1
    senyales(:,14)=S(:,7)-S(:,20);   % T4 - A1
    senyales(:,15)=S(:,16)-S(:,21);  % T5 - A2
    senyales(:,16)=S(:,12)-S(:,21);  % P3 - A2
    senyales(:,17)=S(:,19)-S(:,20);  % Pz - A1
    senyales(:,18)=S(:,4)-S(:,20);   % P4 - A1
    senyales(:,19)=S(:,8)-S(:,20);   % T6 - A1
    senyales(:,20)=S(:,13)-S(:,21);  % O1 - A2
    senyales(:,21)=S(:,5)-S(:,20);   % O2 - A1
elseif strcmp(dispositivo,'profusion')
    if EDF.NS == 29 || EDF.NS == 28 || EDF.NS == 27
        senyales(:,1)=S(:,19);   % EOG izquierdo - A1
        senyales(:,2)=S(:,20);   % EOG derecho - A1
        senyales(:,3)=S(:,1);    % Fp1 - A2
        senyales(:,4)=S(:,9);    % Fp2 - A1
        senyales(:,5)=S(:,6);    % F7 - A2
        senyales(:,6)=S(:,2);    % F3 - A2
        senyales(:,7)=S(:,16);   % Fz - A1
        senyales(:,8)=S(:,10);   % F4 - A1
        senyales(:,9)=S(:,13);   % F8 - A1
        senyales(:,10)=S(:,7);   % T3 - A2
        senyales(:,11)=S(:,3);   % C3 - A2
        senyales(:,12)=S(:,17);  % Cz - A1
        senyales(:,13)=S(:,11);  % C4 - A1
        senyales(:,14)=S(:,14);  % T4 - A1
        senyales(:,15)=S(:,8);   % T5 - A2
        senyales(:,16)=S(:,4);   % P3 - A2
        senyales(:,17)=S(:,18);  % Pz - A1
        senyales(:,18)=S(:,15);  % T6 - A1
        senyales(:,19)=S(:,5);   % O1 - A2
        senyales(:,20)=S(:,12);  % O2 - A1
    elseif EDF.NS==26
        senyales(:,1)=S(:,20);   % EOG izquierdo - A1
        senyales(:,2)=S(:,21);   % EOG derecho - A1
        senyales(:,3)=S(:,1);    % Fp1 - A2
        senyales(:,4)=S(:,9);    % Fp2 - A1
        senyales(:,5)=S(:,6);    % F7 - A2
        senyales(:,6)=S(:,2);    % F3 - A2
        senyales(:,7)=S(:,17);   % Fz - A1
        senyales(:,8)=S(:,10);   % F4 - A1
        senyales(:,9)=S(:,14);   % F8 - A1
        senyales(:,10)=S(:,7);   % T3 - A2
        senyales(:,11)=S(:,3);   % C3 - A2
        senyales(:,12)=S(:,18);  % Cz - A1
        senyales(:,13)=S(:,11);  % C4 - A1
        senyales(:,14)=S(:,15);  % T4 - A1
        senyales(:,15)=S(:,8);   % T5 - A2
        senyales(:,16)=S(:,4);   % P3 - A2
        senyales(:,17)=S(:,19);  % Pz - A1
        senyales(:,18)=S(:,12);  % P4 - A1
        senyales(:,19)=S(:,16);  % T6 - A1
        senyales(:,20)=S(:,5);   % O1 - A2
        senyales(:,21)=S(:,13);  % O2 - A1
    elseif EDF.NS == 13
        senyales(:,1)=S(:,7);    % EOG izquierdo - A2
        senyales(:,2)=S(:,8);    % EOG derecho - A2
        senyales(:,3)=S(:,1);    % F3 - A2
        senyales(:,4)=S(:,4);    % F4 - A1
        senyales(:,5)=S(:,2);    % C3 - A2
        senyales(:,6)=S(:,5);    % C4 - A1
        senyales(:,7)=S(:,3);    % O1 - A2
        senyales(:,8)=S(:,6);    % O2 - A1
    elseif EDF.NS == 21
        senyales(:,1)=S(:,1);    % EOG izquierdo - A2
        senyales(:,2)=S(:,2);    % EOG derecho - A1
        senyales(:,3)=S(:,3);    % F3 - A2
        senyales(:,4)=S(:,4);    % F4 - A1
        senyales(:,5)=S(:,5);    % C3 - A2
        senyales(:,6)=S(:,6);    % C4 - A1
        senyales(:,7)=S(:,7);    % O1 - A2
        senyales(:,8)=S(:,8);    % O2 - A1
    elseif EDF.NS == 30
        senyales(:,1)=S(:,20);   % EOG izquierdo - A1
        senyales(:,2)=S(:,21);   % EOG derecho - A1
        senyales(:,3)=S(:,1);    % Fp1 - A2
        senyales(:,4)=S(:,9);    % Fp2 - A1
        senyales(:,5)=S(:,6);    % F7 - A2
        senyales(:,6)=S(:,2);    % F3 - A2
        senyales(:,7)=S(:,17);   % Fz - A1
        senyales(:,8)=S(:,10);   % F4 - A1
        senyales(:,9)=S(:,14);   % F8 - A1
        senyales(:,10)=S(:,7);   % T3 - A2
        senyales(:,11)=S(:,3);   % C3 - A2
        senyales(:,12)=S(:,18);  % Cz - A1
        senyales(:,13)=S(:,11);  % C4 - A1
        senyales(:,14)=S(:,15);  % T4 - A1
        senyales(:,15)=S(:,8);   % T5 - A2
        senyales(:,16)=S(:,4);   % P3 - A2
        senyales(:,17)=S(:,19);  % Pz - A1
        senyales(:,18)=S(:,12);  % P4 - A1
        senyales(:,19)=S(:,16);  % T6 - A1
        senyales(:,20)=S(:,5);   % O1 - A2
        senyales(:,21)=S(:,13);  % O2 - A1
    elseif EDF.NS == 34
        senyales(:,1)=S(:,1);    % EOG izquierdo - A1
        senyales(:,2)=S(:,2);    % EOG derecho - A1
        senyales(:,3)=S(:,3);    % Fp1 - A2
        senyales(:,4)=S(:,11);   % Fp2 - A1
        senyales(:,5)=S(:,8);    % F7 - A2
        senyales(:,6)=S(:,4);    % F3 - A2
        senyales(:,7)=S(:,19);   % Fz - A1
        senyales(:,8)=S(:,12);   % F4 - A1
        senyales(:,9)=S(:,16);   % F8 - A1
        senyales(:,10)=S(:,9);   % T3 - A2
        senyales(:,11)=S(:,5);   % C3 - A2
        senyales(:,12)=S(:,20);  % Cz - A1
        senyales(:,13)=S(:,13);  % C4 - A1
        senyales(:,14)=S(:,17);  % T4 - A1
        senyales(:,15)=S(:,10);  % T5 - A2
        senyales(:,16)=S(:,6);   % P3 - A2
        senyales(:,17)=S(:,21);  % Pz - A1
        senyales(:,18)=S(:,14);  % P4 - A1
        senyales(:,19)=S(:,18);  % T6 - A1
        senyales(:,20)=S(:,7);   % O1 - A2
        senyales(:,21)=S(:,15);  % O2 - A1
    end
elseif strcmp(dispositivo, 'NewYork')
    if EDF.NS == 20 || EDF.NS==21
        senyales(:,1)=S(1:count(7),7);    % EOG 1 - M2
        senyales(:,2)=S(1:count(8),8);    % EOG 2 - M1
        senyales(:,3)=S(1:count(1),1);    % F3 - M2
        senyales(:,4)=S(1:count(2),2);    % F4 - M1
        senyales(:,5)=S(1:count(3),3);    % C3 - M2
        senyales(:,6)=S(1:count(4),4);    % C4 - M1
        senyales(:,7)=S(1:count(5),5);    % O1 - M2
        senyales(:,8)=S(1:count(6),6);    % O2 - M1
    elseif EDF.NS == 17
        senyales(:,1)=S(1:count(4),4);     % EOG1 - M1
        senyales(:,2)=S(1:count(5),5);     % EOG2 - M1
        senyales(:,3)=S(1:count(1),1);     % F4 - M1
        senyales(:,4)=S(1:count(2),2);     % C3 - M2
        senyales(:,5)=S(1:count(3),3);     % O2 - M1
    elseif EDF.NS == 25
        senyales(:,1)=S(1:count(12),12);    % EOG L
        senyales(:,2)=S(1:count(13),13);    % EOG R
        senyales(:,3)=S(1:count(11),11);    % Fz - A2
        senyales(:,4)=S(1:count(7),7);      % C3 - A2
        senyales(:,5)=S(1:count(8),8);      % C4 - A1
        senyales(:,6)=S(1:count(9),9);      % O1 - A2
        senyales(:,7)=S(1:count(10),10);    % O2 - A1
    elseif EDF.NS == 19
        senyales(:,1)=S(1:count(6),6);    % EOG L
        senyales(:,2)=S(1:count(7),7);    % EOG R
        senyales(:,3)=S(1:count(1),1);    % Fz - A2
        senyales(:,4)=S(1:count(2),2);    % C3 - A2
        senyales(:,5)=S(1:count(3),3);    % C4 - A1
        senyales(:,6)=S(1:count(4),4);    % O1 - A2
        senyales(:,7)=S(1:count(5),5);    % O2 - A1
    elseif EDF.NS == 23
        senyales(:,1)=S(1:count(8),8);    % EOG L
        senyales(:,2)=S(1:count(9),9);    % EOG R
        senyales(:,3)=S(1:count(14),14);  % F3 - A2
        senyales(:,4)=S(1:count(5),5);    % C3 - A2
        senyales(:,5)=S(1:count(6),6);    % C4 - A1
        senyales(:,6)=S(1:count(10),10);  % O1 - A2
        senyales(:,7)=S(1:count(7),7);    % O2 - A1
    end
end

