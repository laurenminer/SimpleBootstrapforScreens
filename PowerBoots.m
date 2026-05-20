% Bootstrap Power Analysis

%% Generate a distribution based on sample size 15

Pilot_Control = load('Pilot_Control.mat');
Pilot_Control = Pilot_Control.Pilot_Control;

Pilot_High = load('Pilot_High.mat');
Pilot_High = Pilot_High.Pilot_High;

Pilot_Low = load('Pilot_Low.mat');
Pilot_Low = Pilot_Low.Pilot_Low;


% Parameters
n_samples = 15;        % number of values in each bootstrap sample
n_reps = 1000000;        % number of bootstrap replicates

% Preallocate array for bootstrap means
boot_means = zeros(n_reps, 1);

% Bootstrap sampling
for i = 1:n_reps
    sample = randsample(Pilot_High, n_samples, true);  % true = with replacement
    boot_means(i) = mean(sample);
end

% Compute 95% confidence interval
ci_bounds = prctile(boot_means, [2.5, 97.5]);
lower_ci = ci_bounds(1);
upper_ci = ci_bounds(2);

% Print to console
fprintf('95%% Confidence Interval for Mean (n = %d): [%.2f, %.2f]\n', n_samples, lower_ci, upper_ci);

% Plot histogram
figure;
histogram(boot_means, 50, 'Normalization', 'pdf');
xlabel('Sample Mean');
ylabel('Probability Density');
title('Bootstrap Distribution of Sample Means (n = 15)');
grid on;

% Add vertical lines for CI
hold on;
xline(lower_ci, 'r--', 'LineWidth', 2, 'Label', sprintf('%.2f', lower_ci), ...
    'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left');
xline(upper_ci, 'r--', 'LineWidth', 2, 'Label', sprintf('%.2f', upper_ci), ...
    'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right');
hold off;

%% Generate a power analysis 
Pilot_Control = load('Pilot_Control.mat');
Pilot_Control = Pilot_Control.Pilot_Control;

Pilot_Low = load('Pilot_Low.mat');
Pilot_Low = Pilot_Low.Pilot_Low;

Pilot_High = load('Pilot_High.mat');
Pilot_High = Pilot_High.Pilot_High;

% Parameters
n_reps = 1000000;                          % bootstrap repetitions
alpha = 0.05;                           % significance level
sample_sizes = 5:5:50;                 % range of sample sizes to test

% Preallocate power results
power_low = zeros(size(sample_sizes));
power_high = zeros(size(sample_sizes));

% Loop over each sample size
for idx = 1:length(sample_sizes)
    n = sample_sizes(idx);
    sig_count_low = 0;
    sig_count_high = 0;
    
    for rep = 1:n_reps
        % Sample with replacement from each group
        sample_ctrl  = randsample(Pilot_Control, n, true);
        sample_low   = randsample(Pilot_Low, n, true);
        sample_high  = randsample(Pilot_High, n, true);

        % Two-sided t-tests
        [~, p_low]  = ttest2(sample_ctrl, sample_low, 'Vartype', 'unequal');
        [~, p_high] = ttest2(sample_ctrl, sample_high, 'Vartype', 'unequal');

        % Count if significant
        sig_count_low  = sig_count_low  + (p_low  < alpha);
        sig_count_high = sig_count_high + (p_high < alpha);
    end

    % Store empirical power
    power_low(idx)  = sig_count_low  / n_reps;
    power_high(idx) = sig_count_high / n_reps;
    
    % Print update
    fprintf('n = %2d | Power Low: %.3f | Power High: %.3f\n', n, power_low(idx), power_high(idx));
end

% Plot power curves
figure;
plot(sample_sizes, power_low,  '-o', 'DisplayName', 'Control vs Low');
hold on;
plot(sample_sizes, power_high, '-o', 'DisplayName', 'Control vs High');
yline(0.8, 'r--', 'DisplayName', '80% Power');
xlabel('Sample Size per Group');
ylabel('Estimated Power');
title('Bootstrap Power Analysis');
legend('Location', 'southeast');
grid on;

%% Tph1 test

percent_caught = sum(boot_means > 62.67)/length(boot_means);
