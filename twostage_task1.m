function Out = twostage_task1(a_SR,a_IR,b,g,tasktype)

%
tr = [0.7 0.3; 0.3 0.7];
SRM = [
    1 0 g*tr(1,1)*0.5 g*tr(1,1)*0.5 g*tr(1,2)*0.5 g*tr(1,2)*0.5;
    0 1 g*tr(2,1)*0.5 g*tr(2,1)*0.5 g*tr(2,2)*0.5 g*tr(2,2)*0.5;
    0 0 1 0 0 0;
    0 0 0 1 0 0;
    0 0 0 0 1 0;
    0 0 0 0 0 1];
w = zeros(6,1);
Vsr = SRM * w;
Vir = zeros(6,1);
Vint = (Vsr + Vir)/2;

num_trial = 201;
totalR = 0;
choices = NaN(num_trial,2);
p_rew = 0.25 + 0.5*rand(1,4);
p_rew_set = NaN(num_trial,4);
for k_trial = 1:num_trial
    
    % reward probability
    if tasktype == 2
        if k_trial <= 50
            p_rew = [0.1 0.5 0.5 0.9];
        elseif k_trial <= 100
            p_rew = [0.9 0.5 0.5 0.1];
        elseif k_trial <= 150
            p_rew = [0.5 0.1 0.9 0.5];
        else
            p_rew = [0.5 0.9 0.1 0.5];
        end
    end
    p_rew_set(k_trial,:) = p_rew;
    
    % generate random numbers used for choice, stage transition, and reward
    tmp = rand(1,4);
    
    % choice at the first stage
    tmp_prob1 = exp(b*Vint(1)) / sum(exp(b*Vint(1:2)));
    if tmp(1) <= tmp_prob1
        choices(k_trial,1) = 1;
    else
        choices(k_trial,1) = 2;
    end
    
    % stage transition
    if tmp(2) <= tr(choices(k_trial,1),1)
        options = [3 4];
    else
        options = [5 6];
    end
    
    % choice at the second stage
    tmp_prob2 = exp(b*Vint(options(1))) / sum(exp(b*Vint(options)));
    if tmp(3) <= tmp_prob2
        choices(k_trial,2) = options(1);
    else
        choices(k_trial,2) = options(2);
    end
    
    % reward
    if tmp(4) <= p_rew(choices(k_trial,2)-2)
        R = 1;
    else
        R = 0;
    end
    totalR = totalR + R;
    
    % TD RPE for the first stage, and recalculate the values
    TDE1 = 0 + g*Vint(choices(k_trial,2)) - Vint(choices(k_trial,1));
    Vir(choices(k_trial,1)) = Vir(choices(k_trial,1)) + a_IR(2-(TDE1>=0))*TDE1;
    w = w + a_SR(2-(TDE1>=0))*SRM(choices(k_trial,1),:)'*TDE1;
    Vsr = SRM * w;
    Vint = (Vsr + Vir)/2;
    
    % TD error for SR features
    tmp_state_vector = zeros(1,6);
    tmp_state_vector(choices(k_trial,2)) = 1;
    TDEsr = tmp_state_vector + 0 - SRM(choices(k_trial,1),:);
    SRM(choices(k_trial,1),:) = SRM(choices(k_trial,1),:) + a_SR(3)*TDEsr;
    
    % TD RPE for the second stage, and recalculate the values
    TDE2 = R + 0 - Vint(choices(k_trial,2));
    Vir(choices(k_trial,2)) = Vir(choices(k_trial,2)) + a_IR(2-(TDE2>=0))*TDE2;
    w = w + a_SR(2-(TDE2>=0))*SRM(choices(k_trial,2),:)'*TDE2;
    Vsr = SRM * w;
    Vint = (Vsr + Vir)/2;
    
    % reward probability
    if tasktype == 1
        tmp_randn = randn(1,4);
        for k = 1:4
            p_tmp = p_rew(k) + 0.025*tmp_randn(k);
            if p_tmp < 0.25
                p_rew(k) = 0.25 + (0.25 - p_tmp);
            elseif p_tmp > 0.75
                p_rew(k) = 0.75 - (p_tmp - 0.75);
            else
                p_rew(k) = p_tmp;
            end
            if (p_rew(k)<0.25) || (p_rew(k)>0.75)
                error('reward probability becomes out of range');
            end
        end
    end
    
end

% output
Out.totalR = totalR;
Out.p_rew_set = p_rew_set;
