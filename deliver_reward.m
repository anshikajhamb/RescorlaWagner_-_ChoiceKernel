function outcome = deliver_reward(chosen_option, reward_probabilities)
    reward_random_number = rand;
    if reward_random_number < reward_probabilities(chosen_option)
        outcome = 1; 
    else
        outcome = 0; 
    end
end
