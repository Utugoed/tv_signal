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
