function res=MMTLMOEAD(Problem,popSize,MaxIt,T_parameter,group)
clear A PopF0 PopV0 Sample
for T = 1:floor(T_parameter(group,3)/T_parameter(group,2))
        t = 1/T_parameter(group,1)*T;
        DX = size(Problem.XLow,1);
        Generator.Name  = 'LPCA';       % name of generator
        Generator.NClu  = 4;            % parameter of generator, the number of clusters(default) 
        Generator.Iter  = 5;           % maximum trainning steps in LPCA
                                        % usually, LPCA stops less than 10
                                        % iterations
        Generator.Exte  = 0.45;         % parameter of generator, extension rate(default)
        fprintf(' %d',T);
        if T==1
          
%             [PopX,Pareto,POF_iter,Pareto_iter,runTime] = RMMEDA( Problem,popSize,50, t);
            [PopX,Pareto,POF_iter] = moead( Problem,popSize,1, t);
            %��һ�α仯�У�ʹ�þ�̬���̵õ������Ž���Ǩ��
            for i=1:size(PopX,2)
                [PopF0(:,i),PopV0(:,i)] = Problem.FObj(PopX(:,i),t);
            end
            [PopF0,PopX0,PopV0] = ParetoFilter(PopF0,PopX,PopV0);
            [PopF0,PopX0,PopV0] = MOSelector( PopF0, PopX, PopV0, popSize/2 );
            LastBestPop = PopX0;
 
        else
            clear PopFf PopXx PopVv tempPopF tempPopV
            % ����仯��������10����Ϊ�˿����ⲿ��Ⱥ������ֻ�������10���������Ÿ���
%             if T>=11
%                 for Ts = T-10:T-1
%                     for i=1:size(A{Ts},2)
%                         [tempPopF{Ts}(:,i),tempPopV{Ts}(:,i)] = Problem.FObj(A{Ts}(:,i),t);                                                             
%                     end
%                     [PopFf{Ts},PopXx{Ts},PopVv{Ts}] = ParetoFilter(tempPopF{Ts},A{Ts},tempPopV{Ts});
%                 end
%             else
%                 for Ts = 1:T-1
%                     for i=1:size(A{Ts},2)
%                         [tempPopF{Ts}(:,i),tempPopV{Ts}(:,i)] = Problem.FObj(A{Ts}(:,i),t);
%                     end
%                     [PopFf{Ts},PopXx{Ts},PopVv{Ts}] = ParetoFilter(tempPopF{Ts},A{Ts},tempPopV{Ts});
%                 end
%             end
            %��ǰ������ʱ����õ���POPɸѡ�����ڵ�ǰʱ����õĸ��壬�����������Nini��һ�룬��ͨ���ܶ�ɸѡ���������������ﵽNini/2��
%             [PopF,PopX,PopV] = ParetoFilter(cell2mat(PopFf),cell2mat(PopXx),cell2mat(PopVv));
%             
%             
%             
%             if size(PopX,2)>popSize/2
%                 [~,PopX,~]   = MOSelector( PopF, PopX, PopV, popSize/2 ); 
%                 LastBestPop = PopX;%��һʱ�̵ĳ�ʼ��Ⱥһ������֮ǰʱ��
%             else
%                 newpop = addNoise(PopX, popSize/2, DX);
%                 LastBestPop = [PopX, newpop];
%             end
            LastBestPop=Predict(A,t,Problem);
            

            
        end%end TIF
         %% ���濪ʼ����Ǩ��ѧϰ����,Դ�����ҵ�����õ���Щ���壬Ŀ������t+1ʱ��������ĸ��壬�����TransPop
  
        DLat = Problem.NObj-1;
        Model  = LPCA(LastBestPop, Generator.NClu, DLat, Generator.Iter);
        nums   = zeros(Generator.NClu,1);
        for i=1:Generator.NClu
            nums(i) = sum(Model.Index == i);
        end
        TransPop = [];
        for Clu = 1:Generator.NClu
            Source = LastBestPop(:,Model.Index==Clu);
            SampleN = ceil(popSize/3);
            Sample.X = rand(DX,SampleN);% t+1ʱ��������ɵĸ���
            for i=1:SampleN
                [Sample.F(:,i),Sample.V(:,i)] = Problem.FObj(Sample.X(:,i),t);
            end
            [~,Target,~]   = MOSelector( Sample.F,Sample.X,Sample.V, popSize );%��������ɵĸ�����ѡ��200������ΪĿ����
            phi = SGF(Model.Eve(:,:,Clu),pca(Target'),DLat);
            NewPop = zeros(DX,nums(Clu));
            for idx = 1:nums(Clu)
                tempSample = Source(:,idx)'*phi;
                dist = @(X)sum((tempSample-X'*phi).^2);
                NewPop(:,idx) = fmincon(@(NewSample)dist(NewSample), rand(DX,1),[], [], [], [], zeros(DX,1), ones(DX,1), [], optimset('display', 'off'));
            end
            TransPop = [TransPop NewPop];
        end 
       

        %% ��һʱ�̵ĳ�ʼ��Ⱥ������������ɣ���һ����������֮ǰʱ�̵���õĸ��壬�ڶ�������ͨ��Ǩ��ѧϰ�õ�
        init_population = [LastBestPop, TransPop];%���߶���
%                     init_population = TransPop;%ֻ�û�������Ǩ��ѧϰ�ķ���
%                     init_population = LastBestPop;%ֻ�û��ڼ���ķ���

        
        %֮���ʵ������������ϸ����������趨
        [PopX,Pareto,POF_iter] = moead( Problem,popSize,MaxIt, t,init_population);
%         [PopX,Pareto,POF_iter,Pareto_iter,runTime] = RMMEDA( Problem,popSize,MaxIt, t,init_population);
%         [PopX, Pareto] = RMMEDA( Problem, Generator, popSize, T_parameter(group,2), t, testfunc, repeat, group, T, POF_Benchmark,init_population);
        POF = Pareto.F; 
        POS = Pareto.X;
        %% ���õ���Pop�����ⲿ�洢�ռ�
        A{T} = PopX;
            
        res{T}.turePOF=getBenchmarkPOF(Problem.Name,group,T,T_parameter );
        res{T}.POF_iter=POF_iter;
        res{T}.POS=PopX;
end
end






                    