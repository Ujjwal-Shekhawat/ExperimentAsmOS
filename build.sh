fasm boot_sect.asm 
fasm kernel.asm 

cat boot_sect.bin kernel.bin > os.bin

qemu-system-i386 -fda os.bin
