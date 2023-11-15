#include <stdio.h>
#include <time.h>
#include <unistd.h>

#include <asm/termbits.h>
#include <sys/ioctl.h>


struct termios canon_terminal;
struct termios noncan_terminal;


int set_noncan()
{
    unsigned int ECHO_FLAG = 0x8;
    unsigned int ICANON_FLAG = 0x2;

    ioctl(0, TCGETS, &canon_terminal);
    ioctl(0, TCGETS, &noncan_terminal);

    noncan_terminal.c_lflag = noncan_terminal.c_lflag & ECHO_FLAG;
    noncan_terminal.c_lflag = noncan_terminal.c_lflag & ICANON_FLAG;

    ioctl(0, TCSETS, &canon_terminal);

    return 0;
}

int set_canon()
{
    ioctl(0, TCSETS, &canon_terminal);
    return 0;
}

int clear_screen()
{
    printf("%c[H", 0x1b);
    printf("%c[2J", 0x1b);
    return 0;
}

int move_cursor(int y, int x)
{
    printf("%c[%d;%dH", 0x1b, y, x);
    return 0;
}

int main()
{
    FILE *signal_ptr;
    char signal_char;
    int signal;

    struct timespec delay = {0,5000000};
    struct timespec tr;

    short no_signal = 0;
    short skip_frame = 0;

    set_noncan();
    clear_screen();
    fflush(stdout);

    while (1)
    {
        for (int i = 0; i < 16; i++)
        {
            move_cursor(i, 0);
	    fflush(stdout);
            for (int j = 0; j < 24; j++)
            {
		signal_ptr = fopen("cable", "r");

                fseek(signal_ptr, 0, SEEK_SET);
		signal_char = fgetc(signal_ptr);
                signal = signal_char - '0';

		fclose(signal_ptr);
		if (signal == 2)
		{
		    skip_frame = 1;
		    break;
		}
		if (signal == 3)
		{
		    j = -1;
		    move_cursor(i, 0);
        	    fflush(stdout);
		    continue;
		}
		if (signal == 0)
                    printf(".");
		else
                    printf("@");
		fflush(stdout);
		nanosleep(&delay, &tr);
            }
	    if (skip_frame == 1)
	    {
		skip_frame = 0;
                break;
	    }
        }
    }

    set_canon();
    return 0;
}
