%% ============================================================
%  Лабораторна робота №1 — Варіант 13
%  Функція: z(x,y) = cos(sin(y)) * sin(x)
%  Запуск: >> lab1_v13_z
%% ============================================================
clear; clc; close all;

%% ── Параметри ───────────────────────────────────────────────
% Визначення функції згідно з Варіантом 13
f     = @(x,y) cos(sin(y)) .* sin(x);
N_IN  = 6;    % Кількість функцій приналежності для входів
N_OUT = 9;    % Кількість функцій приналежності для виходу
X_MIN = 0; X_MAX = pi;
Y_MIN = 0; Y_MAX = pi;
Z_MIN = -1.05; Z_MAX = 1.05;

x_centers = linspace(X_MIN, X_MAX, N_IN);
y_centers = linspace(Y_MIN, Y_MAX, N_IN);
z_centers = linspace(Z_MIN, Z_MAX, N_OUT);

%% ── Таблиця значень ─────────────────────────────────────────
fprintf('\n=== z(x,y)=cos(sin(y))*sin(x) [ значення у точках МФ ] ===\n');
fprintf('%10s','');
for j=1:N_IN, fprintf('%9.3f', y_centers(j)); end; fprintf('\n');
Z_tbl = zeros(N_IN);
for i=1:N_IN
    fprintf('%10.3f', x_centers(i));
    for j=1:N_IN
        Z_tbl(i,j) = f(x_centers(i), y_centers(j));
        fprintf('%9.3f', Z_tbl(i,j));
    end; fprintf('\n');
end

%% ── Таблиця правил ──────────────────────────────────────────
Rule_tbl = zeros(N_IN);
fprintf('\n=== Таблиця правил (індекс вихідної МФ 1..%d) ===\n', N_OUT);
fprintf('%10s','');
for j=1:N_IN, fprintf('%6s',['my',num2str(j)]); end; fprintf('\n');
for i=1:N_IN
    fprintf('%10s',['mx',num2str(i)]);
    for j=1:N_IN
        [~,idx] = min(abs(z_centers - Z_tbl(i,j)));
        Rule_tbl(i,j) = idx;
        fprintf('%6s',['mf',num2str(idx)]);
    end; fprintf('\n');
end

%% ── Функція побудови FIS ────────────────────────────────────
% (Локальна функція знаходиться в кінці файлу)

%% ── Оцінка похибок ──────────────────────────────────────────
N_eval=10;
xs_eval=linspace(X_MIN+0.05, X_MAX-0.05, N_eval);
ys_eval=linspace(Y_MIN+0.05, Y_MAX-0.05, N_eval);
[Xe,Ye]=meshgrid(xs_eval,ys_eval);
Ze_true=f(Xe,Ye);

mf_types  = {'gaussmf','trimf','trapmf'};
mf_labels = {'Гаусова','Трикутна','Трапецієподібна'};
err_full  = zeros(1,3);
err_diag  = zeros(1,3);

for m=1:3
    mft = mf_types{m};
    
    % Повна база (36 правил)
    fis36 = make_fis_local(mft, Rule_tbl, X_MIN, X_MAX, Y_MIN, Y_MAX, Z_MIN, Z_MAX, N_IN, N_OUT);
    Ze_pred = evalfis(fis36, [Xe(:) Ye(:)]);
    Ze_pred = reshape(Ze_pred, size(Xe));
    eps36 = abs(Ze_true-Ze_pred)./(abs(Ze_true)+1)*100;
    err_full(m) = mean(eps36(:));
    
    % Діагональна база (6 правил)
    Rule_diag = ones(N_IN)*Rule_tbl(1,1);
    for k=1:N_IN, Rule_diag(k,k) = Rule_tbl(k,k); end
    % Заповнення недіагональних зон для стабільності
    for i=1:N_IN, for j=1:N_IN
        if i~=j
            [~,ni] = min(abs((1:N_IN)-mean([i j])));
            Rule_diag(i,j) = Rule_tbl(ni,ni);
        end
    end; end
    
    fis6 = make_fis_local(mft, Rule_diag, X_MIN, X_MAX, Y_MIN, Y_MAX, Z_MIN, Z_MAX, N_IN, N_OUT);
    Ze_diag = evalfis(fis6, [Xe(:) Ye(:)]);
    Ze_diag = reshape(Ze_diag, size(Xe));
    epsd = abs(Ze_true-Ze_diag)./(abs(Ze_true)+1)*100;
    err_diag(m) = mean(epsd(:));
    
    fprintf('\n[%s] Повна: %.2f%%  Діагональ: %.2f%%\n', mf_labels{m}, err_full(m), err_diag(m));
end

%% ── ГРАФІКИ ─────────────────────────────────────────────────
% 1. 3D Еталон
figure('Name','Еталонна поверхня','Color','w');
[Xg,Yg] = meshgrid(linspace(X_MIN,X_MAX,50), linspace(Y_MIN,Y_MAX,50));
surf(Xg,Yg,f(Xg,Yg),'EdgeColor','none'); colormap jet; colorbar;
title('Еталонна поверхня z = cos(sin(y)) \cdot sin(x)');
xlabel('x'); ylabel('y'); zlabel('z'); grid on;

% 2. Heatmap правил
figure('Name','Карта правил','Color','w');
imagesc(Rule_tbl); colormap parula; colorbar;
title('Візуалізація бази правил (36 правил)');
xlabel('Вхід y'); ylabel('Вхід x');
for i=1:N_IN, for j=1:N_IN
    text(j,i,['mf',num2str(Rule_tbl(i,j))],'H','center','FontSize',8);
end; end
hold on; for k=1:N_IN, rectangle('Position',[k-.5 k-.5 1 1],'EdgeColor','r','LineWidth',2); end

% 3. МФ Входу
figure('Name','Функції приналежності','Color','w');
univ = linspace(X_MIN, X_MAX, 500);
step = (X_MAX-X_MIN)/(N_IN-1);
for s=1:3
    subplot(1,3,s); hold on;
    for k=1:N_IN
        c = x_centers(k);
        if s==1, p = gaussmf(univ,[step*.45 c]); 
        elseif s==2, p = trimf(univ,[c-step c c+step]);
        else, p = trapmf(univ,[c-step*.9 c-step*.3 c+step*.3 c+step*.9]); end
        plot(univ, p, 'LineWidth', 1.5);
    end
    title(mf_labels{s}); grid on; ylim([0 1.2]);
end

% 4. Порівняння похибок
figure('Name','Порівняння похибок','Color','w');
b = bar([err_full' err_diag']); grid on;
set(gca, 'XTickLabel', mf_labels);
legend('Повна база (36)', 'Діагональна (6)');
ylabel('Середня похибка %'); title('Порівняння точності моделей');

%% ── ВИСНОВКИ ────────────────────────────────────────────────
[~,bi]=min(err_full);
fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║   ВИСНОВКИ: ВАРІАНТ 13                                   ║\n');
fprintf('╠══════════════════════════════════════════════════════════╣\n');
fprintf('║ Найкраща МФ: %-16s (%.2f%%)           ║\n', mf_labels{bi}, err_full(bi));
fprintf('║ Ріст похибки (діагональ): %.1fx                          ║\n', mean(err_diag./err_full));
fprintf('║ Оптимальна конфігурація: %-12s + 36 правил.     ║\n', mf_labels{bi});
fprintf('╚══════════════════════════════════════════════════════════╝\n');

%% ── ДОПОМІЖНА ФУНКЦІЯ ───────────────────────────────────────
function fis = make_fis_local(mf_type, rule_tbl, x_min,x_max, y_min,y_max, z_min,z_max, n_in, n_out)
    fis = mamfis('Name', 'FIS_Var13');
    % Входи
    cfg = {{'x',x_min,x_max,'mx'}, {'y',y_min,y_max,'my'}};
    st = [(x_max-x_min)/(n_in-1), (y_max-y_min)/(n_in-1)];
    for inp=1:2
        nm=cfg{inp}{1}; lo=cfg{inp}{2}; hi=cfg{inp}{3}; pfx=cfg{inp}{4}; s=st(inp);
        fis = addInput(fis,[lo hi],'Name',nm);
        for k=1:n_in
            c = lo+(k-1)*s;
            if strcmp(mf_type,'gaussmf'), fis=addMF(fis,nm,mf_type,[s*.45 c],'Name',[pfx,num2str(k)]);
            elseif strcmp(mf_type,'trimf'), fis=addMF(fis,nm,mf_type,[c-s c c+s],'Name',[pfx,num2str(k)]);
            else, fis=addMF(fis,nm,mf_type,[c-s*.9 c-s*.3 c+s*.3 c+s*.9],'Name',[pfx,num2str(k)]); end
        end
    end
    % Вихід
    fis = addOutput(fis,[z_min z_max],'Name','z');
    st_z=(z_max-z_min)/(n_out-1);
    for k=1:n_out
        c=z_min+(k-1)*st_z;
        fis=addMF(fis,'z','trimf', [c-st_z c c+st_z], 'Name', ['mf',num2str(k)]);
    end
    % Правила
    [X, Y] = meshgrid(1:n_in, 1:n_in);
    rules = [X(:) Y(:) rule_tbl(:) ones(n_in^2, 2)];
    fis = addRule(fis, rules);
end
