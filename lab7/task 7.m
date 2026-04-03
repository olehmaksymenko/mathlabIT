% Завдання 7. Імовірнісна інтерпретація кон'юнктивних і диз'юнктивних операторів

x = 0:0.1:10;
y1 = gaussmf(x, [2 4]);
y2 = gaussmf(x, [2 7]);

% --- Алгебраїчний добуток: prod (кон'юнкція) ---
subplot(1, 2, 1);
y_prod = prod([y1; y2]);
plot(x, y1, 'b--', x, y2, 'r--', 'LineWidth', 1.5);
hold on;
plot(x, y_prod, 'k', 'LineWidth', 2.5);
hold off;
xlabel('x');
ylabel('Ступінь приналежності');
title('Алгебраїчний добуток (prod)');
legend('A', 'B', 'A · B');
grid on;

% --- Алгебраїчна сума: probor (диз'юнкція) ---
subplot(1, 2, 2);
y_probor = probor([y1; y2]);
plot(x, y1, 'b--', x, y2, 'r--', 'LineWidth', 1.5);
hold on;
plot(x, y_probor, 'k', 'LineWidth', 2.5);
hold off;
xlabel('x');
ylabel('Ступінь приналежності');
title('Алгебраїчна сума (probor)');
legend('A', 'B', 'A + B - A·B');
grid on;
