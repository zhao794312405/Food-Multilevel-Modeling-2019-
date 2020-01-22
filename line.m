close all
clear all
clc

xmk = normrnd(0.035/12,0.0075^0.5,120,1);
xbar = 0.00297;
delta = xmk-xbar;
[m n]=size(delta);
for i=1:m 
    for j=1:n 
        delta2(i,j)=(delta(i,j))^2
    end
end
sigm2 = sum(sum(delta2))/119;
sigm2=0.0.0072;
sig2=12*sigm2;
sig=sig2^0.5;





