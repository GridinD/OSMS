% Входные данные
transmitter_power_BS = 46; % Мощность передатчика BS в децибелах милливатт (dBm)
sectors = 3; % Число секторов на одной BS
transmitter_power_UE = 24; % Мощность передатчика пользовательского терминала UE в dBm
antenna_BS = 21; % Коэффициент усиления антенны BS в децибелах изотропного излучателя (dBi)
wall = 15; % Запас мощности сигнала на проникновения сквозь стены (dB)
interference = 1; % Запас мощности сигнала на интерференцию (dB)
frequency_range = 1.8; % Диапазон частот (Гигагерцы)
UL_bandwidth = 10; % Полоса частот в uplink (Мегагерцы)
DL_bandwidth = 20; % Полоса частот в downlink (Мегагерцы)
noise_BS = 2.4; % Коэффициент шума приемника BS (dB)
noise_UE = 6; % Коэффициент шума приемника пользователя (dB)
SINR_DL = 2; % Требуемое отношение сигнал-шум-интерференция (SINR) для downlink (dB)
SINR_UL = 4; % Требуемое отношение SINR для uplink (dB)
MIMO = 2; % Число приемо-передающих антенн на BS (MIMO)
area = 100; % Площадь территории (квадратные километры)
area_centers = 4; % Площадь торговых и бизнес центров (квадратные метры)

% Расчет бюджета восходящего канала
transmitter_power_BS_budget = 10^((transmitter_power_BS - 30) / 10);
transmitter_power_UE_budget = 10^((transmitter_power_UE - 30) / 10);

% Расчет диапазона радиосвязи
wavelength = 3e8 / (frequency_range * 1e9);
radius = sqrt(area * 1e6 / pi);

% Расчет свободной пространственной потери
loss = 20 * log10(4 * pi * radius / wavelength);

% Расчет общей потери на уровне мощности
total_loss = (loss + transmitter_power_UE_budget + antenna_BS - transmitter_power_BS_budget - wall - interference - noise_UE - noise_BS);

% Расстояния между приемником и передатчиком (от 1 до 1000 метров)
distances = 1:1000;

% Расчет бюджета и входных потерь для разных моделей
input_losses = zeros(1, length(distances));

for distance = distances
    % Расчет свободной пространственной потери
    loss = 20 * log10(4 * pi * distance / wavelength);
    
    % Расчет общей потери на уровне мощности для COST 231 Hata
    total_loss_COST231 = (loss + transmitter_power_UE_budget + antenna_BS - transmitter_power_BS_budget - wall - interference - noise_UE - noise_BS);
    
    input_losses(distance) = total_loss_COST231;
end

% Расчет максимально допустимых потерь сигнала (MAPL_UL)
MAPL_UL = transmitter_power_UE + SINR_DL - SINR_UL - total_loss;
MAPL_DL = transmitter_power_BS + SINR_UL - SINR_DL - total_loss;

fprintf('Максимально допустимые потери сигнала для MAPL_UL: %f\n', MAPL_UL);
fprintf('Максимально допустимые потери сигнала для MAPL_DL: %f\n', MAPL_DL);

% Построение графиков
figure;
plot(distances, input_losses, 'b-', 'LineWidth', 2);
xlabel('Расстояние между приемником и передатчиком (метры)');
ylabel('Входные потери радиосигнала (дБ)');
title('Зависимость входных потерь радиосигнала от расстояния');
grid on;
legend('COST 231 Hata');

% Расчет площади одной базовой станции (UL)
wavelength_UL = 3e8 / (frequency_range * 1e9); % Длина волны в метрах (UL)
min_radius_BS_UL = sqrt((area_centers * 1e6) / (pi * sectors));
area_BS_sqm_UL = pi * min_radius_BS_UL^2;

% Расчет площади одной базовой станции (DL)
wavelength_DL = 3e8 / (frequency_range * 1e9); % Длина волны в метрах (DL)
min_radius_BS_DL = sqrt((area_centers * 1e6) / (pi * sectors));
area_BS_sqm_DL = pi * min_radius_BS_DL^2;

% Определение минимальной площади
min_area_BS = min(area_BS_sqm_UL, area_BS_sqm_DL);

% Расчет необходимого количества базовых станций (сайтов) для покрытия всей территории
required_number_of_BS = ceil(area * 1e6 / min_area_BS);

fprintf('Радиус базовой станции в восходящем канале на UL: %f\n', min_radius_BS_UL);
fprintf('Радиус базовой станции в нисходящем канале на DL: %f\n', min_radius_BS_DL);
fprintf('Минимальный радиус базовой станции: %f\n', min(min_radius_BS_UL, min_radius_BS_DL));
fprintf('Площадь одной базовой станции на UL: %f\n', area_BS_sqm_UL);
fprintf('Площадь одной базовой станции на DL: %f\n', area_BS_sqm_DL);
fprintf('Минимальная площадь одной базовой станции: %f\n', min_area_BS);
fprintf('Необходимое количество базовых станций: %d\n', required_number_of_BS);
