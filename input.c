#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "screen.h"


struct pollfd {
	int fd;
	short events;
	short revents;
}

int main()
{
    char c[1] = {'0'};
    short x = 0;
    FILE* fp;

    set_noncan();

    while (1)
    {
        x = poll(0, 1, 0);
	printf("%d", x);
	if (x > 0)
	{
	    printf("x");
	    read(0, c, 1);
	}
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

    set_canon();
}
