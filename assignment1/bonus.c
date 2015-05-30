#include<stdio.h>
#define NUM 100

int main()
{
    int a = 0;
    for(int i = 0; i <= 3; i++) {
        if(a <= 5) a = a + i;
        else {
            a = 0;
            i = 99;
        }
    }


    int x = 0, y = 10;

    while(x != y) {
        x++;
        y--;
        if(x == y) a = 100;
    }

    char* str = "hello, world";

    return 0;
}
