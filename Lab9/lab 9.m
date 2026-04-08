% ============================================================
% ЛАБОРАТОРНА РОБОТА 4
% Моделювання об'єкта управління з двома входами і одним
% виходом на основі нейронних мереж
% ============================================================
% Функція двох змінних: z = sin(x) * cos(y)
% Входи: x, y в діапазоні [-pi, pi]
% Вихід нормований в діапазон (-1, 1) — Gain = 1 (вже в межах)
% ============================================================

%% --- Генерація вхідних даних (імітація Simulink To Workspace) ---
N = 500;
x = linspace(-pi, pi, N);
y = linspace(-pi, pi, N);

% Два входи нейронної мережі
Input  = [x; y];          % розмір [2 x N]
Output = sin(x) .* cos(y); % розмір [1 x N], вже в (-1, 1)

%% --- Конфігурації мереж ---
% Формат: {тип, [нейрони по шарах], назва}
configs = {
    'feedforwardnet',  [10],     'Feed-forward, 1 шар, 10 нейронів';
    'feedforwardnet',  [20],     'Feed-forward, 1 шар, 20 нейронів';
    'cascadeforwardnet',[20],    'Cascade-forward, 1 шар, 20 нейронів';
    'cascadeforwardnet',[10 10], 'Cascade-forward, 2 шари по 10 нейронів';
    'elmannet',        [15],     'Elman, 1 шар, 15 нейронів';
    'elmannet',        [5 5 5],  'Elman, 3 шари по 5 нейронів';
};

results = zeros(1, 6); % середні відносні помилки

for i = 1:6
    net_type  = configs{i, 1};
    layers    = configs{i, 2};
    net_name  = configs{i, 3};

    fprintf('\n=== Конфігурація %d: %s ===\n', i, net_name);

    % Створення мережі
    switch net_type
        case 'feedforwardnet'
            net = feedforwardnet(layers);
        case 'cascadeforwardnet'
            net = cascadeforwardnet(layers);
        case 'elmannet'
            net = elmannet(layers);
    end

    % Параметри навчання
    net.trainParam.epochs  = 1000;
    net.trainParam.goal    = 1e-6;
    net.trainParam.show    = 25;
    net.trainParam.showWindow = false; % без GUI

    % Навчання мережі
    [net, tr] = train(net, Input, Output);

    % Симуляція
    Output_nn = net(Input);

    % Середня відносна похибка (%)
    err = mean(abs(Output - Output_nn) ./ (abs(Output) + 1e-10)) * 100;
    results(i) = err;

    fprintf('Середня відносна похибка: %.6f %%\n', err);
    fprintf('MSE на тренуванні: %.2e\n', tr.best_perf);
end

%% --- Зведена таблиця результатів ---
fprintf('\n============================================\n');
fprintf('%-45s | Похибка (%%)\n', 'Конфігурація мережі');
fprintf('--------------------------------------------\n');
for i = 1:6
    fprintf('%-45s | %.6f\n', configs{i,3}, results(i));
end
fprintf('============================================\n');

%% --- Графік порівняння похибок ---
figure('Name', 'Порівняння похибок нейронних мереж');
bar(results, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'k');
set(gca, 'XTickLabel', {
    'FF 1×10', 'FF 1×20', ...
    'CF 1×20', 'CF 2×10', ...
    'EL 1×15', 'EL 3×5'});
xlabel('Конфігурація мережі');
ylabel('Середня відносна похибка (%)');
title('Порівняння похибок різних конфігурацій НМ');
grid on;

%% --- Графіки апроксимації для кожної конфігурації ---
% (запускати після виконання навчання вище)
% Для наочності будуємо один приклад — конфігурацію 1
net1 = feedforwardnet([10]);
net1.trainParam.epochs = 1000;
net1.trainParam.showWindow = false;
net1 = train(net1, Input, Output);
Out1 = net1(Input);

figure('Name', 'Апроксимація функції нейронною мережею');
plot(x, Output, 'b-', 'LineWidth', 2, 'DisplayName', 'Оригінальна функція');
hold on;
plot(x, Out1, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Вихід НМ (FF 1×10)');
hold off;
xlabel('x (при y = x)');
ylabel('z = sin(x)·cos(y)');
title('Апроксимація функції двох змінних нейронною мережею');
legend('Location', 'best');
grid on;
