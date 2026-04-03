%% ============================================================
%  Лабораторна робота №1 — Варіант 13
%  Функція 1: y(x) = x * sin(x) * cos(x)
%  Функція 2: z(x,y) = cos(sin(y)) * sin(x)
%% ============================================================
clear; clc; close all;

% Параметри моделі
N_IN = 6;    % 6 МФ для входів
N_OUT = 9;   % 9 МФ для виходу
X_MIN = 0; X_MAX = pi;
Y_MIN = 0; Y_MAX = pi;

% Визначення функцій
f1 = @(x,y) x .* sin(x) .* cos(x); 
f2 = @(x,y) cos(sin(y)) .* sin(x);

funcs = {f1, f2};
names = {'y = x*sin(x)*cos(x)', 'z = cos(sin(y))*sin(x)'};

for f_idx = 1:2
    f = funcs{f_idx};
    fprintf('\n' + string(repmat('=',1,50)) + '\n');
    fprintf(' АНАЛІЗ ФУНКЦІЇ %d: %s\n', f_idx, names{f_idx});
    fprintf(string(repmat('=',1,50)) + '\n');

    % Значення для формування бази правил
    x_c = linspace(X_MIN, X_MAX, N_IN);
    y_c = linspace(Y_MIN, Y_MAX, N_IN);
    [Xc, Yc] = meshgrid(x_c, y_c);
    Z_val = f(Xc, Yc);
    
    % Діапазон виходу для нормалізації
    z_min = min(Z_val(:)) - 0.1;
    z_max = max(Z_val(:)) + 0.1;
    z_c = linspace(z_min, z_max, N_OUT);

    % Визначення індексів вихідних МФ для бази правил
    Rule_tbl = zeros(N_IN);
    for i=1:N_IN
        for j=1:N_IN
            [~, idx] = min(abs(z_c - Z_val(i,j)));
            Rule_tbl(i,j) = idx;
        end
    end

    % Оцінка похибок
    mf_types = {'gaussmf', 'trimf', 'trapmf'};
    mf_names = {'Gaussian', 'Triangular', 'Trapezoidal'};
    
    % Сітка для перевірки похибки (10x10 точок)
    [Xe, Ye] = meshgrid(linspace(X_MIN+0.1, X_MAX-0.1, 10), linspace(Y_MIN+0.1, Y_MAX-0.1, 10));
    Ze_true = f(Xe, Ye);

    for m = 1:3
        % 1. Повна база (36 правил)
        fis36 = create_fis(mf_types{m}, Rule_tbl, X_MIN, X_MAX, Y_MIN, Y_MAX, z_min, z_max, N_IN, N_OUT);
        Ze_36 = evalfis(fis36, [Xe(:) Ye(:)]);
        Ze_36 = reshape(Ze_36, size(Xe));
        err36 = mean(abs(Ze_true(:) - Ze_36(:))./(abs(Ze_true(:))+1)*100);

        % 2. Діагональна база (6 правил)
        Rule_diag = ones(N_IN)*Rule_tbl(1,1);
        for k=1:N_IN, Rule_diag(k,k) = Rule_tbl(k,k); end
        fis6 = create_fis(mf_types{m}, Rule_diag, X_MIN, X_MAX, Y_MIN, Y_MAX, z_min, z_max, N_IN, N_OUT);
        Ze_6 = evalfis(fis6, [Xe(:) Ye(:)]);
        Ze_6 = reshape(Ze_6, size(Xe));
        err6 = mean(abs(Ze_true(:) - Ze_6(:))./(abs(Ze_true(:))+1)*100);

        fprintf('[%s] Повна база: %.2f%% | Діагональна: %.2f%%\n', mf_names{m}, err36, err6);
        
        if m == 1 % Малюємо поверхню тільки для Гауса як приклад
            figure('Name', names{f_idx});
            gensurf(fis36); title(['FIS Surface: ', names{f_idx}]);
        end
    end
end

% Допоміжна функція створення FIS
function fis = create_fis(mft, r_tbl, xmin, xmax, ymin, ymax, zmin, zmax, nin, nout)
    fis = mamfis('Name', 'Lab1');
    fis = addInput(fis, [xmin xmax], 'Name', 'x');
    fis = addInput(fis, [ymin ymax], 'Name', 'y');
    fis = addOutput(fis, [zmin zmax], 'Name', 'z');
    
    sx = (xmax-xmin)/(nin-1); sy = (ymax-ymin)/(nin-1); sz = (zmax-zmin)/(nout-1);
    
    for k=1:nin
        cx = xmin+(k-1)*sx; cy = ymin+(k-1)*sy;
        fis = addMF(fis, 'x', mft, get_params(mft, cx, sx), 'Name', "mx"+k);
        fis = addMF(fis, 'y', mft, get_params(mft, cy, sy), 'Name', "my"+k);
    end
    for k=1:nout
        cz = zmin+(k-1)*sz;
        fis = addMF(fis, 'z', 'trimf', [cz-sz cz cz+sz], 'Name', "mf"+k);
    end
    
    [X, Y] = meshgrid(1:nin, 1:nin);
    rules = [X(:) Y(:) r_tbl(:) ones(nin^2, 2)];
    fis = addRule(fis, rules);
end

function p = get_params(mft, c, s)
    if strcmp(mft,'gaussmf'), p = [s*0.4 c];
    elseif strcmp(mft,'trimf'), p = [c-s c c+s];
    else, p = [c-s*0.9 c-s*0.3 c+s*0.3 c+s*0.9]; end
end