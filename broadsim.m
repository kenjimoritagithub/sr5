function broadsim(model_type, g, b, firsttime)

% model names
model_names{1} = 'SRIR';
model_names{2} = 'SRSR';
model_names{3} = 'IRIR';
num_a_SRfeatures_set = [5 5 1];
num_sim_set = [100 50 50];

% varying parameters
g_set = [0.6 0.7 0.8];
b_set = [5 10 15];
k_g = find(g==g_set);
k_b = find(b==b_set);

% random numbers
broadsim_rand_twister_start_set{1} = [
    2714630, 2814630, 2914630;
    2114630, 2214630, 2514630;
    2314630, 2414630, 2614630
    ];
broadsim_rand_twister_start_set{2} = [
    2724630, 2824630, 2924630;
    2124630, 2224630, 2524630;
    2324630, 2424630, 2624630
    ];
broadsim_rand_twister_start_set{3} = [
    2734630, 2834630, 2934630;
    2134630, 2234630, 2534630;
    2334630, 2434630, 2634630
    ];
rand_twister_start = broadsim_rand_twister_start_set{model_type}(k_g,k_b);

% other parameters
a_set = [0.2:0.15:0.8];
a_SRfeatures_set = [0.05:0.05:0.25];
dur_ini = 500; % duration (time steps) for the initial no-reward epoch
dur_epoch = 500; % duration for each rewarded epoch
num_epoch = 9; % number of the rewarded epochs
R_prob = 0.6; % probability with which reward was placed at the special reward candidate state

% create or load the data
where_to_start = [];
if firsttime
    where_to_start = [1 1 1];
    totalRset = NaN(num_a_SRfeatures_set(model_type),length(a_set),length(a_set),length(a_set),length(a_set),num_sim_set(model_type));
else
    load(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b) '.mat']);
    for k1 = 1:num_a_SRfeatures_set(model_type)
        for k2 = 1:length(a_set)
            for k3 = 1:length(a_set)
                if (k2 == length(a_set)) && (k3 == length(a_set))
                    tmp = 100;
                else
                    tmp = num_sim_set(model_type);
                end
                if isnan(totalRset(k1,k2,k3,end,end,tmp))
                    where_to_start = [k1 k2 k3];
                    break;
                elseif totalRset(k1,k2,k3,end,end,tmp) == 0
                    error('0 is detected. Check if it is valid.');
                end
            end
            if ~isempty(where_to_start)
                break;
            end
        end
        if ~isempty(where_to_start)
            break;
        end
    end
end

if model_type == 1 % SR-IR
    for k_SRf = where_to_start(1):length(a_SRfeatures_set)
        if k_SRf == where_to_start(1)
            tmp_k_SR1_start = where_to_start(2);
        else
            tmp_k_SR1_start = 1;
        end
        for k_SR1 = tmp_k_SR1_start:length(a_set)
            if (k_SRf == where_to_start(1)) && (k_SR1 == where_to_start(2))
                tmp_k_SR2_start = where_to_start(3);
            else
                tmp_k_SR2_start = 1;
            end
            for k_SR2 = tmp_k_SR2_start:length(a_set)
                rand_twister = rand_twister_start + (k_SRf-1)*length(a_set)*length(a_set) + (k_SR1-1)*length(a_set) + k_SR2;
                rand('twister',rand_twister);
                for k_IR1 = 1:length(a_set)
                    for k_IR2 = 1:length(a_set)
                        for k_sim = 1:num_sim_set(model_type)
                            fprintf('f %d SR %d-%d IR %d-%d sim%d\n',k_SRf,k_SR1,k_SR2,k_IR1,k_IR2,k_sim);
                            Out = gridtask_SRIR([a_set(k_SR1) a_set(k_SR2) a_SRfeatures_set(k_SRf)],...
                                [a_set(k_IR1) a_set(k_IR2)],b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                            totalRset(k_SRf,k_SR1,k_SR2,k_IR1,k_IR2,k_sim) = Out.totalR;
                        end
                    end
                end
                save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
            end
        end
    end
    save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
    
elseif model_type == 2 % SR-SR
    for k_SRf = where_to_start(1):length(a_SRfeatures_set)
        if k_SRf == where_to_start(1)
            tmp_k_SR11_start = where_to_start(2);
        else
            tmp_k_SR11_start = 1;
        end
        for k_SR11 = tmp_k_SR11_start:length(a_set)
            if (k_SRf == where_to_start(1)) && (k_SR11 == where_to_start(2))
                tmp_k_SR12_start = where_to_start(3);
            else
                tmp_k_SR12_start = 1;
            end
            for k_SR12 = tmp_k_SR12_start:length(a_set)
                rand_twister = rand_twister_start + (k_SRf-1)*length(a_set)*length(a_set) + (k_SR11-1)*length(a_set) + k_SR12;
                rand('twister',rand_twister);
                for k_SR21 = 1:length(a_set)
                    for k_SR22 = 1:length(a_set)
                        for k_sim = 1:num_sim_set(model_type)
                            fprintf('f %d SR1 %d-%d SR2 %d-%d sim %d\n',k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim);
                            Out = gridtask_SRSR([a_set(k_SR11) a_set(k_SR12) a_SRfeatures_set(k_SRf); ...
                                a_set(k_SR21) a_set(k_SR22) a_SRfeatures_set(k_SRf)],b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                            totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = Out.totalR;
                        end
                        for k_sim = num_sim_set(model_type)+1:2*num_sim_set(model_type)
                            fprintf('f %d SR1 %d-%d SR2 %d-%d sim %d\n',k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim);
                            if (k_SR11==k_SR21) && (k_SR12==k_SR22)
                                Out = gridtask_SRSR([a_set(k_SR11) a_set(k_SR12) a_SRfeatures_set(k_SRf); ...
                                    a_set(k_SR21) a_set(k_SR22) a_SRfeatures_set(k_SRf)],b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = Out.totalR;
                            else
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = NaN;
                            end
                        end
                    end
                end
                save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
            end
        end
    end
    for k_SRf = 1:length(a_SRfeatures_set)
        for k_SR11 = 1:length(a_set)
            for k_SR12 = 1:length(a_set)
                for k_SR21 = 1:length(a_set)
                    for k_SR22 = 1:length(a_set)
                        for k_sim = num_sim_set(model_type)+1:2*num_sim_set(model_type)
                            if ~((k_SR11==k_SR21) && (k_SR12==k_SR22))
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = totalRset(k_SRf,k_SR21,k_SR22,k_SR11,k_SR12,k_sim-num_sim_set(model_type));
                            end
                        end
                    end
                end
            end
        end
    end
    save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
    
elseif model_type == 3 % IR-IR
    for k_SRf = 1
        for k_IR11 = where_to_start(2):length(a_set)
            if k_IR11 == where_to_start(2)
                tmp_k_IR12_start = where_to_start(3);
            else
                tmp_k_IR12_start = 1;
            end
            for k_IR12 = tmp_k_IR12_start:length(a_set)
                rand_twister = rand_twister_start + (k_IR11-1)*length(a_set) + k_IR12;
                rand('twister',rand_twister);
                for k_IR21 = 1:length(a_set)
                    for k_IR22 = 1:length(a_set)
                        for k_sim = 1:num_sim_set(model_type)
                            fprintf('IR-IR IR1 %d-%d IR2 %d-%d sim %d\n',k_IR11,k_IR12,k_IR21,k_IR22,k_sim);
                            Out = gridtask_IRIR([a_set(k_IR11) a_set(k_IR12); ...
                                a_set(k_IR21) a_set(k_IR22)],b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                            totalRset(1,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = Out.totalR;
                        end
                        for k_sim = num_sim_set(model_type)+1:2*num_sim_set(model_type)
                            fprintf('IR-IR IR1 %d-%d IR2 %d-%d sim %d\n',k_IR11,k_IR12,k_IR21,k_IR22,k_sim);
                            if (k_IR11==k_IR21) && (k_IR12==k_IR22)
                                Out = gridtask_IRIR([a_set(k_IR11) a_set(k_IR12); ...
                                    a_set(k_IR21) a_set(k_IR22)],b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                                totalRset(1,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = Out.totalR;
                            else
                                totalRset(1,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = NaN;
                            end
                        end
                    end
                end
                save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
            end
        end
    end
    for k_SRf = 1
        for k_IR11 = 1:length(a_set)
            for k_IR12 = 1:length(a_set)
                for k_IR21 = 1:length(a_set)
                    for k_IR22 = 1:length(a_set)
                        for k_sim = num_sim_set(model_type)+1:2*num_sim_set(model_type)
                            if ~((k_IR11==k_IR21) && (k_IR12==k_IR22))
                                totalRset(1,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = totalRset(1,k_IR21,k_IR22,k_IR11,k_IR12,k_sim-num_sim_set(model_type));
                            end
                        end
                    end
                end
            end
        end
    end
    save(['totalRset_' model_names{model_type} '_g0p' num2str(g*10) '_b' num2str(b)],'totalRset');
    
end
