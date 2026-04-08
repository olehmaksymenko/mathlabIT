% ============================================================
% ЛАБОРАТОРНА РОБОТА 5
% Моделювання нейронної мережі Хебба
% Розпізнавання букв: В, І, Т, А
% Сітка 7x5 = 35 пікселів (біполярне кодування: +1/-1)
% ============================================================

clc; clear; close all;

%% --- Крок 1. Визначення зображень букв (7x5 сітка, біполярне) ---

% Буква В
V = [ 1,  1,  1, -1, -1;
      1, -1, -1,  1, -1;
      1, -1, -1,  1, -1;
      1,  1,  1, -1, -1;
      1, -1, -1,  1, -1;
      1, -1, -1,  1, -1;
      1,  1,  1, -1, -1];

% Буква І
II = [-1,  1,  1,  1, -1;
      -1, -1,  1, -1, -1;
      -1, -1,  1, -1, -1;
      -1, -1,  1, -1, -1;
      -1, -1,  1, -1, -1;
      -1, -1,  1, -1, -1;
      -1,  1,  1,  1, -1];

% Буква Т
T = [ 1,  1,  1,  1,  1;
     -1, -1,  1, -1, -1;
     -1, -1,  1, -1, -1;
     -1, -1,  1, -1, -1;
     -1, -1,  1, -1, -1;
     -1, -1,  1, -1, -1;
     -1, -1,  1, -1, -1];

% Буква А
A = [-1, -1,  1, -1, -1;
     -1,  1, -1,  1, -1;
      1, -1, -1, -1,  1;
      1,  1,  1,  1,  1;
      1, -1, -1, -1,  1;
      1, -1, -1, -1,  1;
      1, -1, -1, -1,  1];

% Перетворення в вектори-стовпці (35x1)
x1 = V(:);
x2 = II(:);
x3 = T(:);
x4 = A(:);

% Навчальна вибірка: {(X^k, t^k)}
% В -> [+1, -1, -1, -1]
% І -> [-1, +1, -1, -1]
% Т -> [-1, -1, +1, -1]
% А -> [-1, -1, -1, +1]
patterns = [x1, x2, x3, x4];   % 35 x 4
targets  = [  1 -1 -1 -1;       % 4 x 4
             -1  1 -1 -1;
             -1 -1  1 -1;
             -1 -1 -1  1]';

n = size(patterns, 1);  % 35 входів
m = 4;                  % 4 нейрони

%% --- Алгоритм мережі Хебба ---

% Крок 1. Ініціалізація ваг [m x (n+1)] з урахуванням зміщення
W = zeros(m, n+1);

max_epochs = 100;
converged  = false;

for epoch = 1:max_epochs
    % Кроки 2-5: для кожної пари (X^k, t^k)
    for k = 1:4
        xk = [1; patterns(:,k)];  % x0=1 (зміщення)
        yk = targets(:,k);

        S     = W * xk;
        y_out = sign(S);
        y_out(y_out == 0) = -1;

        % Крок 5: коригування якщо вихід не збігається
        if any(y_out ~= yk)
            for i = 1:m
                W(i,:) = W(i,:) + yk(i) * xk';
            end
        end
    end

    % Крок 6: перевірка умов зупинки
    all_correct = true;
    for k = 1:4
        xk    = [1; patterns(:,k)];
        S     = W * xk;
        y_out = sign(S);
        y_out(y_out == 0) = -1;
        if any(y_out ~= targets(:,k))
            all_correct = false;
            break;
        end
    end

    if all_correct
        fprintf('Навчання завершено за %d епох\n', epoch);
        converged = true;
        break;
    end
end

if ~converged
    fprintf('УВАГА: Алгоритм не збігся за %d епох!\n', max_epochs);
end

%% --- Тестування на навчальних зображеннях ---
letter_names = {'В', 'І', 'Т', 'А'};

fprintf('\n=== Тест на навчальних зображеннях ===\n');
for k = 1:4
    xk    = [1; patterns(:,k)];
    S     = W * xk;
    y_out = sign(S);
    y_out(y_out == 0) = -1;
    [~, idx] = max(y_out);
    status = 'OK';
    if idx ~= k; status = 'ПОМИЛКА'; end
    fprintf('Вхід: %s -> Розпізнано: %s [%s]\n', ...
        letter_names{k}, letter_names{idx}, status);
end

%% --- Тестування із зашумленими зображеннями ---
fprintf('\n=== Тест із зашумленими зображеннями ===\n');

for nl = [0.10, 0.20]
    fprintf('\n--- Шум %.0f%% ---\n', nl*100);
    for k = 1:4
        x_noisy  = patterns(:,k);
        n_flip   = round(nl * n);
        idx_flip = randperm(n, n_flip);
        x_noisy(idx_flip) = -x_noisy(idx_flip);

        xk    = [1; x_noisy];
        S     = W * xk;
        y_out = sign(S);
        y_out(y_out == 0) = -1;
        [~, rec_idx] = max(y_out);
        status = 'OK';
        if rec_idx ~= k; status = 'ПОМИЛКА'; end
        fprintf('Оригінал: %s -> Розпізнано: %s [%s]\n', ...
            letter_names{k}, letter_names{rec_idx}, status);
    end
end

%% --- Графік: зображення букв ---
figure('Name', 'Навчальні зображення букв В, І, Т, А');
for i = 1:4
    subplot(1, 4, i);
    img = reshape(patterns(:,i), 7, 5);
    imagesc(img); colormap(gray); axis off;
    title(letter_names{i}, 'FontSize', 16, 'FontWeight', 'bold');
end
sgtitle('Навчальні зображення (7x5 сітка)', 'FontSize', 13);

%% --- Графік: матриці ваг ---
figure('Name', 'Матриці ваг нейронів');
for i = 1:4
    subplot(1, 4, i);
    w_map = reshape(W(i, 2:end), 7, 5);
    imagesc(w_map); colorbar; axis off;
    title(['Нейрон ', letter_names{i}], 'FontSize', 12);
end
sgtitle('Матриці ваг мережі Хебба (В, І, Т, А)', 'FontSize', 13);
