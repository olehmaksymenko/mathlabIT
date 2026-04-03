%% ============================================================
%  Лабораторна робота — Твій варіант
%  Функція: y(x) = x * sin(x) * cos(x)
%% ============================================================
clear; clc; close all;

%% ── Параметри ───────────────────────────────────────────────
f   = @(x,~) x .* sin(x) .* cos(x);
N_IN  = 6;
N_OUT = 9;
X_MIN = 0; X_MAX = pi;
Y_MIN = 0; Y_MAX = pi;
Z_MIN = -1.5; Z_MAX = 1.5;

x_centers = linspace(X_MIN, X_MAX, N_IN);
y_centers = linspace(Y_MIN, Y_MAX, N_IN);
z_centers = linspace(Z_MIN, Z_MAX, N_OUT);

%% ── Таблиця значень функції ─────────────────────────────────
fprintf('\n=== y(x)=x*sin(x)*cos(x) ===\n');
Z_tbl = zeros(N_IN);
for i=1:N_IN
    for j=1:N_IN
        Z_tbl(i,j) = f(x_centers(i), y_centers(j));
    end
end

%% ── Таблиця правил ──────────────────────────────────────────
Rule_tbl = zeros(N_IN);
for i=1:N_IN
    for j=1:N_IN
        [~,idx] = min(abs(z_centers - Z_tbl(i,j)));
        Rule_tbl(i,j) = idx;
    end
end

%% ── FIS ─────────────────────────────────────────────────────
function fis = make_fis(mf_type, rule_tbl, ...
        x_min,x_max, y_min,y_max, z_min,z_max, n_in, n_out)

    fis = mamfis('Name', mf_type);

    fis = addInput(fis,[x_min x_max],'Name','x');
    fis = addInput(fis,[y_min y_max],'Name','y');

    step = (x_max-x_min)/(n_in-1);

    for k=1:n_in
        c = x_min+(k-1)*step;

        switch mf_type
            case 'gaussmf'
                fis = addMF(fis,'x','gaussmf',[step*0.45 c]);
                fis = addMF(fis,'y','gaussmf',[step*0.45 c]);
            case 'trimf'
                fis = addMF(fis,'x','trimf',[c-step c c+step]);
                fis = addMF(fis,'y','trimf',[c-step c c+step]);
            case 'trapmf'
                fis = addMF(fis,'x','trapmf',[c-step c-step/2 c+step/2 c+step]);
                fis = addMF(fis,'y','trapmf',[c-step c-step/2 c+step/2 c+step]);
        end
    end

    fis = addOutput(fis,[z_min z_max],'Name','z');

    step_z = (z_max-z_min)/(n_out-1);
    for k=1:n_out
        c = z_min+(k-1)*step_z;
        fis = addMF(fis,'z','trimf',[c-step_z c c+step_z]);
    end

    rules = [];
    for i=1:n_in
        for j=1:n_in
            rules(end+1,:) = [i j rule_tbl(i,j) 1 1];
        end
    end
    fis = addRule(fis, rules);
end

%% ── Похибка ─────────────────────────────────────────────────
[Xe,Ye] = meshgrid(linspace(0,pi,20));
Ze_true = f(Xe,Ye);

mf_types = {'gaussmf','trimf','trapmf'};
err = zeros(1,3);

for m=1:3
    fis = make_fis(mf_types{m},Rule_tbl,...
        X_MIN,X_MAX,Y_MIN,Y_MAX,Z_MIN,Z_MAX,N_IN,N_OUT);

    Ze = zeros(size(Xe));
    for i=1:numel(Xe)
        Ze(i) = evalfis(fis,[Xe(i) Ye(i)]);
    end

    err(m) = mean(abs(Ze_true-Ze),'all')*100;
end

%% ── Графіки ─────────────────────────────────────────────────

% Еталон
figure;
xp = linspace(0,pi,300);
plot(xp, xp.*sin(xp).*cos(xp),'LineWidth',2);
title('y(x) = x*sin(x)*cos(x)');
grid on;

% МФ
figure;
univ = linspace(0,pi,500);
for k=1:N_IN
    plot(univ, gaussmf(univ,[0.5 x_centers(k)])); hold on;
end
title('MF');

% Похибки
figure;
bar(err);
set(gca,'XTickLabel',{'Gauss','Triangular','Trap'});
title('Error');