% function written by Supatim (displayGammaTuningSFOri) to calculate
% preferred orientation and orientation selectivity

function [prefOrientation,orientationSelectivity] = getPOandOS(x,oValsUnique)
num=0;
den=0;

for i=1:length(oValsUnique)
    num = num+x(i)*sind(2*oValsUnique(i));
    den = den+x(i)*cosd(2*oValsUnique(i));
end

prefOrientation = 90*atan2(num,den)/pi;
orientationSelectivity = abs(den+1i*num)/sum(x);

if prefOrientation<0
    prefOrientation = prefOrientation+180;
end
end