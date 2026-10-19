int f(int x) { return x > 1;} 
int main() { int a; if (true) { a = 5; } else { a = f(a); } return a;}