function [EoI] = filtre_EoI(Ppunt,Npunt,A2)
    z = 1;
    for i = 1:length(Ppunt)
        Ppunt2(i) = find(A2(1:Ppunt(i))==0,1,'last')+1;
        Npunt2(i) = find(A2(Npunt(i):end)==0,1,'first')-1+Npunt(i);
        EoI(z,1) = Ppunt2(i);
        EoI(z,2) = Npunt2(i);
        z = z+1;
    end
    EoI = unique(EoI,'rows');
end