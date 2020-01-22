clear all
clc
x=-10:0.1:10;
y=1./(1+exp(-x));
figure;
plot(x,y)
grid on