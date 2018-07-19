function epoca=llegir_epoca(hipno,ini,fin)
    % funció que llegeix a quina epoca està un event. 
    %Ini i fin son inicis i finals en segons, Hipno s'extreu del
    %hipnograma (obrir hipnograma i llegir EDF.hipno)
    % CORRESPONDENCIA:
    % 2 --> N3
    % 3 --> N2
    % 4 --> N1 
    % 5 --> REM
    % 6 --> Awake
    
    l_hipno=1:length(hipno);
    inih=ini/5;
    finh=fin/5;
            
    for ep=1:length(hipno)
        pos = ep;
        if hipno(ep) == 4
            hipno(ep) = 2; % SWS or N3 (former S4)
        elseif hipno(ep) == 3
            hipno(ep) = 2; % SWS or N3 (former S3)
        elseif hipno(ep) == 2
            hipno(ep) = 3; % Light sleep or N2 (S2)
        elseif hipno(ep) == 1 
            hipno(ep) = 4; % Transition to sleep or N1
        elseif hipno(ep) == 9
            hipno(ep) = 6; % Awake
        elseif hipno(ep) == 8
            while hipno(pos) == 8
                pos = pos-1;
            end
            hipno(ep) = hipno(pos);
        end
    end  
    
    id_ini=find(l_hipno>=inih,1,'first');
    id_fin=find(l_hipno>=finh,1,'first');

    epoca=round(mean(hipno(id_ini:id_fin)));
        
        
