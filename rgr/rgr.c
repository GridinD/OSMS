#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define K 20
#define M 7 
#define G 31 
#define POLYNOMIAL "11111111" 
#define LENGTH 5
#define N 5

void createBinaryData(char *name, double *binaryData) {
    int i, j, k;

    for (i = 0; name[i] != '\0'; ++i) {
        int ascCode = name[i];

        for (j = 7; j >= 0; --j) {
            k = ascCode >> j;
            if (k & 1) {
                *binaryData = 1.0;
            } else {
                *binaryData = 0.0;
            }
            ++binaryData;
        }
    }
}

void countingCRC(const double *data, const char *polynomial, char *result, int dataLength, int polynomialLength) {
    char *extendedData = malloc((dataLength + polynomialLength - 1) * sizeof(char));

    for (int i = 0; i < dataLength; i++) {
        extendedData[i] = (data[i] > 0.5) ? '1' : '0';
    }

    for (int i = dataLength; i < dataLength + polynomialLength - 1; i++) {
        extendedData[i] = '0';
    }
    
    for (int i = 0; i < dataLength; i++) {
        if (extendedData[i] == '1') {
            for (int j = 0; j < polynomialLength; j++) {
                extendedData[i + j] ^= polynomial[j] - '0';
            }
        }
    }

    strncpy(result, extendedData + dataLength, polynomialLength - 1);
    result[polynomialLength - 1] = '\0';

    free(extendedData);
}

void shift_register_x(int *register_state_x) {
    int feedback = (register_state_x[2] + register_state_x[3]) % 2;
    for (int i = LENGTH - 1; i > 0; i--) {
        register_state_x[i] = register_state_x[i - 1];
    }
    register_state_x[0] = feedback;
}

void shift_register_y(int *register_state_y) {
    int feedback = (register_state_y[1] + register_state_y[2]) % 2;
    for (int i = LENGTH - 1; i > 0; i--) { 
        register_state_y[i] = register_state_y[i - 1];
    }
    register_state_y[0] = feedback;
}

void generate_pseudo_random_sequence(double *result, int *register_state_x, int *register_state_y, int length) {
    printf("Последовательность Голда равняется: ");
    double bit = 0.0;
    for (int i = 0; i < length; i++) {
        bit = fmod(register_state_x[4] + register_state_y[4], 2.0);
        printf("%1.f", bit);

        shift_register_x(register_state_x);
        shift_register_y(register_state_y);
        *result = bit;
        ++result;
    }
    printf("\n");
}

void generateNormalNoise(double *noise, int length, double mean, double stddev) {
    for (int i = 0; i < length; i++) {
        double u1 = ((double) rand() / RAND_MAX); 
        double u2 = ((double) rand() / RAND_MAX); 
        double z = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2);


        noise[i] = mean + stddev * z;
    }
}

double calculate_correlation(const double *sequence1, int length1, const double *sequence2, int length2, int offset) {
    double correlation = 0.0;
    int min_length = (length1 < length2) ? length1 : length2;

    for (int i = 0; i < min_length; i++) {
        correlation += sequence1[i] * sequence2[(i + offset) % length2];
    }

    return correlation / min_length;
}

void decreaseDoubleSequence(double *input, double *output, int length, int NT) {
    int inputLength = length;
    int outputIndex = 0;

    for (int i = 0; i < inputLength; i += NT) {
        output[outputIndex++] = input[i];
    }
}

void bitsToWord(const int *bits, int bitCount, char *result) {
    int byteCount = bitCount / 8;
    int byteIndex = 0;
    int currentByte = 0;

    for (int i = 0; i < bitCount; ++i) {
        currentByte |= (bits[i] & 1) << (7 - (i % 8));

        if ((i + 1) % 8 == 0) {
            result[byteIndex++] = (char)currentByte;
            currentByte = 0;
        }
    }

    result[byteIndex] = '\0';
}

int main() {
    char name[K], surname[K];
    double binaryData[K * 8];
    char resultForCRC[M];
    double randomsequence[G];
    
    int register_state_x[LENGTH] = {0, 0, 1, 1, 1};
    int register_state_y[LENGTH] = {0, 1, 1, 1, 0};
    int cons = pow(2, LENGTH) - 1;

    printf("Введите имя: ");
    scanf("%s", name);

    printf("Введите фамилию: ");
    scanf("%s", surname);

    createBinaryData(name, binaryData);
    int nameBit = strlen(name) * 8;
    createBinaryData(surname, binaryData + nameBit);

    FILE *file = fopen("binaryData.txt", "w");

    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }

    long int L = strlen(name) * 8 + strlen(surname) * 8;
    
    double resultAllBinaryData[L + M + G];
    
    for (int i = 0; i < L; i++) {
        fprintf(file, "%1.f", binaryData[i]);
    }

    printf("Битовая последовательность: ");
    for (int i = 0; i < L; i++) {
        printf("%1.f", binaryData[i]);
    }
    fclose(file);
    printf("\n");

    countingCRC(binaryData, POLYNOMIAL, resultForCRC, L, strlen(POLYNOMIAL));
    
    generate_pseudo_random_sequence(randomsequence, register_state_x, register_state_y, cons);
    
    double resultAll[L+M+G];
    
    memcpy(resultAllBinaryData, randomsequence, G * sizeof(double));
    
    memcpy(resultAllBinaryData + G, binaryData, (L) * sizeof(double));
       
    printf("CRC равняется: ");
    double doubleResultForCRC[M];
    for (int i = 0; i < M; ++i) {
        doubleResultForCRC[i] = resultForCRC[i] - '0';
        printf("%1.f", doubleResultForCRC[i]);
    }
    printf("\n");
    
    memcpy(resultAllBinaryData + G + L, doubleResultForCRC, (M) * sizeof(double));  // добавляю CRC
    
    file = fopen("AllBinaryData.txt", "w"); 

    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }

    printf("Последовательность голда с битовой последовательностью и с CRC: ");
    for (int i = 0; i < G + L + M; i++) {
        printf("%1.f", resultAllBinaryData[i]);
        fprintf(file, "%1.f", resultAllBinaryData[i]);
    }
    fclose(file);
    printf("\n");
    
    file = fopen("BinaryDataWithN.txt", "w");

    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }

    double binaryDataWithN[N * (L + M + G)];
    printf("Результат битовой последовательности увеличенный на N отсчетов: ");
    int index = 0;
    int resultNIndex = 0;
    while (index < G + L + M) {
        for (int i = 0; i < N; i++) {
            binaryDataWithN[resultNIndex++] = resultAllBinaryData[index];
            printf("%1.f", binaryDataWithN[resultNIndex - 1]);
            fprintf(file, "%1.f", binaryDataWithN[resultNIndex - 1]);
        }
        ++index;
    }
    fclose(file);
    printf("\n");

    
    file = fopen("Signal.txt", "w");
//    file = fopen("SignalWithN4.txt", "w");
//    file = fopen("SignalWithN9.txt", "w"); 
//    file = fopen("SignalWithN14.txt", "w"); 
    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }

    double signal[2 * N * (L + M + G)];
    
    printf("Введите число от 0 до %ld: ", N * (L + M + G));
    int element;
    scanf("%d", &element);

    if (element < 0 || element >= N * (L + M + G)) {
        printf("Введенное число не входит в заданный диапазон\n");
        return 1; 
    }

    for (int i = 0; i < element; i++) {
        signal[i] = 0.0;
    }

    memcpy(signal + element, binaryDataWithN, N * (L + M + G) * sizeof(double));

    for (int i = element + N * (L + M + G); i < 2 * N * (L + M + G); i++) {
        signal[i] = 0.0;
    }

    printf("Массив с нулями: ");
    for (int i = 0; i < 2 * N * (L + M + G); i++) {
        printf("%1.f", signal[i]);
        fprintf(file, "%1.f", signal[i]);
    }
    fclose(file);
    printf("\n");

    
    file = fopen("NoiseSignal.txt", "w");
//    file = fopen("NoiseSignalWithN4.txt", "w"); // для 13 задания с N = 4
//    file = fopen("NoiseSignalWithN9.txt", "w"); // для 13 задания с N = 9
//    file = fopen("NoiseSignalWithN14.txt", "w"); // для 13 задания с N = 14
    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }
    
    double noise[2 * N * (L + M + G)];
    double mean = 0.0;
    double stddev = 0.1;

    generateNormalNoise(noise, 2 * N * (L + M + G), mean, stddev);

    double noiseBinaryData[2 * N * (L + M + G)];

    printf("Сигнал с шумом: ");
    for (int i = 0; i < 2 * N * (L + M + G); i++) {
        noiseBinaryData[i] = signal[i] + noise[i];
        printf("%f ", noiseBinaryData[i]);
        fprintf(file, "%f ", noiseBinaryData[i]);
    }
    fclose(file);
    
    double randomseq[G*N];
    
    int resultNIndexs = 0;
    for (int i = 0; i < G; ++i) { 
        for (int j = 0; j < N; ++j) {
            randomseq[resultNIndexs++] = randomsequence[i];
        }
    }
    printf("\n");
    
    const int length1 = N * G; 
    const int length2 = 2 * N * (L + M + G); 
    
    double maxCorrelation = -1.0;
    int syncStartSample = 0;
    double corelationResult[2 * N * (L + M + G)];
    
    for (int offset = 0; offset < (2 * N * (L + M + G)); offset++) { 
        double correlation = calculate_correlation(randomseq, length1, noiseBinaryData, length2, offset);
        corelationResult[offset] = correlation;
        if (correlation > maxCorrelation) {
            maxCorrelation = correlation;
            syncStartSample = offset;
        }
    }
            
//    file = fopen("CorelationResult.txt", "w"); // сохраняем результат корреляции 31 бит
//    file = fopen("CorelationResultMin.txt", "w"); // сохраняем результат корреляции c уменьшенной последовательностью голда до 15 бит
    
    if (file == NULL) {
        perror("Не удалось открыть файл");
        exit(EXIT_FAILURE);
    }
    
    for (int i = 0; i < 2 * N * (L + M + G); i++) {
        fprintf(file, "%f ", corelationResult[i]);
    }
    fclose(file);
    
    printf("Начальный семпл синхросигнала: %d\n", syncStartSample);
    
    
    int suncStartIndex = 0;
    for (int i = syncStartSample; i < (2 * N * (L + M + G)); i++) { 
        noiseBinaryData[suncStartIndex++] = noiseBinaryData[i];
    }
    
    printf("Массив с удаленным шумом: ");
    double deleteNoise[2 * N * (L + M + G)];
    for (int i = 0; i < (2 * N * (L + M + G)); i++) {
        if (noiseBinaryData[i] < 0.0) {
            noiseBinaryData[i] = 0.0;
        } else if (noiseBinaryData[i] > 0.6) {  
            noiseBinaryData[i] = 1.0;
        }
        deleteNoise[i] = noiseBinaryData[i];
        printf("%1.f", deleteNoise[i]);
    }
    printf("\n");
    
   
    long int lengthOfBinaryDataWithN = sizeof(binaryDataWithN) / sizeof(double);
    int elementsToCopy = lengthOfBinaryDataWithN;
    double deleteZero[elementsToCopy];
    
    memcpy(deleteZero, deleteNoise, elementsToCopy * sizeof(double));
    printf("Битовая последовательность без нулей: ");
    for (int i = 0; i < N * (L + M + G); ++i) {
        printf("%1.f", deleteZero[i]);
        }
    printf("\n");
    
    int length = N * (L + M + G);
    double deletedN[length / N]; 
    
    decreaseDoubleSequence(deleteZero, deletedN, length, N); 
    
    printf("Битовая последовательность без отсчетов: ");
    for (int i = 0; i < length / N; i++) {
        printf("%1.f", deletedN[i]);
    }
    printf("\n");
    
    
   
    double deleteRandomSequency[L + M]; 


    for (int i = G; i < G + L + M; ++i) {
        deleteRandomSequency[i - G] = deletedN[i];
    }


    printf("Массив без последовательности голда: ");
    for (int i = 0; i < L + M; ++i) {
        printf("%1.f", deleteRandomSequency[i]);
    }
    printf("\n");
    
    char resultCRC[M];
    
    countingCRC(deleteRandomSequency, POLYNOMIAL, resultCRC, L + M, strlen(POLYNOMIAL));
    printf("СРС на приеме равняется: %s\n", resultCRC);
    
    double resultBinaryData[L];

    for (int i = 0; i < L; ++i) {
        resultBinaryData[i] = deleteRandomSequency[i];
    }

   
    printf("Массив без CRC последовательности: ");
    for (int i = 0; i < L; ++i) {
        printf("%1.f", resultBinaryData[i]);
    }
    printf("\n");
    
    int resBinaryData[L];
    for (int i = 0; i < L; i++) { 
        resBinaryData[i] = (int)resultBinaryData[i];
    }

    char resultName[(nameBit / 8) + 1];
    char resultSurname[((L - nameBit) / 8) + 1];

    bitsToWord(resBinaryData, nameBit, resultName);
    printf("Расшифрованное имя: %s\n", resultName);

    bitsToWord(resBinaryData + nameBit, L - nameBit, resultSurname);
    printf("Расшифрованная фамилия: %s\n", resultSurname);
    return 0;
}