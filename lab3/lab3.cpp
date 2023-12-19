#include <iostream>
#include <iomanip>
#include <cmath>

#define N 8

int Correlation(int a[], int b[]) {
    double sum = 0;
    for (int i = 0; i < N; i++) {
        sum += a[i] * b[i];
    }
    return sum;
}

double NormalCorrelation(int a[], int b[]) {
    double sum_norm = 0;
    double sumA_squared = 0;
    double sumB_squared = 0;
    
    for (int i = 0; i < N; i++) {
        sum_norm += a[i] * b[i];
        sumA_squared += pow(a[i], 2);
        sumB_squared += pow(b[i], 2);
    }
    
    double normalization = sqrt(sumA_squared * sumB_squared);
    return sum_norm / normalization;
}

int main() {
    int a[] = { 5, 2, 8, -2, -4, -4, 1, 3};
    int b[] = { 4, 1, 7, 0, -6, -5, 2, 5};
    int c[] = {-6, -1, -3,-9, 2, -8, 4, 1};

    int corrAB = Correlation(a, b);
    int corrAC = Correlation(a, c);
    int corrBC = Correlation(b, c);
    
    double normAB = NormalCorrelation(a, b);
    double normAC = NormalCorrelation(a, c);
    double normBC = NormalCorrelation(b, c);
    
    std::cout << "\nCorrelation between a and b:\n";
    std::cout << "   | a     | b     |c\n";
    std::cout << "a  |   -   |  " << corrAB << "   | " << corrAC << "\n";
    std::cout << "b  |  " << corrAB << "   |   -   | " << corrBC << "\n";
    std::cout << "c  |  " << corrAC << "   |  " << corrBC << "   | -\n";
    
    std::cout << "\nNormalized correlation between a, b and c:\n";
    std::cout << "   | a       | b       | c\n";
    std::cout << "a  |    -    | " << std::fixed << std::setprecision(4) << normAB << "  | " << normAC << "\n";
    std::cout << "b  | " << normAB << "  |    -    | " << normBC << "\n";
    std::cout << "c  | " << normAC << "  | " << normBC << "  |    -\n";

    return 0;
}
