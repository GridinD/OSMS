heightBS = 60; %%Высота антенны
hBuild = 30; %%Высота зданий
freq = 1.8; %%Диапазон частот
TxPowerBS = 46; %%Мощность передатчика базовой станции dBm
TxPowerUE = 24; %%Мощность передатчика пользователского терминала dBm
AntGainBS = 21; %%Коеффициент усиления антенны BS в децибелах изотропного излучателя dB
fi = 35; %%Угол наклона
IM = 6; %%Интерференция 
NoiseFigure1 = 2.4; %%Коэффициент шума приемника BS dBm
NoiseFigure2 = 6; %%Коэффициент шума приемника пользователя dB
SINR_DL = 2; %%Требуемое отношение сигнал-интерференция для downlink dB
SINR_UL = 4; %%uplink dB
MIMOGain = 2; %%Число антенн БС
PenetrWall = 15; %%Коэффициет проникновения


ThermalNoise1 = -174 + 10 * log10(20000000);
ThermalNoise2 = -174 + 10 * log10(10000000);
fprintf('Шум приемника BS %2f\n', ThermalNoise1);
fprintf('Шум примника пользователя %2f\n', ThermalNoise2);

RxSensUE = NoiseFigure1 + ThermalNoise1 + SINR_DL;
RxSensBS = NoiseFigure2 + ThermalNoise2 + SINR_UL;
fprintf('RxSensUE %2f\n', RxSensUE);
fprintf('RxSensBS %2f\n', RxSensBS);

MAPL_DL = TxPowerBS + AntGainBS + MIMOGain - IM - PenetrWall - RxSensUE;
MAPL_UL = TxPowerUE + AntGainBS + MIMOGain - IM - PenetrWall - RxSensBS;
fprintf('MAPL_DL %2f\n', MAPL_DL);
fprintf('MAPL_UL %2f\n', MAPL_UL);

arr = zeros(1, 3000);
arr2 = zeros(1, 3000);
arr3 = zeros(1, 3000);
arr4 = zeros(1, 3000);

% Model1
key1 = true;
for i = 1:3000
    path_long = i;
    PL = 26 * log10(freq) + 22.7 + 36.7 * log10(path_long);
    arr(i) = PL;
    if PL > MAPL_UL && key1
        R1 = i - 1;
        key1 = false;
        fprintf('Модель UMiNLOS: R1 = %d\n', R1);
    end
end
AreaBS = 1.95 * R1 * R1;
fprintf('Площадь базовой станции модель UMiNLOS %f\n', AreaBS);
Area1 = 100000000 / AreaBS;
fprintf('Количество станций на 100кв.км:%.0f\n', Area1);
ShopCenter = 4000000 / AreaBS;
fprintf('Количество станций необходимых для покрытия микро и фемтосот: %.0f\n',ShopCenter);


% Model2
key = true;
for i = 1:3000
    path_long = i;
    a = 3.2 * (log10(11.75 * 4) ^ 2) - 4.97;
    LClutter = -(2 * (log10(1800 / 28) ^ 2) + 5.4);
    s = 44.9 - 6.55 * log10(1800);
    PL = 46.3 + 33.9 * log10(1800) - 13.82 * log10(150) - a + s * log10(i / 1000) + 3;
    arr2(i) = PL;
    if PL > MAPL_UL && key
        R = i - 1;
        key = false;
        fprintf('Модель COST231: R = %d\n', R);
    end
end
AreaBS1 = 1.95 * R * R;
fprintf('Площадь базовой станции модель COST231 %f\n', AreaBS1);
Area2 = (100000000 / AreaBS1);
fprintf('Количество станций на 100кв.км:%.0f\n', Area2);
ShopCenter1 = 4000000 / AreaBS1;
fprintf('Количество станций необходимых для покрытия микро и фемтосот: %.0f\n',ShopCenter1);

% Model3
for i = 1:3000
    path_long = i;
    PL = 42.6 + 20 * log10(1.9) + 26 * log10(i);
    arr3(i) = PL;
end
%fprintf('Модель Walfish-Ikegami Llos\n');

% Model4
for i = 1:3000
    path_long = i;
    L0 = 32.44 + 20 * log10(1.9) + 20 * log10(i);
    if fi < 35 && fi > 0
        qoef = -10 + 0.354 * fi;
    elseif fi < 55 && fi >= 35
        qoef = 2.5 + 0.075 * fi;
    elseif fi < 90 && fi >= 55
        qoef = 4.0 - 0.114 * fi;
    end
    L2 = -16.9 - 10 * log10(20) + 10 * log10(1.9) + 20 * log10(hBuild - 3) + qoef;
    if heightBS > hBuild
        L1_1 = -18 * log10(1 + heightBS - hBuild);
        kD = 18;
    elseif heightBS <= hBuild
        L1_1 = 0;
        kD = 18 - 15 * ((heightBS - hBuild) / hBuild);
    end
    if heightBS <= hBuild && path_long > 500
        kA = 54 - 0.8 * (heightBS - hBuild);
    elseif heightBS <= hBuild && path_long <= 500
        kA = 54 - 0.8 * (heightBS - hBuild) * path_long / 0.5;
    elseif heightBS > hBuild
        kA = 54;
        kF = -4 + 0.7 * (1.9 / 925 - 1);
    end
    L1 = L1_1 + kA + kD * log10(path_long) + kF * log10(1.9) - 9 * log10(20);
    if L1 + L2 > 0
        Llnos = L0 + L1 + L2;
    elseif L1 + L2 <= 0
        Llnos = L0;
    end
    arr4(i) = Llnos;
end
%fprintf('Модель Walfish-Ikegami Lnlos\n');

q1_1 = 10000000 / (1.95 * (R ^ 2));
q1_2 = 4000000 / (1.95 * (R1 ^ 2));

figure('Position', [100, 100, 800, 600]);
hold on;
grid on;
plot(arr, 'b', 'LineWidth', 2);
plot(arr2, 'g--', 'LineWidth', 2);
plot(arr3, 'r-.', 'LineWidth', 2);
plot(arr4, 'm:', 'LineWidth', 2);

xlabel('Path Length');
ylabel('Path Loss (dB)');
legend('UMiNLOS', 'COST231', 'Walfish-Ikegami Llos', 'Walfish-Ikegami Lnlos');
title('Path Loss Models');
