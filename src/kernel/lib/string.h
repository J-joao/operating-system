#ifndef __STRING_H
#define __STRING_H

#include <stddef.h>

// counts the size of a null terminated string 
size_t strlen(const char *str) {
    size_t len = 0;

    while (str[len]) {
        len++;
    }
    return len;
}

#endif //__STRING_H