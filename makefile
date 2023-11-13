tv: tv.o
	gcc -o tv tv.o -no-pie
tv.o: tv.asm
	nasm -f elf64 -g -F dwarf -o tv.o tv.asm
