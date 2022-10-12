function Out = twostage_task2(a_SR,a_IR,b,g)

%
tr = [0.6 0.2 0.2; 0.2 0.6 0.2; 0.2 0.2 0.6];
SRM = [
    1 0 0 g*tr(1,1)*0.5 g*tr(1,1)*0.5 g*tr(1,2)*0.5 g*tr(1,2)*0.5 g*tr(1,3)*0.5 g*tr(1,3)*0.5;
    0 1 0 g*tr(2,1)*0.5 g*tr(2,1)*0.5 g*tr(2,2)*0.5 g*tr(2,2)*0.5 g*tr(2,3)*0.5 g*tr(2,3)*0.5;
    0 0 1 g*tr(3,1)*0.5 g*tr(3,1)*0.5 g*tr(3,2)*0.5 g*tr(3,2)*0.5 g*tr(3,3)*0.5 g*tr(3,3)*0.5;
    0 0 0 1 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 1 0;
    0 0 0 0 0 0 0 0 1];
w{1} = zeros(size(SRM,1),1);
w{2} = zeros(size(SRM,1),1);
Vsr{1} = SRM * w{1};
Vsr{2} = SRM * w{2};
Vir{1} = zeros(size(SRM,1),1);
Vir{2} = zeros(size(SRM,1),1);
if size(a_SR,1) == 2
    Vint = (Vsr{1} + Vsr{2})/2;
elseif size(a_IR,1) == 2
    Vint = (Vir{1} + Vir{2})/2;
else
    Vint = (Vsr{1} + Vir{1})/2;
end

num_trial = 150;
totalR = 0;
choices = NaN(num_trial,2);
for k_trial = 1:num_trial
    
    % reward probability
    if k_trial <= 50
        p_rew = [0.5 0.9 0.1 0.5 0.1 0.5];
    elseif k_trial <= 100
        p_rew = [0.5 0.1 0.9 0.5 0.5 0.1];
    else
        p_rew = [0.1 0.5 0.1 0.5 0.5 0.9];
    end
    
    % generate random numbers used for choice, stage transition, and reward
    tmp = rand(1,4);
    
    % choice at the first stage
    tmp_prob1_1 = exp(b*Vint(1)) / sum(exp(b*Vint(1:3)));
    tmp_prob1_2 = exp(b*Vint(2)) / sum(exp(b*Vint(1:3)));
    if tmp(1) <= tmp_prob1_1
        choices(k_trial,1) = 1;
    elseif tmp(1) <= tmp_prob1_1 + tmp_prob1_2
        choices(k_trial,1) = 2;
    else
        choices(k_trial,1) = 3;
    end
    
    % stage transition
    if tmp(2) <= tr(choices(k_trial,1),1)
        options = [4 5];
    elseif tmp(2) <= tr(choices(k_trial,1),1) + tr(choices(k_trial,1),2)
        options = [6 7];
    else
        options = [8 9];
    end
    
    % choice at the second stage
    tmp_prob2 = exp(b*Vint(options(1))) / sum(exp(b*Vint(options)));
    if tmp(3) <= tmp_prob2
        choices(k_trial,2) = options(1);
    else
        choices(k_trial,2) = options(2);
    end
    
    % reward
    if tmp(4) <= p_rew(choices(k_trial,2)-3)
        R = 1;
    else
        R = 0;
    end
    totalR = totalR + R;
    
    % TD RPE for the first stage
    TDE1 = 0 + g*Vint(choices(k_trial,2)) - Vint(choices(k_trial,1));
    for k_IR = 1:size(a_IR,1)
        Vir{k_IR}(choices(k_trial,1)) = Vir{k_IR}(choices(k_trial,1)) + a_IR(k_IR,2-(TDE1>=0))*TDE1;
    end
    for k_SR = 1:size(a_SR,1)
        w{k_SR} = w{k_SR} + a_SR(k_SR,2-(TDE1>=0))*SRM(choices(k_trial,1),:)'*TDE1;
        Vsr{k_SR} = SRM * w{k_SR};
    end
    
    % recalculate the values
    if size(a_SR,1) == 2
        Vint = (Vsr{1} + Vsr{2})/2;
    elseif size(a_IR,1) == 2
        Vint = (Vir{1} + Vir{2})/2;
    else
        Vint = (Vsr{1} + Vir{1})/2;
    end
    
    % TD error for SR features
    if ~isempty(a_SR)
        tmp_state_vector = zeros(1,size(SRM,1));
        tmp_state_vector(choices(k_trial,2)) = 1;
        TDEsr = tmp_state_vector + 0 - SRM(choices(k_trial,1),:);
        SRM(choices(k_trial,1),:) = SRM(choices(k_trial,1),:) + a_SR(1,3)*TDEsr;
    end
    
    % TD RPE for the second stage
    TDE2 = R + 0 - Vint(choices(k_trial,2));
    for k_IR = 1:size(a_IR,1)
        Vir{k_IR}(choices(k_trial,2)) = Vir{k_IR}(choices(k_trial,2)) + a_IR(k_IR,2-(TDE2>=0))*TDE2;
    end
    for k_SR = 1:size(a_SR,1)
        w{k_SR} = w{k_SR} + a_SR(k_SR,2-(TDE2>=0))*SRM(choices(k_trial,2),:)'*TDE2;
        Vsr{k_SR} = SRM * w{k_SR};
    end
    
    % recalculate the values
    if size(a_SR,1) == 2
        Vint = (Vsr{1} + Vsr{2})/2;
    elseif size(a_IR,1) == 2
        Vint = (Vir{1} + Vir{2})/2;
    else
        Vint = (Vsr{1} + Vir{1})/2;
    end
end

% output
Out.totalR = totalR;
