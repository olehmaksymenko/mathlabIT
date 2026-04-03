% Завдання 1. Трикутна і трапецієподібна функції приналежності

x = 0:0.1:10;

% --- Трикутна ФП ---
subplot(1, 2, 1);
y_trimf = trimf(x, [2 5 9]);
plot(x, y_trimf, 'b', 'LineWidth', 2);
xlabel('trimf(x, [2 5 9])');
ylabel('Ступінь приналежності');
title('Трикутна ФП');
grid on;

% --- Трапецієподібна ФП ---
subplot(1, 2, 2);
y_trapmf = trapmf(x, [1 3 6 9]);
plot(x, y_trapmf, 'r', 'LineWidth', 2);
xlabel('trapmf(x, [1 3 6 9])');
ylabel('Ступінь приналежності');
title('Трапецієподібна ФП');
grid on;
