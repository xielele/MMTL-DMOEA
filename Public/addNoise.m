function newPopulation = addNoise(init_population, Nini, n)

%nά��
%�Ե�ǰȺ��ĸ������Ӱ��������������˰������ĸ����ԭʼ������
    newPopNumber = Nini - size(init_population,2);
    newPopulation = zeros(n,newPopNumber);
    for i = 1:newPopNumber
        
        index = randperm(size(init_population,2));
        index2 = randperm(n);
       
        for idx2 = 1:round(n*0.4)      %���ѡȡһ���λ�����ֲ��仯
            temp = init_population(index2(idx2),index(1));
            temp =cauchyrnd(temp,4);
            if temp <0
                temp = 0;
            end
            if temp >1
                temp =1;
            end
            init_population(index2(idx2),index(1)) = temp;
        end
        
        newPopulation(:,i) = init_population(:,index(1));
    end

  %   fprintf("!!!!!!\n");
end