function [equityLoss equity equityZero paymentVector error] = endogenousdebtrank(interbankLiabilitiesMatrix,externalAssets,externalLiabilities, marketVolatility, recoveryRate)

% PB for BDF2017
%[5] Barucca, Paolo, Marco Bardoscia, Fabio Caccioli, Marco D?Errico, Gabriele Visentin, Stefano Battiston, and Guido Caldarelli.  "Network valuation in financial systems. " (2016).
%interbankLiabilitiesMatrix => L
%A => A
%externalAssets => Ae
%externalLiabilities => Le
%exogenousRecoveryRate => R

L = interbankLiabilitiesMatrix;
A = L';
Ae = externalAssets;
Le = externalLiabilities;


epsilon = 10^(-5);
max_counts = 10^5;

nbanks = length(L);
valuationVector = zeros([nbanks 1]);


l = sum(L,2);

equityZero = Ae - Le + sum(A,2) - l;

equity = equityZero;

error = 1;
counts = 1;

while (error > epsilon)&&(counts < max_counts)
    
    oldEquity = equity;
    for i = 1:nbanks
        valuationVector(i) = valuationFun(equity(i), Ae(i), l(i));
    end
    equity = Ae - Le + A*(valuationVector) - l;
    
    error = norm(equity - oldEquity)/norm(equity);
    counts = counts +1;
end

for i = 1:nbanks
    valuationVector(i) = valuationFun(equity(i), Ae(i), l(i));
end

equity = Ae - Le + A*(valuationVector) - l;

paymentVector = max(0,min( Ae - Le + A*valuationVector, l));

equityLoss = equity - equityZero;

    function V = valuationFun(Ei, Aei, li)
        V = 1 - probDefFun(Ei, Aei, li) + recoveryRate*endogenousRecoveryFun(Ei, Aei, li);
    end

    function p = probDefFun(Ei, Aei, li)
        if Ei<Aei
            p = 0.5*(1 +erf((log(1-Ei/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility)));
        else
            p = 0;
        end
    end

    function rho = endogenousRecoveryFun(Ei, Aei, li)
        rho = max(1 + Ei/li,0)*( probDefFun(Ei, Aei, li) -  probDefFun(Ei+li, Aei, li)) + (1/(2*li)*condAverageFun(Ei, Aei, li));
    end

    function cav = condAverageFun(Ei, Aei, li)
        
        if Ei<Aei-li
            
            cav = -erf((-log(1-Ei/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility)) ...
                -erf((log(1-Ei/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility)) ...
                +erf((log(1-(Ei+li)/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility)) ...
                +erf(-(log(1-(Ei+li)/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility));
        else if Ei<Aei
                cav = -erf((-log(1-Ei/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility)) ...
                      -erf((log(1-Ei/Aei) + 0.5*marketVolatility^2)/(sqrt(2)*marketVolatility));
                
            end
        end
        
    end

end
