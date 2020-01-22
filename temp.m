clear all
close all
clc
w=[.7;.2;.1];
c=[7.344 2.015 3.309;2.015 4.41 1.202;3.309 1.202 3.497]./100;
pi=[.07206;.0295;.0356];
tao=10;
p=[1 0 0;-1 1 0];
q=[.025;.02];
omega=[0.02^2 0;0 0.015^2];
sigma=tao*c;
miubl=pi+sigma*p'*(p*sigma*p'+omega)^(-1)*(q-p*pi)
cbl=c+sigma-sigma*p'*(p*sigma*p'+omega)^(-1)*p*sigma
wbl=.25*cbl^(-1)*miubl
