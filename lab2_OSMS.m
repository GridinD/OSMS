% Входные данные
transmitPower = 46; % Мощность передатчика BS в dBm
numberOfSector = 3; % Число секторов на одной BS
transmitPowerUE = 24; % Мощность передатчика пользовательского терминала UE в dBm
antennaGain = 21; % Коэффициент усиления антенны BS в дБи
soundSignalForPenetration = 15; % Запас мощности сигнала на проникновения сквозь стены (dB)
signalPowerForInterference = 1; % Запас мощности сигнала на интерференцию (dB)
frequencyRange = 1.8; % Диапазон частот (Гигагерцы)
frequencyBandInUL = 10 * (10^6); % Полоса частот в uplink (Мегагерцы)
frequencyBandInDL = 20 * (10^6); % Полоса частот в downlink (Мегагерцы)
receiverNoise = 2.4; % Коэффициент шума приемника BS (dB)
userReceiver = 6; % Коэффициент шума приемника пользователя (dB)
requiredSINRForDL = 2; % Требуемое отношение SINR для DL (dB)
requiredSINRForUL = 4; % Требуемое отношение SINR для UL (dB)
numberOfTransceiver = 2; % Число приемо-передающих антенн на BS (MIMO)
areaOfTerritory = 100; % Площадь территории, на которой требуется спроектировать сеть (квадратные километры)
areaOfShopping = 4; % Площадь торговых и бизнес центров, где требуется спроектировать сеть на базе микро- и фемтосот (квадратные метры)
FeederLoss = 2;
MIMOGain = 3;

% Расчет теплового шума для восходящего и нисходящего каналов
Termal_Noise_UL = -174 + 10 * log10(frequencyBandInUL);
Termal_Noise_DL = -174 + 10 * log10(frequencyBandInDL);

% Расчет бюджета восходящего канала
Rx_Sense_BS = receiverNoise + requiredSINRForDL + Termal_Noise_DL;
Rx_Sense_AT = userReceiver + requiredSINRForUL + Termal_Noise_UL;

MAPL_UL = transmitPowerUE - FeederLoss + antennaGain + MIMOGain - signalPowerForInterference - soundSignalForPenetration - Rx_Sense_BS;

% Расчет бюджета нисходящего канала
MAPL_DL = transmitPower - FeederLoss + antennaGain + MIMOGain - signalPowerForInterference - soundSignalForPenetration - Rx_Sense_AT;

% Расстояния между приемником и передатчиком (от 1 до 1000 метров)
distances_m = 1:15000;

% Модель UMiNLOS
PL_UMiNLOS = zeros(1, length(distances_m));

for i = 1:length(distances_m)
    d = distances_m(i);
    if d < 1
        s = (47.88 + 13.9 * log10(frequencyRange) - 13.9 * log10(1.5)) * (1 / log10(50));
    else
        s = 44.9 - 6.55 * log10(frequencyRange);
    end
    PL_UMiNLOS(i) = s + 22.7 + 36.7 * log10(d);
end

% Выбор местности 
 CLATTER = 'DU';  % плотная городская застройка
% CLATTER = 'U';   % город
% CLATTER = 'SU';   % пригород
% CLATTER = 'RURAL';   % сельская местность
% CLATTER = 'ROAD';    % трасса

A = 46.3;
B = 33.9;
hBS = 50; % m
hms = 1; % m
f = frequencyRange * 1000;

if strcmp(CLATTER, 'DU')
    Lclutter = 3;
    a = 3.2 * ((log10(11.75 * hms))^2) - 4.97;
elseif strcmp(CLATTER, 'U')
    Lclutter = 0;
    a = 3.2 * ((log10(11.75 * hms))^2) - 4.97;
elseif strcmp(CLATTER, 'SU')
    Lclutter = -(2 * ((log10(f / 28))^2) + 5.4);
    a = (1.1 * log10(f)) * hms - (1.56 * log10(f) - 0.8);
elseif strcmp(CLATTER, 'RURAL')
    Lclutter = -(4.78 * ((log10(f))^2) - 18.33 * log10(f) + 40.94);
    a = (1.1 * log10(f)) * hms - (1.56 * log10(f) - 0.8);
elseif strcmp(CLATTER, 'ROAD')
    Lclutter = -(4.78 * ((log10(f))^2) - 18.33 * log10(f) + 35.94);
    a = (1.1 * log10(f)) * hms - (1.56 * log10(f) - 0.8);
else
    Lclutter = 0;
    a = 3.2 * ((log10(11.75 * hms))^2) - 4.97;
end

PL_COST231 = zeros(1, length(distances_m));

for i = 1:length(distances_m)
    PL_COST231(i) = A + B * log10(f) - 13.82 * log10(hBS) - a + S((distances_m(i) / 1000), hBS, f) * log10(distances_m(i) / 1000) + Lclutter;
end

% Walfish
PL_Walfish = zeros(1, length(distances_m));
for i = 1:length(distances_m)
    PL_Walfish(i) = 42.6 + 20 * log10(f) + 26 * log10(distances_m(i) / 1000);
end

% Walfish NLOS calculations
h = 30;
fi = 58;
hBuild = 30;
PL_Walfish_Nloss = zeros(1, length(distances_m));

for i = 1:length(distances_m)
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
    if hBS > hBuild
        L1_1 = -18 * log10(1 + hBS - hBuild);
        kD = 18;
    elseif hBS <= hBuild
        L1_1 = 0;
        kD = 18 - 15 * ((hBS - hBuild) / hBuild);
    end
    if hBS <= hBuild && path_long > 500
        kA = 54 - 0.8 * (hBS - hBuild);
    elseif hBS <= hBuild && path_long <= 500
        kA = 54 - 0.8 * (hBS - hBuild) * path_long / 0.5;
    elseif hBS > hBuild
        kA = 54;
        kF = -4 + 0.7 * (1.9 / 925 - 1);
        L1 = L1_1 + kA + kD * log10(path_long) + kF * log10(1.9) - 9 * log10(20);
    end
    if (L1 + L2) > 0
        Llnos = L0 + L1 + L2;
    elseif (L1 + L2) <= 0
        Llnos = L0;
    end
    PL_Walfish_Nloss(i) = Llnos;
end

MAPL_DL_G = ones(1, length(distances_m)) * MAPL_DL;
MAPL_UL_G = ones(1, length(distances_m)) * MAPL_UL;

UM_Cross_in_UL = -1;
COST_Cross_in_UL = -1;
Wall_Cross_in_UL = -1;
Wall_Cross_Nloss_UL = -1;

for i = 2:(length(PL_UMiNLOS)-1)
    if PL_UMiNLOS(i-1) < MAPL_UL && PL_UMiNLOS(i+1) >= MAPL_UL
        UM_Cross_in_UL = i;
    end
    
    if PL_COST231(i-1) < MAPL_UL && PL_COST231(i+1) >= MAPL_UL
        COST_Cross_in_UL = i;
    end
    
    if PL_Walfish(i-1) < MAPL_UL && PL_Walfish(i+1) >= MAPL_UL
        Wall_Cross_in_UL = i;
    end
    
    if PL_Walfish_Nloss(i-1) < MAPL_UL && PL_Walfish_Nloss(i+1) >= MAPL_UL
        Wall_Cross_Nloss_UL = i;
    end
end

UM_Cross_in_DL = -1;
COST_Cross_in_DL = -1;
Wall_Cross_in_DL = -1;
Wall_Cross_Nloss_DL = -1;

for i = 2:(length(PL_UMiNLOS)-1)
    if PL_UMiNLOS(i-1) < MAPL_DL && PL_UMiNLOS(i+1) >= MAPL_DL
        UM_Cross_in_DL = i;
    end
    
    if PL_COST231(i-1) < MAPL_DL && PL_COST231(i+1) >= MAPL_DL
        COST_Cross_in_DL = i;
    end
    
    if PL_Walfish(i-1) < MAPL_DL && PL_Walfish(i+1) >= MAPL_DL
        Wall_Cross_in_DL = i;
    end
    
    if PL_Walfish_Nloss(i-1) < MAPL_DL && PL_Walfish_Nloss(i+1) >= MAPL_DL
        Wall_Cross_Nloss_DL = i;
    end
end

UM_Cross = zeros(1, length(distances_m));
if UM_Cross_in_UL > 0
    UM_Cross(UM_Cross_in_UL) = PL_UMiNLOS(UM_Cross_in_UL);
end

COST_Cross = zeros(1, length(distances_m));
if COST_Cross_in_UL > 0
    COST_Cross(COST_Cross_in_UL) = PL_COST231(COST_Cross_in_UL);
end

Wall_Cross = zeros(1, length(distances_m));
if Wall_Cross_in_UL > 0
    Wall_Cross(Wall_Cross_in_UL) = PL_Walfish(Wall_Cross_in_UL);
end

if numberOfSector == 3
    S_sot_UM = 1.95 * ((UM_Cross_in_UL/1000)^2);
    S_sot_COST = 1.95 * ((COST_Cross_in_UL/1000)^2);
elseif numberOfSector == 2
    S_sot_UM = 1.73 * ((UM_Cross_in_UL/1000)^2);
    S_sot_COST = 1.73 * ((COST_Cross_in_UL/1000)^2);
else
    S_sot_UM = 2.6 * ((UM_Cross_in_UL/1000)^2);
    S_sot_COST = 2.6 * ((COST_Cross_in_UL/1000)^2);
end

Count_sot_UM = ceil(areaOfShopping / S_sot_UM);
Count_sot_COST = ceil(areaOfTerritory / S_sot_COST);

% Plotting
figure;
hold on;
plot(distances_m, PL_UMiNLOS, 'g', 'LineStyle', '-', 'DisplayName', 'UMiNLOS');
plot(distances_m, PL_COST231, 'r', 'LineStyle', '-', 'DisplayName', ['COST231: ', CLATTER]);
plot(distances_m, PL_Walfish, 'b', 'LineStyle', '-', 'DisplayName', 'Walfish');
plot(distances_m, MAPL_DL_G, 'b--', 'DisplayName', 'MAPL_DL');
plot(distances_m, MAPL_UL_G, 'k--', 'DisplayName', 'MAPL_UL');
plot(distances_m, PL_Walfish_Nloss, 'm--', 'DisplayName', 'Wallfish:Nloss');

%stem(distances_m, UM_Cross);
%stem(distances_m, COST_Cross);
%stem(distances_m, Wall_Cross);

xlabel('Расстояние между приемником и передатчиком (метры)');
ylabel('Входные потери радиосигнала (дБ)');
title('Зависимость входных потерь радиосигнала от расстояния');
legend('UMiNLOS', ['COST231: ', CLATTER], 'Walfish', 'MAPL_DL', 'MAPL_UL', 'Wallfish:Nloss');
grid on;
hold off;

fprintf('выбрана следующая местность: %s\n', CLATTER);
fprintf('радиус базовой станции для модели UMiNLOS: %d m\n', UM_Cross_in_UL);
fprintf('радиус базовой станции для модели COST231: %d m\n', COST_Cross_in_UL);
fprintf('радиус базовой станции для модели Wallfish: %d m\n', Wall_Cross_in_UL);
fprintf('радиус базовой станции для модели Wallfish Nloss: %d m\n', Wall_Cross_Nloss_UL);
fprintf('Площадь базовой станции UMiNLOS: %.2f km^2\n', S_sot_UM);
fprintf('Площадь базовой станции COST231: %.2f km^2\n', S_sot_COST);
fprintf('Количество базовых станций для UMiNLOS: %d\n', Count_sot_UM);
fprintf('Количество базовых станций для COST231: %d\n', Count_sot_COST);
function s = S(d, hBS, f)
    if d < 1
        s = (47.88 + 13.9 * log10(f) - 13.9 * log10(hBS)) * (1 / log10(50));
    else
        s = 44.9 - 6.55 * log10(f);
    end
end
