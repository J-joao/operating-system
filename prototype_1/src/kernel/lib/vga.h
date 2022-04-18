#ifndef __VGA_H
#define __VGA_H

#include <stdint.h>
#include <stddef.h>
#include "string.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

int vga_width = 80;
int vga_height = 20;

uint16_t *video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

// returns formated value for the character to display and it's colour
uint16_t term_format_char(char c, char colour);

// prints out a character to terminal with respect to position (x, y)
void term_pos_putchar(int x, int y, char c, char colour);

// prints out a character to terminal
void term_putchar(char c, char colour);

// clears terminal screen with blankspaces
void term_clearscreen(void);

// prints out a string to terminal
void term_print(const char *str, char colour);

void term_newline(void);


uint16_t term_format_char(char c, char colour) {
    return (colour << 8) | c;
}

void term_pos_putchar(int x, int y, char c, char colour) {
    video_mem[(y * VGA_WIDTH) + x] = term_format_char(c, colour);
}

void term_putchar(char c, char colour) {
    term_pos_putchar(terminal_col, terminal_row, c, colour);
    terminal_col += 1;
    
    if (terminal_col > VGA_WIDTH) {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void term_clearscreen(void) {
    video_mem = (uint16_t*)(0xb8000);
    terminal_row = terminal_col = 0;

    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            term_pos_putchar(x, y, ' ', 0);
        }
    }
}

void term_print(const char *str, char colour) {
    size_t len = strlen(str);

    for (int i = 0; i < len; i++) {
        term_putchar(str[i], colour);
    }
}

void term_newline(void) {
    terminal_col = 0;
    terminal_row++;
}

#endif //__VGA_H