function ov_events=find_overlapped(events,l_samples)

%% OVERLAPPING
% Creamos matriz de ceros
B = zeros(length(events),l_samples);

% Definimos el porcentaje de overlapping

ov = 0.8;


% Rellenamos la matriz con segmentos que sean [ini+(ov/2*long_evento) + fin-(ov/2*long_evento)] 
% (Si el overlapping es del 50% quitamos un 25% del inicio y del final)

for i = 1:length(events)
    
    ini = events(i).eoi(:,1);
    fi = events(i).eoi(:,2);
    long_evento = fi - ini;
    
    ini_ov = ini + round(ov/2*long_evento); % Aqui habria que definir si se es mas restrictivo (poniendo un ceil) pero no debe cambiar mucho
    fi_ov = fi - round(ov/2*long_evento);
    
    for j = 1:length(ini_ov)
        B(i,ini_ov(j):fi_ov(j))=ones(1,1+fi_ov(j)-ini_ov(j));
    end
end


overlapped = sum(B)>0;

% Detectar eventos en overlapped

change=diff(overlapped);
%

ch_pos=sum(change==1);
ch_neg=sum(change==-1);
if ch_pos>ch_neg %si hay 1 positivo mas que negativo, entonces es que hemos acabado encima del threshold--> el ultimo eoi acaba en la muestra final
    p_aux=find(change==1)';
    n_aux=find(change==-1)';
    n_aux(end+1)=length(overlapped);
    ov_interval(:,1)=p_aux;
    ov_interval(:,2)=n_aux;
elseif ch_pos<ch_neg %si hay 1 negativo mas que positivo, entonces es que hemos empezado encima del threshold --> primera muestra es 1
    p_aux(1)=1;
    p_aux(2:ch_pos)=find(change==1)';
    n_aux=find(change==-1)';
    ov_interval(:,1)=p_aux;
    ov_interval(:,2)=n_aux;
else %los dos iguales, no hacemos nada
    ov_interval(:,1)=find(change==1)';
    ov_interval(:,2)=find(change==-1)';
end

% Iteramos por cada canal y cada evento y determinamos a que evento
% solapado pertenece

for i = 1:size(ov_interval,1) % Crear estructura con id de evento y canal
    ov_events(i).id_channel=[];
    ov_events(i).id_event=[];
end

for i = 1:length(events)
    ini = events(i).eoi(:,1);
    fi = events(i).eoi(:,2);
    long_evento = fi - ini;
    ini_ov = ini + round(ov/2*long_evento); % Aqui habria que definir si se es mas restrictivo (poniendo un ceil) pero no debe cambiar mucho
    fi_ov = fi - round(ov/2*long_evento);
    for j = 1:length(ini)
        detected=0;
        k=1;
        while detected==0
           if ov_interval(k,1) <= ini_ov(j) && ov_interval(k,2)>= fi_ov(j)
               detected=1;
               ov_events(k).id_channel=[ov_events(k).id_channel i];
               ov_events(k).id_event=[ov_events(k).id_event j];
           end
           k=k+1;
        end
    end
end
               
            
