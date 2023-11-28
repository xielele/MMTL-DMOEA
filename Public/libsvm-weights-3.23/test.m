tic;
close all;
clear;
clc;
format compact;
%%

% ���ɴ��ع������
x = (-1:0.1:1)';
y = -x.^2;

% ��ģ�ع�ģ��
model = svmtrain(ones(21,1),y,x,'-s 3 -t 2 -c 2.2 -g 2.8 -p 0.01');

% ���ý�����ģ�Ϳ�����ѵ�������ϵĻع�Ч��
[py,~,~] = svmpredict(y,x,model);
figure;
plot(x,y,'o');
hold on;
plot(x,py,'r*');
legend('ԭʼ����','�ع�����');
grid on;

% ����Ԥ��
testx = 1.1;
display('��ʵ����')
testy = 0%-testx.^2

[ptesty,~,~] = svmpredict(testy,testx,model);
display('Ԥ������');
ptesty


plot(testx,testy,'b*');
plot(testx,ptesty,'g*');
%%
toc
