#include <stdio.h>
#include <unistd.h>


int main()
{
    FILE *signal_ptr;

    float delay = 0.1;

    signal_ptr = fopen("cable", "w");
    fseek(signal_ptr, 0, SEEK_SET);
    fputc('2', signal_ptr);
    fclose(signal_ptr);

    sleep(delay);

    while(1)
    {
        for (int i = 0; i < 16; i++)
        {
            for (int j = 0; j < 24; j++)
            {
                signal_ptr = fopen("cable", "w");
                fseek(signal_ptr, 0, SEEK_SET);
                if (j < 3)
                    fputc('1', signal_ptr);
                else
                    fputc('0', signal_ptr);
                fclose(signal_ptr);
                sleep(delay);
            }
        }
    }

    return 0;
}
