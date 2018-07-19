function [senyals,EDF]=leeredf_DEF(EDF,Lepoch,Nepoch,dispositivo)

canales=[1:EDF.NS];
EDF.channel=canales;
x=Lepoch*Nepoch;
if EDF.NRec<0,
    Ch_data=fread(EDF.FILE.FID,'int16');
    R=sum(EDF.Dur*EDF.SampleRate);
    EDF.NRec=fix(length(Ch_data)./R);
    clear Ch_data R;
end
if ((x+Lepoch)<=EDF.Dur*EDF.NRec),
   Start=x/EDF.Dur;
   NoS=Lepoch/EDF.Dur;
   NoR=ceil((Start+NoS))-floor(Start);
   ini=floor(Start);
   offset=EDF.AS.bpb*ini;
   inicial=EDF.HeadLen+offset;
   ini=ini*EDF.Dur;
end
bi=[0;cumsum(EDF.SPR)];
bi=bi(canales);
count=zeros(length(canales),1);
for i=1:NoR,
   for k=1:length(canales),
      inicio=inicial+(EDF.AS.bpb*(i-1))+(bi(k)*2);
      fseek(EDF.FILE.FID,inicio,-1);
      [tmp,cnt]=fread(EDF.FILE.FID,EDF.SPR(canales(k)),'int16');
      if (i==1),
         if (ini==x),
            if (Lepoch>=EDF.Dur),
               S(count(k)+1:count(k)+cnt,k)=tmp;
               clear tmp; 
               count(k)=count(k)+cnt;
            else
               x2=x+Lepoch;
               dif=x2-ini;
               cnt=round(dif*EDF.SPR(canales(k))/EDF.Dur);
               S(count(k)+1:count(k)+cnt,k)=tmp(1:round(dif*EDF.SPR(canales(k))/EDF.Dur));
               clear tmp;
               count(k)=count(k)+cnt;
            end
         elseif (ini<x),
            if ((x+Lepoch)<(ini+EDF.Dur)),
               dif1=x-ini;
               dif2=x+Lepoch-ini;
               cnt=round(dif2*EDF.SPR(canales(k))/EDF.Dur)-round(dif1*EDF.SPR(canales(k))/EDF.Dur);
               S(count(k)+1:count(k)+cnt,k)=tmp(round(dif1*EDF.SPR(canales(k))/EDF.Dur)+1:round(dif2*EDF.SPR(canales(k))/EDF.Dur));
               clear tmp;
               count(k)=count(k)+cnt;
            else   
               dif=x-ini;
               cnt=length(tmp)-round(dif*EDF.SPR(canales(k))/EDF.Dur);
               S(count(k)+1:count(k)+cnt,k)=tmp(round(dif*EDF.SPR(canales(k))/EDF.Dur)+1:length(tmp));
               clear tmp;
               count(k)=count(k)+cnt;
            end
         end
      elseif ((i==NoR) & (i~=1)),
         ini2=ini+(EDF.Dur*(NoR-1));
         x2=x+Lepoch;
         dif=x2-ini2;
         cnt=round(dif*EDF.SPR(canales(k))/EDF.Dur);
         S(count(k)+1:count(k)+cnt,k)=tmp(1:round(dif*EDF.SPR(canales(k))/EDF.Dur));
         clear tmp;
         count(k)=count(k)+cnt;
      else
         S(count(k)+1:count(k)+cnt,k)=tmp(1:length(tmp)); 
         clear tmp;
         count(k)=count(k)+cnt;
      end
   end
end

% CALIBRACIÓN DE LAS SEÑALES
Ssincal=S;
S=[ones(size(S,1),1) S]*EDF.Calib([1 canales+1],:);
%S=S(:,canales);

if strcmp(dispositivo,'deltamed'),
    senyals(:,1)=S(:,24)-S(:,20);   % EOG izquierdo - A1
    senyals(:,2)=S(:,23)-S(:,20);   % EOG derecho - A1
    senyals(:,3)=S(:,9)-S(:,21);    % Fp1 - A2
    senyals(:,4)=S(:,1)-S(:,20);    % Fp2 - A1
    senyals(:,5)=S(:,14)-S(:,21);   % F7 - A2
    senyals(:,6)=S(:,10)-S(:,21);   % F3 - A2
    senyals(:,7)=S(:,17)-S(:,20);   % Fz - A1
    senyals(:,8)=S(:,2)-S(:,20);    % F4 - A1
    senyals(:,9)=S(:,6)-S(:,20);    % F8 - A1
    senyals(:,10)=S(:,15)-S(:,21);   % T3 - A2
    senyals(:,11)=S(:,11)-S(:,21);  % C3 - A2
    senyals(:,12)=S(:,18)-S(:,20);  % Cz - A1
    senyals(:,13)=S(:,3)-S(:,20);   % C4 - A1
    senyals(:,14)=S(:,7)-S(:,20);   % T4 - A1
    senyals(:,15)=S(:,16)-S(:,21);  % T5 - A2
    senyals(:,16)=S(:,12)-S(:,21);  % P3 - A2
    senyals(:,17)=S(:,19)-S(:,20);  % Pz - A1
    senyals(:,18)=S(:,4)-S(:,20);   % P4 - A1
    senyals(:,19)=S(:,8)-S(:,20);   % T6 - A1
    senyals(:,20)=S(:,13)-S(:,21);  % O1 - A2
    senyals(:,21)=S(:,5)-S(:,20);   % O2 - A1
elseif strcmp(dispositivo,'profusion'),
    if (EDF.NS==29) | (EDF.NS==28) | (EDF.NS==27),
        senyals(:,1)=S(:,19);   % EOG izquierdo - A1
        senyals(:,2)=S(:,20);   % EOG derecho - A1
        senyals(:,3)=S(:,1);    % Fp1 - A2
        senyals(:,4)=S(:,9);    % Fp2 - A1
        senyals(:,5)=S(:,6);    % F7 - A2
        senyals(:,6)=S(:,2);    % F3 - A2
        senyals(:,7)=S(:,16);   % Fz - A1
        senyals(:,8)=S(:,10);   % F4 - A1
        senyals(:,9)=S(:,13);   % F8 - A1
        senyals(:,10)=S(:,7);   % T3 - A2
        senyals(:,11)=S(:,3);   % C3 - A2
        senyals(:,12)=S(:,17);  % Cz - A1
        senyals(:,13)=S(:,11);  % C4 - A1
        senyals(:,14)=S(:,14);  % T4 - A1
        senyals(:,15)=S(:,8);   % T5 - A2
        senyals(:,16)=S(:,4);   % P3 - A2
        senyals(:,17)=S(:,18);  % Pz - A1
        senyals(:,18)=S(:,15);  % T6 - A1
        senyals(:,19)=S(:,5);   % O1 - A2
        senyals(:,20)=S(:,12);  % O2 - A1
    elseif EDF.NS==26,
        senyals(:,1)=S(:,20);   % EOG izquierdo - A1
        senyals(:,2)=S(:,21);   % EOG derecho - A1
        senyals(:,3)=S(:,1);    % Fp1 - A2
        senyals(:,4)=S(:,9);    % Fp2 - A1
        senyals(:,5)=S(:,6);    % F7 - A2
        senyals(:,6)=S(:,2);    % F3 - A2
        senyals(:,7)=S(:,17);   % Fz - A1
        senyals(:,8)=S(:,10);   % F4 - A1
        senyals(:,9)=S(:,14);   % F8 - A1
        senyals(:,10)=S(:,7);   % T3 - A2
        senyals(:,11)=S(:,3);   % C3 - A2
        senyals(:,12)=S(:,18);  % Cz - A1
        senyals(:,13)=S(:,11);  % C4 - A1
        senyals(:,14)=S(:,15);  % T4 - A1
        senyals(:,15)=S(:,8);   % T5 - A2
        senyals(:,16)=S(:,4);   % P3 - A2
        senyals(:,17)=S(:,19);  % Pz - A1
        senyals(:,18)=S(:,12);  % P4 - A1
        senyals(:,19)=S(:,16);  % T6 - A1
        senyals(:,20)=S(:,5);   % O1 - A2
        senyals(:,21)=S(:,13);  % O2 - A1
    elseif EDF.NS==13,
        senyals(:,1)=S(:,7);    % EOG izquierdo - A2
        senyals(:,2)=S(:,8);    % EOG derecho - A2
        senyals(:,3)=S(:,1);    % F3 - A2
        senyals(:,4)=S(:,4);    % F4 - A1
        senyals(:,5)=S(:,2);    % C3 - A2
        senyals(:,6)=S(:,5);    % C4 - A1
        senyals(:,7)=S(:,3);    % O1 - A2
        senyals(:,8)=S(:,6);    % O2 - A1
    elseif EDF.NS==21,
        senyals(:,1)=S(:,1);    % EOG izquierdo - A2
        senyals(:,2)=S(:,2);    % EOG derecho - A1
        senyals(:,3)=S(:,3);    % F3 - A2
        senyals(:,4)=S(:,4);    % F4 - A1
        senyals(:,5)=S(:,5);    % C3 - A2
        senyals(:,6)=S(:,6);    % C4 - A1
        senyals(:,7)=S(:,7);    % O1 - A2
        senyals(:,8)=S(:,8);    % O2 - A1
    elseif EDF.NS==30,
        senyals(:,1)=S(:,20);   % EOG izquierdo - A1
        senyals(:,2)=S(:,21);   % EOG derecho - A1
        senyals(:,3)=S(:,1);    % Fp1 - A2
        senyals(:,4)=S(:,9);    % Fp2 - A1
        senyals(:,5)=S(:,6);    % F7 - A2
        senyals(:,6)=S(:,2);    % F3 - A2
        senyals(:,7)=S(:,17);   % Fz - A1
        senyals(:,8)=S(:,10);   % F4 - A1
        senyals(:,9)=S(:,14);   % F8 - A1
        senyals(:,10)=S(:,7);   % T3 - A2
        senyals(:,11)=S(:,3);   % C3 - A2
        senyals(:,12)=S(:,18);  % Cz - A1
        senyals(:,13)=S(:,11);  % C4 - A1
        senyals(:,14)=S(:,15);  % T4 - A1
        senyals(:,15)=S(:,8);   % T5 - A2
        senyals(:,16)=S(:,4);   % P3 - A2
        senyals(:,17)=S(:,19);  % Pz - A1
        senyals(:,18)=S(:,12);  % P4 - A1
        senyals(:,19)=S(:,16);  % T6 - A1
        senyals(:,20)=S(:,5);   % O1 - A2
        senyals(:,21)=S(:,13);  % O2 - A1
    elseif EDF.NS==34,
        senyals(:,1)=S(:,1);    % EOG izquierdo - A1
        senyals(:,2)=S(:,2);    % EOG derecho - A1
        senyals(:,3)=S(:,3);    % Fp1 - A2
        senyals(:,4)=S(:,11);   % Fp2 - A1
        senyals(:,5)=S(:,8);    % F7 - A2
        senyals(:,6)=S(:,4);    % F3 - A2
        senyals(:,7)=S(:,19);   % Fz - A1
        senyals(:,8)=S(:,12);   % F4 - A1
        senyals(:,9)=S(:,16);   % F8 - A1
        senyals(:,10)=S(:,9);   % T3 - A2
        senyals(:,11)=S(:,5);   % C3 - A2
        senyals(:,12)=S(:,20);  % Cz - A1
        senyals(:,13)=S(:,13);  % C4 - A1
        senyals(:,14)=S(:,17);  % T4 - A1
        senyals(:,15)=S(:,10);  % T5 - A2
        senyals(:,16)=S(:,6);   % P3 - A2
        senyals(:,17)=S(:,21);  % Pz - A1
        senyals(:,18)=S(:,14);  % P4 - A1
        senyals(:,19)=S(:,18);  % T6 - A1
        senyals(:,20)=S(:,7);   % O1 - A2
        senyals(:,21)=S(:,15);  % O2 - A1
    end
elseif strcmp(dispositivo,'NewYork'),
    if (EDF.NS==20) | (EDF.NS==21),
        senyals(:,1)=S([1:count(7)],7);    % EOG 1 - M2
        senyals(:,2)=S([1:count(8)],8);    % EOG 2 - M1
        senyals(:,3)=S([1:count(1)],1);    % F3 - M2
        senyals(:,4)=S([1:count(2)],2);    % F4 - M1
        senyals(:,5)=S([1:count(3)],3);    % C3 - M2
        senyals(:,6)=S([1:count(4)],4);    % C4 - M1
        senyals(:,7)=S([1:count(5)],5);    % O1 - M2
        senyals(:,8)=S([1:count(6)],6);    % O2 - M1    
    elseif (EDF.NS==17),
        senyals(:,1)=S([1:count(4)],4);     % EOG1 - M1
        senyals(:,2)=S([1:count(5)],5);     % EOG2 - M1
        senyals(:,3)=S([1:count(1)],1);     % F4 - M1
        senyals(:,4)=S([1:count(2)],2);     % C3 - M2
        senyals(:,5)=S([1:count(3)],3);     % O2 - M1
    elseif (EDF.NS==25),
        senyals(:,1)=S([1:count(12)],12);    % EOG L
        senyals(:,2)=S([1:count(13)],13);    % EOG R
        senyals(:,3)=S([1:count(11)],11);    % Fz - A2
        senyals(:,4)=S([1:count(7)],7);      % C3 - A2
        senyals(:,5)=S([1:count(8)],8);      % C4 - A1
        senyals(:,6)=S([1:count(9)],9);      % O1 - A2
        senyals(:,7)=S([1:count(10)],10);    % O2 - A1
    elseif (EDF.NS==19),
        senyals(:,1)=S([1:count(6)],6);    % EOG L
        senyals(:,2)=S([1:count(7)],7);    % EOG R
        senyals(:,3)=S([1:count(1)],1);    % Fz - A2
        senyals(:,4)=S([1:count(2)],2);    % C3 - A2
        senyals(:,5)=S([1:count(3)],3);    % C4 - A1
        senyals(:,6)=S([1:count(4)],4);    % O1 - A2
        senyals(:,7)=S([1:count(5)],5);    % O2 - A1
    elseif (EDF.NS==23),
        senyals(:,1)=S([1:count(8)],8);    % EOG L
        senyals(:,2)=S([1:count(9)],9);    % EOG R
        senyals(:,3)=S([1:count(14)],14);  % F3 - A2
        senyals(:,4)=S([1:count(5)],5);    % C3 - A2
        senyals(:,5)=S([1:count(6)],6);    % C4 - A1
        senyals(:,6)=S([1:count(10)],10);  % O1 - A2
        senyals(:,7)=S([1:count(7)],7);    % O2 - A1
    end
elseif strcmp(dispositivo,'saphir'),
    senyals(:,1)=S([1:count(1)],1);
    senyals(:,2)=S([1:count(2)],2);
    senyals(:,3)=S([1:count(3)],3);
    senyals(:,4)=S([1:count(4)],4);
    senyals(:,5)=S([1:count(5)],5);
    senyals(:,6)=S([1:count(6)],6);
    senyals(:,7)=S([1:count(7)],7);
    senyals(:,8)=S([1:count(8)],8);
    senyals(:,9)=S([1:count(9)],9);
    senyals(:,10)=S([1:count(10)],10);
    senyals(:,11)=S([1:count(11)],11);
    senyals(:,12)=S([1:count(12)],12);
    senyals(:,13)=S([1:count(13)],13);
    senyals(:,14)=S([1:count(14)],14);
    senyals(:,15)=S([1:count(15)],15);
    senyals(:,16)=S([1:count(16)],16);
    senyals(:,17)=S([1:count(17)],17);
    senyals(:,18)=S([1:count(18)],18);
    senyals(:,19)=S([1:count(19)],19);
    senyals(:,20)=S([1:count(20)],20);
    senyals(:,21)=S([1:count(21)],21);
    senyals(:,22)=S([1:count(22)],22);
    senyals([1:count(23)],23)=S([1:count(23)],23);
    senyals(:,24)=S([1:count(24)],24);
    senyals(:,25)=S([1:count(25)],25);
end
    
