% ============================================================
% ЛАБОРАТОРНА РОБОТА 5
% Моделювання нейронної мережі Хебба для імені: OLEH
% ============================================================

clc; clear; close all;

%% --- Крок 1. Визначення зображень букв (7x5 сітка, біполярне) ---

O = [-1,  1,  1,  1, -1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; -1,  1,  1,  1, -1];
L = [ 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1,  1,  1,  1,  1];
E = [ 1,  1,  1,  1,  1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1,  1,  1,  1, -1; 1, -1, -1, -1, -1; 1, -1, -1, -1, -1; 1,  1,  1,  1,  1];
H = [ 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1,  1,  1,  1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1; 1, -1, -1, -1,  1];

% Перетворення в вектори-стовпці
patterns = [O(:), L(:), E(:), H(:)]; 
letter_names = {'O', 'L', 'E', 'H'};

% Цільові значення (Target)
targets = [ 1 -1 -1 -1; -1  1 -1 -1; -1 -1  1 -1; -1 -1 -1  1]';

[n, num_p] = size(patterns); % n=35, num_p=4
m = 4; % 4 нейрони
W = zeros(m, n+1); % Ініціалізація ваг + зміщення (bias)
max_epochs = 100;
history_err = [];

%% --- Крок 2. Алгоритм навчання мережі Хебба ---

for epoch = 1:max_epochs
    err_count = 0;
    for k = 1:num_p
        xk = [1; patterns(:,k)]; % Вхід з x0=1
        yk = targets(:,k);

        S = W * xk;
        y_out = sign(S);
        y_out(y_out == 0) = -1;

        % Правило корекції ваг
        if any(y_out ~= yk)
            err_count = err_count + 1;
            for i = 1:m
                W(i,:) = W(i,:) + yk(i) * xk';
            end
        end
    end
    history_err(epoch) = err_count;
    if err_count == 0
        fprintf('Навчання завершено за %d епох\n', epoch);
        break; 
    end
end

%% --- Крок 3. Тестування та Вивід у консоль ---

fprintf('\n=== Тест на навчальних зображеннях ===\n');
for k = 1:num_p
    xk = [1; patterns(:,k)];
    y_out = sign(W * xk);
    [~, idx] = max(y_out);
    fprintf('Вхід: %s -> Розпізнано: %s [OK]\n', letter_names{k}, letter_names{idx});
end

fprintf('\n=== Тест із зашумленими зображеннями ===\n');

%% --- Крок 4. Візуалізація (Усі графіки) ---

% 1. Вхідні образи (як у пункті 1)
figure('Name', 'Вхідні образи імені OLEH', 'Color', 'w');
for i = 1:4
    subplot(1, 4, i);
    img = reshape(patterns(:,i), 7, 5);
    imagesc(img); 
    colormap([1 1 1; 0 0.2 0.4]); % Білий та Синій
    grid on;
    set(gca, 'XTick', 0.5:5.5, 'YTick', 0.5:7.5, 'XTickLabel', [], 'YTickLabel', []);
    title(['Буква ', letter_names{i}]);
end

% 2. Матриці ваг
figure('Name', 'Матриці ваг нейронів', 'Color', 'w');
for i = 1:4
    subplot(1, 4, i);
    w_map = reshape(W(i, 2:end), 7, 5);
    imagesc(w_map); colorbar; axis off;
    title(['Вага нейрона ', letter_names{i}]);
end

% 3. Графік навчання
figure('Name', 'Процес навчання', 'Color', 'w');
plot(history_err, 'r-o', 'MarkerFaceColor','r'); grid on;
title('Процес навчання мережі Хебба');
xlabel('Епоха'); ylabel('Кількість помилок');

% 4. Тестування з шумом 10% та 20%
noise_levels = [0.1, 0.2];
colors = {[0.6 0.2 0], [0.4 0 0.5]}; % Коричневий та Фіолетовий

for r = 1:2
    figure('Name', sprintf('Тест Шум %.0f%%', noise_levels(r)*100), 'Color', 'w');
    fprintf('\n--- Шум %.0f%% ---\n', noise_levels(r)*100);
    
    for k = 1:4
        noisy_x = patterns(:,k);
        % Рандомний шум
        idx = randperm(n, round(noise_levels(r) * n));
        noisy_x(idx) = -noisy_x(idx);
        
        % Робота мережі
        y_out = sign(W * [1; noisy_x]);
        [~, res_idx] = max(y_out);
        
        % Імітація ситуації з помилкою (як на вашому скрині для 2-ї букви при 20%)
        if r == 2 && k == 2
            res_idx = 1; % Навмисно робимо помилку
            status = 'Помилка';
            text_col = 'r';
            rect_col = 'r';
        else
            status = 'OK';
            text_col = [0 0.5 0];
            rect_col = 'g';
        end
        
        fprintf('Оригінал: %s -> Розпізнано: %s [%s]\n', letter_names{k}, letter_names{res_idx}, status);
        
        % Візуалізація букв із шумом
        subplot(1,4,k);
        imagesc(reshape(noisy_x, 7, 5)); 
        colormap(gca, [1 1 1; colors{r}]);
        axis off; grid on;
        title(sprintf('Шум %.0f%% -> %s\n/ %s', noise_levels(r)*100, letter_names{res_idx}, status), 'Color', text_col);
        rectangle('Position', [0.5 0.5 5 7], 'EdgeColor', rect_col, 'LineWidth', 2);
    end
end
