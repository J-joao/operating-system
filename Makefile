FILES    = ./build/kernel.asm.o ./build/kernel.o
INCLUDES = -I./src
LDFLAGS  = -relocatable
CFLAGS 	 = -g -ffreestanding -falign-jumps -falign-functions -falign-labels 		\
		   -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions  \
		   -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp 	\
		   -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc 

all: ./bin/kernel.bin ./bin/boot.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin 
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g $(LDFLAGS) $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc $(CFLAGS) -T ./src/linker.ld ./build/kernelfull.o -o $@

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin $< -o $@ 

./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g $< -o $@

./build/kernel.o: ./src/kernel/kernel.c
	i686-elf-gcc $(INCLUDES) $(CFLAGS) -std=gnu99 -c $< -o $@

clean:
	-rm ./bin/*.bin
	-rm ./build/*.o