%输入数据
a=xlsread('newdata.xlsx','C700:AE974');
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