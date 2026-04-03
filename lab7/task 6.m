% Завдання 6. Мінімаксна інтерпретація логічних операторів

x = 0:0.1:10;
y1 = gaussmf(x, [2 4]);
y2 = gaussmf(x, [2 7]);

% --- Перетин: min (кон'юнкція) ---
subplot(1, 2, 1);
y_min = min([y1; y2]);
plot(x, y1, 'b--', x, y2, 'r--', 'LineWidth', 1.5);
hold on;
plot(x, y_min, 'k', 'LineWidth', 2.5);
hold off;
xlabel('x');
ylabel('Ступінь приналежності');
title('Перетин — min (кон''юнкція)');
legend('A', 'B', 'A ∩ B = min(A,B)');
grid on;

% --- Об'єднання: max (диз'юнкція) ---
subplot(1, 2, 2);
y_max = max([y1; y2]);
plot(x, y1, 'b--', x, y2, 'r--', 'LineWidth', 1.5);
hold on;
plot(x, y_max, 'k', 'LineWidth', 2.5);
hold off;
xlabel('x');
ylabel('Ступінь приналежності');
title('Об''єднання — max (диз''юнкція)');
legend('A', 'B', 'A ∪ B = max(A,B)');
grid on;
