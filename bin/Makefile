franxx: boot_sect.bin file_table.bin kernel.bin calculator.bin dino_game.bin
	cat boot_sect.bin file_table.bin kernel.bin calculator.bin dino_game.bin > franxx.bin

boot_sect.bin:
	fasm ../src/asm/boot_sect.asm
	mv ../src/asm/boot_sect.bin ./

file_table.bin:
	fasm ../src/asm/file_table.asm
	mv ../src/asm/file_table.bin ./

kernel.bin:
	fasm ../src/asm/kernel.asm
	mv ../src/asm/kernel.bin ./

calculator.bin:
	fasm ../src/programs/calculator.asm
	mv ../src/programs/calculator.bin ./

dino_game.bin:
	nasm -f bin ../src/games/dino_game.asm -o ../src/games/dino_game.bin
	mv ../src/games/dino_game.bin ./

run:
	make clean
	make franxx
	qemu-system-x86_64 -fda franxx.bin
clean:
	rm *.bin
