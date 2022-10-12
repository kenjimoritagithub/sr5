% make_figure7_8_tableS1_S2_additionalIRIR

% run simulations by using "broadsim" and save data for Figures 7 and 8 and Tables S1 and S2
% Note: this would take much time, and it would be better to divide this into small pieces as we did
g_set = [0.6 0.7 0.8];
b_set = [5 10 15];
for model_type = 1:3
    for k_g = 1:length(g_set)
        g = g_set(k_g);
        for k_b = 1:length(b_set)
            b = b_set(k_b);
            broadsim(model_type, g, b, 1);
        end
    end
end

% obtain the max (and min) mean performance across all the simulation results
Pfminmax_all = [Inf, 0];
for k_model = 1:3
    for k_g = 1:length(g_set)
        for k_b = 1:length(b_set)
            [Pfminmax, Pfgood] = broadanaplot(k_model, g_set(k_g), b_set(k_b), [], 0, 0);
            Pfminmax_all(1) = min(Pfminmax_all(1), Pfminmax(1));
            Pfminmax_all(2) = max(Pfminmax_all(2), Pfminmax(2));
            close all % to close the figures
        end
    end
end
Pfmax_all = ceil(Pfminmax_all(2));

% make Figures 7 and 8 and Table S1
for k_model = 1:3
    for k_g = 1:length(g_set)
        for k_b = 1:length(b_set)
            [Pfminmax, Pfgood] = broadanaplot(k_model, g_set(k_g), b_set(k_b), [0 Pfmax_all], 1, 1);
            close all % to close the figures
        end
    end
end

% make the color bar for Figures 7 and 8
F = figure;
A = axes;
hold on;
P = colorbar;
set(P,'YTick',[1 65],'YTickLabel',[0 Pfmax_all],'FontSize',40);
print(F,'-depsc','Figure7-8-colorbar');

% make Table S2
broadsim(2, 0.5, 15, 1);
broadsim(2, 0.5, 20, 1);
broadsim(2, 0.6, 20, 1);
broadanaplot(2, 0.5, 15, [], 1, 0);
broadanaplot(2, 0.5, 20, [], 1, 0);
broadanaplot(2, 0.6, 20, [], 1, 0);

% additional simulations for the model consisting of two IR-based systems mentioned in the main text
broadsim(3, 0.6, 2.5, 1);
broadsim(3, 0.7, 2.5, 1);
broadsim(3, 0.8, 2.5, 1);
broadanaplot(3, 0.6, 2.5, [], 1, 0);
broadanaplot(3, 0.7, 2.5, [], 1, 0);
broadanaplot(3, 0.8, 2.5, [], 1, 0);
