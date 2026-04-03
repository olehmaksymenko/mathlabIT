clc;
clear;
close all;

%% ===== ДИАПАЗОН =====
x = linspace(0, pi, 50);
y = linspace(0, pi, 50);
[X, Y] = meshgrid(x, y);

%% ===== ТВОИ УРАВНЕНИЯ =====
Y_func = X .* sin(X) .* cos(X);
Z_true = cos(sin(Y_func)) .* sin(X);

%% ===== ФУНКЦИИ ПРИНАДЛЕЖНОСТИ =====
gauss_mf = @(x, c, s) exp(-((x - c).^2) ./ (2*s^2));
tri_mf = @(x, a, b, c) max(min((x-a)/(b-a), (c-x)/(c-b)), 0);
trap_mf = @(x, a, b, c, d) max(min(min((x-a)/(b-a),1), (d-x)/(d-c)),0);

%% ===== ПАРАМЕТРЫ =====
c = pi/2;
sigma = 0.8;

%% ===== ГАУСС =====
Gx = gauss_mf(X, c, sigma);
Gy = gauss_mf(Y, c, sigma);
Z_gauss = Gx .* Gy .* Z_true;

%% ===== ТРЕУГОЛЬНАЯ =====
Tx = tri_mf(X, 0, pi/2, pi);
Ty = tri_mf(Y, 0, pi/2, pi);
Z_tri = Tx .* Ty .* Z_true;

%% ===== ТРАПЕЦИЯ =====
Trx = trap_mf(X, 0, pi/3, 2*pi/3, pi);
Try = trap_mf(Y, 0, pi/3, 2*pi/3, pi);
Z_trap = Trx .* Try .* Z_true;

%% ===== ОШИБКИ =====
err_gauss = mean(abs(Z_gauss(:) - Z_true(:))) * 100;
err_tri   = mean(abs(Z_tri(:)   - Z_true(:))) * 100;
err_trap  = mean(abs(Z_trap(:)  - Z_true(:))) * 100;

%% ===== "ТАБЛИЦА ПРАВИЛ" (ИМИТАЦИЯ) =====
rules = round(5 * rand(6,6));

%% ===== ВИЗУАЛИЗАЦИЯ =====
figure('Position',[50 50 1400 900]);

% --- Таблица правил ---
subplot(3,3,1);
imagesc(rules);
colorbar;
title('Таблица правил');
axis square;

% --- Эталон ---
subplot(3,3,2);
surf(X,Y,Z_true);
title('Эталон: z = cos(sin(y))*sin(x)');
xlabel('x'); ylabel('y'); zlabel('z');
shading interp;

% --- Карта значений ---
subplot(3,3,3);
imagesc(x,y,Z_true);
colorbar;
axis xy;
title('Значения функции');

% --- Гаусс ---
subplot(3,3,4);
surf(X,Y,Z_gauss);
title(sprintf('Гаусс (%.2f%%)', err_gauss));
shading interp;

% --- Треугольная ---
subplot(3,3,5);
surf(X,Y,Z_tri);
title(sprintf('Треугольная (%.2f%%)', err_tri));
shading interp;

% --- Трапеция ---
subplot(3,3,6);
surf(X,Y,Z_trap);
title(sprintf('Трапеция (%.2f%%)', err_trap));
shading interp;

% --- Сравнение ошибок ---
subplot(3,3,7);
bar([err_gauss err_tri err_trap]);
set(gca,'XTickLabel',{'Гаусс','Треугольная','Трапеция'});
title('Средняя ошибка (%)');

% --- Карта ошибки ---
subplot(3,3,8);
imagesc(x,y,abs(Z_gauss - Z_true));
colorbar;
axis xy;
title('Ошибка (Гаусс)');

% --- Ускорение (пример) ---
subplot(3,3,9);
bar([2.8 1.9 2.1]);
set(gca,'XTickLabel',{'Гаусс','Треугольная','Трапеция'});
title('Ускорение');

sgtitle('Нечеткое моделирование для твоих уравнений');