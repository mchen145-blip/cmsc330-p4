int max (int a, int b) {
    int result;
    if (a > b) {
        result = a;
    } else {
        result = b;
    }
    return result;
}
int main() {
    return max(3, 7) + max(10, 2);
}