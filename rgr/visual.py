import numpy as np
import matplotlib.pyplot as plt
from scipy.fft import fft, fftfreq

with open("binaryData.txt", "r") as file:
    binary_data = file.read()

binary_array = np.array([int(bit) for bit in binary_data])

with open("AllBinaryData.txt", "r") as file:
    all_binary_data = file.read()

all_binary_array = np.array([int(bit) for bit in all_binary_data])

with open("BinaryDataWithN.txt", "r") as file:
    binary_data_n = file.read()

binary_array_n = np.array([int(bit) for bit in binary_data_n])

with open("Signal.txt", "r") as file:
    signal_data = file.read()

signal_array = np.array([int(bit) for bit in signal_data if bit.strip()])

with open("NoiseSignal.txt", "r") as file:
    noise_signal_data = [float(value) for value in file.read().split()]

plt.subplot(2, 1, 1)
plt.plot(binary_array, drawstyle='steps-pre')
plt.title('Битовая последовательность')
plt.xlabel('Бит')
plt.ylabel('Значение')

plt.subplot(2, 1, 2)
plt.plot(all_binary_array, drawstyle='steps-pre')
plt.title('Измененная битовая последовательность')
plt.xlabel('Бит')
plt.ylabel('Значение')

plt.tight_layout()
plt.show()

plt.subplot(2, 1, 1)
plt.plot(binary_array_n, drawstyle='steps-pre')
plt.title('Битовая последовательность с N отчетами')
plt.xlabel('Бит')
plt.ylabel('Значение')

plt.subplot(2, 1, 2)
plt.plot(signal_array, drawstyle='steps-pre')
plt.title('Массив Signal')
plt.xlabel('Бит')
plt.ylabel('Значение')

plt.tight_layout()
plt.show()

plt.plot(noise_signal_data, drawstyle='steps-pre')
plt.title('Визуализация зашумленного принятого сигнала ')
plt.xlabel('Отcчеты')
plt.ylabel('Значение')
plt.grid(True)
plt.show()



with open("NoiseSignalWithN4.txt", "r") as file:
    noise_signal_min = np.array([float(value) for value in file.read().split()])

with open("SignalWithN4.txt", "r") as file:
    signal_min_binary_data = file.read()

signal_min = np.array([int(bit) for bit in signal_min_binary_data])

with open("NoiseSignalWithN9.txt", "r") as file:
    noise_signal_average = np.array([float(value) for value in file.read().split()])

with open("SignalWithN9.txt", "r") as file:
    signal_average_binary_data = file.read()

signal_average = np.array([int(bit) for bit in signal_average_binary_data if bit.strip()])

with open("NoiseSignalWithN14.txt", "r") as file:
    noise_signal_max = np.array([float(value) for value in file.read().split()])

with open("SignalWithN14.txt", "r") as file:
    signal_max_binary_data = file.read()

signal_max = np.array([int(bit) for bit in signal_max_binary_data if bit.strip()])

# сигнал на передаче
sendingMinN = np.fft.fft(signal_min)
sendingAvgN = np.fft.fft(signal_average)
sendingHighN = np.fft.fft(signal_max)

# сигнал на приеме
receptionMinN = np.fft.fft(noise_signal_min)
receptionAvgN = np.fft.fft(noise_signal_average)
receptionHighN = np.fft.fft(noise_signal_max)

kM = np.arange(1072)
kA = np.arange(2412)
kH = np.arange(3752)

plt.plot(kH, np.abs(receptionHighN), label='Сигнал на приеме с N=14', color='yellow')
plt.plot(kA, np.abs(receptionAvgN), label='Сигнал на приеме с N=9', color='green')
plt.plot(kM, np.abs(receptionMinN), label='Сигнал на приеме с N=4', color='red')

plt.title('Передаваемый сигнал')
plt.xlabel('Бит')
plt.ylabel('Значение')
plt.legend()
plt.grid(True)
plt.show()

plt.plot(kH, np.abs(sendingHighN), label='Сигнал на передаче с N=14', color='yellow')
plt.plot(kA, np.abs(sendingAvgN), label='Сигнал на передаче с N=9', color='green')
plt.plot(kM, np.abs(sendingMinN), label='Сигнал на передаче с N=4', color='red')

plt.title('Принимаемый сигнал')
plt.xlabel('Бит')
plt.ylabel('Значение')
plt.legend()
plt.grid(True)
plt.show()







