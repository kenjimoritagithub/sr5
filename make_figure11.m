% make_figure11

% parameters
a_sum = 1;
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b = 5;
g = 0.7;
decay_rate = 0.001;
c_set = [0:0.1:0.3];
dur_ini = 500;
dur_epoch = 500;
num_epoch = 9;
R_prob = 0.6;
num_sim = 100;

% simulation
rand('twister',2014503);
for k1 = 1:length(c_set)
    c = c_set(k1);
    totalRset{k1} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
    for k_IR = 1:length(a_posiprop_set)
        for k_SR = 1:length(a_posiprop_set)
            a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
            a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k1,k_IR,k_SR,k_sim);
                Out = gridtask_SRIRex(a_SR,a_IR,b,g,decay_rate,c,dur_ini,dur_epoch,num_epoch,R_prob);
                totalRset{k1}(k_IR,k_SR,k_sim) = Out.totalR;
            end
        end
    end
end
save data_SRIRex totalRset

% Figure 11B,E
tmp_max = 0;
tmp_min = Inf;
for k1 = 1:length(c_set)
    tmp_max = max(tmp_max, max(max(mean(totalRset{k1},3))));
    tmp_min = min(tmp_min, min(min(mean(totalRset{k1},3))));
end
tmp_letters{1} = 'B'; tmp_letters{2} = 'E1'; tmp_letters{3} = 'E2'; tmp_letters{4} = 'E3';
for k1 = 1:length(c_set)
    heatmap_performance(mean(totalRset{k1},3),length(a_posiprop_set),[tmp_max tmp_min],['Figure11' tmp_letters{k1}]);
end

% Figure 11C,D
rand('twister',2014503);
for k1 = 1
    c = c_set(k1);
    for k_IR = 1:2
        for k_SR = 1:length(a_posiprop_set)
            a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
            a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k1,k_IR,k_SR,k_sim);
                Out = gridtask_SRIRex(a_SR,a_IR,b,g,decay_rate,c,dur_ini,dur_epoch,num_epoch,R_prob);
                if (k_IR == 2) && (k_SR == 8)
                    Out_set{k_sim} = Out;
                end
            end
            if (k_IR == 2) && (k_SR == 8)
                break;
            end
        end
    end
end
save data_SRIRex_Figure11CD Out_set
%
for k1 = 1:2
    F = figure;
    A = axes;
    hold on;
    axis([0 26 -7 11]);
    P = plot([0 26],[0 0],'k:');
    if k1 == 1
        P = plot([1:25],Out_set{1}.SR*Out_set{1}.w(:,1),'r');
        P = plot([1:25],Out_set{1}.SR*Out_set{1}.w(:,2),'b');
    elseif k1 == 2
        P = plot([1:25],Out_set{1}.IRSV(:,1),'r');
        P = plot([1:25],Out_set{1}.IRSV(:,2),'b');
    end
    set(A,'XTick',[1:25],'XTickLabel',[1:25],'FontSize',40);
    set(A,'YTick',[-6:2:10],'YTickLabel',[-6:2:10],'FontSize',40);
    print(F,'-depsc',['Figure11C' num2str(k1)]);
end
%
V_means = NaN(4,num_sim);
V_SDs = NaN(4,num_sim);
for k_sim = 1:num_sim
    V_means(1,k_sim) = mean(Out_set{k_sim}.SR*Out_set{k_sim}.w(:,1));
    V_means(2,k_sim) = mean(Out_set{k_sim}.SR*Out_set{k_sim}.w(:,2));
    V_means(3,k_sim) = mean(Out_set{k_sim}.IRSV(:,1));
    V_means(4,k_sim) = mean(Out_set{k_sim}.IRSV(:,2));
    V_SDs(1,k_sim) = std(Out_set{k_sim}.SR*Out_set{k_sim}.w(:,1),1);
    V_SDs(2,k_sim) = std(Out_set{k_sim}.SR*Out_set{k_sim}.w(:,2),1);
    V_SDs(3,k_sim) = std(Out_set{k_sim}.IRSV(:,1),1);
    V_SDs(4,k_sim) = std(Out_set{k_sim}.IRSV(:,2),1);
end
tmp_letters = 'LR';
for k1 = 1:2
    if k1 == 1
        tmp_data = V_means;
        tmp_YTick = [-5:1:7];
    elseif k1 == 2
        tmp_data = V_SDs;
        tmp_YTick = [0:0.5:2.5];
    end
    F = figure;
    A = axes;
    hold on;
    axis([0.5 5.5 tmp_YTick(1) tmp_YTick(end)]);
    P = bar([1 4], mean(tmp_data([1 3],:),2),0.2);
    set(P,'FaceColor','r');
    P = bar([2 5], mean(tmp_data([2 4],:),2),0.2);
    set(P,'FaceColor','b');
    P = errorbar([1 4], mean(tmp_data([1 3],:),2), std(tmp_data([1 3],:),1,2), 'r.');
    P = errorbar([2 5], mean(tmp_data([2 4],:),2), std(tmp_data([2 4],:),1,2), 'b.');
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    set(A,'Box','off');
    set(A,'XTick',[1 2 4 5],'XTickLabel',[]);
    set(A,'YTick',tmp_YTick,'YTickLabel',tmp_YTick,'FontSize',40);
    print(F,'-depsc',['Figure11D-' tmp_letters(k1)]);
end
