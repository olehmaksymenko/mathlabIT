% Завдання 5. Поліноміальні функції приналежності (Z, PI, S)

x = 0:0.1:10;

% --- Z-функція (відкрита зліва) ---
subplot(1, 3, 1);
y_zmf = zmf(x, [3 7]);
plot(x, y_zmf, 'b', 'LineWidth', 2);
xlabel('zmf(x, [3 7])');
ylabel('Ступінь приналежності');
title('Z-функція (zmf)');
grid on;

% --- PI-функція ---
subplot(1, 3, 2);
y_pimf = pimf(x, [2 4 6 8]);
plot(x, y_pimf, 'r', 'LineWidth', 2);
xlabel('pimf(x, [2 4 6 8])');
ylabel('Ступінь приналежності');
title('PI-функція (pimf)');
grid on;

% --- S-функція (дзеркало Z-функції) ---
subplot(1, 3, 3);
y_smf = smf(x, [3 7]);
plot(x, y_smf, 'g', 'LineWidth', 2);
xlabel('smf(x, [3 7])');
ylabel('Ступінь приналежності');
title('S-функція (smf)');
grid on;
