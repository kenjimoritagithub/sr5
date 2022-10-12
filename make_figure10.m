% make_figure10

% common parameters
a_sum = 1;
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b = 5;
g = 1;
num_sim = 1000;

% Figure 10B-left
rand('twister',1255133);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1
            Out = twostage_task1(a_SR,a_IR,b,g,1);
        end
    end
end
F = figure;
A = axes;
hold on;
axis([1 201 0 1]);
tmp_colors = 'rbgm';
for k = 1:4
    P = plot([1:201],Out.p_rew_set(:,k),tmp_colors(k));
end
%set(A,'PlotBoxAspectRatio',[1 1 1]);
set(A,'XTick',[1:50:201],'XTickLabel',[1:50:201],'FontSize',40);
set(A,'YTick',[0:0.25:1],'YTickLabel',[0:0.25:1],'FontSize',40);
print(F,'-depsc','Figure10Bleft');

% Figure 10B-right
rand('twister',1255133);
totalRset = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('task1-1 %d-%d-%d\n',k_IR,k_SR,k_sim);
            Out = twostage_task1(a_SR,a_IR,b,g,1);
            totalRset(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
save data_figure10Bright totalRset
heatmap_performance(mean(totalRset,3),length(a_posiprop_set),[],'Figure10Bright');

% Figure 10C-right
clear totalRset
rand('twister',1255134);
totalRset = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('task1-2 %d-%d-%d\n',k_IR,k_SR,k_sim);
            Out = twostage_task1(a_SR,a_IR,b,g,2);
            totalRset(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
save data_figure10Cright totalRset
heatmap_performance(mean(totalRset,3),length(a_posiprop_set),[],'Figure10Cright');

% Figure 10E-G
clear totalRset
rand('twister',1255135);
for k_model = 1:3
    totalRset{k_model} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
    for k1 = 1:length(a_posiprop_set)
        if k_model == 1
            tmp_range_max = length(a_posiprop_set);
        else
            tmp_range_max = k1;
        end
        for k2 = 1:tmp_range_max
            if k_model == 1
                a_IR = a_sum*[a_posiprop_set(k1), 1-a_posiprop_set(k1)];
                a_SR = [a_sum*[a_posiprop_set(k2), 1-a_posiprop_set(k2)], a_SRfeatures];
            elseif k_model == 2
                a_IR = [];
                a_SR = [a_sum*[a_posiprop_set(k1), 1-a_posiprop_set(k1)], a_SRfeatures;...
                    a_sum*[a_posiprop_set(k2), 1-a_posiprop_set(k2)], NaN];
            elseif k_model == 3
                a_IR = [a_sum*[a_posiprop_set(k1), 1-a_posiprop_set(k1)]; a_sum*[a_posiprop_set(k2), 1-a_posiprop_set(k2)]];
                a_SR = [];
            end
            for k_sim = 1:num_sim
                fprintf('task2 %d-%d-%d-%d\n',k_model,k1,k2,k_sim);
                Out = twostage_task2(a_SR,a_IR,b,g);
                totalRset{k_model}(k1,k2,k_sim) = Out.totalR;
            end
        end
    end
end
save data_figure10E-G totalRset
% top images
tmp_letters = 'EFG';
for k_model = 1:3
    heatmap_performance(mean(totalRset{k_model},3),length(a_posiprop_set),[],['Figure8' tmp_letters(k_model) 'top']);
end
% bottom graphs
tmp_plot_max = 0;
for k_model = 1:3
    data_mean{k_model} = mean(totalRset{k_model},3);
    data_std{k_model} = std(totalRset{k_model},1,3);
    tmp_mean{k_model} = diag(fliplr(data_mean{k_model}));
    tmp_std{k_model} = diag(fliplr(data_std{k_model}));
    tmp_sem{k_model} = tmp_std{k_model} / sqrt(num_sim);
    tmp_plot_max = max(tmp_plot_max, max(tmp_mean{k_model})+max(tmp_std{k_model}));
end
tmp_xs = [1:9; 9:-1:1; 1:9];
for k_model = 1:3
    F = figure;
    A = axes;
    hold on;
    axis([0.5 9.5 0 ceil(tmp_plot_max/10)*10]);
    P = plot([5 5],[0 ceil(tmp_plot_max/10)*10],'k:');
    P = errorbar(tmp_xs(k_model,:),tmp_mean{k_model},tmp_std{k_model},'k--');
    P = errorbar(tmp_xs(k_model,:),tmp_mean{k_model},tmp_sem{k_model},'k');
    P = plot(tmp_xs(k_model,:),tmp_mean{k_model},'r');
    %set(A,'PlotBoxAspectRatio',[1 1 1]);
    set(A,'XTick',[1:9],'XTickLabel',[1:9],'FontSize',40);
    set(A,'YTick',[0:10:ceil(tmp_plot_max/10)*10],'YTickLabel',[0:10:ceil(tmp_plot_max/10)*10],'FontSize',40);
    print(F,'-depsc',['Figure10' tmp_letters(k_model) 'bottom']);
end
