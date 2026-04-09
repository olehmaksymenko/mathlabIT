% ============================================================
% ЛАБОРАТОРНА РОБОТА 6
% Нейро-нечітке моделювання в середовищі MATLAB (ANFIS)
% Задача: Прогнозування фінансового індексу РТС
% ============================================================

clc; clear; close all;

%% --- Завдання 1-2. Дані фінансового індексу РТС ---
rts = [688.72, 686.21, 667.27, 669.26, 673.25, 688.68, 680.86, ...
       671.33, 669.55, 676.20, 680.57, 698.70, 708.59, 721.81, ...
       712.88, 713.15, 705.16, 706.71, 716.55, 721.35, 736.28, ...
       688.72, 686.21, 667.27, 669.26, 673.25, 688.68, 680.86, ...
       671.33, 669.55, 676.20, 680.57];

% Формування вибірки: вікно 3 попередніх значення -> наступне
n_lag = 3;
N = length(rts) - n_lag;
data = zeros(N, n_lag + 1);
for i = 1:N
    data(i, :) = rts(i : i + n_lag);
end

% Розбивка: 80% навчання, 20% тестування
n_train = round(0.8 * N);
train_data = data(1:n_train, :);
test_data  = data(n_train+1:end, :);

% Збереження навчальних даних у файл .dat
dlmwrite('rts_train.dat', train_data, 'delimiter', '\t', 'precision', 4);
dlmwrite('rts_test.dat',  test_data,  'delimiter', '\t', 'precision', 4);

fprintf('Навчальна вибірка: %d рядків\n', n_train);
fprintf('Тестова вибірка:   %d рядків\n', N - n_train);

%% --- Завдання 3. Генерація та візуалізація структури ANFIS ---

% Генерація початкової FIS методом решітки (Grid partition)
% 3 входи, по 3 функції приналежності (trimf) для кожного
num_mf  = 3;
mf_type = 'trimf';

fis_init = genfis1(train_data, num_mf, mf_type);

fprintf('\nСтруктура FIS:\n');
fprintf('  Входів:  %d\n', length(fis_init.input));
fprintf('  Виходів: %d\n', length(fis_init.output));
fprintf('  Правил:  %d\n', length(fis_init.rule));

%% --- Завдання 4. Навчання ANFIS ---

% Параметри навчання:
% [epochs, error_goal, initial_step, step_decrease, step_increase]
epochs     = 40;
error_goal = 0;
opt = anfisOptions('InitialFIS', fis_init, ...
                   'EpochNumber', epochs, ...
                   'ErrorGoal',   error_goal, ...
                   'OptimizationMethod', 1, ... % 1 = hybrid
                   'DisplayANFISInformation', 1, ...
                   'DisplayErrorValues', 1);

fprintf('\n=== Навчання ANFIS (гібридний метод) ===\n');
[fis_trained, train_error, ~, ~, check_error] = anfis(train_data, opt);

fprintf('Фінальна помилка навчання: %.4f\n', train_error(end));

%% --- Завдання 5. Система нечіткого виводу ---

% Виведення правил
fprintf('\n=== Перші 5 правил нечіткого виводу ===\n');
showrule(fis_trained, 1:min(5, length(fis_trained.rule)));

%% --- Завдання 6. Перевірка адекватності (прогнозування) ---

% Прогноз на навчальній вибірці
y_train_pred = evalfis(fis_trained, train_data(:, 1:n_lag));
y_train_real = train_data(:, end);

% Прогноз на тестовій вибірці
y_test_pred  = evalfis(fis_trained, test_data(:, 1:n_lag));
y_test_real  = test_data(:, end);

% Похибки
mse_train = mean((y_train_real - y_train_pred).^2);
mse_test  = mean((y_test_real  - y_test_pred).^2);
rmse_train = sqrt(mse_train);
rmse_test  = sqrt(mse_test);
mape_train = mean(abs((y_train_real - y_train_pred)./y_train_real)) * 100;
mape_test  = mean(abs((y_test_real  - y_test_pred) ./y_test_real))  * 100;

fprintf('\n=== Результати ===\n');
fprintf('RMSE (навчання): %.4f\n', rmse_train);
fprintf('RMSE (тест):     %.4f\n', rmse_test);
fprintf('MAPE (навчання): %.4f %%\n', mape_train);
fprintf('MAPE (тест):     %.4f %%\n', mape_test);

% Прогноз наступного значення
last3 = rts(end-2:end);
next_val = evalfis(fis_trained, last3);
fprintf('\nПрогноз наступного значення РТС: %.2f\n', next_val);

%% --- Графіки ---

% Figure 1: Графік навчання
figure('Name', 'ANFIS: Крива навчання');
semilogy(1:epochs, train_error, 'b-o', 'LineWidth', 2, 'MarkerSize', 4);
xlabel('Епоха'); ylabel('Похибка (log)');
title('Крива навчання ANFIS (гібридний метод)');
grid on;

% Figure 2: Порівняння реальних і прогнозованих значень
figure('Name', 'ANFIS: Прогнозування РТС');
subplot(2,1,1);
plot(y_train_real, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(y_train_pred, 'r--s', 'LineWidth', 1.5, 'MarkerSize', 4);
hold off;
xlabel('Індекс'); ylabel('Значення РТС');
title('Навчальна вибірка: реальні vs прогнозовані');
legend('Реальні', 'ANFIS прогноз'); grid on;

subplot(2,1,2);
plot(y_test_real, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(y_test_pred, 'r--s', 'LineWidth', 1.5, 'MarkerSize', 4);
hold off;
xlabel('Індекс'); ylabel('Значення РТС');
title(sprintf('Тестова вибірка: RMSE=%.2f, MAPE=%.4f%%', rmse_test, mape_test));
legend('Реальні', 'ANFIS прогноз'); grid on;

% Figure 3: Функції приналежності до і після навчання
figure('Name', 'ANFIS: Функції приналежності (після навчання)');
for i = 1:3
    subplot(1, 3, i);
    plotmf(fis_trained, 'input', i);
    title(sprintf('Вхід %d (після навчання)', i));
end
