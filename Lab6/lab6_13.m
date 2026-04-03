%% ============================================================
%  Лабораторна робота №1 — Повний Звіт (Варіант 13)
%  Функція: z(x,y) = cos(sin(y)) * sin(x)
%% ============================================================
clear; clc; close all;

%% ── 1. Параметри моделі ──────────────────────────────────────
f = @(x,y) cos(sin(y)) .* sin(x); 
N_IN = 6; N_OUT = 9;
X_MIN = 0; X_MAX = pi;
Y_MIN = 0; Y_MAX = pi;
Z_MIN = -1.05; Z_MAX = 1.05;

x_c = linspace(X_MIN, X_MAX, N_IN);
y_c = linspace(Y_MIN, Y_MAX, N_IN);
z_c = linspace(Z_MIN, Z_MAX, N_OUT);

% Розрахунок значень та правил
[Xc, Yc] = meshgrid(x_c, y_c);
Z_val = f(Xc, Yc);
Rule_tbl = zeros(N_IN);
for i=1:N_IN
    for j=1:N_IN
        [~,idx] = min(abs(z_c - Z_val(i,j)));
        Rule_tbl(i,j) = idx;
    end
end

%% ── 2. Створення графічного вікна (3x3 Tiles) ───────────────
fig = figure('Name','Звіт: Варіант 13','Color','w','Position', [50 50 1300 900]);
tlo = tiledlayout(3, 3, 'TileSpacing', 'compact', 'Padding', 'tight');

%% ── ПЕРШИЙ РЯД: База та Еталон ───────────────────────────────

% 1. Таблиця правил (Heatmap)
nexttile;
imagesc(Rule_tbl); colormap(gca, parula); colorbar;
set(gca, 'XTick', 1:N_IN, 'YTick', 1:N_IN, 'XTickLabel', "mx"+(1:N_IN), 'YTickLabel', "my"+(1:N_IN));
title('Таблиця правил (36 шт)');
for i=1:N_IN, for j=1:N_IN
    text(j, i, num2str(Rule_tbl(i,j)), 'H', 'center', 'Color', 'w', 'FontSize', 8);
end; end

% 2. Еталонна поверхня
nexttile;
[Xg, Yg] = meshgrid(linspace(X_MIN, X_MAX, 50));
surf(Xg, Yg, f(Xg, Yg)); shading interp; colormap(gca, jet); colorbar;
title('Еталон: z = cos(sin(y)) \cdot sin(x)'); view(-35, 35); grid on;

% 3. Значення у точках МФ
nexttile;
imagesc(x_c, y_c, Z_val); colormap(gca, 'summer'); colorbar;
title('Значення z у точках МФ');
for i=1:N_IN, for j=1:N_IN
    text(x_c(j), y_c(i), sprintf('%.2f', Z_val(i,j)), 'H', 'center', 'FontSize', 7);
end; end

%% ── ДРУГИЙ РЯД: Моделі за типами МФ ──────────────────────────
mf_types = {'gaussmf', 'trimf', 'trapmf'};
mf_names = {'Гаусова', 'Трикутна', 'Трапецієподібна'};
err_full = zeros(1,3);

% Сітка для оцінки похибки
[Xe, Ye] = meshgrid(linspace(X_MIN+0.1, X_MAX-0.1, 12));
Ze_true = f(Xe, Ye);

for m = 1:3
    fis = create_fis_internal(mf_types{m}, Rule_tbl, X_MIN, X_MAX, Y_MIN, Y_MAX, Z_MIN, Z_MAX, N_IN, N_OUT);
    Ze_p = evalfis(fis, [Xe(:) Ye(:)]);
    Ze_p = reshape(Ze_p, size(Xe));
    err_full(m) = mean(abs(Ze_true(:) - Ze_p(:))./(abs(Ze_true(:))+1)*100);
    
    ax = nexttile;
    surf(Xe, Ye, Ze_p); shading interp; colormap(ax, jet);
    title(sprintf('Модель (%s)\n\\epsilon = %.2f%%', mf_names{m}, err_full(m)));
    view(-35, 35); grid on;
end

%% ── ТРЕТІЙ РЯД: Порівняння та Аналіз ─────────────────────────

% Розрахунок діагональної бази (6 правил)
err_diag = zeros(1,3);
Rule_diag = ones(N_IN)*Rule_tbl(1,1);
for k=1:N_IN, Rule_diag(k,k) = Rule_tbl(k,k); end
% (Заповнення фону середнім значенням для стабільності)
for i=1:N_IN, for j=1:N_IN, if i~=j, [~,ni]=min(abs((1:N_IN)-mean([i j]))); Rule_diag(i,j)=Rule_tbl(ni,ni); end; end; end

for m = 1:3
    fis_d = create_fis_internal(mf_types{m}, Rule_diag, X_MIN, X_MAX, Y_MIN, Y_MAX, Z_MIN, Z_MAX, N_IN, N_OUT);
    Ze_d = evalfis(fis_d, [Xe(:) Ye(:)]);
    Ze_d = reshape(Ze_d, size(Xe));
    err_diag(m) = mean(abs(Ze_true(:) - Ze_d(:))./(abs(Ze_true(:))+1)*100);
end

% 7. Бар-чарт похибок
nexttile([1 2]);
b = bar([err_full' err_diag'], 'grouped');
set(gca, 'XTickLabel', mf_names); ylabel('Похибка \epsilon, %');
legend('36 правил (повна)', '6 правил (діагональ)', 'Location', 'northoutside', 'Orientation', 'horizontal');
title('Порівняння середньої відносної похибки'); grid on;
for k=1:3
    text(k-0.15, err_full(k)+1, sprintf('%.1f%%', err_full(k)), 'H', 'center', 'FontWeight', 'bold');
    text(k+0.15, err_diag(k)+1, sprintf('%.1f%%', err_diag(k)), 'H', 'center', 'Color', 'r');
end

% 8. Коефіцієнт зростання
nexttile;
growth = err_diag ./ err_full;
bar(growth, 'FaceColor', [0.2 0.5 0.8]);
set(gca, 'XTickLabel', mf_names); ylabel('Коефіцієнт');
title('Зростання похибки (раз)'); grid on;
for k=1:3, text(k, growth(k)+0.2, sprintf('x%.1f', growth(k)), 'H', 'center', 'FontWeight', 'bold'); end

%% ── Допоміжна функція створення FIS ──────────────────────────
function fis = create_fis_internal(mft, r_tbl, xmin, xmax, ymin, ymax, zmin, zmax, nin, nout)
    fis = mamfis('Name', 'FIS');
    fis = addInput(fis, [xmin xmax], 'Name', 'x');
    fis = addInput(fis, [ymin ymax], 'Name', 'y');
    sx = (xmax-xmin)/(nin-1); sy = (ymax-ymin)/(nin-1);
    for k=1:nin
        cx = xmin+(k-1)*sx; cy = ymin+(k-1)*sy;
        if strcmp(mft,'gaussmf'), px=[sx*0.4 cx]; py=[sy*0.4 cy];
        elseif strcmp(mft,'trimf'), px=[cx-sx cx cx+sx]; py=[cy-sy cy cy+sy];
        else, px=[cx-sx*0.9 cx-sx*0.3 cx+sx*0.3 cx+sx*0.9]; py=[cy-sy*0.9 cy-sy*0.3 cy+sy*0.3 cy+sy*0.9]; end
        fis = addMF(fis, 'x', mft, px, 'Name', "mx"+k);
        fis = addMF(fis, 'y', mft, py, 'Name', "my"+k);
    end
    fis = addOutput(fis, [zmin zmax], 'Name', 'z');
    sz = (zmax-zmin)/(nout-1);
    for k=1:nout
        cz = zmin+(k-1)*sz;
        fis = addMF(fis, 'z', 'trimf', [cz-sz cz cz+sz], 'Name', "mf"+k);
    end
    [X, Y] = meshgrid(1:nin, 1:nin);
    rules = [X(:) Y(:) r_tbl(:) ones(nin^2, 2)];
    fis = addRule(fis, rules);
end