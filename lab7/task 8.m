% Завдання 8. Доповнення нечіткої множини (логічне заперечення НЕ А)

x = 0:0.1:10;

% Вихідна нечітка множина A
y1 = gaussmf(x, [2 5]);

% Доповнення: НЕ А = 1 - A
y_comp = 1 - y1;

plot(x, y1, 'b--', 'LineWidth', 2);
hold on;
plot(x, y_comp, 'r', 'LineWidth', 2);
hold off;
xlabel('x');
ylabel('Ступінь приналежності');
title('Доповнення нечіткої множини (НЕ А)');
legend('A = gaussmf(x, [2 5])', 'НЕ A = 1 - A');
grid on;
