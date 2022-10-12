% make_figure3C

% run "gridtask_SRIR" for 49 sets of 100 simulations and save data for Figure 3C
rand_twister_start = 7103351;
a_sum = 1;
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b = 5;
g = 0.7;
dur_ini = 500;
dur_epoch = 500;
num_epoch = 9;
R_prob = 0.6;
num_sim = 100;
num_set = 49;
for k_set = 1:num_set
    rand_twister = rand_twister_start + k_set;
    rand('twister',rand_twister);
    totalRset{k_set} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
    for k_IR = 1:length(a_posiprop_set)
        for k_SR = 1:length(a_posiprop_set)
            a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)]; % learning rates for the IR system
            a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures]; % learning rates for the SR system
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k_set,k_IR,k_SR,k_sim);
                Out = gridtask_SRIR(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob);
                totalRset{k_set}(k_IR,k_SR,k_sim) = Out.totalR;
            end
        end
    end
    save data_figure3C totalRset
end
save data_figure3C totalRset

% Figure 3C
load data_figure3C
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
num_set = 49;
num_max_matrix = zeros(length(a_posiprop_set),length(a_posiprop_set));
max_indice_set = NaN(num_set,2);
for k_set = 1:num_set
    tmp = mean(totalRset{k_set},3);
    [Cmax, Imax] = max(tmp(:));
    if sum(sum(tmp == Cmax)) > 1
        error('more than one max');
    end
    [max_indice_set(k_set,1),max_indice_set(k_set,2)] = ind2sub(size(tmp), Imax);
    num_max_matrix(max_indice_set(k_set,1),max_indice_set(k_set,2)) = num_max_matrix(max_indice_set(k_set,1),max_indice_set(k_set,2)) + 1;
end
clear totalRset
% add the result for the data shown in Figure 3A/B (1 set of 100 simulations)
load data_gridtask_SRIR
tmp = mean(totalRset{1}{1}{2},3);
[Cmax, Imax] = max(tmp(:));
if sum(sum(tmp == Cmax)) > 1
    error('more than one max');
end
[tmp_index1,tmp_index2] = ind2sub(size(tmp), Imax);
max_indice_set = [tmp_index1,tmp_index2; max_indice_set];
num_max_matrix(max_indice_set(1,1),max_indice_set(1,2)) = num_max_matrix(max_indice_set(1,1),max_indice_set(1,2)) + 1;
%
F = figure;
A = axes;
hold on;
axis([0.5 length(a_posiprop_set)+0.5 0.5 length(a_posiprop_set)+0.5]);
%P = image([0 1 4;2 3 1]+1);
P = image(num_max_matrix'+1);
C = [1:-1/max(max(num_max_matrix)):0; 1:-1/max(max(num_max_matrix)):0; 1:-1/max(max(num_max_matrix)):0]';
colormap(C);
P = colorbar;
set(P,'YTick',[0 max(max(num_max_matrix))]+1,'YTickLabel',[0 max(max(num_max_matrix))]);
P = plot([0.5 length(a_posiprop_set)+0.5],[0.5 length(a_posiprop_set)+0.5],'k-');
set(A,'PlotBoxAspectRatio',[1 1 1],'Box','on');
set(A,'XTick',[],'XTickLabel',[],'FontSize',22);
set(A,'YTick',[],'YTickLabel',[],'FontSize',22);
print(F,'-depsc','Figure3C');
