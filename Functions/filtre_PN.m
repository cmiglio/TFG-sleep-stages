function [Ppunt,Npunt] = filtre_PN(envolvent_CZabs,Th)
n = 1; m = 1;
    for i=1:length(envolvent_CZabs)-1
        if envolvent_CZabs(i)<=Th && envolvent_CZabs(i+1)>=Th
            Ppunt(n)=i;
            n=n+1;
        end
        if envolvent_CZabs(i)>=Th && envolvent_CZabs(i+1)<=Th
            Npunt(m)=i;
            m=m+1;
        end
    end

end

