function [pRank,SetDominamt,NumDom] = fastNonDominatedSort(A,CompIndex)
% ���ٷ�֧�����򣺸��ݱȽ�ָʾ����CompIndex���бȽ�
% �ο����ף�A fast and elitist multiobjective genetic algorithm:NSGA-II��2002��IEEE��
% 
% ������� CompIndex ���趨ԭ�򣺣����Բ����룬Ĭ����ԽСԽ�ã�
% ���ԽСԽ��(ԽС��ֵԽ��ǰ��),��ֵ�趨Ϊ1(Ĭ��)������С��ֵ֧������ֵ
% ���Խ��Խ��(Խ���ֵԽ��ǰ��),��ֵ�趨Ϊ-1     ���������ֵ֧���С��ֵ
% 
% CompIndex ��ֵֻ���� +1 �� -1
% ���CompIndex(ii) == 1��ʾ���մ�С����Ƚϣ�Ĭ�ϣ�:ȡ < ��
% ���CompIndex(ii) == -1��ʾ���մӴ�С�Ƚϣ�      ȡ > ��
%
% pareto����pRank(ii)==1��ʾ��߼��𣬱�ʾû����������֧��ø���ii
% ֧�伯SetDominamt(ii):��ʾ����ii֧����������壨��ţ�
% NumDom(ii)����ʾ֧�����ii�������������������ȸ���ii���õĸ�������
%
% ���ӣ�A = [1 8;2 6;3 4;2 5;4 9;4 10]; 
% �����һ�к͵ڶ��ж�Ĭ����ԽСԽ�ã���CompIndex = [1 1];
% ִ�д��룺[pRank,SetDominamt,NumDom] = fastNonDominatedSort(A,CompIndex);
%   ��    [pRank,SetDominamt,NumDom] = fastNonDominatedSort(A);
% ���Ƶأ������һ����ԽСԽ�ã����ڶ�����Խ��Խ�ã���CompIndex = [1 -1];
% ִ�д��룺[pRank,SetDominamt,NumDom] = fastNonDominatedSort(A,CompIndex);
% 
% Input
% A                                          - ���ݾ����б�ʾ������������б�ʾ���Ի�ָ��
% CompIndex                         - �Ƚϵ�ָʾ������1*size(A,2)������������A������
% 
% Output
% pRank                                   - ���и����pareto������ֵԽС����Խ��
% SetDominamt                      - ���и����֧�伯��cell��
% NumDom                             - ���и��屻����֧�������
%
%  ---------------------------------------------


if (nargin < 2) || (isempty(CompIndex)), CompIndex = ones(1,size(A,2)); end

N = size(A,1);                                             % �����������Ŀ

% SetDominamt(ii)��ʾ��ii��������֧��ĸ��壨ʵ�ʴ洢����֧�����ı����Ϣ��
SetDominamt = cell(1,N);                         % ���и����֧�伯�������е�S_p
NumInSetD = zeros(1,N);                          % ���и����֧�伯�еĸ�������

NumDominated = zeros(1,N);                       % ���и��屻����������֧�������:�����е�n_p
pRank = zeros(1,N);                                        % ���и�������ǰ��front����ţ������е�p_rank

Front1 = [];

for ii = 1:N
    Sp = [];                                       % ��ʱ�洢�ĵ�ii�������֧�伯(ʵ��Ϊ��֧��ĸ����ż���)
    % NumDominated(ii) = 0;
    % ������N-1������Ƚϣ���֧�仹�Ǳ�֧�䣬����Ҳ������Ƚ�(������ʶ�����)
    for jj = 1:N                                 % ������N-1������Ƚϣ���֧�仹�Ǳ�֧��
        Index = Dominant2VecMin(A(ii,:),A(jj,:),CompIndex);
        if Index == 1                            % ����ii֧�����jj
            Sp = [Sp jj];                         % ������jj������֧�伯
            NumInSetD(ii) = NumInSetD(ii) + 1;
        elseif Index == -1                       % ����jj֧�����ii(ii��jj֧��)
            NumDominated(ii) = NumDominated(ii) + 1; % ii��֧����������1
        end
    end
    % SetDominamt(ii) = Sp;
    SetDominamt{ii} = Sp;
    
    if NumDominated(ii) == 0                     % iiû�б���������֧��
        pRank(ii) = 1;                              % ����ii���ڵ�һ��ǰ�أ�first front
        Front1 = [Front1,ii];                    % ������ii�����һ��ǰ��
    end
end

NumDom = NumDominated;                           % �����仯�����ΪNumDom�Ա����

curFrontID = 1;                                              % ��ǰ�����ǰ�ر�ţ������е�i=1

CurFront = Front1;                                         % ��ǰ�����ǰ�أ������е�F_i
NumInFront = length(CurFront);                   % ��ǰǰ���еĸ�������

while NumInFront > 0                             % ��ǰ��curFrontIDǰ�طǿ�
    Q = [];                                                 % �����洢��һ��ǰ����������ļ�������
    for ii = 1:NumInFront                        % �Ե�ǰǰ��F_i�е�ÿһ��p�����б�
        pInFront = CurFront(ii);                 % �����е� p ���� F_i
        Sp = cell2mat(SetDominamt(pInFront));    % p��֧�伯
        for jj = 1:NumInSetD(pInFront)
            qID = Sp(jj);                                        % �����е� q ���� S_p
            NumDominated(qID) = NumDominated(qID) - 1; % �����е� n_q = n_q - 1
            if NumDominated(qID) == 0            % q������һ��ǰ��
                pRank(qID) = curFrontID + 1;     % ������q��ǰ�صȼ�ֵ
                Q = [Q,qID];                                 % ������q������һǰ�ؼ�
            end
        end
    end
    curFrontID = curFrontID + 1;                 % ����һ��ǰ����Ÿ�ֵ
    CurFront = Q;                                         % ȷ����һ��ǰ����������(���)
    NumInFront = length(Q);                      % ��ǰǰ��������������
end

% end of function fastNonDominatedSort
%%


function Index = Dominant2VecMin(v1,v2,CompIndex)
% �����ָ��CompIndex��ֵ��Ĭ����ԽСԽ��
% ������� CompIndex ���趨ԭ��
% ���ԽСԽ��(ԽС��ֵԽ��ǰ��),��ֵ�趨Ϊ1(Ĭ��)������С��ֵ֧������ֵ
% ���Խ��Խ��(Խ���ֵԽ��ǰ��),��ֵ�趨Ϊ-1     ���������ֵ֧���С��ֵ
% CompIndex ��ֵֻ���� +1 �� -1
% 
% Input
% v1                                       - ��������1,1*n��n*1
% v2                                       - ��������2,1*n��n*1
% CompIndex                        - �Ƚϵ�ָʾ����
% 
% Output
% ���� Index ��ֵ��0��ʾ��Ȼ�û�н��
% Index == 1:  ��ʾ v1 ֧�� v2 (v1��v2ǰ��, v2��v1����)
% Index == -1: ��ʾ v2 ֧�� v1��v2��v1ǰ��, v1��v2���棩
% 

if (nargin < 3) || (isempty(CompIndex)), CompIndex = ones(size(v1)); end
n = length(v1);

V1 = v1 .* CompIndex;
V2 = v2 .* CompIndex;

num1 = sum(V1 <= V2);
num2 = sum(V1 < V2);
equalNum = num1 - num2;

num3 = sum(V1 > V2);

if (num3 > 0) && ((equalNum + num3) == n)
    Index = -1;
elseif (num2 > 0) && ((equalNum + num2) == n)
    Index = 1;
else
    Index = 0;
end

% end of function Dominant2VecMin
%%

