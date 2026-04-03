% Завдання 2. Проста і двостороння функція приналежності Гаусса

x = -20:1:30;

% --- Проста ФП Гаусса ---
subplot(1, 2, 1);
y_gauss = gaussmf(x, [4 5]);
plot(x, y_gauss, 'b', 'LineWidth', 2);
xlabel('gaussmf(x, [4 5])');
ylabel('Ступінь приналежності');
title('Проста ФП Гаусса');
grid on;

% --- Двостороння ФП Гаусса ---
subplot(1, 2, 2);
y1 = gauss2mf(x, [4 3 6 7]);
y2 = gauss2mf(x, [4 4 6 8]);
y3 = gauss2mf(x, [4 5 6 9]);
plot(x, y1, 'b', x, y2, 'r', x, y3, 'g', 'LineWidth', 2);
xlabel('gauss2mf');
ylabel('Ступінь приналежності');
title('Двостороння ФП Гаусса');
legend('[4 3 6 7]', '[4 4 6 8]', '[4 5 6 9]');
grid on;
