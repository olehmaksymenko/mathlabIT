% Завдання 4. Сигмоїдальні функції приналежності

x = 0:0.1:10;

% --- Основна сигмоїда (відкрита праворуч) ---
subplot(1, 3, 1);
y_sig = sigmf(x, [4 5]);
plot(x, y_sig, 'b', 'LineWidth', 2);
xlabel('sigmf(x, [4 5])');
ylabel('Ступінь приналежності');
title('Основна сигмоїда (sigmf)');
grid on;

% --- dsigmf: різниця двох сигмоїд (двостороння) ---
subplot(1, 3, 2);
y_dsig = dsigmf(x, [4 3 6 7]);
plot(x, y_dsig, 'r', 'LineWidth', 2);
xlabel('dsigmf(x, [4 3 6 7])');
ylabel('Ступінь приналежності');
title('Двостороння (dsigmf)');
grid on;

% --- psigmf: добуток двох сигмоїд (несиметрична) ---
subplot(1, 3, 3);
y_psig = psigmf(x, [6 3 -5 7]);
plot(x, y_psig, 'g', 'LineWidth', 2);
xlabel('psigmf(x, [6 3 -5 7])');
ylabel('Ступінь приналежності');
title('Несиметрична (psigmf)');
grid on;
