#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "screen.h"


int main()
{
    char c[1] = {'0'};

    struct pollfd ufds[1];
    ufds[0].fd = 0;
    ufds[0].events = POLLIN;
    ufds[0].revents = 0;

    short x = 0;
    FILE* fp;

    set_noncan();

    while (1)
    {
        x = poll(ufds, 1, 0);
        if (x > 0)
        {
            printf("x");
            read(0, c, 1);

            fp = fopen("bus", "w");

            if (fp == NULL)
            {
                printf("Error opening file");
                exit(1);
            }

            fseek(fp, 0, SEEK_SET);
            fputc(c[0], fp);
            fclose(fp);
        }
    }

    set_canon();
}