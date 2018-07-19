function eois=find_eois(signalf,fs,k)
% Function to find events of interest in signalf using hilbert envelope and
% a relative threshold (mean+k*sd)
win=round(fs*10); %discard first and last 10 s
hb=abs(hilbert(signalf));
m=mean(hb(win:end-win));
sd=std(hb(win:end-win));

th=(m+k*sd);
tp=(hb>(th));
tp2=(hb>th/2);
change=diff(tp2);

if change(find(change,1))==-1
    change(find(change,1))=0;
end

ch_pos=sum(change==1);
ch_neg=sum(change==-1);
if ch_pos>ch_neg %si hay 1 positivo mas que negativo, entonces es que hemos acabado encima del threshold--> descartamos el ultimo positivo
    p_aux=find(change==1)';
    p_aux=p_aux(1:end-1);
    eoi_f1(:,1)=p_aux;
    eoi_f1(:,2)=find(change==-1)';
elseif ch_pos<ch_neg %si hay 1 negativo mas que positivo, entonces es que hemos empezado encima del threshold --> descartamos el primer negativo
    n_aux=find(change==-1)';
    n_aux=n_aux(2:end);
    eoi_f1(:,1)=find(change==1)';
    eoi_f1(:,2)=n_aux;
else %los dos iguales, no hacemos nada
    eoi_f1(:,1)=find(change==1)';
    eoi_f1(:,2)=find(change==-1)';
end

toDel=[];
for j=1:size(eoi_f1,1)
    if sum(signalf(eoi_f1(j,1):eoi_f1(j,2))>th)==0
        toDel=[toDel j];
    end
end
eoi_f1(toDel,:)=[];
eoi_f2=eoi_f1;


eoi_f3=eoi_f2((eoi_f2(:,2)-eoi_f2(:,1))>=0.5*fs,:); % at least 0.5 s
eoi_f3=eoi_f3((eoi_f3(:,2)-eoi_f3(:,1))<=2*fs,:); % maximum 2 s


eoi_f4=eoi_f3;
% for j=1:(size(eoi_f4,1)-1)
%     if (eoi_f4(j+1,1)-eoi_f4(j,2))<fs %merge events that are least than 1s away
%         eoi_f4(j+1,1)=eoi_f4(j,1);
%     end
% end
% [~,ia,~]=unique(eoi_f4(:,1),'last'); %Select indexes with the same begining keep the last index only
% eoi_f4=eoi_f4(ia,:);

%clear those eois that can not be analyzed because they are near the
%begining/end (we cannot perform stockwell transform into them)
% clear first and last 10 seconds
eoi_f5=eoi_f4;

toDel=[];
for j=1:size(eoi_f5,1)
    if (eoi_f5(j,1)-win)<1 || (eoi_f5(j,2)+win)>size(signalf,1)
        toDel=[toDel j];
    end
end
eoi_f5(toDel,:)=[];

eois.f1=eoi_f1; %#ok<*SAGROW>
eois.f2=eoi_f2;
eois.f3=eoi_f3;
eois.f4=eoi_f4;
eois.f5=eoi_f5;
eois.m=m;
eois.sd=sd;
