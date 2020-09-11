franxx: boot_sect.bin file_table.bin kernel.bin
	cat boot_sect.bin file_table.bin kernel.bin > franxx.bin
	qemu-system-x86_64 -fda franxx.bin

boot_sect.bin:
	fasm ../src/asm/boot_sect.asm
	mv ../src/asm/boot_sect.bin ./

file_table.bin:
	fasm ../src/asm/file_table.asm
	mv ../src/asm/file_table.bin ./

kernel.bin:
	fasm ../src/asm/kernel.asm
	mv ../src/asm/kernel.bin ./

clean:
	rm *.bin