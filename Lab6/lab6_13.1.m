%% ============================================================
%  Лабораторна робота №1 — Повний Звіт (Варіант 13)
%  Функція 1: z(x,y) = cos(sin(y)) * sin(x)
%% ============================================================
clear; clc; close all;

%% ── Параметри та Налаштування ───────────────────────────────
f = @(x,y) cos(sin(y)) .* sin(x); % Функція Варіанту 13
N_IN = 6; N_OUT = 9;
X_MIN = 0; X_MAX = pi;
Y_MIN = 0; Y_MAX = pi;
Z_MIN = -1.05; Z_MAX = 1.05;

x_centers = linspace(X_MIN, X_MAX, N_IN);
y_centers = linspace(Y_MIN, Y_MAX, N_IN);
z_centers = linspace(Z_MIN, Z_MAX, N_OUT);

% Створення великого вікна з правильним компонуванням (3 рядки, 3 стовпці)
figure('Name','Повний Звіт: Варіант 13','Color','w','Position',[50 50 1400 900]);
tl = tiledlayout(3, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% Допоміжна функція для створення FIS
create_fis_simple = @(mft, r_tbl) create_fis_internal(mft, r_tbl, X_MIN, X_MAX, Y_MIN, Y_MAX, Z_MIN, Z_MAX, N_IN, N_OUT);

%% ── ПУНКТ 1: База правил та Еталон (Верхній рядок) ──────────

% Розрахунок таблиці значень та правил (повнобазових)
[Xc_grid, Yc_grid] = meshgrid(x_centers, y_centers);
Z_tbl = f(Xc_grid, Yc_grid);
Rule_tbl = zeros(N_IN);
for i=1:N_IN
    for j=1:N_IN
        [~,idx] = min(abs(z_centers - Z_tbl(i,j)));
        Rule_tbl(i,j) = idx;
    end
end

% 1. Таблиця правил (36 правил) - як на скріншоті (Heatmap)
nexttile(1);
imagesc(Rule_tbl); colorbar; colormap(gca, parula(N_OUT));
set(gca, 'XTick', 1:N_IN, 'YTick', 1:N_IN, 'YDir', 'normal', ...
         'XTickLabel', "mx"+(1:N_IN), 'YTickLabel', "my"+(1:N_IN));
title('Таблиця правил (36 правил)','FontSize',10,'FontWeight','bold');
for i=1:N_IN, for j=1:N_IN
    text(j, i, num2str(Rule_tbl(i,j)), 'H', 'center', 'Color', 'white','FontSize',9);
end; end

% 2. Еталон (3D Surface) - твоя хвиляста функція
nexttile(2);
[XX, YY] = meshgrid(linspace(X_MIN, X_MAX, 50));
surf(XX, YY, f(XX, YY)); shading interp; colormap(gca, jet); colorbar;
title('Еталон: z = cos(sin(y)) \cdot sin(x)','FontSize',10,'FontWeight','bold');
xlabel('x'); ylabel('y'); zlabel('z'); view(-35, 30); grid on;

% 3. Значення у точках МФ (Heatmap з кольоровою шкалою)
nexttile(3);
imagesc(x_centers, y_centers, Z_tbl); colorbar; colormap(gca, RdYlGn);
set(gca, 'YDir', 'normal', 'XTick', x_centers, 'YTick', y_centers);
title('Значення z у точках МФ','FontSize',10,'FontWeight','bold');
for i=1:N_IN, for j=1:N_IN
    text(x_centers(j), y_centers(i), sprintf('%.2f', Z_tbl(i,j)), 'H', 'center', 'FontSize',8);
end; end

%% ── ПУНКТ 2: Дослідження форми МФ (Середній рядок) ───────────

mf_types = {'gaussmf','trimf','trapmf'};
mf_names = {'Гаусова','Трикутна','Трапецієподібна'};
err_full = zeros(1,3);

for m = 1:3
    % Побудова FIS для повної бази
    fis36 = create_fis_simple(mf_types{m}, Rule_tbl);
    
    % Графік поверхні FIS (можна використати gensurf)
    ax = nexttile(3+m);
    gensurf(fis36, 'no_gui'); 
    title(['Нечітка модель (', mf_names{m}, ')'],'FontSize',10,'FontWeight','bold');
    xlabel('x'); ylabel('y'); zlabel('z'); grid on; view(-35, 30);
    
    % Розрахунок похибки
    [Xe, Ye] = meshgrid(linspace(X_MIN+0.1, X_MAX-0.1, 10));
    Ze_pred = evalfis(fis36, [Xe(:) Ye(:)]);
    Ze_pred = reshape(Ze_pred, size(Xe));
    eps36 = abs(f(Xe, Ye) - Ze_pred)./(abs(f(Xe, Ye))+1)*100;
    err_full(m) = mean(eps36(:));
    
    % Додаємо текст з похибкою на графік
    text(ax, 0.5, 0.9, sprintf('\\epsilon = %.2f%%', err_full(m)), ...
         'Units', 'normalized', 'Color', 'red', 'FontWeight', 'bold');
end

%% ── ПУНКТ 3: Зменшення правил (Нижній рядок) ────────────────

% Створення діагональної бази (6 правил)
Rule_diag = ones(N_IN)*Rule_tbl(1,1);
for k=1:N_IN, Rule_diag(k,k) = Rule_tbl(k,k); end
for i=1:N_IN, for j=1:N_IN, if i~=j, [~,ni] = min(abs((1:N_IN)-mean([i j]))); Rule_diag(i,j) = Rule_tbl(ni,ni); end; end; end

err_diag = zeros(1,3);
for m = 1:3
    % Побудова FIS для діагональної бази
    fis6 = create_fis_simple(mf_types{m}, Rule_diag);
    
    % Розрахунок похибки (так само)
    [Xe, Ye] = meshgrid(linspace(X_MIN+0.1, X_MAX-0.1, 10));
    Ze_d = evalfis(fis6, [Xe(:) Ye(:)]);
    Ze_d = reshape(Ze_d, size(Xe));
    epsd = abs(f(Xe, Ye) - Ze_d)./(abs(f(Xe, Ye))+1)*100;
    err_diag(m) = mean(epsd(:));
end

% 7. Порівняння похибок (Гістограма)
ax7 = nexttile(7);
xb = 1:3; wb = 0.35;
b1 = bar(ax7, xb-wb/2, err_full, wb, 'FaceColor', [0.18 0.63 0.35]); % Зелений
hold(ax7, 'on');
b2 = bar(ax7, xb+wb/2, err_diag, wb, 'FaceColor', [0.85 0.25 0.25], 'FaceAlpha', 0.5); % Червоний прозорий
set(ax7, 'XTick', xb, 'XTickLabel', mf_names); ylabel('Середня похибка \epsilon, %');
legend(ax7, {'36 правил (повна)','6 правил (діагональ)'},'Location','NorthWest','FontSize',8);
grid(ax7, 'on'); title('Порівняння похибок','FontSize',10,'FontWeight','bold');
% Текст похибок
for k=1:3
    text(ax7, k-wb/2, err_full(k)+0.3, sprintf('%.1f%%',err_full(k)), 'H', 'center', 'FontSize',8, 'FontWeight','bold');
    text(ax7, k+wb/2, err_diag(k)+0.3, sprintf('%.1f%%',err_diag(k)), 'H', 'center', 'FontSize',8, 'Color',[.5 0 0]);
end

% 8. Зростання похибки (Гістограма коефіцієнтів)
ax8 = nexttile(8);
growth = err_diag./err_full;
b3 = bar(ax8, xb, growth, 0.6, 'FaceColor', [0.22 0.48 0.78]); % Синій
set(ax8, 'XTick', xb, 'XTickLabel', mf_names); ylabel('Коефіцієнт зростання');
grid(ax8, 'on'); title('Зростання похибки (повна \rightarrow діагональ)','FontSize',10,'FontWeight','bold');
% Текст коефіцієнтів
for k=1:3
    text(ax8, k, growth(k)+0.05, sprintf('x%.1f', growth(k)), 'H', 'center', 'FontSize',9, 'FontWeight','bold');
end
% Додаємо червону лінію x1 (вихідний рівень)
line(ax8, [0 4], [1 1], 'Color', 'red', 'LineStyle', '--');

%% ── Допоміжна внутрішня функція створення FIS ───────────────
function fis = create_fis_internal(mft, r_tbl, xmin, xmax, ymin, ymax, zmin, zmax, nin, nout)
    fis = mamfis('Name', 'FIS');
    
    fis = addInput(fis, [xmin xmax], 'Name', 'x');
    step_x = (xmax-xmin)/(nin-1);
    for k=1:nin
        c = xmin+(k-1)*step_x;
        fis = addMF(fis, 'x', mft, get_mf_p(mft, c, step_x), 'Name', "mx"+k);
    end
    
    fis = addInput(fis, [ymin ymax], 'Name', 'y');
    step_y = (ymax-ymin)/(nin-1);
    for k=1:nin
        c = ymin+(k-1)*step_y;
        fis = addMF(fis, 'y', mft, get_mf_p(mft, c, step_y), 'Name', "my"+k);
    end
    
    fis = addOutput(fis, [zmin zmax], 'Name', 'z');
    step_z = (zmax-zmin)/(nout-1);
    for k=1:nout
        c = zmin+(k-1)*step_z;
        fis = addMF(fis, 'z', 'trimf', [c-step_z c c+step_z], 'Name', "mf"+k);
    end
    
    [X, Y] = meshgrid(1:nin, 1:nin);
    rules = [X(:) Y(:) r_tbl(:) ones(nin^2, 2)];
    fis = addRule(fis, rules);
end

function p = get_mf_p(mft, c, s)
    if strcmp(mft,'gaussmf'), p = [s*0.45 c];
    elseif strcmp(mft,'trimf'), p = [c-s c c+s];
    else, p = [c-s*0.9 c-s*0.3 c+s*0.3 c+s*0.9]; end
end
