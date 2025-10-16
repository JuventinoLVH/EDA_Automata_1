#include "sys/alt_stdio.h"

// Para usar el puerto PIO
#include "system.h"
#include "io.h"

// Importando el retadro
#include <unistd.h> 

int main() { 

    alt_putstr("Hello World from Nios II. Now in Linux!\n"); 

    int valor = 1;

    while (1) {

        IOWR(PIO_0_BASE, 0, valor);
        if (valor >= 256)  valor = 0; 
        else valor++;

        usleep(715000);
    }

    return 0;
}

