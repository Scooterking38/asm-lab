#include <stdio.h>

void win(void) { puts("you win"); }
void vuln(void) {
    char buf[16];
    fgets(buf, 100, stdin);   // writes up to 100 bytes into 16-byte buf
}
int main(void) { vuln(); return 0; }