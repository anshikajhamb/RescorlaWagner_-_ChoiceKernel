%% Cleanup 
clc; 
clear; 
% 
close all; 

%% Set up the experiment/world
T = 1000; % number of trials
K = 2; % number of options
u = [0.2, 0.8]; % reward probabilities

%% Set up the agent: (model5)
alpha_c = 0.1; % This is the learning rate parameter. It represents how much the prediction error impacts the estimate of values. 
alpha = 0.1;
beta_c = 2; % This is inverse temperature parameter. It determines how noisily choices are made given the values. Higher values mean less noisy. 
beta = 2;
Q_init = [0.5 0.5]; % Initial estimate of the value of each option (i.e. on trial 0).
CK_init = [0 0]; % Initial estimate of the value of each option (i.e. on trial 0). 
choices = NaN(T,1); % a placeholder vector of NaNs to record choices made by agent on every trial
reward = NaN(T,1); % a placeholder vector of NaNs to record rewards earned by agent on every trial
choice_probabilities = NaN(T,2); % a placeholder vector of NaNs to record choice probabilities on every trial
CK = NaN(T,2); % a placeholder matrix of NaNs to record value estimates
CK(1,:) = CK_init;
Q = NaN(T,2); % a placeholder matrix of NaNs to record value estimates
Q(1,:) = Q_init;
correct_choice = 2; % just specifying which option is 'correct' in that it has a higher payoff 

%% Let the agent behave 

for t = 1:T % loop through trials 

    % First compute the choice probabilities based on current value
    % estimates
    choice_probabilities(t,:) = exp(beta*Q(t,:) + CK(t,:)*beta_c)/sum(exp(beta*Q(t,:) + CK(t,:)*beta_c));  

    % Make the choice based on choice probabilities
    choices(t,1) = pick_choice(choice_probabilities(t,:));
    
    % Deliver the reward based on reward probabilities
    reward(t,1) = deliver_reward(choices(t,1), u); 
    
    % Then update the value estimates based on the Rescorla-Wagner rule
    prediction_error_ck =  1-CK(t,choices(t,1)); % compute prediction error as difference between actual reward and expected reward (i.e. value estimate for the chosen option) 
    CK(t+1,:) = CK(t,:); % first copy the current value estimates over to the next row of CK
    CK(t+1, choices(t,1)) = CK(t,choices(t,1)) + alpha_c*prediction_error_ck; % update the value estimate of the chosen option 

    prediction_error =  reward(t,1) - Q(t,choices(t,1)); % compute prediction error as difference between actual reward and expected reward (i.e. value estimate for the chosen option) 
    Q(t+1,:) = Q(t,:); % first copy the current value estimates over to the next row of Q
    Q(t+1, choices(t,1)) = Q(t,choices(t,1)) + alpha*prediction_error; % update the value estimate of the chosen option 
    
end % end the trial loop

%% Plot a figure that displays the cumulative reward as a function of trial number 

figure(); % create an empty figure 
plot(1:1000, cumsum(reward), 'k-', 'LineWidth', 1) % plot the cumulative reward line
ylim([0,1000]) % set the limits of the y axis
xlabel('trial number', 'FontSize', 18) % label the x-axis
ylabel('cumulative reward', 'FontSize', 18) % label the y-axis
ax = gca;
ax.FontSize = 14;

%% Plot a histogram of choices made

figure(); % create an empty figure
histogram(choices) % plot the historgram
xticks([1,2]) % set where the ticks will be present on the x axis

xlabel('option selected as choice', 'FontSize', 18); % label the x-axis
ylabel('frequency of options selected per choice', 'FontSize', 18); % label the y-axis
ax = gca;
ax.FontSize = 14;

%% Plot the data as the probability of 'Staying' with the previous choice as a function of whether or not you were rewarded 
% NB: For model 1, this plot stay behavior should not depend on whether a
% reward was received 

stay = NaN(1,T-1); % a place holder vector to store whether a particular trial is a stay trial or not
prevrew = zeros(1,T-1); % a placeholder vector to store whether the previous trial was rewarded or not

for t = 2:T % loop from trial 2 through T (1000)
    if choices(t) == choices(t-1) % if it was a stay trial
        stay(t-1) = 1; % yes
    else % if it was not
        stay(t-1) = 0; % no 
    end
         prevrew(t-1) = reward(t-1); % store the reward on prev trial  
end

figure() % create an empty figure

plot([0 1], [mean(stay(prevrew==0)), mean(stay(prevrew==1)) ], ['o-k'], 'Linewidth', 2, 'MarkerSize', 25, 'MarkerFaceColor', [1 1 1]); % plot the stay line
xlim([-0.25, 1.25]); % set the limits of the x axis
ylim([0,1]); % set the limits of the y axis
xticks([0,1]) % set where the ticks will be present on the x axis
xlabel('whether(1) or not(0) you were rewarded the previous trial', 'FontSize', 18); % label the x-axis
ylabel('probability of staying with the previous choice', 'FontSize', 18); % label the y-axis
ax = gca;
ax.FontSize = 14;
