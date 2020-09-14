franxx: boot_sect.bin file_table.bin kernel.bin calculator.bin
	cat boot_sect.bin file_table.bin kernel.bin calculator.bin > franxx.bin

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

run:
	make clean
	make franxx
	qemu-system-x86_64 -fda franxx.bin
clean:
	rm *.bin
