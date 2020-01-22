close all
clear all
clc
x=xlsread('newdata.xlsx',['C2:AE800']);
y=xlsread('newdata.xlsx',['B2:B800']);
y_test_nn=xlsread('newdata.xlsx',['B801:B974'])'
inputs = x';
targets = y';
[p1,minp,maxp,t1,mint,maxt]=premnmx(inputs,targets);
%%



%创建网络
net=newff(minmax(inputs),[29,6,1],{'tansig','tansig','purelin'},'trainlm');
%设置训练次数
net.trainParam.epochs = 1000;
%设置收敛误差
net.trainParam.goal=0.04;
%训练网络
[net,tr]=train(net,p1,t1);
%trainlm, Epoch 0/5000, MSE 0.533351/1e-004, Gradient 18.9079/1e-06
%TRAINLM, Epoch 24/5000, MSE 8.81926e-008/1e-004, Gradient 0.0022922/1e-06
%TRAINLM, Performance goal met.

%输入数据
a=xlsread('newdata.xlsx',['C801:AE974']);
a=a';
%将输入数据归一化
a=premnmx(a);
%放入到网络输出数据
b=sim(net,a);
%将得到的数据反归一化得到预测数据
c=postmnmx(b,mint,maxt);
%% 画图，计算mse
figure

hold on
plot( y_test_nn, 'r', 'linewidth', 2 );
plot( c, 'b--', 'linewidth', 2 );
legend({ '真实值', '神经网络预测值'})
nn_per_error = mean(abs(c-y_test_nn) ./ y_test_nn);
nn_mse_error = mean( (c - y_test_nn).^2 );
fprintf('nn model: relative error on test set: %.6f\n', nn_per_error);
fprintf('nn model: mse on test set: %.6f\n', nn_mse_error);