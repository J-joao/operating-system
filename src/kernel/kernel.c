#include "kernel.h"
#include "kernel/lib/vga.h"
#include "kernel/lib/string.h"

void kernel_main(void) {
    term_clearscreen();
    term_putchar('J', 0x04);
    term_newline();
    term_print(" Macaco OS ", 0xF1);
}
