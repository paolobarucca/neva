%BIG DATA FINANCE - EXERCISE 6

nbanks = 3;
interbankLiabilitiesMatrix = [0 4  0; ...
                              0  0 3;... 
                              2 0  0];

externalAssets =      [20; 20; 10];
externalLiabilities = [17; 18; 8];
marketVolatility = 0.1;
recoveryRate = 0.7;

uniformShock = 0.1;

%new% 
shock = uniformShock*externalAssets;
externalAssetsShocked  =  externalAssets - shock;

[equityLoss equity equityZero paymentVector error] = endogenousdebtrank(interbankLiabilitiesMatrix,externalAssetsShocked,externalLiabilities, ...
                                                            marketVolatility, recoveryRate);

bdfplot(nbanks, equityZero, equityZero + shock, equity)